import 'package:flutter/material.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/device_state.dart';

class RiskStatusBadge extends StatelessWidget {
  final RiskStatus status;
  final bool showIcon;
  final bool large;

  const RiskStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.large = false,
  });

  Color _getStatusColor() {
    switch (status) {
      case RiskStatus.aman:
        return AppTheme.statusAman;
      case RiskStatus.waspada:
        return AppTheme.statusWaspada;
      case RiskStatus.risikoTinggi:
        return AppTheme.statusRisikoTinggi;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case RiskStatus.aman:
        return Icons.check_circle;
      case RiskStatus.waspada:
        return Icons.warning;
      case RiskStatus.risikoTinggi:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final fontSize = large ? 14.0 : 12.0;
    final padding = large ? 12.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding + 4, vertical: padding),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getStatusIcon(), color: statusColor, size: large ? 16 : 14),
            const SizedBox(width: 6),
          ],
          Text(
            status.display,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  final RiskStatus status;
  final String message;

  const StatusBanner({super.key, required this.status, required this.message});

  Color _getStatusColor() {
    switch (status) {
      case RiskStatus.aman:
        return AppTheme.statusAman;
      case RiskStatus.waspada:
        return AppTheme.statusWaspada;
      case RiskStatus.risikoTinggi:
        return AppTheme.statusRisikoTinggi;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
