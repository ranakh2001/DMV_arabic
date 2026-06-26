class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.contact});

  final String contact;

  Map<String, dynamic> toJson() => {'contact': contact};
}
