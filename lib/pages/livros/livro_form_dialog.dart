import 'package:flutter/material.dart';

import '../../models/autor.dart';
import '../../models/categoria.dart';
import '../../models/livro.dart';

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

  late final TextEditingController _tituloController;
  late final TextEditingController _isbnController;
  late final TextEditingController _anoController;
  late final TextEditingController _quantidadeController;

  int? _categoriaSelecionada;
  int? _autorSelecionado;

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
        livro?.categoriaId ?? widget.categorias.first.idcategoria;
    _autorSelecionado = livro?.autorId ?? widget.autores.first.idautor;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _isbnController.dispose();
    _anoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = LivroPayload(
      titulo: _tituloController.text.trim(),
      isbn: _isbnController.text.trim(),
      anoPublicacao: int.parse(_anoController.text.trim()),
      quantidade: int.parse(_quantidadeController.text.trim()),
      categoriaId: _categoriaSelecionada!,
      autorId: _autorSelecionado!,
    );

    Navigator.pop(context, payload);
  }

  @override
  Widget build(BuildContext context) {
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o título';
                    }

                    return null;
                  },
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
                    labelText: 'Ano de publicação',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final number = int.tryParse(value ?? '');

                    if (number == null) {
                      return 'Informe um ano válido';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final number = int.tryParse(value ?? '');

                    if (number == null || number < 0) {
                      return 'Informe uma quantidade válida';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _categoriaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.categorias.map((categoria) {
                    return DropdownMenuItem<int>(
                      value: categoria.idcategoria,
                      child: Text(categoria.nome),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaSelecionada = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione uma categoria';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _autorSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Autor',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.autores.map((autor) {
                    return DropdownMenuItem<int>(
                      value: autor.idautor,
                      child: Text(autor.nome),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _autorSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione um autor';
                    }

                    return null;
                  },
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
          onPressed: _salvar,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}