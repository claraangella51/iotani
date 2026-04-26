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

  static PlantProfile defaultPlant() {
    return PlantProfile(
      id: 'silver_vase_plant',
      name: 'Silver Vase Plant',
      category: 'Hias',
      soilMoistureMin: 40,
      soilMoistureMax: 70,
      lightLuxMin: 807,
      lightLuxMax: 1614,
    );
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
