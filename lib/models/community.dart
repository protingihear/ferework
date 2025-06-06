class Community {
  final int id;
  final String name;
  final String description;
  final String imageBase64;
  final int creatorId;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.imageBase64,
    required this.creatorId,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      name: json['name'] ?? 'Unknown Name',
      description: json['description'] ?? 'No description available',
      imageBase64: json['foto'] ?? '',
      creatorId: json['creatorId'] ?? 0,
    );
  }
}
