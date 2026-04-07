import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget to view all SharedPreferences data in a bottom sheet
/// Shows all stored key-value pairs with their data types
class SharedPrefsViewerButton extends StatefulWidget {
  final Color? buttonColor;
  final Color? buttonForegroundColor;

  const SharedPrefsViewerButton({
    Key? key,
    this.buttonColor,
    this.buttonForegroundColor,
  }) : super(key: key);

  @override
  State<SharedPrefsViewerButton> createState() => _SharedPrefsViewerButtonState();
}

class _SharedPrefsViewerButtonState extends State<SharedPrefsViewerButton> {
  Map<String, dynamic> _prefsData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final data = <String, dynamic>{};

      for (final key in keys) {
        data[key] = prefs.get(key);
      }

      setState(() {
        _prefsData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading SharedPreferences: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showPrefsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      '📦 SharedPreferences Viewer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _prefsData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.storage,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No preferences stored',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(12),
                            children: _prefsData.entries
                                .map((e) => _PrefsItem(
                                      prefKey: e.key,
                                      value: e.value,
                                      onRefresh: _loadPrefs,
                                    ))
                                .toList(),
                          ),
              ),
              // Footer with refresh button
              Container(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: _loadPrefs,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showPrefsBottomSheet(context),
      backgroundColor: Colors.blue.withValues(alpha: 0.9),
      foregroundColor: Colors.white,
      tooltip: 'View SharedPreferences (Dev Mode)',
      child: const Icon(Icons.developer_mode),
    );
  }
}

/// Individual preference item display
class _PrefsItem extends StatefulWidget {
  final String prefKey;
  final dynamic value;
  final VoidCallback onRefresh;

  const _PrefsItem({
    required this.prefKey,
    required this.value,
    required this.onRefresh,
  });

  @override
  State<_PrefsItem> createState() => _PrefsItemState();
}

class _PrefsItemState extends State<_PrefsItem> {
  bool _isExpanded = false;

  String _getTypeIcon(dynamic value) {
    if (value is String) return '📝';
    if (value is int) return '🔢';
    if (value is double) return '🔢';
    if (value is bool) return '✓';
    if (value is List) return '📋';
    return '❓';
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      return value.isEmpty ? '(empty string)' : value;
    }
    if (value is List) {
      return '${value.length} items: ${value.toString()}';
    }
    return value.toString();
  }

  Future<void> _copyToClipboard() async {
    final text = '${widget.prefKey}: ${_formatValue(widget.value)}';
    // Using basic copy - you can add clipboard package if needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
    debugPrint('Copied: $text');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Text(_getTypeIcon(widget.value), style: const TextStyle(fontSize: 20)),
            title: Text(
              widget.prefKey,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              widget.value.runtimeType.toString(),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _formatValue(widget.value),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.content_copy, size: 16),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: _copyToClipboard,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          _showDeleteConfirmation();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Preference?'),
        content: Text('Are you sure you want to delete key: ${widget.prefKey}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(widget.prefKey);
              widget.onRefresh();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted: ${widget.prefKey}')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
