import 'package:flutter/material.dart';

class Destination {
  final String id;
  final String name;
  final String country;
  final String subtitle;
  final String description;
  final String iconName;
  final bool isPopular;
  final String? createdAt;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.subtitle,
    required this.description,
    required this.iconName,
    this.isPopular = false,
    this.createdAt,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? 'Bangladesh',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['icon'] as String? ?? 'landscape',
      isPopular: json['isPopular'] == true,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'subtitle': subtitle,
      'description': description,
      'icon': iconName,
      'isPopular': isPopular,
      'createdAt': createdAt,
    };
  }

  /// Maps backend icon string to Flutter Material IconData
  IconData get iconData {
    switch (iconName.toLowerCase()) {
      case 'beach_access':
      case 'beach':
        return Icons.beach_access_rounded;
      case 'landscape':
      case 'hills':
      case 'mountain':
        return Icons.landscape_rounded;
      case 'forest':
      case 'tree':
        return Icons.forest_rounded;
      case 'local_florist':
      case 'garden':
      case 'flower':
        return Icons.local_florist_rounded;
      case 'sailing':
      case 'boat':
      case 'island':
        return Icons.sailing_rounded;
      case 'flight':
      case 'airport':
        return Icons.flight_takeoff_rounded;
      case 'castle':
      case 'historic':
        return Icons.castle_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}
