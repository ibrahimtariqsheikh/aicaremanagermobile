import 'package:aicaremanagermob/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:aicaremanagermob/pages/homepage.dart';
import 'package:aicaremanagermob/widgets/my_button.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Future<void> handleSignIn(String email, String password) async {
      print('Attempting sign in with email: $email'); // Debug print
      final String result = await ref.read(authProvider.notifier).signIn(
            email: email,
            password: password,
          );

      if (result == 'signedIn' && mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: CupertinoColors.systemBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign In',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 1),
                        Expanded(
                          child: Text(
                            'Enter your email and password to sign in to your account.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: CupertinoColors.inactiveGray,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      hintText: 'Email',
                      controller: emailController,
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      hintText: 'Password',
                      controller: passwordController,
                      passwordSuffix: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: GoogleFonts.inter(
                            color: CupertinoColors.systemGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: MyButton(
                  text: 'Sign In',
                  fontWeight: FontWeight.w600,
                  onPressed: () => handleSignIn(
                    emailController.text,
                    passwordController.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
