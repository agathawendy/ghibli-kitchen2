import { useState } from 'react';
import { motion } from 'motion/react';
import { Utensils, Heart, User, Clock, ChefHat, Star } from 'lucide-react';

// Tipagem para as receitas
interface Recipe {
  id: number;
  title: string;
  movie: string;
  emoji: string;
  bgColor: string;
  difficulty: 'Fácil' | 'Médio' | 'Difícil';
  time: string;
  imageUrl: string;
}

// Tipagem para as categorias
interface Category {
  id: number;
  name: string;
  emoji: string;
}

// Tipagem para os filmes
interface Movie {
  id: number;
  title: string;
  emoji: string;
}

const CATEGORIES: Category[] = [
  { id: 1, name: 'Pratos Principais', emoji: '🥘' },
  { id: 2, name: 'Sobremesas', emoji: '🍰' },
  { id: 3, name: 'Lanches', emoji: '🥗' },
  { id: 4, name: 'Bebidas', emoji: '☕' },
];

const RECIPES: Recipe[] = [
  {
    id: 1,
    title: 'Bacon e Ovos do Castelo Animado',
    movie: "Howl's Moving Castle",
    emoji: '🥓',
    bgColor: 'bg-orange-400',
    difficulty: 'Fácil',
    time: '15 min',
    imageUrl: 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?q=80&w=800&auto=format&fit=crop',
  },
  {
    id: 2,
    title: 'Ramen da Ponyo',
    movie: 'Ponyo',
    emoji: '🍜',
    bgColor: 'bg-red-400',
    difficulty: 'Médio',
    time: '30 min',
    imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?q=80&w=800&auto=format&fit=crop',
  },
  {
    id: 3,
    title: 'Onigiri de Haku',
    movie: 'Spirited Away',
    emoji: '🍙',
    bgColor: 'bg-emerald-400',
    difficulty: 'Fácil',
    time: '20 min',
    imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?q=80&w=800&auto=format&fit=crop',
  },
  {
    id: 4,
    title: 'Bolo de Kiki',
    movie: "Kiki's Delivery Service",
    emoji: '🍰',
    bgColor: 'bg-pink-400',
    difficulty: 'Difícil',
    time: '60 min',
    imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?q=80&w=800&auto=format&fit=crop',
  },
];

// ... (dentro do componente App, na renderização do card de receita)
// Substitua o div colorido pela imagem:
/*
<div className="relative h-32 overflow-hidden">
  <img 
    src={recipe.imageUrl} 
    alt={recipe.title} 
    className="w-full h-full object-cover opacity-90"
    referrerPolicy="no-referrer"
  />
  <div className="absolute inset-0 flex items-center justify-center text-5xl bg-black/20">
    {recipe.emoji}
  </div>
</div>
*/

const MOVIES: Movie[] = [
  { id: 1, title: "Howl's Moving Castle", emoji: '🏰' },
  { id: 2, title: 'Spirited Away', emoji: '👻' },
  { id: 3, title: 'Ponyo', emoji: '🌊' },
  { id: 4, title: "Kiki's Delivery Service", emoji: '🧹' },
];

