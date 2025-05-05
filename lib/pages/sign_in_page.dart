import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:aicaremanagermob/pages/homepage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            // Watch the auth state
            final authState = ref.watch(authProvider);
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await ref.read(authProvider.notifier).signIn();
                    
                    if (result == "signedIn" && mounted) {
                    
                      Navigator.pushReplacement(
                        // ignore: use_build_context_synchronously
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    }
                  },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Debug Info:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Current User: ${authState.user.fullName}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
