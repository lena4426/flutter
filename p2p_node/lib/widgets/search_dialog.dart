import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../p2p/p2p_service.dart';
import '../models/message.dart';

// Helper — creates a system/temp chat message
ChatMessage _systemMsg(String text) => ChatMessage(
      sender: '',
      text: text,
      timestamp: DateTime.now(),
      isSystem: true,
    );

/// Mirrors Python cmd_search_with_query() dialog:
///   title | query entry | Find (Enter) | Отмена (Escape)
class SearchDialog extends StatefulWidget {
  final AppColors colors;

  const SearchDialog({super.key, required this.colors});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _ctrl = TextEditingController();

  AppColors get c => widget.colors;

  void _doSearch() {
    final query = _ctrl.text.trim();
    if (query.isEmpty) return;

    Navigator.pop(context);

    // Trigger peer refresh (mirrors perform_search + cmd_list)
    final service = context.read<P2PService>();
    service.refreshPeers();
    service.addLocalMessage(
      _systemMsg('🔍 Search: "$query"'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: c.bgMain,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Nodes',
                style: TextStyle(
                  color: c.accent,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                autofocus: true,
                style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'monospace',
                    fontSize: 13),
                cursorColor: c.accent,
                onSubmitted: (_) => _doSearch(),
                decoration: InputDecoration(
                  hintText: 'Enter search query…',
                  hintStyle: TextStyle(
                      color: c.textSecondary, fontFamily: 'monospace'),
                  filled: true,
                  fillColor: c.bgCard,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: c.borderSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: c.accent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: TextStyle(
                            color: c.textSecondary,
                            fontFamily: 'monospace')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _doSearch,
                    child: const Text('Find',
                        style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
