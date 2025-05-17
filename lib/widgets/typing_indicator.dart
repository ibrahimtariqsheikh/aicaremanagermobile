import 'package:flutter/cupertino.dart';
import 'dart:math';

class TypingIndicator extends StatelessWidget {
  final AnimationController animationController;

  const TypingIndicator({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                // Create a staggered delay for each dot
                final delay = index * 0.2;
                final start = delay;
                final end = start + 0.4;

                // Calculate the current opacity and scale based on the animation value
                double opacity = 0.3;
                double scale = 0.8;
                double yOffset = 0;

                // Get animation position accounting for the delay
                final position =
                    (animationController.value - start) / (end - start);

                // Only animate within the dot's animation window
                if (position >= 0 && position <= 1) {
                  // Create a sine wave pattern for smooth animation
                  final wave = sin(position * 3.14);
                  opacity = 0.3 + (0.7 * wave);
                  scale = 0.8 + (0.4 * wave);
                  yOffset = -3 * wave;
                }

                return Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
