import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Gradient Button ──────────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double? width;
  final IconData? icon;
  final double height;
  final List<Color>? colors;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.width,
    this.icon,
    this.height = 52,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = colors ?? const [AppColors.secondaryBlue, AppColors.primaryNavy];
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isLoading ? null : onTap,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(label, style: AppTextStyles.buttonText),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────
class OutlineAppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double height;

  const OutlineAppButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.borderColor,
    this.textColor,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: borderColor ?? AppColors.primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.buttonText.copyWith(
                color: textColor ?? AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Text Field ───────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.prefix,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
          ),
        ),
      ],
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor ?? color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── App Bar with Avatar ──────────────────────────────────────────────────────
class QlinkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? avatarUrl;
  final int unreadAlerts;
  final VoidCallback? onAlertTap;
  final bool showBack;
  final String? title;

  const QlinkAppBar({
    super.key,
    this.avatarUrl,
    this.unreadAlerts = 0,
    this.onAlertTap,
    this.showBack = false,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 20, color: AppColors.textPrimary),
                )
              else
                Row(
                  children: [
                    // Qlink logo Q
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        gradient: AppGradients.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'Q',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (avatarUrl != null)
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(avatarUrl!),
                      )
                    else
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.borderColor,
                        child: Icon(Icons.person, size: 18, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              if (title != null) ...[
                const SizedBox(width: 12),
                Text(title!, style: AppTextStyles.heading3),
              ],
              const Spacer(),
              // Globe / language
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.language_outlined,
                    color: AppColors.textSecondary),
                iconSize: 22,
              ),
              // Bell with badge
              Stack(
                children: [
                  IconButton(
                    onPressed: onAlertTap,
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textPrimary),
                    iconSize: 24,
                  ),
                  if (unreadAlerts > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading Widget ───────────────────────────────────────────────────────────
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.borderColor),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTextStyles.bodySmall),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

// ─── Blood Type Selector ──────────────────────────────────────────────────────
class BloodTypeSelector extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;

  const BloodTypeSelector({super.key, this.selected, required this.onSelect});

  static const _types = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((type) {
        final isSelected = selected == type;
        return GestureDetector(
          onTap: () => onSelect(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 68,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryNavy : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primaryNavy : AppColors.borderColor,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                type,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Step Progress Indicator ──────────────────────────────────────────────────
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isComplete = i < currentStep;
        final isCurrent = i == currentStep - 1;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
            decoration: BoxDecoration(
              gradient: (isComplete || isCurrent)
                  ? const LinearGradient(
                      colors: [AppColors.secondaryBlue, AppColors.primaryNavy])
                  : null,
              color: (isComplete || isCurrent) ? null : AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
