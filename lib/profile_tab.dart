import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final int favoriteCount;
  final int totalRecipes;
  final int totalMovies;
  final List<Map<String, dynamic>> favoriteRecipes;
  final VoidCallback? onLogout;
  final VoidCallback? onRefresh;

  const ProfileTab({
    super.key,
    this.userData,
    required this.favoriteCount,
    required this.totalRecipes,
    required this.totalMovies,
    required this.favoriteRecipes,
    this.onLogout,
    this.onRefresh,
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
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userData?['full_name'] != widget.userData?['full_name']) {
      _nameController.text = widget.userData?['full_name'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) return;

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileExt = image.path.split('.').last;
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      // Upload image to Supabase Storage
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await Supabase.instance.client.storage.from('avatars').uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        await Supabase.instance.client.storage.from('avatars').upload(
              filePath,
              File(image.path),
              fileOptions: const FileOptions(upsert: true),
            );
      }

      // Get public URL
      final avatarUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update profiles table
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (widget.onRefresh != null) widget.onRefresh!();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'updated_at': DateTime.now().toIso8601String(),
      });

      setState(() => _isEditing = false);
      if (widget.onRefresh != null) widget.onRefresh!();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = widget.userData?['full_name'] ?? 'Fã do Studio Ghibli';
    final String? avatarUrl = widget.userData?['avatar_url'];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF9F2), Color(0xFFFFF1E6)],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Meu Perfil'),
              centerTitle: true,
            ),
            backgroundColor: Color(0xFFFF9D6C),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange.shade200, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                          ],
                        ),
                        child: ClipOval(
                          child: avatarUrl != null
                              ? Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                      child: Text('👤', style: TextStyle(fontSize: 50))),
                                )
                              : const Center(
                                  child: Text('👤', style: TextStyle(fontSize: 50))),
                        ),
                      ),
                      if (_isSaving)
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.orange),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Seu nome mágico',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            autofocus: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: _saveProfile,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => _isEditing = false),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                          onPressed: () => setState(() => _isEditing = true),
                        ),
                      ],
                    ),
                  Text(
                    'Membro da Cozinha Mágica',
                    style: TextStyle(color: Colors.brown[600]),
                  ),
                  const SizedBox(height: 24),

                  // Estatísticas
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Estatísticas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(Icons.favorite,
                                widget.favoriteCount.toString(), 'Favoritos'),
                            _buildStatItem(Icons.restaurant,
                                widget.totalRecipes.toString(), 'Receitas'),
                            _buildStatItem(
                                Icons.movie, widget.totalMovies.toString(), 'Filmes'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Conquistas
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conquistas Ghibli',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAchievement(
                          '🥚',
                          'Aprendiz de Cozinha',
                          widget.favoriteCount >= 1,
                        ),
                        const Divider(height: 20),
                        _buildAchievement(
                          '🍳',
                          'Chef do Castelo',
                          widget.favoriteCount >= 3,
                        ),
                        const Divider(height: 20),
                        _buildAchievement(
                          '👨‍🍳',
                          'Mestre Gastronômico',
                          widget.favoriteCount >= 5,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Menu
                  _buildMenuItem(
                    Icons.settings,
                    'Configurações',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Configurações em breve!')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.help_outline,
                    'Ajuda & Suporte',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Suporte em breve!')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.info_outline,
                    'Sobre o App',
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Ghibli Kitchen',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Inspirado nas obras do Studio Ghibli',
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItemColored(
                    Icons.logout,
                    'Sair da Conta',
                    Colors.red.shade400,
                    () async {
                      await Supabase.instance.client.auth.signOut();
                      if (widget.onLogout != null) widget.onLogout!();
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievement(String emoji, String title, bool unlocked) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
              color: unlocked ? const Color(0xFF4E342E) : Colors.grey[400],
            ),
          ),
        ),
        Icon(
          unlocked ? Icons.stars : Icons.lock_outline,
          color: unlocked ? Colors.orange : Colors.grey[300],
          size: 20,
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return _buildMenuItemColored(icon, title, Colors.orange, onTap);
  }

  Widget _buildMenuItemColored(IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color == Colors.orange ? Colors.black87 : color, fontWeight: color == Colors.orange ? FontWeight.normal : FontWeight.w600)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
