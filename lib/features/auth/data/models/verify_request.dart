class VerifyRequest {
  const VerifyRequest({required this.contact, required this.code});

  final String contact;
  final String code;

  Map<String, dynamic> toJson() => {
        'contact': contact,
        'code': code,
      };
}
