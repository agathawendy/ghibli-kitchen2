import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

const String _supabaseUrl = 'https://ndfgljrcpvtoiolkmxnw.supabase.co';
const String _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kZmdsanJjcHZ0b2lvbGtteG53Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0NDQ4NzMsImV4cCI6MjA4OTAyMDg3M30.rUN0szwPrGDXfFtJAooFVkuVjAg6TU2U5cCJTnoPy7A';

// 1. O INTERRUPTOR GLOBAL
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(const GhibliKitchenApp());
}

class GhibliKitchenApp extends StatelessWidget {
  const GhibliKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Ghibli Kitchen',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // --- TEMA CLARO (Totalmente Corrigido) ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF9D6C), // Acento laranja
              primary: const Color(0xFFFF9D6C), // Cursor e foco laranja
              surface: const Color(0xFFFFF9F2), // Fundo bege claro
            ),
            fontFamily: 'Georgia',
            scaffoldBackgroundColor: const Color(0xFFFFF9F2),
            
            // Texto geral em marrom
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF4E342E)),
              bodyMedium: TextStyle(color: Color(0xFF4E342E)),
            ),

            // O SEGREDO ESTÁ AQUI: Personalização do TextField
            inputDecorationTheme: const InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.grey), // Texto de dica
              labelStyle: TextStyle(color: Colors.grey),
            ),
            
            // Forçamos o texto digitado a ser preto (independente do colorScheme)
            primaryTextTheme: const TextTheme(
              titleMedium: TextStyle(color: Colors.black87), // Texto de entrada
            ),
            // Outra forma de garantir no Material 3
            hintColor: Colors.grey,
            primaryColorLight: Colors.black87, // Ajuda a forçar texto preto
          ),

          // --- TEMA ESCURO (Original) ---
          // --- TEMA ESCURO (Versão Corrigida) ---
darkTheme: ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF9D6C),
    brightness: Brightness.dark,
    surface: const Color(0xFF1E1E1E),
  ),
  fontFamily: 'Georgia',
  scaffoldBackgroundColor: const Color(0xFF121212),
  
  // AQUI ESTAVA O ERRO: Corrigido para uma estrutura simples
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70), // Removido o TextStyle extra
  ),
),
          
          home: const LoginPage(),
        );
      },
    );
  }
}