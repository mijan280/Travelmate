import '../models/destination.dart';
import 'api/api_client.dart';

class DestinationService {
  final ApiClient _api = ApiClient.instance;

  /// Fetch all destinations, optionally filtered by search
  Future<List<Destination>> getDestinations({String? search}) async {
    final endpoint = search != null && search.isNotEmpty
        ? '/destinations?search=${Uri.encodeComponent(search)}'
        : '/destinations';

    final response = await _api.get<List<Destination>>(
      endpoint,
      requiresAuth: false,
      fromDataJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((item) => Destination.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );

    return response.data ?? [];
  }

  /// Fetch popular destinations for Home screen
  Future<List<Destination>> getPopularDestinations() async {
    final response = await _api.get<List<Destination>>(
      '/destinations/popular',
      requiresAuth: false,
      fromDataJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((item) => Destination.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );

    return response.data ?? [];
  }

  /// Fetch single destination details
  Future<Destination> getDestinationById(String id) async {
    final response = await _api.get<Destination>(
      '/destinations/$id',
      requiresAuth: false,
      fromDataJson: (data) =>
          Destination.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw Exception('Destination not found');
  }

  /// Create a new destination
  Future<Destination> createDestination({
    required String name,
    required String country,
    required String subtitle,
    required String description,
    required String icon,
    bool isPopular = false,
  }) async {
    final response = await _api.post<Destination>(
      '/destinations',
      requiresAuth: false,
      body: {
        'name': name.trim(),
        'country': country.trim(),
        'subtitle': subtitle.trim(),
        'description': description.trim(),
        'icon': icon,
        'isPopular': isPopular,
      },
      fromDataJson: (data) =>
          Destination.fromJson(data as Map<String, dynamic>),
    );

    if (response.data != null) {
      return response.data!;
    }
    throw Exception('Failed to create destination');
  }

  /// Delete a destination
  Future<void> deleteDestination(String id) async {
    await _api.delete<dynamic>('/destinations/$id', requiresAuth: false);
  }
}
