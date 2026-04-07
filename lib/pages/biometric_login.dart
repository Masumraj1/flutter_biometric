// import 'package:app_settings/app_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_biometric_auth/pages/home_page.dart';
// import 'package:flutter_biometric_auth/services/auth_service.dart';
//
// class BiometricLogin extends StatefulWidget {
//   const BiometricLogin({super.key});
//
//   @override
//   State<BiometricLogin> createState() => _BiometricLoginState();
// }
//
// class _BiometricLoginState extends State<BiometricLogin> {
//   final AuthService _authService = AuthService();
//   bool _isAuthenticating = false;
//   Future<void> _handleBiometricAuth() async {
//     setState(() {
//       _isAuthenticating = true;
//     });
//
//     final (bool isAuthenticated, String? error) = await _authService.authenticateUser();
//
//     setState(() {
//       _isAuthenticating = false;
//     });
//
//     if (isAuthenticated) {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomePage()),
//         );
//       }
//     } else if (mounted && error != null) {
//       // এখানে ম্যাজিক!
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(error),
//           duration: const Duration(seconds: 5),
//           action: SnackBarAction(
//             label: 'Settings',
//             onPressed: () {
//               // সরাসরি ফোনের সিকিউরিটি/বায়োমেট্রিক সেটিংসে নিয়ে যাবে
//               AppSettings.openAppSettings(type: AppSettingsType.lockAndPassword);
//             },
//           ),
//         ),
//       );
//     }
//   }
//   // Future<void> _handleBiometricAuth() async {
//   //   setState(() {
//   //     _isAuthenticating = true;
//   //   });
//   //
//   //   final (bool isAuthenticated, String? error) = await _authService
//   //       .authenticateUser();
//   //
//   //   setState(() {
//   //     _isAuthenticating = false;
//   //   });
//   //
//   //   if (isAuthenticated) {
//   //     // Navigate to the next screen
//   //     if (mounted) {
//   //       Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => HomePage(),
//   //         ),
//   //       );
//   //     }
//   //   } else
//   //   // Show error message
//   //   if (mounted && error != null) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text(error)),
//   //     );
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           mainAxisAlignment: .center,
//           spacing: 30,
//           children: [
//             Icon(
//               Icons.fingerprint_outlined,
//               size: 60,
//             ),
//             Text(
//               'Use your Biometric to login',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(
//               width: double.infinity,
//               child: FilledButton(
//                 onPressed: _isAuthenticating ? null : _handleBiometricAuth,
//                 child: _isAuthenticating
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : const Text('Login With Biometrics'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_biometric_auth/pages/home_page.dart';
import 'package:flutter_biometric_auth/services/auth_service.dart';
import 'package:local_auth/local_auth.dart';

class BiometricLogin extends StatefulWidget {
  const BiometricLogin({super.key});

  @override
  State<BiometricLogin> createState() => _BiometricLoginState();
}

// WidgetsBindingObserver যুক্ত করা হয়েছে অ্যাপের ফিরে আসা ট্র্যাক করতে
class _BiometricLoginState extends State<BiometricLogin> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = false;
  bool _wasInSettings = false; // ইউজার সেটিংসে গিয়েছে কি না তা বোঝার জন্য

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // অবজারভার চালু করা
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // অবজারভার বন্ধ করা
    super.dispose();
  }

  // অ্যাপ ব্যাকগ্রাউন্ড থেকে ফোরগ্রাউন্ডে আসলে এই মেথড কল হয়
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _wasInSettings) {
      _checkIfBiometricsAdded();
    }
  }

  // সেটিংস থেকে ফেরার পর বায়োমেট্রিক চেক করা
  Future<void> _checkIfBiometricsAdded() async {
    final LocalAuthentication localAuth = LocalAuthentication();
    // চেক করা হচ্ছে কোনো বায়োমেট্রিক এনরোল করা আছে কি না
    List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
    bool canCheck = await localAuth.canCheckBiometrics;

    if (canCheck && availableBiometrics.isNotEmpty) {
      if (mounted) {
        _showWelcomeDialog();
      }
    }
    _wasInSettings = false; // ফ্ল্যাগ রিসেট
  }

  // সফলভাবে সেটআপ করার ডায়ালগ
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Welcome!"),
          ],
        ),
        content: const Text("আপনি সফলভাবে ফিঙ্গারপ্রিন্ট/ফেস আইডি চালু করেছেন। এখন লগইন করতে পারবেন।"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ঠিক আছে", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBiometricAuth() async {
    setState(() {
      _isAuthenticating = true;
    });

    final (bool isAuthenticated, String? error) = await _authService.authenticateUser();

    setState(() {
      _isAuthenticating = false;
    });

    if (isAuthenticated) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else if (mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              setState(() {
                _wasInSettings = true; // সেটিংসে যাওয়ার আগে ফ্ল্যাগ সেট করা
              });
              AppSettings.openAppSettings(type: AppSettingsType.lockAndPassword);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // ফিক্সড: .center থেকে MainAxisAlignment.center
          children: [
            const Icon(
              Icons.fingerprint_outlined,
              size: 60,
            ),
            const SizedBox(height: 30), // spacing এর বিকল্প
            const Text(
              'Use your Biometric to login',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isAuthenticating ? null : _handleBiometricAuth,
                child: _isAuthenticating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Login With Biometrics'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}