import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 255, 255, 255), // Using the hex equivalent of RGB 248, 195, 211
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // The newly generated image containing the logo, title, slogan, and character
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/updategiaodien3.png',
                width: size.width * 0.85,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(
                height:
                    32), // Replaced Spacer(flex: 2) with SizedBox to bring image and buttons closer

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Bắt đầu ngay',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const Spacer(flex: 1),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
