enum AuthFailureType {
  validation,
  system,
}

class AuthResult {
  const AuthResult._({
    required this.isSuccess,
    this.failureType,
    this.message,
  });

  final bool isSuccess;
  final AuthFailureType? failureType;
  final String? message;

  const AuthResult.success() : this._(isSuccess: true);

  const AuthResult.failure({
    required AuthFailureType type,
    required String message,
  }) : this._(
         isSuccess: false,
         failureType: type,
         message: message,
       );
}

