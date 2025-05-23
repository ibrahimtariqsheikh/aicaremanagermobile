import 'package:flutter/material.dart';
import 'package:aicaremanagermob/configs/app_theme.dart';

class IconBackground extends StatelessWidget {
  const IconBackground(
      {Key? key, required this.icon, required this.onTap, this.size = 18})
      : super(key: key);

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColors.mainBlue,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: size,
          ),
        ),
      ),
    );
  }
}

class IconBorder extends StatelessWidget {
  const IconBorder({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      splashColor: AppColors.mainBlue,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            width: 2,
            color: Theme.of(context).cardColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
          ),
        ),
      ),
    );
  }
}
