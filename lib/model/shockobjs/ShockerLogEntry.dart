class ShockerLogEntry {
  final String action; // Shock, Vibrate, Sound
  final double duration; // Duration in seconds
  final String shockerId; // Shocker ID
  final int intensity; // Intensity
  final String name; // Person who triggered it
  final String imageUrl; // Image of the person
  final String? customName; // Optional custom name

  ShockerLogEntry({
    required this.action,
    required this.duration,
    required this.shockerId,
    required this.intensity,
    required this.name,
    required this.imageUrl,
    this.customName,
  });
}
