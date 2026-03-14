import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_tab.dart';
import 'favorites_tab.dart';
import 'profile_tab.dart';
import 'main.dart' show LoginPage;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  StreamSubscription<AuthState>? _authSubscription;

  final Set<String> _favoriteIds = {};
  List<Map<String, dynamic>> recipes = [];
  Map<String, dynamic>? _userData;

  final List<Map<String, dynamic>> _initialRecipes = [
    {
      'title': 'Bacon e Ovos do Castelo Animado',
      'movie': "Castelo Animado",
      'category': 'Principais',
      'difficulty': 'Fácil',
      'time': '15 min',
      'image_url':
          'https://images.pexels.com/photos/5894551/pexels-photo-5894551.jpeg',
      'ingredients': [
        '4 fatias grossas de bacon',
        '2 ovos grandes',
        'Pão caseiro',
        'Manteiga'
      ],
      'instructions': [
        'Aqueça uma frigideira em fogo médio.',
        'Frite o bacon até ficar crocante e soltar a gordura.',
        'Quebre os ovos diretamente na gordura do bacon.',
        'Cozinhe até a clara firmar mas a gema continuar mole.',
        'Sirva com fatias grossas de pão.'
      ],
    },
    {
      'title': 'Ramen da Ponyo',
      'movie': 'Ponyo',
      'category': 'Principais',
      'difficulty': 'Médio',
      'time': '30 min',
      'image_url':
          'https://images.pexels.com/photos/884600/pexels-photo-884600.jpeg?auto=compress&cs=tinysrgb&w=800',
      'ingredients': [
        '1 pacote de ramen instantâneo',
        '2 fatias de presunto',
        '1 ovo cozido (metade)',
        'Cebolinha picada'
      ],
      'instructions': [
        'Ferva a água e cozinhe o macarrão conforme a embalagem.',
        'Prepare o caldo com o tempero.',
        'Coloque o macarrão em uma tigela grande.',
        'Adicione as fatias de presunto e o ovo por cima.',
        'Finalize with cebolinha e tampe por 3 minutos antes de comer.'
      ],
    },
    {
      'title': 'Onigiri de Haku',
      'movie': 'A Viagem de Chihiro',
      'category': 'Lanches',
      'difficulty': 'Fácil',
      'time': '20 min',
      'image_url':
          'https://media.istockphoto.com/id/2152741288/pt/foto/cod-roe-rice-ball.jpg?s=1024x1024&w=is&k=20&c=l99SgPiVM2-_WJi0fA5AO2nr8X17yBhKcfllkG-sGaQ=',
      'ingredients': [
        '2 xícaras de arroz japonês cozido',
        'Sal a gosto',
        'Folhas de alga Nori',
        'Água para molhar as mãos'
      ],
      'instructions': [
        'Molhe as mãos com água e passe um pouco de sal.',
        'Pegue uma porção de arroz morno.',
        'Pressione firmemente forming um triângulo.',
        'Envolva a base with um pedaço de alga Nori.',
        'Repita o processo with o restante do arroz.'
      ],
    },
    {
      'title': 'Bolo da Kiki',
      'movie': "Kiki's Delivery Service",
      'category': 'Sobremesas',
      'difficulty': 'Difícil',
      'time': '60 min',
      'image_url':
          'https://images.pexels.com/photos/10510747/pexels-photo-10510747.jpeg',
      'ingredients': [
        '2 xícaras de farinha',
        '1 xícara de cacau em pó',
        '3 ovos',
        '1 xícara de açúcar',
        'Cobertura de chocolate'
      ],
      'instructions': [
        'Pré-aqueça o forno a 180°C.',
        'Bata os ovos com o açúcar até dobrar de volume.',
        'Misture delicadamente a farinha e o cacau.',
        'Asse por 40 minutos.',
        'Espere esfriar e cubra com chocolate, desenhando o nome da Kiki.'
      ],
    },
    {
      'title': 'Bolo de Mel do Castelo Animado',
      'movie': 'Castelo Animado',
      'category': 'Sobremesas',
      'difficulty': 'Médio',
      'time': '45 min',
      'image_url':
          'https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg?auto=compress&cs=tinysrgb&w=800',
      'ingredients': [
        '2 xícaras de farinha',
        '1 xícara de mel',
        '3 ovos',
        '1 xícara de leite',
        'Fermento'
      ],
      'instructions': [
        'Misture todos os ingredientes.',
        'Asse em forno pré-aquecido a 180°C por 35 minutos.',
        'Deixe esfriar antes de servir.'
      ],
    },
  ];

  final List<Map<String, dynamic>> movies = [
    {
      'title': 'Castelo Animado',
      'emoji': '🏰',
      'year': '2004',
      'director': 'Hayao Miyazaki',
      'synopsis':
          'Uma jovem chamada Sophie é amaldiçoada por uma bruxa e se transforma em uma idosa. Ela encontra refúgio no Castelo Animado de Howl, um misterioso mago.',
      'imageUrl':
          'https://3.bp.blogspot.com/-9L53YsCzlhw/UP1SHDjRmNI/AAAAAAAADVI/wpdjyOwQcnU/s1600/howl4.png',
    },
    {
      'title': 'A Viagem de Chihiro',
      'emoji': '👻',
      'year': '2001',
      'director': 'Hayao Miyazaki',
      'synopsis':
          'Chihiro, uma menina de 10 anos, descobre um mundo mágico de espíritos e deuses enquanto tenta salvar seus pais transformados em porcos.',
      'imageUrl':
          'https://th.bing.com/th/id/OIP.vbZA-SqCatiPCX2K9xWI5wHaD_?w=316&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3',
    },
    {
      'title': 'Ponyo',
      'emoji': '🌊',
      'year': '2008',
      'director': 'Hayao Miyazaki',
      'synopsis':
          'Um peixinho dourado chamado Ponyo sonha em se tornar humano após fazer amizade com um menino de 5 anos chamado Sosuke.',
      'imageUrl':
          'https://th.bing.com/th/id/OIP.e9XhCnH_X42hG8rCDF-CygHaEA?w=324&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3',
    },
    {
      'title': "Kiki's Delivery Service",
      'emoji': '🧹',
      'year': '1989',
      'director': 'Hayao Miyazaki',
      'synopsis':
          'Kiki, uma jovem bruxa em treinamento, se muda para uma nova cidade e começa um serviço de entregas com seu gato falante Jiji.',
      'imageUrl':
          'https://th.bing.com/th/id/OIP.vN-Uz-GOjifUD2CUuE_AHgHaEK?w=300&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3',
    },
  ];

  final List<Map<String, String>> categories = [
    {'emoji': '🥘', 'name': 'Principais'},
    {'emoji': '🍰', 'name': 'Sobremesas'},
    {'emoji': '🥗', 'name': 'Lanches'},
    {'emoji': '☕', 'name': 'Bebidas'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();

    // Listen to Auth State changes (useful if session expires or user logs out)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || 
          event == AuthChangeEvent.initialSession ||
          event == AuthChangeEvent.tokenRefreshed) {
        _fetchData();
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() {
          _favoriteIds.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // 1. Fetch Recipes (Should be publicly readable)
      var recipesData = await Supabase.instance.client.from('recipes').select();

      // Seed data if database is empty
      if (recipesData.isEmpty) {
        try {
          await Supabase.instance.client.from('recipes').insert(_initialRecipes);
          recipesData = await Supabase.instance.client.from('recipes').select();
        } catch (seedError) {
          debugPrint('Erro ao semear dados: $seedError');
          // If seeding fails, we still continue with empty or existing data
        }
      }

      // 2. Fetch User Favorites (Requires user)
      final user = Supabase.instance.client.auth.currentUser;
      List<dynamic> favoritesData = [];
      
      if (user != null) {
        favoritesData = await Supabase.instance.client
            .from('favorites')
            .select('recipe_id')
            .eq('user_id', user.id);
        debugPrint('Favoritos carregados: ${favoritesData.length}');

        // 3. Fetch User Profile
        try {
          final profileData = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();
          _userData = profileData;
        } catch (profileError) {
          debugPrint('Erro ao buscar perfil: $profileError');
        }
      }

      if (!mounted) return;
      
      setState(() {
        recipes = List<Map<String, dynamic>>.from(recipesData).map((r) {
          return {
            ...r,
            'id': r['id'].toString(),
            'imageUrl': r['image_url'] ?? r['imageUrl'],
          };
        }).toList();

        debugPrint('Receitas carregadas: ${recipes.length}');

        _favoriteIds.clear();
        for (var fav in favoritesData) {
          _favoriteIds.add(fav['recipe_id'].toString());
        }
      });
    } catch (e) {
      debugPrint('Erro ao buscar dados: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _favoriteRecipes {
    return recipes.where((r) => _favoriteIds.contains(r['id'].toString())).toList();
  }

  Future<void> _toggleFavorite(String recipeId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final isRemoving = _favoriteIds.contains(recipeId);

    // Update UI immediately (Optimistic Update)
    setState(() {
      if (isRemoving) {
        _favoriteIds.remove(recipeId);
      } else {
        _favoriteIds.add(recipeId);
      }
    });

    try {
      // Try to parse as int for BigInt columns, but fall back to string if it's a UUID/String ID
      dynamic dbRecipeId = int.tryParse(recipeId) ?? recipeId;

      if (isRemoving) {
        await Supabase.instance.client
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('recipe_id', dbRecipeId);
      } else {
        await Supabase.instance.client.from('favorites').insert({
          'user_id': user.id,
          'recipe_id': dbRecipeId,
        });
      }
    } catch (e) {
      // Revert UI on error
      setState(() {
        if (isRemoving) {
          _favoriteIds.add(recipeId);
        } else {
          _favoriteIds.remove(recipeId);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar favorito (ID: $recipeId): $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparando a cozinha Ghibli... 🍲'),
                ],
              ),
            )
          : IndexedStack(
              index: _selectedIndex,
              children: [
                recipes.isEmpty 
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Nenhuma receita encontrada. Por favor, execute o script SQL de ativação para liberar os pratos! 🍳',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.brown),
                        ),
                      ),
                    )
                  : HomeTab(
                      recipes: recipes,
                      favoriteIds: _favoriteIds,
                      onToggleFavorite: _toggleFavorite,
                      categories: categories,
                      movies: movies,
                    ),
                FavoritesTab(
                  favoriteRecipes: _favoriteRecipes,
                  favoriteIds: _favoriteIds,
                  onToggleFavorite: _toggleFavorite,
                ),
                  ProfileTab(
                    userData: _userData,
                    favoriteCount: _favoriteRecipes.length,
                    totalRecipes: recipes.length,
                    totalMovies: movies.length,
                    favoriteRecipes: _favoriteRecipes,
                    onLogout: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    onRefresh: _fetchData,
                  ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: 'Receitas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
