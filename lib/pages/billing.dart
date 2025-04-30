import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check the platform and return appropriate UI
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _buildMaterialUI(context);
      case TargetPlatform.iOS:
        return _buildCupertinoUI(context);
      default:
        return _buildMaterialUI(context);
    }
  }

  Widget _buildMaterialUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Billing',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Billing Page',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoUI(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Billing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
              'Billing Page',
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