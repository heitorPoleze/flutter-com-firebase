import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/emprestimo.dart';
import '../../models/livro.dart';

class EmprestimoFormDialog extends StatefulWidget {
  final List<Livro> livros;

  const EmprestimoFormDialog({super.key, required this.livros});

  @override
  State<EmprestimoFormDialog> createState() => _EmprestimoFormDialogState();
}

class _EmprestimoFormDialogState extends State<EmprestimoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _nomePessoaController = TextEditingController();
  final TextEditingController _telefonePessoaController = TextEditingController();
  final TextEditingController _documentoPessoaController = TextEditingController();
  final TextEditingController _livroController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController(text: '1');
  final TextEditingController _dataPrevistaController = TextEditingController();

  String? _livroSelecionadoId;
  String? _erroLivro;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataPrevistaController.text = _formatarData(DateTime.now().add(const Duration(days: 7)));
  }

  @override
  void dispose() {
    _nomePessoaController.dispose();
    _telefonePessoaController.dispose();
    _documentoPessoaController.dispose();
    _livroController.dispose();
    _quantidadeController.dispose();
    _dataPrevistaController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) => "${data.year}-${data.month.toString().padLeft(2,'0')}-${data.day.toString().padLeft(2,'0')}";

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: hoje.add(const Duration(days: 7)),
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 5),
    );

    if (data != null) {
      setState(() => _dataPrevistaController.text = _formatarData(data));
    }
  }

  Future<void> _salvar() async {
    if (_livroSelecionadoId == null) {
      setState(() => _erroLivro = 'Selecione um livro');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final int qtd = int.parse(_quantidadeController.text.trim());
      final livro = widget.livros.firstWhere((l) => l.id == _livroSelecionadoId);

      final novoEmprestimo = Emprestimo(
        nomePessoa: _nomePessoaController.text.trim(),
        telefonePessoa: _telefonePessoaController.text.trim(),
        documentoPessoa: _documentoPessoaController.text.trim(),
        dataEmprestimo: _formatarData(DateTime.now()),
        dataPrevistaDevolucao: _dataPrevistaController.text.trim(),
        status: 'ABERTO',
        itens: [EmprestimoItem(livroId: livro.id, livroNome: livro.titulo, qtd: qtd)],
      );

      final batch = _db.batch();
      
      final empRef = _db.collection('emprestimos').doc();
      batch.set(empRef, novoEmprestimo.toFirestore());

      final livroRef = _db.collection('livros').doc(livro.id);
      batch.update(livroRef, {
        'quantidade_disponivel': FieldValue.increment(-qtd) 
      });

      await batch.commit();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo empréstimo'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nomePessoaController,
                  decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.badge_outlined), border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _telefonePessoaController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _documentoPessoaController,
                        decoration: const InputDecoration(labelText: 'Documento', prefixIcon: Icon(Icons.credit_card_outlined), border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownMenu<String>(
                  controller: _livroController,
                  label: const Text('Livro'),
                  expandedInsets: EdgeInsets.zero,
                  errorText: _erroLivro,
                  dropdownMenuEntries: widget.livros.map((livro) => DropdownMenuEntry<String>(
                    value: livro.id,
                    label: '${livro.titulo} (Disp: ${livro.quantidadeDisponivel})',
                  )).toList(),
                  onSelected: (value) => setState(() {
                    _livroSelecionadoId = value;
                    _erroLivro = null;
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()),
                        validator: (value) {
                          final qtd = int.tryParse(value ?? '');
                          final livro = _livroSelecionadoId != null 
                              ? widget.livros.firstWhere((l) => l.id == _livroSelecionadoId) 
                              : null;
                          if (qtd == null || qtd <= 0) return 'Inválido';
                          if (livro != null && qtd > livro.quantidadeDisponivel) return 'Estoque insuficiente';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _dataPrevistaController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Data devolução',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: _selecionarData),
                        ),
                        onTap: _selecionarData,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton.icon(
          onPressed: _isLoading ? null : _salvar,
          icon: const Icon(Icons.save_outlined),
          label: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Salvar'),
        ),
      ],
    );
  }
}