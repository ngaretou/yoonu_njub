import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedEqualizer extends StatelessWidget {
  final bool isAnimating;

  const AnimatedEqualizer({super.key, required this.isAnimating});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBar(context, 0),
          const SizedBox(width: 3),
          _buildBar(context, 1),
          const SizedBox(width: 3),
          _buildBar(context, 2),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, int index) {
    Widget bar = Container(
      width: 4,
      height: isAnimating ? 24 : 2,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(2),
      ),
    );

    return isAnimating
        ? bar
            .animate(onPlay: (controller) => controller.loop(reverse: true))
            .scaleY(
              begin: 0.2,
              end: 1.0,
              duration: 300.ms,
              delay: (100 * index).ms,
              curve: Curves.easeInOut,
            )
        : bar;
  }
}
