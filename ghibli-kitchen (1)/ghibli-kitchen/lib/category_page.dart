import 'package:flutter/material.dart';
import 'recipe_detail_page.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  final String categoryEmoji;
  final List<Map<String, dynamic>> recipes;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const CategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryEmoji,
    required this.recipes,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryEmoji} ${widget.categoryName}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF9F2), Color(0xFFFFF1E6)],
          ),
        ),
        child: widget.recipes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.categoryEmoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma receita em ${widget.categoryName}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.75,
                ),
                itemCount: widget.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = widget.recipes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(
                            recipe: recipe,
                            isFavorite: widget.favoriteIds.contains(recipe['id']),
                            onToggleFavorite: () => widget.onToggleFavorite(recipe['id']),
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    child: _buildRecipeCard(recipe),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                recipe['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      recipe['time'],
                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}