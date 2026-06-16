import 'package:biblioteca_flutter/models/autor.dart';
import 'package:biblioteca_flutter/services/firebase_crud.dart';
import 'package:flutter/material.dart';

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
  final FirestoreService _service = FirestoreService(); 

  late final TextEditingController _nomeController;
  late final TextEditingController _nacionalidadeController;
  bool _isLoading = false; 

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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final autor = Autor(
        id: widget.autor?.id,
        nome: _nomeController.text.trim(),
        nacionalidade: _nacionalidadeController.text.trim(),
      );

      if (widget.autor == null) {
        await _service.add('autores', autor.toFirestore());
      } else {
        await _service.update('autores', widget.autor!.id!, autor.toFirestore());
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nacionalidadeController,
                decoration: const InputDecoration(labelText: 'Nacionalidade', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _salvar,
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}