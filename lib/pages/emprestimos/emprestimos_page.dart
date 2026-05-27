import 'package:flutter/material.dart';

import '../../models/emprestimo.dart';
import '../../models/livro.dart';
import '../../services/api_service.dart';
import '../../widgets/painel_busca_filtros.dart';
import 'emprestimo_form_dialog.dart';

class EmprestimosPage extends StatefulWidget {
  const EmprestimosPage({
    super.key,
  });

  @override
  State<EmprestimosPage> createState() => _EmprestimosPageState();
}

class _EmprestimosPageState extends State<EmprestimosPage> {
  final ApiService _apiService = ApiService();

  final TextEditingController _pesquisaController = TextEditingController();
  final TextEditingController _statusFiltroController = TextEditingController();

  List<Emprestimo> _emprestimos = [];
  List<Livro> _livros = [];

  bool _loading = true;
  String _textoPesquisa = '';
  String _statusFiltro = 'TODOS';

  @override
  void initState() {
    super.initState();

    _statusFiltroController.text = 'Todos os status';
    _carregarDados();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    _statusFiltroController.dispose();
    super.dispose();
  }

  List<Emprestimo> get _emprestimosFiltrados {
    return _emprestimos.where((emprestimo) {
      final texto = _textoPesquisa.toLowerCase().trim();
      final livros = _livrosDoEmprestimo(emprestimo).toLowerCase();

      final correspondePesquisa = texto.isEmpty ||
          emprestimo.nomePessoa.toLowerCase().contains(texto) ||
          (emprestimo.telefonePessoa ?? '').toLowerCase().contains(texto) ||
          (emprestimo.documentoPessoa ?? '').toLowerCase().contains(texto) ||
          emprestimo.status.toLowerCase().contains(texto) ||
          livros.contains(texto) ||
          emprestimo.dataEmprestimo.toLowerCase().contains(texto) ||
          emprestimo.dataPrevistaDevolucao.toLowerCase().contains(texto);

      final correspondeStatus =
          _statusFiltro == 'TODOS' || emprestimo.status == _statusFiltro;

      return correspondePesquisa && correspondeStatus;
    }).toList();
  }

  int get _totalAbertos {
    return _emprestimos
        .where((emprestimo) => emprestimo.status == 'ABERTO')
        .length;
  }

  int get _totalDevolvidos {
    return _emprestimos
        .where((emprestimo) => emprestimo.status == 'DEVOLVIDO')
        .length;
  }

  int get _totalAtrasados {
    return _emprestimos
        .where((emprestimo) => emprestimo.status == 'ATRASADO')
        .length;
  }

