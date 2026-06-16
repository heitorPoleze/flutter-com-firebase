import 'package:biblioteca_flutter/pages/livros/livro_form_dialog.dart';
import 'package:biblioteca_flutter/services/firebase_crud.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/livro.dart';
import '../../models/autor.dart';
import '../../models/categoria.dart';

class LivrosPage extends StatefulWidget {
  const LivrosPage({super.key});

  @override
  State<LivrosPage> createState() => _LivrosPageState();
}

class _LivrosPageState extends State<LivrosPage> {
  final FirestoreService _service = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _abrirFormulario({Livro? livro}) async {
    try {
      final catSnapshot = await _db.collection('categorias').get();
      final autSnapshot = await _db.collection('autores').get();

      final categorias = catSnapshot.docs
          .map((d) => Categoria.fromFirestore(d.data(), d.id))
          .toList();
      final autores = autSnapshot.docs
          .map((d) => Autor.fromFirestore(d.data(), d.id))
          .toList();

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => LivroFormDialog(
          livro: livro,
          categorias: categorias,
          autores: autores,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
    }
  }

  Future<void> _excluir(Livro livro) async {
    final snapshot = await _db.collection('emprestimos').get();

    bool temEmprestimos = snapshot.docs.any((doc) {
      final itens = doc.data()['itens'] as List<dynamic>? ?? [];
      return itens.any((item) => item['livroId'] == livro.id);
    });

    if (temEmprestimos) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não é possível excluir: este livro possui empréstimos registrados.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir livro'),
        content: Text('Deseja excluir "${livro.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true && livro.id.isNotEmpty) {
      await _service.delete('livros', livro.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getCollection('livros'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          final livros = docs
              .map(
                (doc) => Livro.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          if (livros.isEmpty) {
            return _buildEstadoVazio();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: livros.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final livro = livros[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: Text(livro.titulo),
                  subtitle: Text('${livro.autorNome} • ${livro.categoriaNome}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _abrirFormulario(livro: livro),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _excluir(livro),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo livro'),
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nenhum livro cadastrado.'),
        ],
      ),
    );
  }
}
