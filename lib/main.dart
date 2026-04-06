// import 'package:flutter/material.dart';
// import 'package:flutter_biometric_auth/pages/biometric_login.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.brown,
//           brightness: Brightness.light,
//           primary: Colors.brown,
//         ),
//         filledButtonTheme: FilledButtonThemeData(
//           style: FilledButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             textStyle: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ),
//       home: BiometricLogin(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const BiometricScreen(),
    );
  }
}

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  // অথেন্টিকেশন ফাংশন
  Future<void> _authenticateUser() async {
    try {
      // ১. চেক করা যে ডিভাইসে বায়োমেট্রিক সাপোর্ট আছে কিনা
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      if (canAuthenticateWithBiometrics || isDeviceSupported) {
        // ২. বায়োমেট্রিক ডায়ালগ দেখানো
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'অ্যাপটি আনলক করতে আপনার ফিঙ্গারপ্রিন্ট বা ফেস আইডি ব্যবহার করুন',
          // options: const AuthenticationOptions(
          //   stickyAuth: true,      // অ্যাপ ব্যাকগ্রাউন্ডে গেলেও সেশন ধরে রাখবে
          //   biometricOnly: false,  // এটি false থাকলে পিন/প্যাটার্ন ব্যবহারের সুযোগ দেবে
          // ),
        );

        setState(() {
          _isAuthenticated = didAuthenticate;
        });
      } else {
        _showMessage("আপনার ডিভাইসে বায়োমেট্রিক সুবিধা নেই বা সেটআপ করা নেই।");
      }
    } on PlatformException catch (e) {
      print(e);
      _showMessage("Error: ${e.message}");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Auth Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isAuthenticated ? Icons.lock_open_rounded : Icons.lock_rounded,
              size: 80,
              color: _isAuthenticated ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _isAuthenticated ? "Access Granted!" : "Access Denied / Locked",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _authenticateUser,
              icon: const Icon(Icons.fingerprint),
              label: const Text("Authenticate Now"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            if (_isAuthenticated)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton(
                  onPressed: () => setState(() => _isAuthenticated = false),
                  child: const Text("Logout/Lock"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}