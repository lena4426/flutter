import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/peer.dart';
import '../p2p/p2p_service.dart';

/// Mirrors Python build_users_panel():
///   📋 NODES header | count badge | scrollable peer list
class PeersPanel extends StatelessWidget {
  final AppColors colors;
  final Peer? selectedPeer;
  final ValueChanged<Peer> onPeerSelected;

  const PeersPanel({
    super.key,
    required this.colors,
    required this.selectedPeer,
    required this.onPeerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.watch<P2PService>();
    final peerList = service.peers.values.toList();
    final count = peerList.length;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colors.bgSidebar,
        border: Border(right: BorderSide(color: colors.borderSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  '📋 NODES',
                  style: TextStyle(
                    color: colors.accent,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                // Count badge — mirrors nodes_count label
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                  decoration: BoxDecoration(
                    color: count > 0
                        ? colors.accent2.withOpacity(0.2)
                        : colors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: count > 0
                          ? colors.accent2
                          : colors.textSecondary,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Peer list ───────────────────────────────────────────────────────
          Expanded(
            child: count == 0
                ? Center(
                    child: Text(
                      'No nodes found\nSearching…',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: peerList.length,
                    itemBuilder: (ctx, i) {
                      final peer = peerList[i];
                      return _PeerItem(
                        peer: peer,
                        isSelected: selectedPeer?.uid == peer.uid,
                        colors: colors,
                        onTap: () => onPeerSelected(peer),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Single peer row (equiv. to Listbox entry) ────────────────────────────────
class _PeerItem extends StatefulWidget {
  final Peer peer;
  final bool isSelected;
  final AppColors colors;
  final VoidCallback onTap;

  const _PeerItem({
    required this.peer,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_PeerItem> createState() => _PeerItemState();
}

class _PeerItemState extends State<_PeerItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isSelected
        ? widget.colors.accent2.withOpacity(0.25)
        : _hovered
            ? widget.colors.bgHover.withOpacity(0.25)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(color: widget.colors.accent2, width: 1)
                : null,
          ),
          child: Row(
            children: [
              // Avatar initial
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.colors.accent.withOpacity(0.18),
                child: Text(
                  widget.peer.name.isNotEmpty
                      ? widget.peer.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: widget.colors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Name + uid
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.peer.name,
                      style: TextStyle(
                        color: widget.colors.textPrimary,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${widget.peer.shortUid}…',
                      style: TextStyle(
                        color: widget.colors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.isSelected)
                Icon(Icons.chat_bubble_outline,
                    size: 14, color: widget.colors.accent2),
            ],
          ),
        ),
      ),
    );
  }
}
