import 'package:flutter/material.dart';
import 'recipe_detail_page.dart';

class ProfileTab extends StatelessWidget {
  final int favoriteCount;
  final int totalRecipes;
  final int totalMovies;
  final List<Map<String, dynamic>> favoriteRecipes;

  const ProfileTab({
    super.key,
    required this.favoriteCount,
    required this.totalRecipes,
    required this.totalMovies,
    required this.favoriteRecipes,
  });

  @override
  Widget build(BuildContext context) {
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
            expandedHeight: 200,
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
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 3),
                    ),
                    child: const Center(
                      child: Text('👤', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Fã do Studio Ghibli',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Membro desde 2024',
                    style: TextStyle(color: Colors.brown[600]),
                  ),
                  const SizedBox(height: 24),

                  // Estatísticas
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
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
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(Icons.favorite, favoriteCount.toString(), 'Favoritos'),
                            _buildStatItem(Icons.restaurant, totalRecipes.toString(), 'Receitas'),
                            _buildStatItem(Icons.movie, totalMovies.toString(), 'Filmes'),
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
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conquistas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAchievement(
                          '🥚',
                          'Aprendiz',
                          favoriteCount >= 1,
                        ),
                        const Divider(),
                        _buildAchievement(
                          '🍳',
                          'Chef',
                          favoriteCount >= 3,
                        ),
                        const Divider(),
                        _buildAchievement(
                          '👨‍🍳',
                          'Mestre',
                          favoriteCount >= 5,
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
                        const SnackBar(content: Text('Configurações em breve!')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.help,
                    'Ajuda',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajuda em breve!')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.info,
                    'Sobre',
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Ghibli Kitchen',
                        applicationVersion: '1.0.0',
                      );
                    },
                  ),
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
              color: unlocked ? Colors.black : Colors.grey,
            ),
          ),
        ),
        Icon(
          unlocked ? Icons.check_circle : Icons.lock,
          color: unlocked ? Colors.green : Colors.grey,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}