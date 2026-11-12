import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../services/destination_service.dart';
import '../widgets/destination_card.dart';
import 'destination_detail_page.dart';
import 'explore_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final DestinationService _destinationService = DestinationService();
  late Future<List<Destination>> _popularFuture;

  @override
  void initState() {
    super.initState();
    _loadPopularDestinations();
  }

  void _loadPopularDestinations() {
    setState(() {
      _popularFuture = _destinationService.getPopularDestinations();
    });
  }

  void _openDestination(
    BuildContext context, {
    required String name,
    required String country,
    required String description,
    required IconData icon,
    String? subtitle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DestinationDetailPage(
          name: name,
          country: country,
          description: description,
          icon: icon,
          subtitle: subtitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildHomeTab(context),
      ExplorePage(
        onDestinationTap: (destination) {
          _openDestination(
            context,
            name: destination.name,
            country: destination.country,
            description: destination.description,
            icon: destination.iconData,
            subtitle: destination.subtitle,
          );
        },
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelMate'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return RefreshIndicator(
      color: Colors.teal.shade700,
      onRefresh: () async {
        _loadPopularDestinations();
        await _popularFuture;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Text(
            'Where will you go next?',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Discover places for your next adventure.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan a little escape',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'New places. Fresh memories.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.flight_takeoff_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular destinations',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              Text(
                'REST API',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Destination>>(
            future: _popularFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: CircularProgressIndicator(color: Colors.teal),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 36,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString().replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _loadPopularDestinations,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Connection'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final destinations = snapshot.data ?? [];
              if (destinations.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No popular destinations found.')),
                );
              }

              return Column(
                children: [
                  for (final destination in destinations)
                    DestinationCard(
                      name: destination.name,
                      subtitle:
                          '${destination.country} • ${destination.subtitle}',
                      icon: destination.iconData,
                      onTap: () => _openDestination(
                        context,
                        name: destination.name,
                        country: destination.country,
                        description: destination.description,
                        icon: destination.iconData,
                        subtitle: destination.subtitle,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() => _selectedIndex = 1),
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Explore all destinations'),
          ),
        ],
      ),
    );
  }
}
