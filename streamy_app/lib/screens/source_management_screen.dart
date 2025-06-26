import 'package:flutter/material.dart';
import '../models/web_source.dart';
import '../services/web_scraping_service.dart';

class SourceManagementScreen extends StatefulWidget {
  const SourceManagementScreen({super.key});

  @override
  State<SourceManagementScreen> createState() => _SourceManagementScreenState();
}

class _SourceManagementScreenState extends State<SourceManagementScreen> {
  final WebScrapingService _webScrapingService = WebScrapingService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _webScrapingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Sources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSourceDialog,
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Predefined Sources',
            children: WebScrapingService.predefinedSources.map((source) => 
              _buildSourceTile(source, isPredefined: true)
            ).toList(),
          ),
          _buildSection(
            title: 'Custom Sources',
            children: _webScrapingService.allSources
                .where((source) => !WebScrapingService.predefinedSources.contains(source))
                .map((source) => _buildSourceTile(source, isPredefined: false))
                .toList(),
          ),
          const SizedBox(height: 20),
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
      ],
    );
  }

  Widget _buildSourceTile(WebSource source, {required bool isPredefined}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: source.isEnabled 
              ? Theme.of(context).primaryColor 
              : Colors.grey,
          child: Icon(
            Icons.language,
            color: Colors.white,
          ),
        ),
        title: Text(source.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source.baseUrl,
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (source.adBlockPatterns.isNotEmpty)
              Text(
                '${source.adBlockPatterns.length} ad block patterns',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: source.isEnabled,
              onChanged: (value) {
                // In a real implementation, you'd update the source state
                setState(() {
                  // This is a simplified version - you'd need to properly update the source
                });
              },
            ),
            if (!isPredefined)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCustomSource(source),
              ),
          ],
        ),
        onTap: () => _showSourceDetails(source),
      ),
    );
  }

  void _showAddSourceDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final adPatternsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Source Name',
                hintText: 'e.g., My Streaming Site',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://example.com',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: adPatternsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ad Block Patterns (comma-separated)',
                hintText: 'ads.example.com, popup, banner',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              
              if (name.isNotEmpty && url.isNotEmpty) {
                final adPatterns = adPatternsController.text
                    .split(',')
                    .map((p) => p.trim())
                    .where((p) => p.isNotEmpty)
                    .toList();

                final newSource = WebSource(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  baseUrl: url,
                  adBlockPatterns: adPatterns,
                  videoSelectors: {
                    'video': 'video',
                    'iframe': 'iframe[src*="player"]',
                    'source': 'source[src]',
                  },
                );

                _webScrapingService.addCustomSource(newSource);
                setState(() {
                  // Trigger rebuild to show new source
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added source: $name')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomSource(WebSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Source'),
        content: Text('Are you sure you want to delete "${source.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _webScrapingService.removeCustomSource(source.id);
              setState(() {
                // Trigger rebuild to remove source
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted source: ${source.name}')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSourceDetails(WebSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(source.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('URL', source.baseUrl),
            const SizedBox(height: 8),
            _buildDetailRow('Status', source.isEnabled ? 'Enabled' : 'Disabled'),
            const SizedBox(height: 8),
            _buildDetailRow('Ad Block Patterns', '${source.adBlockPatterns.length}'),
            if (source.adBlockPatterns.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Patterns:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    source.adBlockPatterns.join('\n'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
