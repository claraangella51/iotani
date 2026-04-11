import 'package:flutter/material.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/plant_profile.dart';
import 'package:iotani_berhasil/core/theme/app_theme.dart';

class PlantSelectorWidget extends StatelessWidget {
  final PlantProfile activePlant;
  final List<PlantProfile> plants;
  final ValueChanged<PlantProfile> onPlantChanged;

  const PlantSelectorWidget({
    super.key,
    required this.activePlant,
    required this.plants,
    required this.onPlantChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Tanaman',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            physics: const BouncingScrollPhysics(),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final isActive = plant.id == activePlant.id;
              return GestureDetector(
                onTap: () => onPlantChanged(plant),
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == plants.length - 1 ? 0 : 12,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? AppTheme.primaryGreen
                                : AppTheme.dividerColor,
                            width: isActive ? 3 : 1,
                          ),
                          color: isActive
                              ? AppTheme.primaryGreen.withOpacity(0.1)
                              : AppTheme.backgroundColor,
                        ),
                        child: Icon(
                          _getPlantIcon(plant.category),
                          size: 40,
                          color: isActive
                              ? AppTheme.primaryGreen
                              : AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 80,
                        child: Text(
                          plant.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getPlantIcon(String category) {
    switch (category) {
      case 'Buah':
        return Icons.favorite;
      case 'Sayur':
        return Icons.eco;
      case 'Hias':
        return Icons.local_florist;
      default:
        return Icons.nature;
    }
  }
}
