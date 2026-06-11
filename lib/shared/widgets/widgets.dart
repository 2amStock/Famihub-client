import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
export 'responsive_wrapper.dart';

class FamiButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double? height;
  final bool useGradient;

  const FamiButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.icon,
    this.color,
    this.width,
    this.height,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || loading;

    Widget btnContent = _child;

    if (outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 56,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color ?? AppColors.primary,
            side: BorderSide(color: color ?? AppColors.primary, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: btnContent,
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: height ?? 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: (useGradient && !isDisabled) ? AppColors.primaryGradient : null,
        color: (useGradient && !isDisabled) ? null : (color ?? AppColors.primary),
        boxShadow: isDisabled ? [] : [
          BoxShadow(
            color: (color ?? AppColors.primary).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: btnContent,
      ),
    );
  }

  Widget get _child => loading
      ? const SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
      : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
            Flexible(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
}

class FamiTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;

  const FamiTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
          validator: validator,
          maxLines: maxLines,
          autocorrect: !obscure,
          enableSuggestions: !obscure,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint ?? 'Nhập $label...',
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary, size: 22)
                : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  static Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'Pending':
        return {
          'color': AppColors.pending,
          'label': 'Chờ làm',
          'icon': Icons.hourglass_empty
        };
      case 'InProgress':
        return {
          'color': AppColors.inProgress,
          'label': 'Đang làm',
          'icon': Icons.play_circle
        };
      case 'Submitted':
        return {
          'color': AppColors.submitted,
          'label': 'Chờ duyệt',
          'icon': Icons.upload_rounded
        };
      case 'Approved':
        return {
          'color': AppColors.approved,
          'label': 'Hoàn thành',
          'icon': Icons.check_circle
        };
      case 'Rejected':
        return {
          'color': AppColors.rejected,
          'label': 'Bị từ chối',
          'icon': Icons.cancel
        };
      default:
        return {
          'color': AppColors.textHint,
          'label': status,
          'icon': Icons.info
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _getStatusInfo(status);
    final Color color = info['color'];
    final String label = info['label'];
    final IconData icon = info['icon'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class PointsBadge extends StatelessWidget {
  final int points;
  const PointsBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text('$points điểm',
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool loading;
  final Widget child;
  const LoadingOverlay({super.key, required this.loading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (loading)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.white.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}
