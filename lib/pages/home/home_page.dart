import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../livros/livros_page.dart';
import '../categorias/categorias_page.dart';
import '../autores/autores_page.dart';
import '../emprestimos/emprestimos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

enum MenuApp {
  livros,
  categorias,
  autores,
  emprestimos,
}

class _HomePageState extends State<HomePage> {
  MenuApp _menuSelecionado = MenuApp.livros;

  String get _titulo {
    switch (_menuSelecionado) {
      case MenuApp.livros:
        return 'Livros';
      case MenuApp.categorias:
        return 'Categorias';
      case MenuApp.autores:
        return 'Autores';
      case MenuApp.emprestimos:
        return 'Empréstimos';
    }
  }

  Widget get _conteudo {
   switch (_menuSelecionado) {
     case MenuApp.livros:
       return const LivrosPage();
     case MenuApp.categorias:
       return const CategoriasPage();
     case MenuApp.autores:
       return const AutoresPage();
     case MenuApp.emprestimos:
       return const EmprestimosPage();
   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulo),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair',
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            }, 
          )
        ],
      ),
      body: _conteudo,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _menuSelecionado.index,
        onDestinationSelected: (index) {
          setState(() {
            _menuSelecionado = MenuApp.values[index];
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Livros',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categorias',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Autores',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_return_outlined),
            selectedIcon: Icon(Icons.assignment_return),
            label: 'Empréstimos',
          ),
        ],
      ),
    );
  }
}