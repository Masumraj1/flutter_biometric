import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication localAuth = LocalAuthentication();

  Future<(bool, String?)> authenticateUser() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate to proceed',
        biometricOnly: true,
      );
      return (isAuthenticated, null);
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noCredentialsSet:
          return (
            false,
            'No biometrics enrolled. Please set up biometrics on your device.',
          );
        case LocalAuthExceptionCode.biometricLockout:
          return (
            false,
            'Too many failed attempts. Biometrics are temporarily locked. Please try again later.',
          );
        case LocalAuthExceptionCode.userCanceled:
          return (
            false,
            'Authentication canceled by user.',
          );
        default:
          return (
            false,
            'An error occurred during authentication. Please try again.',
          );
      }
    }
  }
}
