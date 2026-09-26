# Apple IAP backend fixes — account token endpoint + sandbox verification fallback

Written for the backend engineer maintaining `https://usaarabdrivers.com/api`
(Laravel repo, not in this repository). Ready to apply as-is; adjust
namespaces/paths to match the existing project layout.

## Why

App Review rejected the iOS app (Guideline 2.1(b)) because Apple's payment
sheet never appeared — the client showed a generic "unable to start
purchase" snackbar instead. Root-caused (client-side investigation) to the
client's `GET /subscriptions/apple-account-token` call failing before it
ever reaches StoreKit. The client has since been changed to treat that call
as best-effort (a failure no longer blocks the purchase — see
`InAppPurchasePaymentService.purchaseSubscription` in the Flutter repo), but
the endpoint should still exist and work, since `/subscriptions/verify` is
strengthened by having `appAccountToken` to cross-check.

This doc covers exactly two pieces, both already scoped in
`docs/backend/apple-iap-server-side.md` (§3, §4) in the Flutter repo:

1. The `apple-account-token` route + controller.
2. Sandbox fallback in the Apple transaction verifier used by
   `POST /subscriptions/verify` — App Review purchases are always sandbox,
   so without this fallback the *next* step will fail once the account-token
   issue above is no longer blocking.

## 1. Account token endpoint

### Migration

```php
// database/migrations/xxxx_add_apple_account_token_to_users.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->uuid('apple_account_token')->nullable()->unique()->after('id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('apple_account_token');
        });
    }
};
```

### Route

```php
// routes/api.php, inside the existing auth:sanctum group that already has
// subscriptions/initiate, subscriptions/status, etc.
Route::get('subscriptions/apple-account-token', [AppleIapController::class, 'accountToken']);
```

### Controller

```php
// app/Http/Controllers/Api/AppleIapController.php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AppleIapController extends Controller
{
    /**
     * Returns a stable per-user UUID, minted on first call, used by the
     * client as StoreKit's `applicationUserName` so a transaction can be
     * pre-linked to this account. Best-effort on the client — do not assume
     * every verified transaction carries one (see verify() below).
     */
    public function accountToken(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->apple_account_token) {
            $user->forceFill(['apple_account_token' => (string) Str::uuid()])->save();
        }

        return response()->json([
            'success' => true,
            'data' => ['token' => $user->apple_account_token],
        ]);
    }
}
```

No special error handling is needed beyond Laravel's defaults — `auth:sanctum`
already returns 401 for an unauthenticated request, and the client now
treats *any* failure of this endpoint (401, 404, 500, malformed body) as
non-fatal to the purchase. Just make sure the route is registered and the
`users` migration has run in every environment (including whatever App
Review's reviewer account hits).

## 2. Sandbox fallback in `AppleTransactionVerifier`

`POST /subscriptions/verify` must succeed for a sandbox transaction — every
App Review purchase, and every purchase your own TestFlight sandbox testers
make, is sandbox. If the verifier only tries the production App Store
Server API endpoint, every one of those purchases will fail verification
with a 404/`environment mismatch`, which is the *next* thing Apple will hit
once the account-token issue stops blocking the sheet from opening.

```php
// app/Services/AppleTransactionVerifier.php
namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

final class AppleTransactionVerifier
{
    private const PRODUCTION_BASE = 'https://api.storekit.itunes.apple.com';
    private const SANDBOX_BASE = 'https://api.storekit-sandbox.itunes.apple.com';

    public function __construct(
        private readonly AppleJwtSigner $jwtSigner, // signs the ES256 JWT from the .p8 IAP key
    ) {}

    /**
     * Fetches a transaction by ID, trying production first and falling back
     * to sandbox — App Review / TestFlight sandbox transactions 404 (or
     * come back with a body Apple's docs describe as an environment
     * mismatch) against the production endpoint.
     */
    public function fetch(string $transactionId): ?AppleTransaction
    {
        $transaction = $this->fetchFrom(self::PRODUCTION_BASE, $transactionId, 'production');
        if ($transaction !== null) {
            return $transaction;
        }

        return $this->fetchFrom(self::SANDBOX_BASE, $transactionId, 'sandbox');
    }

    private function fetchFrom(string $base, string $transactionId, string $environment): ?AppleTransaction
    {
        try {
            $response = Http::withToken($this->jwtSigner->sign())
                ->acceptJson()
                ->get("{$base}/inApps/v1/transactions/{$transactionId}");
        } catch (ConnectionException $e) {
            Log::warning('apple_iap.verify_connection_failed', [
                'environment' => $environment,
                'transaction_id' => $transactionId,
                'error' => $e->getMessage(),
            ]);
            return null;
        }

        if ($response->notFound()) {
            // Expected for a sandbox transaction queried against production
            // (and vice versa) — not an error, just "try the other one".
            return null;
        }

        if (! $response->successful()) {
            Log::warning('apple_iap.verify_unexpected_status', [
                'environment' => $environment,
                'transaction_id' => $transactionId,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            return null;
        }

        $signedTransactionInfo = $response->json('signedTransactionInfo');
        if (! is_string($signedTransactionInfo)) {
            return null;
        }

        return AppleTransaction::fromSignedTransactionInfo($signedTransactionInfo, $environment);
        // AppleTransaction::fromSignedTransactionInfo() decodes the JWS,
        // verifies its x5c chain against the Apple Root CA G3, and exposes
        // transactionId / productId / bundleId / appAccountToken /
        // purchaseDate / revocationDate / environment. Existing code if
        // already using readdle/app-store-server-api or
        // imdhemy/laravel-purchases — swap this class's internals for
        // whatever that package already gives you; only the
        // production-then-sandbox retry order matters here.
    }
}
```

```php
// config/services.php — make sure production is the default so a
// genuine production transaction is never sent to sandbox first (the
// reverse order would work but wastes a round trip on every real purchase).
'apple_iap' => [
    'bundle_id' => env('APPLE_IAP_BUNDLE_ID'),
    'issuer_id' => env('APPLE_IAP_ISSUER_ID'),
    'key_id'    => env('APPLE_IAP_KEY_ID'),
    'private_key' => env('APPLE_IAP_PRIVATE_KEY'),
],
```

### Where this plugs into `AppleIapController::verify()`

No change needed to the controller's own logic from
`docs/backend/apple-iap-server-side.md` §5 — it already just calls
`$this->verifier->fetch($request->transaction_id)`. This fix is entirely
inside `AppleTransactionVerifier`. Just double check whatever the current
implementation is doing does *not* stop at the first production 404 without
retrying sandbox.

## Test plan (backend)

* `GET /subscriptions/apple-account-token` twice for the same user → same
  UUID both times; a fresh user gets a UUID minted on first call.
* `GET /subscriptions/apple-account-token` with no/garbage bearer token →
  401 (confirms the client's non-blocking fallback path is the only thing
  standing between a bad token and a broken checkout — this endpoint itself
  should still behave normally).
* A **sandbox** tester purchase's `transaction_id` against
  `POST /subscriptions/verify` → verifier tries production (404), falls back
  to sandbox, succeeds.
* A **production** purchase's `transaction_id` → verifier succeeds on the
  first (production) call, no sandbox call made (check logs/mocks for call
  count if you want to assert this).
* An unknown/garbage `transaction_id` → both environments 404 →
  `fetch()` returns `null` → controller's existing 422 path.
