/// Mirrors the {uid: name} dict entries from Python's P2PBridge.found_computers.
class Peer {
  final String uid;
  final String name;
  final String? ip;

  const Peer({required this.uid, required this.name, this.ip});

  /// First 16 chars of uid — matches Python's uid[:16] display.
  String get shortUid => uid.length > 16 ? uid.substring(0, 16) : uid;

  /// E.g. "Alice (aabbccddeeff0011…)"
  String get displayName => '$name ($shortUid…)';
}
