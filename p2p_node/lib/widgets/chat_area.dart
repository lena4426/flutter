import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/peer.dart';
import '../models/message.dart';
import '../p2p/p2p_service.dart';

/// Mirrors Python build_chat_area() + add_message().
/// Shows chat title, selected user, scrollable message list.
class ChatArea extends StatefulWidget {
  final AppColors colors;
  final Peer? selectedPeer;

  const ChatArea({super.key, required this.colors, required this.selectedPeer});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<P2PService>();
    final msgs = service.messages;

    // Auto-scroll on new messages (mirrors chat_display.see('end'))
    if (msgs.length != _lastMessageCount) {
      _lastMessageCount = msgs.length;
      _scrollToBottom();
    }

    return Container(
      color: widget.colors.bgMain,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Chat header ─────────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  '💬 CHAT',
                  style: TextStyle(
                    color: widget.colors.accent,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (widget.selectedPeer != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    '→ ${widget.selectedPeer!.name}',
                    style: TextStyle(
                      color: widget.colors.accent2,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Message list ────────────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              decoration: BoxDecoration(
                color: widget.colors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.colors.borderSoft),
              ),
              child: msgs.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet.\nSelect a node and start chatting.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.colors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(12),
                      itemCount: msgs.length,
                      itemBuilder: (ctx, i) => _MessageRow(
                        message: msgs[i],
                        colors: widget.colors,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single message row ───────────────────────────────────────────────────────
class _MessageRow extends StatelessWidget {
  final ChatMessage message;
  final AppColors colors;

  const _MessageRow({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    // System / temp messages (show_temp_message equivalent)
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          '  ${message.text}',
          style: TextStyle(
            color: colors.textSecondary,
            fontFamily: 'monospace',
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final isOwn = message.isOwn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar (other side only)
          if (!isOwn) ...[
            CircleAvatar(
              radius: 13,
              backgroundColor: colors.accent.withOpacity(0.15),
              child: Text(
                message.sender.isNotEmpty
                    ? message.sender[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: colors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isOwn
                    ? colors.accent.withOpacity(0.14)
                    : colors.bgSidebar,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isOwn
                      ? colors.accent.withOpacity(0.3)
                      : colors.borderSoft,
                ),
              ),
              child: Column(
                crossAxisAlignment: isOwn
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // [HH:MM] SENDER — matches Python's tag format
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '[${message.formattedTime}] ',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                        TextSpan(
                          text: message.sender,
                          style: TextStyle(
                            color: isOwn
                                ? colors.accent
                                : colors.textPrimary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isOwn) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
