import 'package:biblioteca_flutter/services/firebase_crud.dart';
import 'package:flutter/material.dart';
import '../../models/livro.dart';
import '../../models/autor.dart';
import '../../models/categoria.dart';

class LivroFormDialog extends StatefulWidget {
  final Livro? livro;
  final List<Categoria> categorias;
  final List<Autor> autores;

  const LivroFormDialog({
    super.key,
    required this.livro,
    required this.categorias,
    required this.autores,
  });

  @override
  State<LivroFormDialog> createState() => _LivroFormDialogState();
}

class _LivroFormDialogState extends State<LivroFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirestoreService _service = FirestoreService();

  late final TextEditingController _tituloController;
  late final TextEditingController _isbnController;
  late final TextEditingController _anoController;
  late final TextEditingController _quantidadeController;

  String? _categoriaSelecionada;
  String? _autorSelecionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final livro = widget.livro;

    _tituloController = TextEditingController(text: livro?.titulo ?? '');
    _isbnController = TextEditingController(text: livro?.isbn ?? '');
    _anoController = TextEditingController(
      text: livro?.anoPublicacao?.toString() ?? '',
    );
    _quantidadeController = TextEditingController(
      text: livro?.quantidade.toString() ?? '1',
    );

    _categoriaSelecionada =
        livro?.categoriaId ??
        (widget.categorias.isNotEmpty ? widget.categorias.first.id : null);
    _autorSelecionado =
        livro?.autorId ??
        (widget.autores.isNotEmpty ? widget.autores.first.id : null);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _isbnController.dispose();
    _anoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSelecionada == null || _autorSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione autor e categoria')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final int novaQtdTotal = int.parse(_quantidadeController.text.trim());
      int novaDisponibilidade;

      if (widget.livro == null) {
        // CASO: Novo Livro -> Disponibilidade é igual ao total
        novaDisponibilidade = novaQtdTotal;
      } else {
        // CASO: Edição -> Recalcula baseada na diferença
        final int antigaQtdTotal = widget.livro!.quantidade;
        final int diff = novaQtdTotal - antigaQtdTotal;

        // Ajusta a disponibilidade antiga com a diferença
        novaDisponibilidade = widget.livro!.quantidadeDisponivel + diff;

        // Segurança: Se a nova disponibilidade for negativa, o usuário tentou
        // reduzir o estoque total abaixo do número de livros que já estão emprestados.
        if (novaDisponibilidade < 0) {
          throw Exception(
            'Você tem livros emprestados! Não pode reduzir o total para $novaQtdTotal.',
          );
        }
      }

      final categoria = widget.categorias.firstWhere(
        (c) => c.id == _categoriaSelecionada,
      );
      final autor = widget.autores.firstWhere((a) => a.id == _autorSelecionado);

      final livro = Livro(
        id: widget.livro?.id ?? '',
        titulo: _tituloController.text.trim(),
        isbn: _isbnController.text.trim(),
        anoPublicacao: int.tryParse(_anoController.text.trim()),
        quantidade: novaQtdTotal,
        quantidadeDisponivel: novaDisponibilidade,
        categoriaId: categoria.id!,
        categoriaNome: categoria.nome,
        autorId: autor.id!,
        autorNome: autor.nome,
      );

      if (widget.livro == null) {
        await _service.add('livros', livro.toFirestore());
      } else {
        await _service.update('livros', widget.livro!.id, livro.toFirestore());
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categorias.isEmpty || widget.autores.isEmpty) {
      return const AlertDialog(
        title: Text('Erro'),
        content: Text('Cadastre autores e categorias primeiro!'),
      );
    }

    return AlertDialog(
      title: Text(widget.livro == null ? 'Novo livro' : 'Editar livro'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _isbnController,
                  decoration: const InputDecoration(
                    labelText: 'ISBN',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _anoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ano',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _categoriaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.categorias
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.nome)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoriaSelecionada = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _autorSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Autor',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.autores
                      .map(
                        (a) =>
                            DropdownMenuItem(value: a.id, child: Text(a.nome)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _autorSelecionado = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _salvar,
          icon: const Icon(Icons.save_outlined),
          label: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
