import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../models/peer.dart';
import '../p2p/p2p_service.dart';
import '../theme/theme_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/peers_panel.dart';
import '../widgets/chat_area.dart';
import '../widgets/message_input_bar.dart';

/// Root screen — mirrors Python ChatUI.__init__() + build_layout().
///
/// • Initialises P2PService on first frame (equiv. P2PBridge() call in __init__)
/// • Polls for peers every 3 s (equiv. _start_polling / root.after(3000, ...))
/// • Routes send/broadcast actions to the service + adds local echo messages
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Peer? _selectedPeer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Defer init so context is ready (equiv. mainloop starting after __init__)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<P2PService>().init();
      _startPolling();
    });
  }

  /// Mirrors Python _start_polling() — refreshes peers every 3 seconds.
  void _startPolling() {
    _pollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) context.read<P2PService>().refreshPeers();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Mirrors cmd_send() ──────────────────────────────────────────────────────
  void _handleSend(String text) {
    if (_selectedPeer == null || text.isEmpty) return;
    final svc = context.read<P2PService>();
    svc.sendMessage(_selectedPeer!.uid, text);
    svc.addLocalMessage(ChatMessage(
      sender: 'YOU',
      text: text,
      timestamp: DateTime.now(),
      isOwn: true,
    ));
  }

  // ── Mirrors cmd_broadcast() ─────────────────────────────────────────────────
  void _handleBroadcast(String text) {
    if (text.isEmpty) return;
    final svc = context.read<P2PService>();
    svc.broadcastMessage(text);
    svc.addLocalMessage(ChatMessage(
      sender: 'YOU → ALL',
      text: text,
      timestamp: DateTime.now(),
      isOwn: true,
      isBroadcast: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final colors = tp.colors;

    return Scaffold(
      backgroundColor: colors.bgMain,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          AppHeader(colors: colors, isDark: tp.isDark),

          // ── Body: sidebar + chat ───────────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PeersPanel(
                  colors: colors,
                  selectedPeer: _selectedPeer,
                  onPeerSelected: (peer) =>
                      setState(() => _selectedPeer = peer),
                ),
                Expanded(
                  child: ChatArea(
                    colors: colors,
                    selectedPeer: _selectedPeer,
                  ),
                ),
              ],
            ),
          ),

          // ── Input bar ─────────────────────────────────────────────────────
          MessageInputBar(
            colors: colors,
            selectedPeer: _selectedPeer,
            onSend: _handleSend,
            onBroadcast: _handleBroadcast,
          ),
        ],
      ),
    );
  }
}
