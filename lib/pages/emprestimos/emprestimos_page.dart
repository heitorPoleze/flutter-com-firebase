import 'package:biblioteca_flutter/services/firebase_crud.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/emprestimo.dart';
import '../../models/livro.dart';
import '../../widgets/painel_busca_filtros.dart';
import 'emprestimo_form_dialog.dart';

class EmprestimosPage extends StatefulWidget {
  const EmprestimosPage({super.key});

  @override
  State<EmprestimosPage> createState() => _EmprestimosPageState();
}

class _EmprestimosPageState extends State<EmprestimosPage> {
  final FirestoreService _service = FirestoreService();

  final TextEditingController _pesquisaController = TextEditingController();
  final TextEditingController _statusFiltroController = TextEditingController();

  String _textoPesquisa = '';
  String _statusFiltro = 'TODOS';

  @override
  void initState() {
    super.initState();
    _statusFiltroController.text = 'Todos os status';
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    _statusFiltroController.dispose();
    super.dispose();
  }

  Future<void> _devolver(Emprestimo emprestimo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Devolver empréstimo'),
        content: Text(
          'Confirmar devolução do empréstimo #${emprestimo.id}?\n\n'
          'Pessoa: ${emprestimo.nomePessoa}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.assignment_turned_in_outlined),
            label: const Text('Devolver'),
          ),
        ],
      ),
    );

    if (confirmar != true || emprestimo.id == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      final empRef = FirebaseFirestore.instance
          .collection('emprestimos')
          .doc(emprestimo.id);
      batch.update(empRef, {
        'status': 'DEVOLVIDO',
        'dataDevolucao': DateTime.now().toIso8601String(),
      });

      for (var item in emprestimo.itens) {
        final livroRef = FirebaseFirestore.instance
            .collection('livros')
            .doc(item.livroId);
        batch.update(livroRef, {
          'quantidade_disponivel': FieldValue.increment(item.qtd),
        });
      }

      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Empréstimo devolvido!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _novoEmprestimo() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('livros')
        .where('quantidade_disponivel', isGreaterThan: 0)
        .get();

    final livrosDisponiveis = querySnapshot.docs
        .map((doc) => Livro.fromFirestore(doc.data(), doc.id))
        .toList();

    if (livrosDisponiveis.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem livros disponíveis.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => EmprestimoFormDialog(livros: livrosDisponiveis),
    );
  }

  String _formatarData(String? data) {
    if (data == null || data.isEmpty) return '-';
    final dt = DateTime.tryParse(data);
    return dt != null
        ? "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}"
        : data;
  }

  String _textoStatus(String status) => status == 'DEVOLVIDO'
      ? 'Devolvido'
      : (status == 'ATRASADO' ? 'Atrasado' : 'Aberto');

  Color _corStatus(String status) => status == 'DEVOLVIDO'
      ? Colors.green.shade600
      : (status == 'ATRASADO' ? Colors.red.shade600 : Colors.orange.shade700);

  IconData _iconeStatus(String status) => status == 'DEVOLVIDO'
      ? Icons.check_circle_outline
      : (status == 'ATRASADO'
            ? Icons.warning_amber_outlined
            : Icons.schedule_outlined);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getCollection('emprestimos'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final emprestimos = docs
              .map(
                (d) => Emprestimo.fromFirestore(
                  d.data() as Map<String, dynamic>,
                  d.id,
                ),
              )
              .toList();

          final filtrados = emprestimos.where((e) {
            final t = _textoPesquisa.toLowerCase();
            final matchTexto =
                t.isEmpty ||
                e.nomePessoa.toLowerCase().contains(t) ||
                e.itens.any((i) => i.livroNome.toLowerCase().contains(t));
            final matchStatus =
                _statusFiltro == 'TODOS' || e.status == _statusFiltro;
            return matchTexto && matchStatus;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
            children: [
              _buildCabecalho(emprestimos.length),
              _buildResumoGeral(emprestimos),
              _buildPainelFiltros(emprestimos.length, filtrados.length),
              if (filtrados.isEmpty)
                _buildEstadoVazio()
              else
                ...filtrados.map(_buildEmprestimoCard),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoEmprestimo,
        icon: const Icon(Icons.add),
        label: const Text('Novo empréstimo'),
      ),
    );
  }

  Widget _buildCabecalho(int total) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Empréstimos',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              Text('Acompanhe livros, devoluções e prazos.'),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$total empréstimo(s)',
            style: const TextStyle(
              color: Color(0xFF37448F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildResumoGeral(List<Emprestimo> list) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildResumoCard(
            'Total',
            list.length.toString(),
            Icons.assignment_outlined,
            Colors.indigo,
          ),
          _buildResumoCard(
            'Abertos',
            list.where((e) => e.status == 'ABERTO').length.toString(),
            Icons.schedule_outlined,
            Colors.orange,
          ),
          _buildResumoCard(
            'Devolvidos',
            list.where((e) => e.status == 'DEVOLVIDO').length.toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
          _buildResumoCard(
            'Atrasados',
            list.where((e) => e.status == 'ATRASADO').length.toString(),
            Icons.warning_amber_outlined,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCard(
    String titulo,
    String valor,
    IconData icon,
    MaterialColor cor,
  ) => Container(
    width: 180,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE3E5EF)),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cor.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: cor.shade700),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valor,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              titulo,
              style: const TextStyle(fontSize: 13, color: Color(0xFF696B78)),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildPainelFiltros(int total, int resultado) => PainelBuscaFiltros(
    controllerBusca: _pesquisaController,
    titulo: 'Busca e filtros',
    hintBusca: 'Digite pessoa, documento ou livro',
    textoResultado: 'Resultado: $resultado de $total empréstimo(s)',
    possuiBuscaDigitada: _textoPesquisa.isNotEmpty,
    onBuscaAlterada: (v) => setState(() => _textoPesquisa = v),
    onLimparBusca: () => setState(() {
      _textoPesquisa = '';
      _pesquisaController.clear();
    }),
    onLimparFiltros: () => setState(() {
      _textoPesquisa = '';
      _statusFiltro = 'TODOS';
      _pesquisaController.clear();
      _statusFiltroController.text = 'Todos os status';
    }),
    filtros: [
      SizedBox(
        width: 320,
        child: DropdownMenu<String>(
          controller: _statusFiltroController,
          label: const Text('Status'),
          initialSelection: _statusFiltro,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'TODOS', label: 'Todos'),
            DropdownMenuEntry(value: 'ABERTO', label: 'Aberto'),
            DropdownMenuEntry(value: 'DEVOLVIDO', label: 'Devolvido'),
            DropdownMenuEntry(value: 'ATRASADO', label: 'Atrasado'),
          ],
          onSelected: (v) => setState(() => _statusFiltro = v ?? 'TODOS'),
        ),
      ),
    ],
    chipsAtivos: [
      if (_textoPesquisa.isNotEmpty)
        InputChip(
          label: Text('Busca: $_textoPesquisa'),
          onDeleted: () => setState(() => _textoPesquisa = ''),
        ),
      if (_statusFiltro != 'TODOS')
        InputChip(
          label: Text('Status: $_statusFiltro'),
          onDeleted: () => setState(() => _statusFiltro = 'TODOS'),
        ),
    ],
  );

  Widget _buildEmprestimoCard(Emprestimo emp) => Card(
    elevation: 0.8,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: Color(0xFFE3E5EF)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.assignment, color: Color(0xFF37448F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empréstimo #${emp.id?.substring(0, 6) ?? '...'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('Pessoa: ${emp.nomePessoa}'),
                Text(
                  'Livros: ${emp.itens.map((i) => "${i.livroNome} (${i.qtd})").join(', ')}',
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(_formatarData(emp.dataEmprestimo))),
                    Chip(label: Text(_formatarData(emp.dataPrevistaDevolucao))),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _corStatus(emp.status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconeStatus(emp.status),
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _textoStatus(emp.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (emp.status != 'DEVOLVIDO') ...[
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => _devolver(emp),
                  child: const Text('Devolver'),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildEstadoVazio() => const Padding(
    padding: EdgeInsets.only(top: 80),
    child: Column(
      children: [
        Icon(Icons.assignment_return_outlined, size: 76, color: Colors.grey),
        Text('Nenhum empréstimo encontrado.'),
      ],
    ),
  );
}
