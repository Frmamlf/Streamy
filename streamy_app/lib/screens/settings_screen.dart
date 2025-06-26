import 'package:flutter/material.dart';
import 'source_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableDarkMode = true;
  bool _enableNotifications = true;
  bool _enableAutoPlay = true;
  bool _enableAdBlocking = true;
  bool _enableWebSources = true;
  String _videoQuality = 'Auto';
  final List<String> _videoQualities = ['Auto', '1080p', '720p', '480p', '360p'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: _enableDarkMode,
                onChanged: (value) {
                  setState(() {
                    _enableDarkMode = value;
                  });
                  // In a real app, you would update the app's theme
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme change will be available in future updates')),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Playback',
            children: [
              SwitchListTile(
                title: const Text('Auto Play'),
                subtitle: const Text('Automatically play videos'),
                value: _enableAutoPlay,
                onChanged: (value) {
                  setState(() {
                    _enableAutoPlay = value;
                  });
                },
              ),
              ListTile(
                title: const Text('Video Quality'),
                subtitle: Text(_videoQuality),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () {
                  _showQualitySelector();
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Web Sources & Ad Blocking',
            children: [
              SwitchListTile(
                title: const Text('Enable Web Sources'),
                subtitle: const Text('Search across external streaming sites'),
                value: _enableWebSources,
                onChanged: (value) {
                  setState(() {
                    _enableWebSources = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Ad Blocking'),
                subtitle: const Text('Block ads and popups from external sites'),
                value: _enableAdBlocking,
                onChanged: (value) {
                  setState(() {
                    _enableAdBlocking = value;
                  });
                },
              ),
              ListTile(
                title: const Text('Manage Sources'),
                subtitle: const Text('Add, remove, and configure web sources'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SourceManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive content updates'),
                value: _enableNotifications,
                onChanged: (value) {
                  setState(() {
                    _enableNotifications = value;
                  });
                },
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0 (Beta)'),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Policy will be added in future updates')),
                  );
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms of Service will be added in future updates')),
                  );
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showClearDataDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Clear App Data'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const Divider(),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  void _showQualitySelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Video Quality'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _videoQualities
                .map(
                  (quality) => RadioListTile<String>(
                    title: Text(quality),
                    value: quality,
                    groupValue: _videoQuality,
                    onChanged: (value) {
                      setState(() {
                        _videoQuality = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear App Data'),
          content: const Text('This will clear all cached data and reset your settings. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App data cleared')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