  Future<void> _carregarDados() async {
    setState(() {
      _loading = true;
    });

    try {
      final emprestimos = await _apiService.getEmprestimos();
      final livros = await _apiService.getLivros();

      setState(() {
        _emprestimos = emprestimos;
        _livros = livros;
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

  void _limparBusca() {
    setState(() {
      _textoPesquisa = '';
      _pesquisaController.clear();
    });
  }

  void _limparFiltros() {
    setState(() {
      _textoPesquisa = '';
      _statusFiltro = 'TODOS';

      _pesquisaController.clear();
      _statusFiltroController.text = 'Todos os status';
    });
  }

  Future<void> _novoEmprestimo() async {
    final livrosDisponiveis = _livros
        .where((livro) => livro.quantidade > 0)
        .toList();

    if (livrosDisponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não existem livros disponíveis para empréstimo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final payload = await showDialog<EmprestimoPayload>(
      context: context,
      builder: (_) => EmprestimoFormDialog(
        livros: livrosDisponiveis,
      ),
    );

    if (payload == null) {
      return;
    }

    try {
      await _apiService.criarEmprestimo(payload);
      await _carregarDados();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empréstimo criado com sucesso.'),
        ),
      );
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

  Future<void> _devolver(Emprestimo emprestimo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Devolver empréstimo'),
        content: Text(
          'Deseja confirmar a devolução do empréstimo #${emprestimo.idemprestimo}?\n\n'
          'Pessoa: ${emprestimo.nomePessoa}\n'
          'Livros: ${_livrosDoEmprestimo(emprestimo)}',
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

    if (confirmar != true) {
      return;
    }

    try {
      await _apiService.devolverEmprestimo(emprestimo.idemprestimo);
      await _carregarDados();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empréstimo devolvido com sucesso.'),
        ),
      );
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

  String _valorOuTraco(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return '-';
    }

    return valor;
  }

  String _livrosDoEmprestimo(Emprestimo emprestimo) {
    if (emprestimo.itens.isEmpty) {
      return 'Nenhum livro informado';
    }

    return emprestimo.itens
        .map((item) => '${item.livroNome} (${item.qtd})')
        .join(', ');
  }

  String _formatarData(String? data) {
    if (data == null || data.trim().isEmpty) {
      return '-';
    }

    final dataConvertida = DateTime.tryParse(data);

    if (dataConvertida == null) {
      return data;
    }

    final dia = dataConvertida.day.toString().padLeft(2, '0');
    final mes = dataConvertida.month.toString().padLeft(2, '0');
    final ano = dataConvertida.year.toString().padLeft(4, '0');

    return '$dia/$mes/$ano';
  }

  String _textoStatus(String status) {
    switch (status) {
      case 'DEVOLVIDO':
        return 'Devolvido';
      case 'ATRASADO':
        return 'Atrasado';
      default:
        return 'Aberto';
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'DEVOLVIDO':
        return Colors.green.shade600;
      case 'ATRASADO':
        return Colors.red.shade600;
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _iconeStatus(String status) {
    switch (status) {
      case 'DEVOLVIDO':
        return Icons.check_circle_outline;
      case 'ATRASADO':
        return Icons.warning_amber_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }

  Widget _buildCabecalho() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empréstimos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF20212A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Acompanhe os livros emprestados, devoluções e prazos.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF696B78),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_emprestimos.length} empréstimo(s)',
              style: const TextStyle(
                color: Color(0xFF37448F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoGeral() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildResumoCard(
            titulo: 'Total',
            valor: _emprestimos.length.toString(),
            icon: Icons.assignment_outlined,
            cor: Colors.indigo,
          ),
          _buildResumoCard(
            titulo: 'Abertos',
            valor: _totalAbertos.toString(),
            icon: Icons.schedule_outlined,
            cor: Colors.orange,
          ),
          _buildResumoCard(
            titulo: 'Devolvidos',
            valor: _totalDevolvidos.toString(),
            icon: Icons.check_circle_outline,
            cor: Colors.green,
          ),
          _buildResumoCard(
            titulo: 'Atrasados',
            valor: _totalAtrasados.toString(),
            icon: Icons.warning_amber_outlined,
            cor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCard({
    required String titulo,
    required String valor,
    required IconData icon,
    required MaterialColor cor,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFE3E5EF)),
        ),
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
            child: Icon(
              icon,
              color: cor.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF20212A),
                  ),
                ),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF696B78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChipsAtivos() {
    return [
      if (_textoPesquisa.trim().isNotEmpty)
        InputChip(
          avatar: const Icon(Icons.search, size: 18),
          label: Text('Busca: $_textoPesquisa'),
          onDeleted: _limparBusca,
        ),
      if (_statusFiltro != 'TODOS')
        InputChip(
          avatar: Icon(
            _iconeStatus(_statusFiltro),
            size: 18,
          ),
          label: Text('Status: ${_textoStatus(_statusFiltro)}'),
          onDeleted: () {
            setState(() {
              _statusFiltro = 'TODOS';
              _statusFiltroController.text = 'Todos os status';
            });
          },
        ),
    ];
  }

  Widget _buildFiltroStatus() {
    return SizedBox(
      width: 320,
      child: DropdownMenu<String>(
        controller: _statusFiltroController,
        label: const Text('Status'),
        hintText: 'Digite para procurar',
        width: 320,
        menuHeight: 260,
        enableFilter: true,
        enableSearch: true,
        requestFocusOnTap: true,
        initialSelection: _statusFiltro,
        dropdownMenuEntries: const <DropdownMenuEntry<String>>[
          DropdownMenuEntry<String>(
            value: 'TODOS',
            label: 'Todos os status',
          ),
          DropdownMenuEntry<String>(
            value: 'ABERTO',
            label: 'Aberto',
          ),
          DropdownMenuEntry<String>(
            value: 'DEVOLVIDO',
            label: 'Devolvido',
          ),
          DropdownMenuEntry<String>(
            value: 'ATRASADO',
            label: 'Atrasado',
          ),
        ],
        onSelected: (value) {
          setState(() {
            _statusFiltro = value ?? 'TODOS';

            if (_statusFiltro == 'TODOS') {
              _statusFiltroController.text = 'Todos os status';
            }
          });
        },
      ),
    );
  }

  Widget _buildPainelFiltros() {
    return PainelBuscaFiltros(
      controllerBusca: _pesquisaController,
      titulo: 'Busca e filtros',
      hintBusca: 'Digite pessoa, documento, telefone, livro ou data',
      textoResultado:
          'Resultado: ${_emprestimosFiltrados.length} de ${_emprestimos.length} empréstimo(s)',
      possuiBuscaDigitada: _textoPesquisa.trim().isNotEmpty,
      onBuscaAlterada: (value) {
        setState(() {
          _textoPesquisa = value;
        });
      },
      onLimparBusca: _limparBusca,
      onLimparFiltros: _limparFiltros,
      filtros: [
        _buildFiltroStatus(),
      ],
      chipsAtivos: _buildChipsAtivos(),
    );
  }

  Widget _buildStatusChip(Emprestimo emprestimo) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _corStatus(emprestimo.status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconeStatus(emprestimo.status),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            _textoStatus(emprestimo.status),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLinha({
    required IconData icon,
    required String texto,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: const Color(0xFF696B78),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Color(0xFF4D4F5C),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniResumo({
    required String label,
    required String valor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF55586A),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $valor',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3F4150),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmprestimoCard(Emprestimo emprestimo) {
    return Card(
      elevation: 0.8,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(
          color: Color(0xFFE3E5EF),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EBFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                emprestimo.idemprestimo.toString(),
                style: const TextStyle(
                  color: Color(0xFF37448F),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Empréstimo #${emprestimo.idemprestimo}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF20212A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoLinha(
                    icon: Icons.person_outline,
                    texto: 'Pessoa: ${emprestimo.nomePessoa}',
                  ),
                  _buildInfoLinha(
                    icon: Icons.phone_outlined,
                    texto:
                        'Telefone: ${_valorOuTraco(emprestimo.telefonePessoa)}',
                  ),
                  _buildInfoLinha(
                    icon: Icons.badge_outlined,
                    texto:
                        'Documento: ${_valorOuTraco(emprestimo.documentoPessoa)}',
                  ),
                  _buildInfoLinha(
                    icon: Icons.menu_book_outlined,
                    texto: 'Livros: ${_livrosDoEmprestimo(emprestimo)}',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMiniResumo(
                        label: 'Empréstimo',
                        valor: _formatarData(emprestimo.dataEmprestimo),
                        icon: Icons.calendar_today_outlined,
                      ),
                      _buildMiniResumo(
                        label: 'Previsão',
                        valor: _formatarData(
                          emprestimo.dataPrevistaDevolucao,
                        ),
                        icon: Icons.event_available_outlined,
                      ),
                      _buildMiniResumo(
                        label: 'Devolução',
                        valor: _formatarData(emprestimo.dataDevolucao),
                        icon: Icons.assignment_turned_in_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusChip(emprestimo),
                if (!emprestimo.devolvido) ...[
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => _devolver(emprestimo),
                    icon: const Icon(Icons.assignment_turned_in_outlined),
                    label: const Text('Devolver'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.assignment_return_outlined,
            size: 76,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum empréstimo encontrado com os filtros informados.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF696B78),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final emprestimosFiltrados = _emprestimosFiltrados;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
          children: [
            _buildCabecalho(),
            _buildResumoGeral(),
            _buildPainelFiltros(),
            if (emprestimosFiltrados.isEmpty)
              _buildEstadoVazio()
            else
              ...emprestimosFiltrados.map(_buildEmprestimoCard),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoEmprestimo,
        icon: const Icon(Icons.add),
        label: const Text('Novo empréstimo'),
      ),
    );
  }
}