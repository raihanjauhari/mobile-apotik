import 'package:flutter/material.dart';
import 'package:login_signup/screens/signin_screen.dart';
import 'package:login_signup/theme/theme.dart';
import 'package:login_signup/widgets/custom_scaffold.dart';
import 'package:login_signup/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Selamat Datang!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text:
                            '\nSederhanakan distribusi obat dan fokus pada perawatan pasien yang lebih baik.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight, // Tetap di kanan bawah
              child: Row(
                children: [
                  // Expanded kosong ini akan mengisi separuh kiri dari Row
                  const Expanded(child: SizedBox.shrink()),
                  // Tombol 'Sign in' ini akan mengisi separuh kanan
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Login',
                      onTap: const SignInScreen(),
                      color: Colors.white,
                      textColor: const Color(0xFF2A4D69),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
