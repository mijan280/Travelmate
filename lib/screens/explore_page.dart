import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../services/destination_service.dart';
import '../widgets/destination_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, required this.onDestinationTap});

  final ValueChanged<Destination> onDestinationTap;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final DestinationService _destinationService = DestinationService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Destination>> _destinationsFuture;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDestinations({String? query}) {
    setState(() {
      _destinationsFuture = _destinationService.getDestinations(search: query);
    });
  }

  void _showAddDestinationDialog() {
    final nameCtrl = TextEditingController();
    final countryCtrl = TextEditingController(text: 'Bangladesh');
    final subtitleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedIcon = 'landscape';
    bool isPopular = true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Destination'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name *'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: countryCtrl,
                    decoration: const InputDecoration(labelText: 'Country *'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: subtitleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subtitle / Tagline *',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIcon,
                    decoration: const InputDecoration(
                      labelText: 'Icon Category',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'landscape',
                        child: Text('Mountains / Hills'),
                      ),
                      DropdownMenuItem(
                        value: 'beach_access',
                        child: Text('Sea / Beach'),
                      ),
                      DropdownMenuItem(
                        value: 'forest',
                        child: Text('Forest / Wildlife'),
                      ),
                      DropdownMenuItem(
                        value: 'local_florist',
                        child: Text('Gardens / Tea'),
                      ),
                      DropdownMenuItem(
                        value: 'sailing',
                        child: Text('Island / Boat'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedIcon = val);
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Popular Destination'),
                    contentPadding: EdgeInsets.zero,
                    value: isPopular,
                    activeThumbColor: Colors.teal.shade700,
                    onChanged: (val) => setDialogState(() => isPopular = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);

                try {
                  await _destinationService.createDestination(
                    name: nameCtrl.text,
                    country: countryCtrl.text,
                    subtitle: subtitleCtrl.text,
                    description: descCtrl.text,
                    icon: selectedIcon,
                    isPopular: isPopular,
                  );
                  _loadDestinations();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Destination added to backend!'),
                        backgroundColor: Colors.teal.shade700,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red.shade700,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save Destination'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDestinationDialog,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Place'),
      ),
      body: RefreshIndicator(
        color: Colors.teal.shade700,
        onRefresh: () async {
          _loadDestinations(query: _searchController.text.trim());
          await _destinationsFuture;
        },
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Explore',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose a destination to view more details.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (val) => _loadDestinations(query: val.trim()),
              decoration: InputDecoration(
                hintText: 'Search destinations by name or country...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadDestinations();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Destination>>(
              future: _destinationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(color: Colors.teal),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
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
                          snapshot.error.toString().replaceAll(
                            'Exception: ',
                            '',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _loadDestinations(
                            query: _searchController.text.trim(),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final destinations = snapshot.data ?? [];
                if (destinations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        'No destinations found matching your criteria.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
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
                        onTap: () => widget.onDestinationTap(destination),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
