import 'package:flutter/material.dart';

import '../../models/autor.dart';
import '../../services/api_service.dart';
import 'autor_form_dialog.dart';

class AutoresPage extends StatefulWidget {
  const AutoresPage({super.key});

  @override
  State<AutoresPage> createState() => _AutoresPageState();
}

class _AutoresPageState extends State<AutoresPage> {
  final ApiService _apiService = ApiService();

  List<Autor> _autores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
    });

    try {
      final autores = await _apiService.getAutores();

      setState(() {
        _autores = autores;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _abrirFormulario({Autor? autor}) async {
    final payload = await showDialog<AutorPayload>(
      context: context,
      builder: (_) => AutorFormDialog(autor: autor),
    );

    if (payload == null) {
      return;
    }

    try {
      if (autor == null) {
        await _apiService.criarAutor(payload);
      } else {
        await _apiService.atualizarAutor(autor.idautor, payload);
      }

      await _carregar();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _excluir(Autor autor) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir autor'),
        content: Text('Deseja excluir "${autor.nome}"?'),
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

    if (confirmar != true) {
      return;
    }

    try {
      await _apiService.excluirAutor(autor.idautor);
      await _carregar();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _autores.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.person_outline,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text('Nenhum autor cadastrado.'),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _autores.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final autor = _autores[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(autor.nome),
                      subtitle: Text(autor.nacionalidade ?? 'Sem nacionalidade'),
                      trailing: Wrap(
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
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo autor'),
      ),
    );
  }
}