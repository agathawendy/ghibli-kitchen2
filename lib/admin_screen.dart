import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  int _totalRecipes = 0;
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Busca receitas e usuários
      final recipesRes = await Supabase.instance.client.from('recipes').select('id');
      final usersRes = await Supabase.instance.client.from('profiles').select('id');
      
      if (mounted) {
        setState(() {
          _totalRecipes = recipesRes.length;
          _totalUsers = usersRes.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro nas estatísticas: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchStats();
              setState(() {}); // Força a atualização do Badge também
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey[900]),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text('AD', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            ),
            accountName: const Text('Administrador'),
            accountEmail: const Text('admin@g.com'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          
          // --- O VERDINHO USANDO FUTURE (MUITO MAIS SEGURO) ---
          ListTile(
            leading: FutureBuilder(
              future: Supabase.instance.client.from('suggestions').select('id'),
              builder: (context, AsyncSnapshot snapshot) {
                // Se ainda estiver carregando, mostra o ícone normal
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Icon(Icons.feedback_outlined);
                }
                
                // Se der erro, mostra um ponto de exclamação
                if (snapshot.hasError) {
                  return const Icon(Icons.warning, color: Colors.amber);
                }

                final count = (snapshot.data as List?)?.length ?? 0;

                return Badge(
                  label: Text(count.toString()),
                  isLabelVisible: count > 0,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.feedback_outlined),
                );
              },
            ),
            title: const Text('Sugestões'),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Usuários'),
            selected: _selectedIndex == 3,
            onTap: () {
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    switch (_selectedIndex) {
      case 0: return _buildDashboard();
      case 2: return _buildSuggestionsManager();
      default: return const Center(child: Text('Em desenvolvimento...'));
    }
  }

  // --- TELA QUE MOSTRA AS SUGESTÕES ---
  Widget _buildSuggestionsManager() {
    return FutureBuilder(
      future: Supabase.instance.client.from('suggestions').select(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final suggestions = snapshot.data as List;
        if (suggestions.isEmpty) return const Center(child: Text('Nenhuma sugestão encontrada no banco.'));

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final s = suggestions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(s['user_name'] ?? 'Usuário'),
                subtitle: Text(s['content'] ?? 'Sem conteúdo'),
                leading: const Icon(Icons.message_outlined, color: Colors.blue),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Status do Sistema', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildStatCard('Pratos', _totalRecipes.toString(), Icons.restaurant, Colors.orange),
              _buildStatCard('Usuários', _totalUsers.toString(), Icons.people, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}