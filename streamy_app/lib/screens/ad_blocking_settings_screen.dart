import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import '../services/ad_blocking_engine.dart';
import '../services/app_service_manager.dart';

class AdBlockingSettingsScreen extends StatefulWidget {
  const AdBlockingSettingsScreen({super.key});

  @override
  State<AdBlockingSettingsScreen> createState() => _AdBlockingSettingsScreenState();
}

class _AdBlockingSettingsScreenState extends State<AdBlockingSettingsScreen> {
  late AdBlockingConfig _config;
  final TextEditingController _customPatternController = TextEditingController();
  final TextEditingController _allowedDomainController = TextEditingController();
  final AppServiceManager _serviceManager = AppServiceManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    _config = _serviceManager.adBlockingConfig;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveConfiguration() async {
    await _serviceManager.updateAdBlockingConfig(_config);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad blocking settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updateConfig(AdBlockingConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    _saveConfiguration();
  }

  void _addCustomPattern() {
    final pattern = _customPatternController.text.trim();
    if (pattern.isNotEmpty) {
      final newPatterns = [..._config.customPatterns, pattern];
      _updateConfig(_config.copyWith(customPatterns: newPatterns));
      _customPatternController.clear();
    }
  }

  void _removeCustomPattern(String pattern) {
    final newPatterns = _config.customPatterns.where((p) => p != pattern).toList();
    _updateConfig(_config.copyWith(customPatterns: newPatterns));
  }

  void _addAllowedDomain() {
    final domain = _allowedDomainController.text.trim();
    if (domain.isNotEmpty) {
      final newDomains = [..._config.allowedDomains, domain];
      _updateConfig(_config.copyWith(allowedDomains: newDomains));
      _allowedDomainController.clear();
    }
  }

  void _removeAllowedDomain(String domain) {
    final newDomains = _config.allowedDomains.where((d) => d != domain).toList();
    _updateConfig(_config.copyWith(allowedDomains: newDomains));
  }

  Future<void> _exportFilters() async {
    try {
      final exportData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'config': _config.toJson(),
      };

      final exportJson = jsonEncode(exportData);
      
      // Get the downloads directory
      final directory = await getExternalStorageDirectory();
      final downloadsPath = directory?.path ?? '/storage/emulated/0/Download';
      final fileName = 'streamy_filters_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '$downloadsPath/$fileName';
      
      final file = File(filePath);
      await file.writeAsString(exportJson);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filters exported to $fileName'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                // Could implement file opening here
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importFilters() async {
    // Import functionality temporarily disabled
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Blocking Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Main toggles
          _buildSectionHeader('Core Settings'),
          _buildToggleTile(
            'Network Filtering',
            'Block ads and trackers at the network level',
            _config.networkFilteringEnabled,
            (value) => _updateConfig(_config.copyWith(networkFilteringEnabled: value)),
          ),
          _buildToggleTile(
            'Cosmetic Filtering',
            'Hide ad elements using CSS selectors',
            _config.cosmeticFilteringEnabled,
            (value) => _updateConfig(_config.copyWith(cosmeticFilteringEnabled: value)),
          ),
          _buildToggleTile(
            'Script Blocking',
            'Block tracking and advertising scripts',
            _config.scriptBlockingEnabled,
            (value) => _updateConfig(_config.copyWith(scriptBlockingEnabled: value)),
          ),
          
          const SizedBox(height: 24),
          
          // Content-specific settings
          _buildSectionHeader('Content Filtering'),
          _buildToggleTile(
            'Cookie Notices',
            'Hide cookie consent banners and notices',
            _config.cookieNoticesBlocked,
            (value) => _updateConfig(_config.copyWith(cookieNoticesBlocked: value)),
          ),
          _buildToggleTile(
            'Social Widgets',
            'Block social media widgets and buttons',
            _config.socialWidgetsBlocked,
            (value) => _updateConfig(_config.copyWith(socialWidgetsBlocked: value)),
          ),
          _buildToggleTile(
            'Tracking Protection',
            'Block analytics and tracking requests',
            _config.trackingBlocked,
            (value) => _updateConfig(_config.copyWith(trackingBlocked: value)),
          ),
          
          const SizedBox(height: 24),
          
          // Custom patterns
          _buildSectionHeader('Custom Patterns'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add custom blocking patterns (supports wildcards and regex)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customPatternController,
                          decoration: const InputDecoration(
                            hintText: 'e.g., *.ads.com, /ads/*, ||example.com^',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addCustomPattern(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addCustomPattern,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_config.customPatterns.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _config.customPatterns.map((pattern) => Chip(
                        label: Text(pattern),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeCustomPattern(pattern),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Allowed domains
          _buildSectionHeader('Allowed Domains'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Domains that should bypass ad blocking entirely',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _allowedDomainController,
                          decoration: const InputDecoration(
                            hintText: 'e.g., example.com',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addAllowedDomain(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addAllowedDomain,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_config.allowedDomains.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _config.allowedDomains.map((domain) => Chip(
                        label: Text(domain),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeAllowedDomain(domain),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Import/Export section
          _buildSectionHeader('Import/Export'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup or restore your custom ad blocking filters',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exportFilters,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Export Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _importFilters,
                          icon: const Icon(Icons.file_download),
                          label: const Text('Import Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Info card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Advanced Ad Blocking',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Streamy uses advanced ad blocking techniques inspired by uBlock Origin, including:\n\n'
                    '• Network request filtering\n'
                    '• Cosmetic element hiding\n'
                    '• Script injection blocking\n'
                    '• Procedural filtering\n'
                    '• Domain-specific rules\n\n'
                    'These settings will take effect on new page loads.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Reset button
          Center(
            child: TextButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text('This will reset all ad blocking settings to their default values. Continue?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  _updateConfig(AdBlockingConfig());
                }
              },
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Defaults'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _customPatternController.dispose();
    _allowedDomainController.dispose();
    super.dispose();
  }
}
