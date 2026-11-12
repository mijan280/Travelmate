import 'package:flutter/material.dart';

class DestinationDetailPage extends StatelessWidget {
  const DestinationDetailPage({
    super.key,
    required this.name,
    required this.country,
    required this.description,
    required this.icon,
    this.subtitle,
  });

  final String name;
  final String country;
  final String description;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Destination details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 88, color: Colors.teal.shade700),
          ),
          const SizedBox(height: 22),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle != null ? '$country • $subtitle' : country,
            style: TextStyle(
              color: Colors.teal.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.cloud_done_outlined, color: Colors.teal),
              title: Text('Live REST API Data'),
              subtitle: Text(
                'Fetched in real-time from Node.js backend with JSON persistent storage.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to TravelMate'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
