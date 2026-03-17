import 'suggestion_page.dart';
import 'package:flutter/material.dart';
import 'category_page.dart';
import 'recipe_detail_page.dart';
import 'movie_detail_page.dart';

class HomeTab extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;
  final List<Map<String, String>> categories;
  final List<Map<String, dynamic>> movies;

  const HomeTab({
    super.key,
    required this.recipes,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.categories,
    required this.movies,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredRecipes {
    if (_searchQuery.isEmpty) return widget.recipes;
    return widget.recipes.where((r) => 
      r['title'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.orange[200] : const Color(0xFF4E342E);
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

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
          // APP BAR
          SliverAppBar(
            expandedHeight: 340.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF263238) : const Color(0xFFFF9D6C),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF37474F), const Color(0xFF263238)]
                      : [const Color(0xFFFF9D6C), const Color(0xFFFFD05B)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                  child: Column(
                    children: [
                      const Text(
                        '🍽️ Ghibli Kitchen',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // PESQUISA
                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Pesquisar receitas...',
                            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Colors.orange),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSuggestionButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // TÍTULO E CATEGORIAS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Bom apetite!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTextColor)),
                  const SizedBox(height: 24),
                  Text('Categorias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: widget.categories.map((cat) => _buildCategoryItem(cat, isDark)).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Receitas em Destaque', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                ],
              ),
            ),
          ),

          // GRID DE RECEITAS
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recipe = _filteredRecipes[index];
                  final isFavorite = widget.favoriteIds.contains(recipe['id']);
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe, isFavorite: isFavorite, onToggleFavorite: () => widget.onToggleFavorite(recipe['id'])))),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.network(recipe['imageUrl'], fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(recipe['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : const Color(0xFF4E342E)), maxLines: 2),
                                Text(recipe['movie'].toUpperCase(), style: const TextStyle(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _filteredRecipes.length,
              ),
            ),
          ),

          // SEÇÃO DE FILMES
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Filmes Ghibli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: widget.movies.map((m) => _buildMovieCard(m, isDark, cardColor)).toList(),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MÉTODOS AUXILIARES SIMPLIFICADOS
  Widget _buildCategoryItem(Map<String, String> category, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.white, shape: BoxShape.circle),
            child: Center(child: Text(category['emoji']!, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 4),
          Text(category['name']!, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.brown)),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie, bool isDark, Color cardColor) {
    return Container(
      width: 140, margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(movie['emoji'], style: const TextStyle(fontSize: 30)),
          Text(movie['title'], textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.brown)),
        ],
      ),
    );
  }

  Widget _buildSuggestionButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SuggestionPage(recipes: widget.recipes, favoriteIds: widget.favoriteIds, onToggleFavorite: widget.onToggleFavorite))),
      child: const Text('Sugestão Mágica ✨', style: TextStyle(color: Colors.white)),
    );
  }
}