import 'package:biblioteca_flutter/services/firebase_crud.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/autor.dart';
import 'autor_form_dialog.dart';

class AutoresPage extends StatefulWidget {
  const AutoresPage({super.key});

  @override
  State<AutoresPage> createState() => _AutoresPageState();
}

class _AutoresPageState extends State<AutoresPage> {
  final FirestoreService _service = FirestoreService();

  Future<void> _abrirFormulario({Autor? autor}) async {
    
    await showDialog(
      context: context,
      builder: (_) => AutorFormDialog(autor: autor),
    );
    
  }

  Future<void> _excluir(Autor autor) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir autor'),
        content: Text('Deseja excluir "${autor.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmar == true && autor.id != null) {
      await _service.delete('autores', autor.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getCollection('autores'),
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

          final autores = docs.map((doc) {
            return Autor.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: autores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final autor = autores[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(autor.nome),
                  subtitle: Text(autor.nacionalidade ?? 'Sem nacionalidade'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _abrirFormulario(autor: autor),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _excluir(autor),
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
        label: const Text('Novo autor'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.person_outline, size: 72, color: Colors.grey),
        SizedBox(height: 16),
        Center(child: Text('Nenhum autor cadastrado.')),
      ],
    );
  }
}