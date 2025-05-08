import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasShadow;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 16,
    this.hasShadow = true,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget card = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth,
              )
            : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
