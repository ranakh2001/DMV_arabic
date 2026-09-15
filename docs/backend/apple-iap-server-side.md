# Apple In-App Purchase — backend (Laravel) requirements

Written for the backend engineer maintaining `https://usaarabdrivers.com/api`.
The Laravel code is not in this repository; this document lists exactly what the
Flutter client sends per platform, where the current backend assumes Stripe, and
a stub for the Apple receipt-verification path.

## 1. What the client calls today

### Android (Stripe) — unchanged

| Step | Method | Endpoint | Payload / notes |
|---|---|---|---|
| 1 | POST | `/subscriptions/initiate` | `{ package_id, platform: "android" }` → `{ payment_id, client_secret, customer_id, ephemeral_key, publishable_key }` |
| 2 | — | Stripe SDK confirms the PaymentIntent on-device | |
| 3 | GET | `/subscriptions/status` | polled 3× (1 s apart) → `{ has_active_subscription }` |
| — | webhook | `payment_intent.succeeded` (Stripe → Laravel) | **this is what activates the subscription** |

### iOS (Apple In-App Purchase) — what the client sends now

| Step | Method | Endpoint | Payload / notes |
|---|---|---|---|
| 1 | GET | `/subscriptions/apple-account-token` | → `{ token }`. Opaque per-user token; client passes it to StoreKit as `applicationUserName` (UUID recommended) |
| 2 | — | StoreKit purchase (`com.dmv.us.monthly` / `com.dmv.us.sixmonths`) | |
| 3 | POST | `/subscriptions/verify` | `{ transaction_id, product_id, receipt_data, platform: "ios" }` — receipt validation only, must **not** activate |
| 4 | POST | `/subscriptions/apple-iap` | `{ transaction_id, product_id }` — **activates** the subscription (Apple equivalent of the Stripe webhook) |
| 5 | GET | `/subscriptions/status` | polled 3× (1 s apart), same as Android |

`receipt_data` is `PurchaseDetails.verificationData.serverVerificationData`,
which on iOS is the **base64 app receipt** (StoreKit 1 path of the
`in_app_purchase_storekit` plugin). `transaction_id` is the StoreKit
`transactionIdentifier`.

The client only calls `completePurchase()` (finishes the StoreKit transaction)
after step 4 succeeds, or after a **4xx** from step 3/4 (treated as a definitive
rejection). On network errors / 5xx the transaction is left open and StoreKit
redelivers it on next launch, at which point steps 3–4 are retried. **Both
endpoints must therefore be idempotent on `transaction_id`.**

## 2. Where the backend currently assumes Stripe (flag list)

Check these in the Laravel project:

1. **`POST /subscriptions/initiate`** — creates a Stripe Customer, ephemeral key
   and PaymentIntent. It already receives `platform`; today `"ios"` presumably
   still goes down the Stripe path. The iOS client no longer calls it. Recommend
   rejecting `platform: "ios"` with 422 so a stale build can never obtain a
   Stripe client secret from an iPhone.
