class SongPlaylist {
  final String id;
  String name;
  final List<int> songIds;
  final DateTime createdAt;
  SongPlaylist({required this.id, required this.name, required List<int> songIds, required this.createdAt}) : songIds = List<int>.from(songIds);
  factory SongPlaylist.fromJson(Map<String, dynamic> json) => SongPlaylist(
    id: json['id'] as String,
    name: json['name'] as String,
    songIds: (json['songIds'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'songIds': songIds, 'createdAt': createdAt.toIso8601String()};
}
