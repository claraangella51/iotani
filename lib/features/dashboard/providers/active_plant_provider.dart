import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/plant_profile.dart';

// Global active plant provider
// Only Beranda can update this
final activePlantProvider = StateProvider<PlantProfile>((ref) {
  return PlantProfile.builtInPlants[0]; // Tomat Cherry as default
});

final plantListProvider = Provider<List<PlantProfile>>((ref) {
  return PlantProfile.builtInPlants;
});