2. **Stripe webhook handler** (`payment_intent.succeeded` → mark `payments`
   row paid → create/extend `subscriptions` row). This is the only activation
   path. The activation logic (compute `activation_date` / `expiry_date` from
   the package's `duration_days`, set `status = active`, notify) needs to be
   extracted into a service (e.g. `SubscriptionActivator::activate(User,
   SubscriptionPackage, Payment)`) so the Apple path reuses it verbatim.
3. **`payments` table / model** — likely has `stripe_payment_intent_id`,
   `stripe_customer_id`, `amount_usd`, `payment_status`. Needs a
   `provider` enum (`stripe` | `apple_iap`) and a nullable, **unique**
   `provider_transaction_id` (the Apple `transaction_id`).
4. **`GET /subscriptions/history`** — returns `amount_usd` and
   `payment_status`; if it joins on Stripe-specific columns the Apple rows need
   a fallback (amount from the package price, status `paid`).
5. **Refunds** — Stripe refunds arrive via `charge.refunded`. Apple refunds
   arrive via App Store Server Notifications V2 (`REFUND`, `REVOKE`). If you
   want revocation parity, expose `POST /webhooks/apple` (see §4). Optional
   for non-renewing subscriptions but recommended.

## 3. Required new/changed endpoints (keyed by platform)

| Endpoint | Exists? | Needed change |
|---|---|---|
| `GET /subscriptions/apple-account-token` | client already calls it — **confirm it exists** | Return a stable UUID per user (store on `users.apple_account_token`). Used to map a transaction's `appAccountToken` back to the user server-side. |
| `POST /subscriptions/verify` | client already calls it — **confirm it exists** | Verify with Apple (see §4). Return `{ success: true }` only if the transaction is genuine, for this bundle ID, for `product_id`, and (if present) its `appAccountToken` matches the authenticated user's token. 422 on mismatch, 409 if already consumed by another user. Must **not** grant entitlement. |
| `POST /subscriptions/apple-iap` | client already calls it — **confirm it exists** | Idempotent on `transaction_id`: if already recorded for this user return 200 `{ success: true }`. Otherwise create the `payments` row (`provider = apple_iap`) and call the same `SubscriptionActivator` the Stripe webhook uses. Never trust the client's `product_id` alone — use the product ID stored during `/verify`. |
| `POST /webhooks/apple` | new (optional) | App Store Server Notifications V2 for `REFUND` / `REVOKE` → mark the payment refunded and expire the subscription. |

Product → package mapping (backend must mirror `AppleIapProductCatalog`):

| App Store product ID | Package | Duration |
|---|---|---|
| `com.dmv.us.monthly` | monthly package | 30 days |
| `com.dmv.us.sixmonths` | 6-month package | 180 days |

## 4. Verification approach

Use the **App Store Server API** (not the deprecated `verifyReceipt`):

* Endpoint: `GET https://api.storekit.itunes.apple.com/inApps/v1/transactions/{transactionId}`
  (sandbox: `https://api.storekit-sandbox.itunes.apple.com/...`).
* Auth: ES256 JWT signed with an **In-App Purchase key** from App Store
  Connect (Users and Access → Integrations → In-App Purchase). Needs
  `issuer_id`, `key_id`, the `.p8` private key, and the bundle ID.
* Response: `signedTransactionInfo` — a JWS. Verify its x5c chain against the
  Apple Root CA G3, then read `transactionId`, `productId`, `bundleId`,
  `appAccountToken`, `purchaseDate`, `revocationDate`, `environment`.
* Try production first; on 404 / `environment` mismatch retry sandbox (App
  Review purchases are sandbox).

Recommended package: `readdle/app-store-server-api` (or `imdhemy/laravel-purchases`).

`receipt_data` (the base64 app receipt) can be ignored with this approach —
the `transaction_id` is enough — but keep accepting the field; if you prefer
`verifyReceipt` as a temporary fallback, POST it to
`https://buy.itunes.apple.com/verifyReceipt` and retry sandbox on status 21007.

## 5. Laravel stub

```php
// routes/api.php  (inside the auth:sanctum group)
Route::get   ('subscriptions/apple-account-token', [AppleIapController::class, 'accountToken']);
Route::post  ('subscriptions/verify',              [AppleIapController::class, 'verify']);
Route::post  ('subscriptions/apple-iap',           [AppleIapController::class, 'record']);
// unauthenticated, signed by Apple:
Route::post  ('webhooks/apple',                    [AppleNotificationsController::class, 'handle']);
```

```php
// app/Http/Controllers/Api/AppleIapController.php
final class AppleIapController extends Controller
{
    public function __construct(
        private readonly AppleTransactionVerifier $verifier,
        private readonly SubscriptionActivator $activator,   // same class the Stripe webhook uses
    ) {}

    public function accountToken(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user->apple_account_token) {
            $user->forceFill(['apple_account_token' => (string) Str::uuid()])->save();
        }
        return response()->json(['success' => true, 'data' => ['token' => $user->apple_account_token]]);
    }

    public function verify(VerifyApplePurchaseRequest $request): JsonResponse
    {
        // validated: transaction_id (string), product_id (in: com.dmv.us.monthly, com.dmv.us.sixmonths),
        //            receipt_data (string), platform (in: ios)
        $user = $request->user();
        $tx   = $this->verifier->fetch($request->transaction_id);   // App Store Server API, prod → sandbox

        if ($tx === null || $tx->bundleId !== config('services.apple_iap.bundle_id')) {
            return response()->json(['success' => false, 'message' => 'تعذر التحقق من عملية الشراء.'], 422);
        }
        if ($tx->productId !== $request->product_id) {
            return response()->json(['success' => false, 'message' => 'تعذر التحقق من عملية الشراء.'], 422);
        }
        if ($tx->appAccountToken && $tx->appAccountToken !== $user->apple_account_token) {
            return response()->json(['success' => false, 'message' => 'هذه العملية مرتبطة بحساب آخر.'], 409);
        }
        if ($tx->revocationDate !== null) {
            return response()->json(['success' => false, 'message' => 'تم إلغاء عملية الشراء.'], 422);
        }

        AppleVerifiedTransaction::updateOrCreate(
            ['transaction_id' => $tx->transactionId],
            ['user_id' => $user->id, 'product_id' => $tx->productId,
             'environment' => $tx->environment, 'purchased_at' => $tx->purchaseDate],
        );

        return response()->json(['success' => true]);
    }

    public function record(RecordApplePurchaseRequest $request): JsonResponse
    {
        // validated: transaction_id, product_id
        $user = $request->user();

        return DB::transaction(function () use ($user, $request) {
            $existing = Payment::where('provider', 'apple_iap')
                ->where('provider_transaction_id', $request->transaction_id)
                ->lockForUpdate()->first();

            if ($existing) {                                   // idempotent replay
                if ($existing->user_id !== $user->id) {
                    return response()->json(['success' => false, 'message' => 'هذه العملية مرتبطة بحساب آخر.'], 409);
                }
                return response()->json(['success' => true]);
            }

            $verified = AppleVerifiedTransaction::where('transaction_id', $request->transaction_id)
                ->where('user_id', $user->id)->first();
            if (! $verified) {                                 // /verify must run first
                return response()->json(['success' => false, 'message' => 'تعذر التحقق من عملية الشراء.'], 422);
            }

            $package = SubscriptionPackage::forAppleProduct($verified->product_id); // map table in §3

            $payment = Payment::create([
                'user_id'                 => $user->id,
                'subscription_package_id' => $package->id,
                'provider'                => 'apple_iap',
                'provider_transaction_id' => $verified->transaction_id,
                'amount_usd'              => $package->price_usd,
                'payment_status'          => 'paid',
                'platform'                => 'ios',
            ]);

            $this->activator->activate($user, $package, $payment);   // identical to Stripe webhook path

            return response()->json(['success' => true]);
        });
    }
}
```

```php
// database/migrations/xxxx_add_apple_iap_to_payments.php
Schema::table('payments', function (Blueprint $table) {
    $table->string('provider', 16)->default('stripe')->after('id');
    $table->string('provider_transaction_id', 64)->nullable()->after('provider');
    $table->unique(['provider', 'provider_transaction_id']);
});
Schema::table('users', fn (Blueprint $t) => $t->uuid('apple_account_token')->nullable()->unique());
Schema::create('apple_verified_transactions', function (Blueprint $t) {
    $t->id();
    $t->string('transaction_id', 64)->unique();
    $t->foreignId('user_id')->constrained();
    $t->string('product_id', 64);
    $t->string('environment', 16);
    $t->timestamp('purchased_at');
    $t->timestamps();
});
```

```php
// config/services.php
'apple_iap' => [
    'bundle_id' => env('APPLE_IAP_BUNDLE_ID'),         // e.g. com.dmv.arabic.us
    'issuer_id' => env('APPLE_IAP_ISSUER_ID'),
    'key_id'    => env('APPLE_IAP_KEY_ID'),
    'private_key' => env('APPLE_IAP_PRIVATE_KEY'),      // contents of the .p8
    'environment' => env('APPLE_IAP_ENV', 'production'), // verifier retries sandbox on miss
],
```

## 6. Response envelope

Keep the existing `{ success: bool, message?: string, data?: object }` shape.
The client reads `message` (Arabic) straight into the snackbar on failure.

## 7. Test plan (backend)

* Sandbox tester purchases `com.dmv.us.monthly` → `/verify` 200 → `/apple-iap`
  200 → `/subscriptions/status` returns active within 1 s.
* Replay `/apple-iap` with the same `transaction_id` → 200, no second
  subscription row.
* `/apple-iap` with a `transaction_id` that never went through `/verify` → 422.
* `/verify` with another user's token → 409.
* `/subscriptions/initiate` with `platform: "ios"` → 422.
