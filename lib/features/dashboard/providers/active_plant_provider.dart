import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/plant_profile.dart';

// Global active plant provider
// Only Beranda can update this
final activePlantProvider = StateProvider<PlantProfile>((ref) {
  return PlantProfile.defaultPlant();
});

final plantListProvider = FutureProvider<List<PlantProfile>>((ref) async {
  final catalogJson = await rootBundle.loadString(
    'functions/shared/plant_profiles.json',
  );
  final catalog = jsonDecode(catalogJson) as List<dynamic>;

  return catalog
      .map((item) {
        final plant = item['plant'] as Map<String, dynamic>;
        final light = item['light'] as String? ?? 'medium';
        final water = item['water'] as String? ?? 'moist';

        return PlantProfile(
          id: plant['name'].toString().toLowerCase().replaceAll(' ', '_'),
          name: plant['name'].toString(),
          category: 'Hias',
          soilMoistureMin: _soilMinForWater(water),
          soilMoistureMax: _soilMaxForWater(water),
          lightLuxMin: _lightMinForLevel(light),
          lightLuxMax: _lightMaxForLevel(light),
        );
      })
      .toList(growable: false);
});

int _soilMinForWater(String water) {
  switch (water) {
    case 'dry':
      return 20;
    case 'moist':
      return 40;
    default:
      return 70;
  }
}

int _soilMaxForWater(String water) {
  switch (water) {
    case 'dry':
      return 40;
    case 'moist':
      return 70;
    default:
      return 90;
  }
}

int _lightMinForLevel(String light) {
  switch (light) {
    case 'low':
      return 270;
    case 'medium':
      return 807;
    default:
      return 1614;
  }
}

int _lightMaxForLevel(String light) {
  switch (light) {
    case 'low':
      return 807;
    case 'medium':
      return 1614;
    default:
      return 10764;
  }
}
