import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

/// A reusable primary (green) button used across the app.
///
/// Usage:
/// ```dart
/// PrimaryButton(
///   label: 'View Cart',
///   onPressed: () {},
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  final String? label;
  final String? subtitle;
  final Widget? child;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double? width;

  const PrimaryButton({
    super.key,
    this.label,
    this.subtitle,
    this.child,
    this.onPressed,
    this.leading,
    this.trailing,
    this.borderRadius = 14,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final bgColor = isDisabled
        ? AppColors.disabled
        : (backgroundColor ?? AppColors.primary);

    Widget innerContent = child ?? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        if (subtitle == null)
          Text(
            label ?? '',
            style: textStyle ?? const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label ?? '',
                style: textStyle ?? const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        disabledBackgroundColor: AppColors.disabled,
        foregroundColor: Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
        textStyle: textStyle,
      ),
      child: innerContent,
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
