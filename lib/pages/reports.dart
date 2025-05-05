import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('Reports Page - Building...');
    
    // Watch the entire auth state
    final authState = ref.watch(authProvider);
    print('Reports Page - Full Auth State: $authState');
    
    // Watch the user specifically
    final user = ref.watch(authProvider.select((state) => state.user));
    print('Reports Page - User from select: $user');
    
    // Watch the fullName specifically
    final fullName = ref.watch(authProvider.select((state) => state.user.fullName));
    print('Reports Page - Full Name from select: $fullName');
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
            // Explicitly setting decoration to none to prevent yellow lines
            decoration: TextDecoration.none,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.gear),
          onPressed: null,
        ),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          color: CupertinoColors.black,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Reports',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}