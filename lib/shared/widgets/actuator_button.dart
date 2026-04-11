import 'package:flutter/material.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';

class ActuatorButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onToggle;
  final bool isLoading;
  final String? iconType; // 'pump', 'uv', or null

  const ActuatorButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onToggle,
    this.isLoading = false,
    this.iconType,
  });

  @override
  State<ActuatorButton> createState() => _ActuatorButtonState();
}

class _ActuatorButtonState extends State<ActuatorButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.isActive
            ? AppTheme.statusRisikoTinggi
            : AppTheme.dividerColor,
        foregroundColor: widget.isActive ? Colors.white : AppTheme.textDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: widget.isLoading ? null : widget.onToggle,
      child: SizedBox(
        height: 24,
        child: widget.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                children: [
                  Icon(
                    widget.iconType == 'pump'
                        ? Icons.water_drop
                        : widget.iconType == 'uv'
                        ? Icons.lightbulb
                        : Icons.toggle_on,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(widget.label),
                ],
              ),
      ),
    );
  }
}
