import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
          colors: colors ?? [AppColors.primaryBlue, AppColors.primaryPurple],
        ),
      ),
      child: child,
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final List<Color>? colors;
  final double? elevation;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.colors,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppConstants.smallSpacing),
      decoration: BoxDecoration(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppConstants.mediumRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [AppColors.lightBlue, AppColors.lightPurple],
        ),
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppConstants.mediumSpacing),
        child: child,
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? colors;
  final double? elevation;
  final double? width;
  final double? height;

  const GradientButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius,
    this.colors,
    this.elevation,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppConstants.mediumRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [AppColors.primaryBlue, AppColors.primaryPurple],
        ),
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppConstants.mediumRadius),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppConstants.largeSpacing,
                  vertical: AppConstants.mediumSpacing,
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration? duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.duration,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration ?? const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: AppColors.primaryBlue,
      end: AppColors.lightBlue,
    ).animate(_controller);

    _color2 = ColorTween(
      begin: AppColors.primaryPurple,
      end: AppColors.lightPurple,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _color1.value ?? AppColors.primaryBlue,
                _color2.value ?? AppColors.primaryPurple,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
