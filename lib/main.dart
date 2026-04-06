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
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(const MaterialApp(home: BiometricEnrollment()));

class BiometricEnrollment extends StatefulWidget {
  const BiometricEnrollment({super.key});

  @override
  State<BiometricEnrollment> createState() => _BiometricEnrollmentState();
}

class _BiometricEnrollmentState extends State<BiometricEnrollment> {
  final LocalAuthentication auth = LocalAuthentication();
  final storage = const FlutterSecureStorage();

  int currentStep = 0; // ০ = শুরু, ১ = প্রথমবার সম্পন্ন, ২ = কনফার্মড
  String statusText = "আপনার বায়োমেট্রিক সেটআপ করুন";

  // ফিঙ্গারপ্রিন্ট ভেরিফাই করার ফাংশন
  Future<bool> _scanBiometric(String reason) async {
    try {
      return await auth.authenticate(
        localizedReason: reason,
        // options: const AuthenticationOptions(
        //   stickyAuth: true,
        //   biometricOnly: true,
        // ),
      );
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  // মূল প্রসেস
  void _handleEnrollment() async {
    // ধাপ ১: প্রথমবার স্ক্যান
    if (currentStep == 0) {
      bool success = await _scanBiometric("সেটআপ শুরু করতে আঙুল দিন");
      if (success) {
        setState(() {
          currentStep = 1;
          statusText = "দারুণ! এবার নিশ্চিত করতে আরেকবার আঙুল দিন।";
        });
      }
    }
    // ধাপ ২: কনফার্ম করার জন্য দ্বিতীয়বার স্ক্যান
    else if (currentStep == 1) {
      bool confirmed = await _scanBiometric("কনফার্ম করতে পুনরায় আঙুল দিন");
      if (confirmed) {
        // চিরস্থায়ীভাবে সেভ করে রাখা যে বায়োমেট্রিক সেট হয়েছে
        await storage.write(key: 'isBiometricSet', value: 'true');

        setState(() {
          currentStep = 2;
          statusText = "অভিনন্দন! আপনার ফিঙ্গারপ্রিন্ট লক সেট হয়ে গেছে।";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("কনফার্মেশন মেলেনি! আবার চেষ্টা করুন।")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Lock Setup")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // প্রোগ্রেস ইন্ডিকেটর বা আইকন
              Icon(
                currentStep == 2 ? Icons.check_circle : Icons.fingerprint,
                size: 100,
                color: currentStep == 2 ? Colors.green : Colors.blue,
              ),
              const SizedBox(height: 30),
              Text(
                statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),

              if (currentStep < 2)
                ElevatedButton(
                  onPressed: _handleEnrollment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(currentStep == 0 ? "শুরু করুন" : "কনফার্ম করুন"),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    // সেটআপ শেষ, এখন হোম স্ক্রিনে নিয়ে যান
                  },
                  child: const Text("অ্যাপে প্রবেশ করুন"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}