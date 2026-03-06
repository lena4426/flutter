import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/peer.dart';

/// Mirrors Python build_input_bar():
///   ✎ icon | message entry | SEND (Enter) | BROADCAST (Ctrl+Enter)
class MessageInputBar extends StatefulWidget {
  final AppColors colors;
  final Peer? selectedPeer;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onBroadcast;

  const MessageInputBar({
    super.key,
    required this.colors,
    required this.selectedPeer,
    required this.onSend,
    required this.onBroadcast,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ── Mirrors cmd_send() ──────────────────────────────────────────────────────
  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    if (widget.selectedPeer == null) {
      _showHint('Select a node first or use BROADCAST');
      return;
    }
    widget.onSend(text);
    _ctrl.clear();
    _focus.requestFocus();
  }

  // ── Mirrors cmd_broadcast() ─────────────────────────────────────────────────
  void _broadcast() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onBroadcast(text);
    _ctrl.clear();
    _focus.requestFocus();
  }

  void _showHint(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: TextStyle(
                fontFamily: 'monospace',
                color: widget.colors.textPrimary,
                fontSize: 12)),
        backgroundColor: widget.colors.bgCard,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.colors.bgSidebar,
        border: Border(top: BorderSide(color: widget.colors.borderSoft)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // ✎ icon
          Icon(Icons.edit_outlined, size: 18, color: widget.colors.textSecondary),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.enter,
                    control: true): _broadcast,
              },
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                autofocus: true,
                style: TextStyle(
                    color: widget.colors.textPrimary,
                    fontFamily: 'monospace',
                    fontSize: 13),
                cursorColor: widget.colors.accent,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Write a message…',
                  hintStyle: TextStyle(
                      color: widget.colors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 13),
                  filled: true,
                  fillColor: widget.colors.bgCard,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: widget.colors.borderSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: widget.colors.accent, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // SEND button
          _InputButton(
            label: 'SEND',
            tooltip: 'Enter',
            colors: widget.colors,
            isPrimary: true,
            onTap: _send,
          ),
          const SizedBox(width: 8),

          // BROADCAST button
          _InputButton(
            label: 'BROADCAST',
            tooltip: 'Ctrl+Enter',
            colors: widget.colors,
            isPrimary: false,
            onTap: _broadcast,
          ),
        ],
      ),
    );
  }
}

// ─── Button (mirrors Python RoundedButton in input bar) ───────────────────────
class _InputButton extends StatefulWidget {
  final String label;
  final String tooltip;
  final AppColors colors;
  final bool isPrimary;
  final VoidCallback onTap;

  const _InputButton({
    required this.label,
    required this.tooltip,
    required this.colors,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_InputButton> createState() => _InputButtonState();
}

class _InputButtonState extends State<_InputButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hovered
        ? widget.colors.accent3
        : widget.isPrimary
            ? widget.colors.accent
            : widget.colors.bgCard;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: widget.isPrimary
                  ? null
                  : Border.all(color: widget.colors.borderSoft),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.isPrimary
                    ? Colors.white
                    : widget.colors.textPrimary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
