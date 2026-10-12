import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The iconic hero SOS trigger button with glowing radial halo.
class PrimarySosButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final bool showCaption;

  const PrimarySosButton({
    super.key,
    required this.onTap,
    this.size = 200,
    this.showCaption = true,
  });

  @override
  State<PrimarySosButton> createState() => _PrimarySosButtonState();
}

class _PrimarySosButtonState extends State<PrimarySosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFE53935),
                    Color(0x99D32F2F),
                    Color(0x33B71C1C),
                    Colors.transparent,
                  ],
                  stops: [0.65, 0.8, 0.92, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sosRed.withValues(alpha: 0.45),
                    blurRadius: 36,
                    spreadRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF160A0D),
                  border: Border.all(color: AppColors.sosRed, width: 3.5),
                  gradient: const RadialGradient(
                    colors: [Color(0xFF2B0A11), Color(0xFF14080B)],
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      color: AppColors.sosRed,
                      size: 32,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'TAP FOR HELP',
                      style: TextStyle(
                        color: Color(0xFFE28A8F),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.showCaption) ...[
          const SizedBox(height: 14),
          const Text(
            'Press to create an emergency request',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
