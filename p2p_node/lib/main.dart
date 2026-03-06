import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_colors.dart';
import 'theme/theme_provider.dart';
import 'p2p/p2p_service.dart';
import 'screens/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        // Swap P2PServiceStub → RealP2PService once networking is implemented
        ChangeNotifierProvider<P2PService>(create: (_) => P2PServiceStub()),
      ],
      child: const P2PNodeApp(),
    ),
  );
}

class P2PNodeApp extends StatelessWidget {
  const P2PNodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return MaterialApp(
      title: 'P2P NODE',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: _buildMaterialTheme(AppColors.light, Brightness.light),
      darkTheme: _buildMaterialTheme(AppColors.dark, Brightness.dark),
      home: const ChatScreen(),
    );
  }

  ThemeData _buildMaterialTheme(AppColors c, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.accent,
        onPrimary: Colors.white,
        secondary: c.accent2,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        background: c.bgMain,
        onBackground: c.textPrimary,
        surface: c.bgCard,
        onSurface: c.textPrimary,
      ),
      scaffoldBackgroundColor: c.bgMain,
      fontFamily: 'monospace',
      dialogBackgroundColor: c.bgCard,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.bgCard,
        contentTextStyle:
            TextStyle(color: c.textPrimary, fontFamily: 'monospace'),
      ),
    );
  }
}
