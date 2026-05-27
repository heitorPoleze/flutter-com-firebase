import 'package:flutter/material.dart';

import '../../models/emprestimo.dart';
import '../../models/livro.dart';

class EmprestimoFormDialog extends StatefulWidget {
  final List<Livro> livros;

  const EmprestimoFormDialog({
    super.key,
    required this.livros,
  });

  @override
  State<EmprestimoFormDialog> createState() => _EmprestimoFormDialogState();
}

class _EmprestimoFormDialogState extends State<EmprestimoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomePessoaController = TextEditingController();
  final TextEditingController _telefonePessoaController =
      TextEditingController();
  final TextEditingController _documentoPessoaController =
      TextEditingController();

  final TextEditingController _livroController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _dataPrevistaController =
      TextEditingController();

  int? _livroSelecionado;
  String? _erroLivro;

  @override
  void initState() {
    super.initState();

    if (widget.livros.isNotEmpty) {
      final primeiroLivro = widget.livros.first;
      _livroSelecionado = primeiroLivro.idlivro;
      _livroController.text = _labelLivro(primeiroLivro);
    }

    _quantidadeController.text = '1';
    _dataPrevistaController.text = _formatarDataParaApi(
      DateTime.now().add(const Duration(days: 7)),
    );

    _livroController.addListener(_validarTextoLivroDigitado);
  }

  @override
  void dispose() {
    _livroController.removeListener(_validarTextoLivroDigitado);

    _nomePessoaController.dispose();
    _telefonePessoaController.dispose();
    _documentoPessoaController.dispose();
    _livroController.dispose();
    _quantidadeController.dispose();
    _dataPrevistaController.dispose();

    super.dispose();
  }

  String _labelLivro(Livro livro) {
    return '${livro.titulo} - disponível: ${livro.quantidadeDisponivel}';
  }

  Livro? _buscarLivroPorId(int? id) {
    if (id == null) {
      return null;
    }

    for (final livro in widget.livros) {
      if (livro.idlivro == id) {
        return livro;
      }
    }

    return null;
  }

  Livro? _buscarLivroPorLabel(String label) {
    final texto = label.trim();

    if (texto.isEmpty) {
      return null;
    }

    for (final livro in widget.livros) {
      if (_labelLivro(livro) == texto) {
        return livro;
      }
    }

    return null;
  }

  Livro? get _livroAtual {
    return _buscarLivroPorId(_livroSelecionado);
  }

  void _validarTextoLivroDigitado() {
    final livroEncontrado = _buscarLivroPorLabel(_livroController.text);

    if (livroEncontrado != null) {
      if (_livroSelecionado != livroEncontrado.idlivro || _erroLivro != null) {
        setState(() {
          _livroSelecionado = livroEncontrado.idlivro;
          _erroLivro = null;
        });
      }

      return;
    }

    if (_livroSelecionado != null && _livroController.text.trim().isNotEmpty) {
      setState(() {
        _livroSelecionado = null;
      });
    }
  }

  String _formatarDataParaApi(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');

    return '$ano-$mes-$dia';
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: hoje.add(const Duration(days: 7)),
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 5),
    );

    if (data == null) {
      return;
    }

    setState(() {
      _dataPrevistaController.text = _formatarDataParaApi(data);
    });
  }

  void _salvar() {
    if (_livroSelecionado == null) {
      setState(() {
        _erroLivro = 'Selecione um livro da lista';
      });

      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      EmprestimoPayload(
        livroId: _livroSelecionado!,
        qtd: int.parse(_quantidadeController.text.trim()),
        dataPrevistaDevolucao: _dataPrevistaController.text.trim(),
        nomePessoa: _nomePessoaController.text.trim(),
        telefonePessoa: _telefonePessoaController.text.trim(),
        documentoPessoa: _documentoPessoaController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final livroAtual = _livroAtual;

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
                  decoration: const InputDecoration(
                    labelText: 'Nome de quem alugou',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final texto = value?.trim() ?? '';

                    if (texto.isEmpty) {
                      return 'Informe o nome da pessoa';
                    }

                    if (texto.length < 3) {
                      return 'Informe um nome válido';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonePessoaController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _documentoPessoaController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Documento',
                    prefixIcon: Icon(Icons.credit_card_outlined),
                    border: OutlineInputBorder(),
                    helperText: 'Pode ser CPF, matrícula ou outro documento',
                  ),
                ),
                const SizedBox(height: 12),

                // Campo pesquisável de livro
                DropdownMenu<int>(
                  controller: _livroController,
                  label: const Text('Livro'),
                  hintText: 'Digite para procurar o livro',
                  expandedInsets: EdgeInsets.zero,
                  menuHeight: 360,
                  enableFilter: true,
                  enableSearch: true,
                  requestFocusOnTap: true,
                  initialSelection: _livroSelecionado,
                  leadingIcon: const Icon(Icons.menu_book_outlined),
                  errorText: _erroLivro,
                  dropdownMenuEntries: widget.livros.map((livro) {
                    return DropdownMenuEntry<int>(
                      value: livro.idlivro,
                      label: _labelLivro(livro),
                    );
                  }).toList(),
                  onSelected: (value) {
                    final livro = _buscarLivroPorId(value);

                    setState(() {
                      _livroSelecionado = value;
                      _erroLivro = null;

                      if (livro != null) {
                        _livroController.text = _labelLivro(livro);
                      }
                    });
                  },
                ),

                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantidade',
                    border: const OutlineInputBorder(),
                    helperText: livroAtual == null
                        ? 'Selecione um livro para validar a quantidade'
                        : 'Disponível: ${livroAtual.quantidadeDisponivel}',
                  ),
                  validator: (value) {
                    final qtd = int.tryParse(value ?? '');

                    if (qtd == null || qtd <= 0) {
                      return 'Informe uma quantidade válida';
                    }

                    final livro = _livroAtual;

                    if (livro != null && qtd > livro.quantidadeDisponivel) {
                      return 'Quantidade maior que o estoque disponível';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dataPrevistaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Data prevista de devolução',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _selecionarData,
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a data prevista';
                    }

                    return null;
                  },
                  onTap: _selecionarData,
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