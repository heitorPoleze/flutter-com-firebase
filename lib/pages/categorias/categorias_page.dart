import 'package:biblioteca_flutter/services/firebase_crud.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/categoria.dart';
import 'categoria_form_dialog.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  final FirestoreService _service = FirestoreService();

  Future<void> _abrirFormulario({Categoria? categoria}) async {
    await showDialog(
      context: context,
      builder: (_) => CategoriaFormDialog(categoria: categoria),
    );
  }

  Future<void> _excluir(Categoria categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Deseja excluir "${categoria.nome}"?'),
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

    if (confirmar == true && categoria.id != null) {
      await _service.delete('categorias', categoria.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getCollection('categorias'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          final categorias = docs.map((doc) {
            return Categoria.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categorias.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final categoria = categorias[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(categoria.nome),
                  subtitle: Text(categoria.descricao ?? 'Sem descrição'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _abrirFormulario(categoria: categoria),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _excluir(categoria),
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
        label: const Text('Nova categoria'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.category_outlined, size: 72, color: Colors.grey),
        SizedBox(height: 16),
        Center(child: Text('Nenhuma categoria cadastrada.')),
      ],
    );
  }
}