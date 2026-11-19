import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FBTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;

  const FBTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? AppColors.textDarkPrimary : AppColors.charcoal,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          cursorColor: isDark ? AppColors.primaryAccentDark : AppColors.primaryGreen,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textDarkPrimary : AppColors.charcoal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textDarkSecondary : AppColors.mutedGrey,
            ),
            prefixIcon: prefixIcon,
            prefixIconColor: isDark ? AppColors.textDarkSecondary : AppColors.mutedGrey,
            suffixIcon: suffixIcon,
            suffixIconColor: isDark ? AppColors.textDarkSecondary : AppColors.mutedGrey,
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryAccentDark : AppColors.primaryGreen,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 2.0,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.errorRed,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
