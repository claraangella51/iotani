class PlantProfile {
  final String id;
  final String name;
  final String category; // Buah, Sayur, Hias
  final int soilMoistureMin;
  final int soilMoistureMax;
  final int lightLuxMin;
  final int lightLuxMax;

  PlantProfile({
    required this.id,
    required this.name,
    required this.category,
    required this.soilMoistureMin,
    required this.soilMoistureMax,
    required this.lightLuxMin,
    required this.lightLuxMax,
  });

  static final List<PlantProfile> builtInPlants = [
    PlantProfile(
      id: 'tomat_cherry',
      name: 'Tomat Cherry',
      category: 'Buah',
      soilMoistureMin: 50,
      soilMoistureMax: 70,
      lightLuxMin: 3000,
      lightLuxMax: 8000,
    ),
    PlantProfile(
      id: 'cabai_rawit',
      name: 'Cabai Rawit',
      category: 'Buah',
      soilMoistureMin: 50,
      soilMoistureMax: 80,
      lightLuxMin: 3000,
      lightLuxMax: 9000,
    ),
    PlantProfile(
      id: 'stroberi',
      name: 'Stroberi',
      category: 'Buah',
      soilMoistureMin: 60,
      soilMoistureMax: 80,
      lightLuxMin: 2000,
      lightLuxMax: 6000,
    ),
    PlantProfile(
      id: 'selada',
      name: 'Selada',
      category: 'Sayur',
      soilMoistureMin: 60,
      soilMoistureMax: 80,
      lightLuxMin: 2000,
      lightLuxMax: 5000,
    ),
    PlantProfile(
      id: 'pakcoy',
      name: 'Pakcoy',
      category: 'Sayur',
      soilMoistureMin: 60,
      soilMoistureMax: 80,
      lightLuxMin: 2000,
      lightLuxMax: 5000,
    ),
    PlantProfile(
      id: 'bayam',
      name: 'Bayam',
      category: 'Sayur',
      soilMoistureMin: 60,
      soilMoistureMax: 80,
      lightLuxMin: 2500,
      lightLuxMax: 6000,
    ),
    PlantProfile(
      id: 'lidah_mertua',
      name: 'Lidah Mertua',
      category: 'Hias',
      soilMoistureMin: 20,
      soilMoistureMax: 40,
      lightLuxMin: 500,
      lightLuxMax: 3000,
    ),
    PlantProfile(
      id: 'monstera',
      name: 'Monstera',
      category: 'Hias',
      soilMoistureMin: 40,
      soilMoistureMax: 60,
      lightLuxMin: 1000,
      lightLuxMax: 3000,
    ),
    PlantProfile(
      id: 'aglonema',
      name: 'Aglonema',
      category: 'Hias',
      soilMoistureMin: 40,
      soilMoistureMax: 60,
      lightLuxMin: 500,
      lightLuxMax: 2500,
    ),
  ];

  static PlantProfile? getById(String id) {
    try {
      return builtInPlants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
