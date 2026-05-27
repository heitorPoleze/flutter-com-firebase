import 'package:flutter/material.dart';

import '../../models/autor.dart';

class AutorFormDialog extends StatefulWidget {
  final Autor? autor;

  const AutorFormDialog({
    super.key,
    required this.autor,
  });

  @override
  State<AutorFormDialog> createState() => _AutorFormDialogState();
}

class _AutorFormDialogState extends State<AutorFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _nacionalidadeController;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.autor?.nome ?? '');
    _nacionalidadeController = TextEditingController(
      text: widget.autor?.nacionalidade ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nacionalidadeController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      AutorPayload(
        nome: _nomeController.text.trim(),
        nacionalidade: _nacionalidadeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.autor == null ? 'Novo autor' : 'Editar autor'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nacionalidadeController,
                decoration: const InputDecoration(
                  labelText: 'Nacionalidade',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}