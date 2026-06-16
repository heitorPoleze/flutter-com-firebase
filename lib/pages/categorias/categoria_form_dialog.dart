import 'package:biblioteca_flutter/services/firebase_crud.dart';
import 'package:flutter/material.dart';
import '../../models/categoria.dart';

class CategoriaFormDialog extends StatefulWidget {
  final Categoria? categoria;

  const CategoriaFormDialog({
    super.key,
    required this.categoria,
  });

  @override
  State<CategoriaFormDialog> createState() => _CategoriaFormDialogState();
}

class _CategoriaFormDialogState extends State<CategoriaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirestoreService _service = FirestoreService();

  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.categoria?.nome ?? '');
    _descricaoController = TextEditingController(
      text: widget.categoria?.descricao ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final categoria = Categoria(
        id: widget.categoria?.id,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
      );

      if (widget.categoria == null) {
        await _service.add('categorias', categoria.toFirestore());
      } else {
        await _service.update('categorias', widget.categoria!.id!, categoria.toFirestore());
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
      title: Text(widget.categoria == null ? 'Nova categoria' : 'Editar categoria'),
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
                validator: (value) => (value == null || value.trim().isEmpty) 
                    ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
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