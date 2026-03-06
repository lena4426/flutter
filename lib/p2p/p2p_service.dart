import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/peer.dart';
import '../models/message.dart';

abstract class P2PService extends ChangeNotifier {
  String get myName;
  String get myIp;
  bool get isOnline;
  bool get isInitialized;

  Map<String, Peer> get peers;
  List<ChatMessage> get messages;

  Future<void> init();
  Future<void> sendMessage(String targetUid, String text);
  Future<void> broadcastMessage(String text);

  void refreshPeers();
  void addLocalMessage(ChatMessage msg);
}

// ─────────────────────────────────────────────────────────────────────────────
// Stub implementation — UI without real networking.
// Replace with RealP2PService when wiring up actual mDNS + TCP + crypto.
// ─────────────────────────────────────────────────────────────────────────────

class P2PServiceStub extends P2PService {
  String _myName = '—';
  String _myIp = '—';
  bool _isOnline = false;
  bool _isInitialized = false;

  final Map<String, Peer> _peers = {};
  final List<ChatMessage> _messages = [];

  @override String get myName => _myName;
  @override String get myIp => _myIp;
  @override bool get isOnline => _isOnline;
  @override bool get isInitialized => _isInitialized;
  @override Map<String, Peer> get peers => Map.unmodifiable(_peers);
  @override List<ChatMessage> get messages => List.unmodifiable(_messages);

  @override
  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final iface in interfaces) {
        if (iface.addresses.isNotEmpty) {
          _myIp = iface.addresses.first.address;
          break;
        }
      }
    } catch (_) {
      _myIp = '127.0.0.1';
    }

    _myName = 'MY_NODE';
    _isOnline = true;
    _isInitialized = true;

    notifyListeners();
  }

  @override
  Future<void> sendMessage(String targetUid, String text) async {
    // TODO: open TCP socket to _peers[targetUid].ip, encrypt, send
  }

  @override
  Future<void> broadcastMessage(String text) async {
    for (final uid in _peers.keys) {
      await sendMessage(uid, text);
    }
  }

  @override
  void refreshPeers() {
    // TODO: nsd.startDiscovery('_p2p_chat._tcp') and update _peers
    notifyListeners();
  }

  @override
  void addLocalMessage(ChatMessage msg) {
    _messages.add(msg);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
