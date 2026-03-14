import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'favorites_tab.dart';
import 'profile_tab.dart';
import 'category_page.dart';
import 'recipe_detail_page.dart';
import 'movie_detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final Set<String> _favoriteIds = {};

  final List<Map<String, dynamic>> recipes = [
    {
      'id': '1',
      'title': 'Bacon e Ovos do Castelo Animado',
      'movie': "Castelo Animado",
      'category': 'Principais',
      'difficulty': 'Fácil',
      'time': '15 min',
      'imageUrl': 'https://images.pexels.com/photos/5894551/pexels-photo-5894551.jpeg',
      'ingredients': ['4 fatias grossas de bacon', '2 ovos grandes', 'Pão caseiro', 'Manteiga'],
      'instructions': [
        'Aqueça uma frigideira em fogo médio.',
        'Frite o bacon até ficar crocante e soltar a gordura.',
        'Quebre os ovos diretamente na gordura do bacon.',
        'Cozinhe até a clara firmar mas a gema continuar mole.',
        'Sirva com fatias grossas de pão.'
      ],
    },
    {
      'id': '2',
      'title': 'Ramen da Ponyo',
      'movie': 'Ponyo',
      'category': 'Principais',
      'difficulty': 'Médio',
      'time': '30 min',
      'imageUrl': 'https://images.pexels.com/photos/884600/pexels-photo-884600.jpeg?auto=compress&cs=tinysrgb&w=800',
      'ingredients': ['1 pacote de ramen instantâneo', '2 fatias de presunto', '1 ovo cozido (metade)', 'Cebolinha picada'],
      'instructions': [
        'Ferva a água e cozinhe o macarrão conforme a embalagem.',
        'Prepare o caldo com o tempero.',
        'Coloque o macarrão em uma tigela grande.',
        'Adicione as fatias de presunto e o ovo por cima.',
        'Finalize com cebolinha e tampe por 3 minutos antes de comer.'
      ],
    },
    {
      'id': '3',
      'title': 'Onigiri de Haku',
      'movie': 'A Viagem de Chihiro',
      'category': 'Lanches',
      'difficulty': 'Fácil',
      'time': '20 min',
      'imageUrl': 'https://media.istockphoto.com/id/2152741288/pt/foto/cod-roe-rice-ball.jpg?s=1024x1024&w=is&k=20&c=l99SgPiVM2-_WJi0fA5AO2nr8X17yBhKcfllkG-sGaQ=',
      'ingredients': ['2 xícaras de arroz japonês cozido', 'Sal a gosto', 'Folhas de alga Nori', 'Água para molhar as mãos'],
      'instructions': [
        'Molhe as mãos com água e passe um pouco de sal.',
        'Pegue uma porção de arroz morno.',
        'Pressione firmemente formando um triângulo.',
        'Envolva a base com um pedaço de alga Nori.',
        'Repita o processo com o restante do arroz.'
      ],
    },
    {
      'id': '4',
      'title': 'Bolo da Kiki',
      'movie': "Kiki's Delivery Service",
      'category': 'Sobremesas',
      'difficulty': 'Difícil',
      'time': '60 min',
      'imageUrl': 'https://images.pexels.com/photos/10510747/pexels-photo-10510747.jpeg',
      'ingredients': ['2 xícaras de farinha', '1 xícara de cacau em pó', '3 ovos', '1 xícara de açúcar', 'Cobertura de chocolate'],
      'instructions': [
        'Pré-aqueça o forno a 180°C.',
        'Bata os ovos com o açúcar até dobrar de volume.',
        'Misture delicadamente a farinha e o cacau.',
        'Asse por 40 minutos.',
        'Espere esfriar e cubra com chocolate, desenhando o nome da Kiki.'
      ],
    },
    {
      'id': '5',
      'title': 'Bolo de Mel do Castelo Animado',
      'movie': 'Castelo Animado',
      'category': 'Sobremesas',
      'difficulty': 'Médio',
      'time': '45 min',
      'imageUrl': 'https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg?auto=compress&cs=tinysrgb&w=800',
      'ingredients': ['2 xícaras de farinha', '1 xícara de mel', '3 ovos', '1 xícara de leite', 'Fermento'],
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
      'synopsis': 'Uma jovem chamada Sophie é amaldiçoada por uma bruxa e se transforma em uma idosa. Ela encontra refúgio no Castelo Animado de Howl, um misterioso mago.',
      'imageUrl': 'https://3.bp.blogspot.com/-9L53YsCzlhw/UP1SHDjRmNI/AAAAAAAADVI/wpdjyOwQcnU/s1600/howl4.png',
    },
    {
      'title': 'A Viagem de Chihiro',
      'emoji': '👻',
      'year': '2001',
      'director': 'Hayao Miyazaki',
      'synopsis': 'Chihiro, uma menina de 10 anos, descobre um mundo mágico de espíritos e deuses enquanto tenta salvar seus pais transformados em porcos.',
      'imageUrl': 'https://th.bing.com/th/id/OIP.vbZA-SqCatiPCX2K9xWI5wHaD_?w=316&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3',
    },
    {
      'title': 'Ponyo',
      'emoji': '🌊',
      'year': '2008',
      'director': 'Hayao Miyazaki',
      'synopsis': 'Um peixinho dourado chamado Ponyo sonha em se tornar humano após fazer amizade com um menino de 5 anos chamado Sosuke.',
      'imageUrl': 'https://th.bing.com/th/id/OIP.e9XhCnH_X42hG8rCDF-CygHaEA?w=324&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3',
    },
    {
      'title': "Kiki's Delivery Service",
      'emoji': '🧹',
      'year': '1989',
      'director': 'Hayao Miyazaki',
      'synopsis': 'Kiki, uma jovem bruxa em treinamento, se muda para uma nova cidade e começa um serviço de entregas com seu gato falante Jiji.',
      'imageUrl': 'https://th.bing.com/th/id/OIP.vN-Uz-GOjifUD2CUuE_AHgHaEK?w=300&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3',
    },
  ];

  final List<Map<String, String>> categories = [
    {'emoji': '🥘', 'name': 'Principais'},
    {'emoji': '🍰', 'name': 'Sobremesas'},
    {'emoji': '🥗', 'name': 'Lanches'},
    {'emoji': '☕', 'name': 'Bebidas'},
  ];

  List<Map<String, dynamic>> get _favoriteRecipes {
    return recipes.where((r) => _favoriteIds.contains(r['id'])).toList();
  }

  void _toggleFavorite(String recipeId) {
    setState(() {
      if (_favoriteIds.contains(recipeId)) {
        _favoriteIds.remove(recipeId);
      } else {
        _favoriteIds.add(recipeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(
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
            favoriteCount: _favoriteRecipes.length,
            totalRecipes: recipes.length,
            totalMovies: movies.length,
            favoriteRecipes: _favoriteRecipes,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
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