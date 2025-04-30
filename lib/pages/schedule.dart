import 'package:flutter/cupertino.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Using const for the entire widget tree to optimize performance
    // and prevent yellow lines from Flutter's performance warnings
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Schedule',
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
            child: Text(
              'Schedule Page',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
                fontSize: 15,
             
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}