export default function App() {
  const [activeTab, setActiveTab] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRecipe, setSelectedRecipe] = useState<Recipe | null>(null);

  const filteredRecipes = RECIPES.filter(r => 
    r.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (selectedRecipe) {
    return (
      <div className="min-h-screen pastel-bg pb-10">
        <div className="relative h-72">
          <img 
            src={selectedRecipe.imageUrl} 
            className="w-full h-full object-cover" 
            referrerPolicy="no-referrer"
          />
          <button 
            onClick={() => setSelectedRecipe(null)}
            className="absolute top-6 left-6 bg-white/80 p-2 rounded-full shadow-lg"
          >
            <Star className="w-6 h-6 rotate-180" />
          </button>
        </div>
        <div className="px-6 py-8 -mt-8 bg-[#FFF9F2] rounded-t-[40px] relative z-10 space-y-6">
          <div className="flex justify-between items-start">
            <div>
              <h2 className="text-3xl font-bold text-stone-800">{selectedRecipe.title}</h2>
              <p className="text-orange-500 font-bold">{selectedRecipe.movie}</p>
            </div>
            <span className="text-5xl">{selectedRecipe.emoji}</span>
          </div>
          
          <div className="flex justify-around py-4 border-y border-orange-100">
            <div className="text-center">
              <Clock className="w-6 h-6 text-orange-400 mx-auto" />
              <p className="text-xs font-bold mt-1">{selectedRecipe.time}</p>
            </div>
            <div className="text-center">
              <ChefHat className="w-6 h-6 text-orange-400 mx-auto" />
              <p className="text-xs font-bold mt-1">{selectedRecipe.difficulty}</p>
            </div>
            <div className="text-center">
              <Star className="w-6 h-6 text-orange-400 mx-auto" />
              <p className="text-xs font-bold mt-1">4.9</p>
            </div>
          </div>

          <div className="space-y-4">
            <h3 className="text-xl font-bold text-stone-800">Ingredientes</h3>
            <ul className="space-y-2">
              {['Ingrediente 1', 'Ingrediente 2', 'Ingrediente 3'].map((ing, i) => (
                <li key={i} className="flex items-center gap-3 text-stone-600">
                  <div className="w-2 h-2 bg-green-400 rounded-full" />
                  {ing}
                </li>
              ))}
            </ul>
          </div>

          <div className="space-y-4">
            <h3 className="text-xl font-bold text-stone-800">Modo de Preparo</h3>
            <div className="space-y-4">
              {[1, 2, 3].map((step) => (
                <div key={step} className="flex gap-4">
                  <div className="w-6 h-6 bg-orange-400 rounded-full flex items-center justify-center text-white text-xs shrink-0">
                    {step}
                  </div>
                  <p className="text-stone-600 text-sm">Instrução detalhada para o passo {step} da receita mágica.</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col pastel-bg pb-20">
      {/* AppBar Customizada com Search */}
      <header className="ghibli-gradient px-6 pt-4 pb-8 shadow-lg sticky top-0 z-50 rounded-b-[40px] space-y-4">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            🍽️ <span className="font-serif">Ghibli Kitchen</span>
          </h1>
          <Star className="text-white w-5 h-5" />
        </div>
        <div className="relative">
          <input 
            type="text" 
            placeholder="Pesquisar receitas mágicas..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-white rounded-2xl py-3 px-12 text-sm shadow-inner focus:outline-none"
          />
          <Star className="absolute left-4 top-3 w-5 h-5 text-orange-300" />
        </div>
      </header>

      <main className="flex-1 overflow-y-auto px-6 py-8 space-y-8">
        {/* SEÇÃO 1: Cabeçalho com saudação */}
        <motion.section 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-1"
        >
          <h2 className="text-3xl font-bold text-stone-800 tracking-tight">
            Bom apetite, fã de Ghibli!
          </h2>
          <p className="text-stone-500 text-lg">
            Descubra receitas mágicas dos filmes
          </p>
        </motion.section>

        {/* SEÇÃO 2: Categorias em destaque */}
        <section className="space-y-4">
          <h3 className="text-xl font-bold text-stone-700">Categorias</h3>
          <div className="flex gap-4 overflow-x-auto pb-4 no-scrollbar -mx-6 px-6">
            {CATEGORIES.map((cat, index) => (
              <motion.div
                key={cat.id}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.1 }}
                className="flex flex-col items-center gap-2 min-w-[100px]"
              >
                <div className="w-16 h-16 rounded-full bg-white shadow-md flex items-center justify-center text-3xl border-2 border-orange-100">
                  {cat.emoji}
                </div>
                <span className="text-xs font-semibold text-stone-600 text-center">
                  {cat.name}
                </span>
              </motion.div>
            ))}
          </div>
        </section>

        {/* SEÇÃO 3: Receitas em Destaque */}
        <section className="space-y-4">
          <h3 className="text-xl font-bold text-stone-700">Receitas em Destaque</h3>
          <div className="grid grid-cols-2 gap-4">
            {filteredRecipes.map((recipe, index) => (
              <motion.div
                key={recipe.id}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.1 }}
                onClick={() => setSelectedRecipe(recipe)}
                className="bg-white rounded-3xl overflow-hidden shadow-md hover:shadow-xl transition-all border border-orange-50 cursor-pointer"
              >
                <div className="relative h-32 overflow-hidden">
                  <img 
                    src={recipe.imageUrl} 
                    alt={recipe.title} 
                    className="w-full h-full object-cover"
                    referrerPolicy="no-referrer"
                  />
                  <div className="absolute inset-0 flex items-center justify-center text-5xl bg-black/20">
                    {recipe.emoji}
                  </div>
                </div>
                <div className="p-4 space-y-2">
                  <h4 className="font-bold text-stone-800 text-sm leading-tight h-10 line-clamp-2">
                    {recipe.title}
                  </h4>
                  <p className="text-[10px] text-stone-400 font-medium uppercase tracking-wider">
                    {recipe.movie}
                  </p>
                  <div className="flex items-center justify-between pt-2">
                    <div className="flex items-center gap-1 text-[10px] text-stone-500 font-bold">
                      <ChefHat className="w-3 h-3 text-orange-400" />
                      {recipe.difficulty}
                    </div>
                    <div className="flex items-center gap-1 text-[10px] text-stone-500 font-bold">
                      <Clock className="w-3 h-3 text-orange-400" />
                      {recipe.time}
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </section>

        {/* SEÇÃO 4: Filmes em Destaque */}
        <section className="space-y-4">
          <h3 className="text-xl font-bold text-stone-700">Filmes em Destaque</h3>
          <div className="flex gap-4 overflow-x-auto pb-4 no-scrollbar -mx-6 px-6">
            {MOVIES.map((movie, index) => (
              <motion.div
                key={movie.id}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 }}
                className="min-w-[160px] bg-white p-4 rounded-2xl shadow-sm border border-orange-100 flex flex-col items-center gap-3"
              >
                <span className="text-4xl">{movie.emoji}</span>
                <span className="text-xs font-bold text-stone-700 text-center line-clamp-1">
                  {movie.title}
                </span>
              </motion.div>
            ))}
          </div>
        </section>
      </main>

      {/* BottomNavigationBar */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-orange-100 px-8 py-3 flex justify-between items-center shadow-[0_-4px_20px_rgba(0,0,0,0.05)] rounded-t-3xl z-50">
        <button 
          onClick={() => setActiveTab(0)}
          className={`flex flex-col items-center gap-1 ${activeTab === 0 ? 'text-orange-500' : 'text-stone-400'}`}
        >
          <Utensils className="w-6 h-6" />
          <span className="text-[10px] font-bold">Receitas</span>
        </button>
        <button 
          onClick={() => setActiveTab(1)}
          className={`flex flex-col items-center gap-1 ${activeTab === 1 ? 'text-orange-500' : 'text-stone-400'}`}
        >
          <Heart className="w-6 h-6" />
          <span className="text-[10px] font-bold">Favoritos</span>
        </button>
        <button 
          onClick={() => setActiveTab(2)}
          className={`flex flex-col items-center gap-1 ${activeTab === 2 ? 'text-orange-500' : 'text-stone-400'}`}
        >
          <User className="w-6 h-6" />
          <span className="text-[10px] font-bold">Perfil</span>
        </button>
      </nav>

      <style>{`
        .no-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .no-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </div>
  );
}
