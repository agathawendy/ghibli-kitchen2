import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart'; // Certifique-se de que o themeNotifier está acessível aqui

class ProfileTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final int favoriteCount;
  final int totalRecipes;
  final int totalMovies;
  final List<Map<String, dynamic>> favoriteRecipes;
  final VoidCallback? onLogout;
  final VoidCallback? onRefresh;
  final List<Map<String, dynamic>> totalRecipesList;
  final Function(String) onToggleFavorite;
  final Set<String> favoriteIds;

  const ProfileTab({
    super.key,
    this.userData,
    required this.favoriteCount,
    required this.totalRecipes,
    required this.totalMovies,
    required this.favoriteRecipes,
    this.onLogout,
    this.onRefresh,
    required this.totalRecipesList,
    required this.onToggleFavorite,
    required this.favoriteIds,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData?['full_name'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- FUNÇÕES DE DIÁLOGO ---

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Notificações Mágicas'),
              trailing: Icon(Icons.notifications_active, color: Colors.orange),
            ),
            const Divider(),
            // AQUI ESTÁ A OPÇÃO DE ESCOLHA DO TEMA
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, _) {
                return SwitchListTile(
                  title: const Text('Modo Noturno'),
                  secondary: Icon(
                    currentMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.orange,
                  ),
                  value: currentMode == ThemeMode.dark,
                  onChanged: (isDark) {
                    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                  },
                  activeColor: Colors.orange,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda & Suporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email_outlined, color: Colors.orange),
              title: Text('Email'),
              subtitle: Text('suporte@ghiblikitchen.com'),
            ),
            Text('\nO Totoro responderá o mais rápido possível! ✉️'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendi')),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Ghibli Kitchen',
      applicationVersion: '1.2.0',
      applicationIcon: const Icon(Icons.restaurant_menu, color: Colors.orange),
      children: [
        const Text('Um catálogo de receitas mágicas inspiradas no Studio Ghibli. Desenvolvido com carinho para fãs.'),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar Sugestão'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Qual receita você quer ver aqui?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              final content = controller.text.trim();
              if (content.isEmpty) return;
              try {
                final user = Supabase.instance.client.auth.currentUser;
                await Supabase.instance.client.from('suggestions').insert({
                  'user_id': user?.id,
                  'user_name': widget.userData?['full_name'] ?? 'Usuário Anônimo',
                  'content': content,
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sugestão enviada para o Totoro!')));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
              }
            },
            child: const Text('Enviar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE UPLOAD E SALVAR PERFIL ---

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (image == null) return;
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await Supabase.instance.client.storage.from('avatars').uploadBinary(fileName, bytes);
      } else {
        await Supabase.instance.client.storage.from('avatars').upload(fileName, File(image.path));
      }
      final avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
      await Supabase.instance.client.from('profiles').upsert({'id': user.id, 'avatar_url': avatarUrl});
      if (widget.onRefresh != null) widget.onRefresh!();
    } catch (e) {
      debugPrint("Erro upload: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String displayName = widget.userData?['full_name'] ?? 'Fã do Studio Ghibli';
    final String? avatarUrl = widget.userData?['avatar_url'];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
            ? [const Color(0xFF121212), const Color(0xFF1E1E1E)] 
            : [const Color(0xFFFFF9F2), const Color(0xFFFFF1E6)],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Meu Perfil', style: TextStyle(color: isDark ? Colors.white : Colors.white)),
              centerTitle: true,
            ),
            backgroundColor: const Color(0xFFFF9D6C),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.orange.shade100,
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.orange) : null,
                      ),
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: const CircleAvatar(radius: 18, backgroundColor: Colors.orange, child: Icon(Icons.camera_alt, color: Colors.white, size: 18)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // Estatísticas (Cartão Gordinho)
                  _buildSectionContainer(isDark, child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.favorite, widget.favoriteCount.toString(), 'Favoritos'),
                      _buildStatItem(Icons.restaurant, widget.totalRecipes.toString(), 'Receitas'),
                      _buildStatItem(Icons.movie, widget.totalMovies.toString(), 'Filmes'),
                    ],
                  )),
                  
                  const SizedBox(height: 20),

                  // Menu de Opções
                  _buildMenuItem(Icons.settings, 'Configurações', isDark, () => _showSettingsDialog(context)),
                  _buildMenuItem(Icons.help_outline, 'Ajuda & Suporte', isDark, () => _showSupportDialog(context)),
                  _buildMenuItem(Icons.info_outline, 'Sobre o App', isDark, () => _showAboutDialog(context)),
                  _buildMenuItem(Icons.feedback_outlined, 'Enviar Sugestão', isDark, () => _showFeedbackDialog(context)),
                  
                  const SizedBox(height: 12),
                  _buildMenuItem(Icons.logout, 'Sair da Conta', isDark, () async {
                    await Supabase.instance.client.auth.signOut();
                    if (widget.onLogout != null) widget.onLogout!();
                  }, isExit: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionContainer(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isDark, VoidCallback onTap, {bool isExit = false}) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: isExit ? Colors.red : Colors.orange),
        title: Text(title, style: TextStyle(color: isExit ? Colors.red : (isDark ? Colors.white : Colors.black87))),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}