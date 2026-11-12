import 'package:flutter/material.dart';

import '../login_page.dart';
import '../models/user.dart';
import '../services/api/api_config.dart';
import '../services/auth_service.dart';
import '../services/supabase_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      _userFuture = _authService.getCurrentUser();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out? Your session token will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _authService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showEditProfileDialog(User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Profile'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (v) =>
                v == null || v.trim().length < 2 ? 'Min 2 characters' : null,
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
                await _authService.updateProfile(name: nameCtrl.text.trim());
                _loadUser();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile updated successfully!'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        final user = snapshot.data;

        return RefreshIndicator(
          color: Colors.teal.shade700,
          onRefresh: () async {
            _loadUser();
            await _userFuture;
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Your Profile',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.teal.shade50,
                  child: Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.name ?? 'TravelMate Traveler',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showEditProfileDialog(user),
                        tooltip: 'Edit name',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user?.email ?? 'Logged in via REST API',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.teal,
                      ),
                      title: const Text('Account Role'),
                      subtitle: Text(
                        user?.role.toUpperCase() ?? 'TRAVELER',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.dns_outlined,
                        color: Colors.teal,
                      ),
                      title: const Text('Backend Server'),
                      subtitle: Text(ApiConfig.baseUrl),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security, color: Colors.teal),
                      title: const Text('Authentication'),
                      subtitle: Text(
                        SupabaseConfig.shouldUseSupabase
                            ? 'Supabase Auth (JWT Session)'
                            : 'REST API JWT Bearer Token',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Logging out clears your stored authentication token.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
