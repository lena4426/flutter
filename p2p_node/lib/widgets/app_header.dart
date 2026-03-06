import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../p2p/p2p_service.dart';
import 'search_dialog.dart';

/// Mirrors Python build_header():
///   icon | USER / MY IP | ●ONLINE | 🌙DARK | 🔍 | EXIT
class AppHeader extends StatelessWidget {
  final AppColors colors;
  final bool isDark;

  const AppHeader({super.key, required this.colors, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<P2PService>();

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colors.bgSidebar,
        border: Border(bottom: BorderSide(color: colors.borderSoft)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── App icon ──────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SvgPicture.asset(
              'assets/icons/icon.svg',
              width: 38,
              height: 38,
            ),
          ),
          const SizedBox(width: 12),

          // ── User / IP info ────────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'USER: ${service.myName}',
                style: TextStyle(
                  color: colors.accent,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                'MY IP: ${service.myIp}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── ● ONLINE status ───────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 9,
                color: service.isOnline ? colors.accent2 : colors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                service.isOnline ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  color: service.isOnline ? colors.accent2 : colors.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // ── Theme toggle ──────────────────────────────────────────────────
          _HeaderButton(
            colors: colors,
            label: isDark ? '☀  LIGHT' : '🌙  DARK',
            onTap: () => context.read<ThemeProvider>().toggle(),
          ),
          const SizedBox(width: 8),

          // ── Search button ─────────────────────────────────────────────────
          _HeaderButton(
            colors: colors,
            label: '🔍',
            onTap: () => showDialog(
              context: context,
              builder: (_) => SearchDialog(colors: colors),
            ),
          ),
          const SizedBox(width: 8),

          // ── EXIT button ───────────────────────────────────────────────────
          _HeaderButton(
            colors: colors,
            label: 'EXIT',
            isDestructive: true,
            onTap: () => _showExitDialog(context),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Exit',
          style: TextStyle(
              color: colors.textPrimary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to exit P2P NODE?',
          style: TextStyle(
              color: colors.textSecondary, fontFamily: 'monospace', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: colors.textSecondary, fontFamily: 'monospace')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              SystemNavigator.pop();
            },
            child: const Text('Exit',
                style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable header button ────────────────────────────────────────────────────
class _HeaderButton extends StatefulWidget {
  final AppColors colors;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _HeaderButton({
    required this.colors,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hovered ? widget.colors.bgHover : widget.colors.bgCard;
    final fg = widget.isDestructive
        ? widget.colors.accent3
        : widget.colors.textPrimary;

    return Tooltip(
      message: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: fg,
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
