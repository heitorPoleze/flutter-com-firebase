// import 'package:flutter/material.dart';

// import '../../models/autor.dart';
// import '../../models/categoria.dart';
// import '../../models/livro.dart';
// import '../../services/api_service.dart';
// import '../../widgets/painel_busca_filtros.dart';
// import 'livro_form_dialog.dart';

// class LivrosPage extends StatefulWidget {
//   const LivrosPage({super.key});

//   @override
//   State<LivrosPage> createState() => _LivrosPageState();
// }

// class _LivrosPageState extends State<LivrosPage> {
//   final ApiService _apiService = ApiService();

//   final TextEditingController _pesquisaController = TextEditingController();
//   final TextEditingController _categoriaFiltroController =
//       TextEditingController();
//   final TextEditingController _autorFiltroController = TextEditingController();

//   List<Livro> _livros = [];
//   List<Categoria> _categorias = [];
//   List<Autor> _autores = [];

//   bool _loading = true;
//   String _textoPesquisa = '';
//   int _categoriaFiltro = 0;
//   int _autorFiltro = 0;

//   @override
//   void initState() {
//     super.initState();

//     _categoriaFiltroController.text = 'Todas as categorias';
//     _autorFiltroController.text = 'Todos os autores';

//     _carregarDados();
//   }

//   @override
//   void dispose() {
//     _pesquisaController.dispose();
//     _categoriaFiltroController.dispose();
//     _autorFiltroController.dispose();
//     super.dispose();
//   }

//   List<Livro> get _livrosFiltrados {
//     return _livros.where((livro) {
//       final texto = _textoPesquisa.toLowerCase().trim();

//       final correspondePesquisa = texto.isEmpty ||
//           livro.titulo.toLowerCase().contains(texto) ||
//           (livro.isbn ?? '').toLowerCase().contains(texto) ||
//           livro.autorNome.toLowerCase().contains(texto) ||
//           livro.categoriaNome.toLowerCase().contains(texto);

//       final correspondeCategoria =
//           _categoriaFiltro == 0 || livro.categoriaId == _categoriaFiltro;

//       final correspondeAutor =
//           _autorFiltro == 0 || livro.autorId == _autorFiltro;

//       return correspondePesquisa && correspondeCategoria && correspondeAutor;
//     }).toList();
//   }

//   Future<void> _carregarDados() async {
//     setState(() {
//       _loading = true;
//     });

//     try {
//       final livros = await _apiService.getLivros();
//       final categorias = await _apiService.getCategorias();
//       final autores = await _apiService.getAutores();

//       setState(() {
//         _livros = livros;
//         _categorias = categorias;
//         _autores = autores;
//       });
//     } catch (error) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(error.toString().replaceFirst('Exception: ', '')),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _loading = false;
//         });
//       }
//     }
//   }

//   void _limparFiltros() {
//     setState(() {
//       _textoPesquisa = '';
//       _categoriaFiltro = 0;
//       _autorFiltro = 0;

//       _pesquisaController.clear();
//       _categoriaFiltroController.text = 'Todas as categorias';
//       _autorFiltroController.text = 'Todos os autores';
//     });
//   }

//   void _limparBusca() {
//     setState(() {
//       _textoPesquisa = '';
//       _pesquisaController.clear();
//     });
//   }

//   Categoria? _categoriaSelecionada() {
//     for (final categoria in _categorias) {
//       if (categoria.idcategoria == _categoriaFiltro) {
//         return categoria;
//       }
//     }

//     return null;
//   }

//   Autor? _autorSelecionado() {
//     for (final autor in _autores) {
//       if (autor.idautor == _autorFiltro) {
//         return autor;
//       }
//     }

//     return null;
//   }

//   Future<void> _abrirFormulario({Livro? livro}) async {
//     if (_categorias.isEmpty || _autores.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Cadastre pelo menos uma categoria e um autor antes de cadastrar livros.',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     final payload = await showDialog<LivroPayload>(
//       context: context,
//       builder: (_) => LivroFormDialog(
//         livro: livro,
//         categorias: _categorias,
//         autores: _autores,
//       ),
//     );

//     if (payload == null) {
//       return;
//     }

//     try {
//       if (livro == null) {
//         await _apiService.criarLivro(payload);
//       } else {
//         await _apiService.atualizarLivro(livro.idlivro, payload);
//       }

//       await _carregarDados();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             livro == null
//                 ? 'Livro cadastrado com sucesso.'
//                 : 'Livro atualizado com sucesso.',
//           ),
//         ),
//       );
//     } catch (error) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(error.toString().replaceFirst('Exception: ', '')),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _excluirLivro(Livro livro) async {
//     final confirmar = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Remover livro'),
//         content: Text(
//           'Deseja realmente remover "${livro.titulo}"?\n\n'
//           'Se o livro tiver histórico de empréstimo, ele será apenas inativado.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancelar'),
//           ),
//           FilledButton.icon(
//             onPressed: () => Navigator.pop(context, true),
//             icon: const Icon(Icons.delete_outline),
//             label: const Text('Remover'),
//           ),
//         ],
//       ),
//     );

//     if (confirmar != true) {
//       return;
//     }

//     try {
//       await _apiService.excluirLivro(livro.idlivro);
//       await _carregarDados();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Livro removido com sucesso.'),
//         ),
//       );
//     } catch (error) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(error.toString().replaceFirst('Exception: ', '')),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   String _textoStatus(Livro livro) {
//     switch (livro.statusEstoque) {
//       case 'DISPONIVEL':
//         return 'Disponível';
//       case 'PARCIALMENTE_ALUGADO':
//         return 'Parcial';
//       case 'ALUGADO':
//         return 'Alugado';
//       default:
//         return 'Sem estoque';
//     }
//   }

//   Color _corStatus(Livro livro) {
//     switch (livro.statusEstoque) {
//       case 'DISPONIVEL':
//         return Colors.green.shade600;
//       case 'PARCIALMENTE_ALUGADO':
//         return Colors.orange.shade700;
//       case 'ALUGADO':
//         return Colors.red.shade600;
//       default:
//         return Colors.grey.shade600;
//     }
//   }

//   Widget _buildCabecalho() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 18),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Livros',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF20212A),
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Pesquise, filtre e acompanhe a disponibilidade do acervo.',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF696B78),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 14,
//               vertical: 8,
//             ),
//             decoration: BoxDecoration(
//               color: const Color(0xFFEFF2FF),
//               borderRadius: BorderRadius.circular(999),
//             ),
//             child: Text(
//               '${_livros.length} livro(s)',
//               style: const TextStyle(
//                 color: Color(0xFF37448F),
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildChipsAtivos() {
//     final categoria = _categoriaSelecionada();
//     final autor = _autorSelecionado();

//     return [
//       if (_textoPesquisa.trim().isNotEmpty)
//         InputChip(
//           avatar: const Icon(Icons.search, size: 18),
//           label: Text('Busca: $_textoPesquisa'),
//           onDeleted: _limparBusca,
//         ),
//       if (categoria != null)
//         InputChip(
//           avatar: const Icon(Icons.category_outlined, size: 18),
//           label: Text('Categoria: ${categoria.nome}'),
//           onDeleted: () {
//             setState(() {
//               _categoriaFiltro = 0;
//               _categoriaFiltroController.text = 'Todas as categorias';
//             });
//           },
//         ),
//       if (autor != null)
//         InputChip(
//           avatar: const Icon(Icons.person_outline, size: 18),
//           label: Text('Autor: ${autor.nome}'),
//           onDeleted: () {
//             setState(() {
//               _autorFiltro = 0;
//               _autorFiltroController.text = 'Todos os autores';
//             });
//           },
//         ),
//     ];
//   }

//   Widget _buildFiltroCategoria() {
//     return SizedBox(
//       width: 360,
//       child: DropdownMenu<int>(
//         controller: _categoriaFiltroController,
//         label: const Text('Categoria'),
//         hintText: 'Digite para procurar',
//         width: 360,
//         menuHeight: 320,
//         enableFilter: true,
//         enableSearch: true,
//         requestFocusOnTap: true,
//         initialSelection: _categoriaFiltro,
//         dropdownMenuEntries: <DropdownMenuEntry<int>>[
//           const DropdownMenuEntry<int>(
//             value: 0,
//             label: 'Todas as categorias',
//           ),
//           ..._categorias.map((categoria) {
//             return DropdownMenuEntry<int>(
//               value: categoria.idcategoria,
//               label: categoria.nome,
//             );
//           }),
//         ],
//         onSelected: (value) {
//           setState(() {
//             _categoriaFiltro = value ?? 0;

//             if (_categoriaFiltro == 0) {
//               _categoriaFiltroController.text = 'Todas as categorias';
//             }
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildFiltroAutor() {
//     return SizedBox(
//       width: 360,
//       child: DropdownMenu<int>(
//         controller: _autorFiltroController,
//         label: const Text('Autor'),
//         hintText: 'Digite para procurar',
//         width: 360,
//         menuHeight: 320,
//         enableFilter: true,
//         enableSearch: true,
//         requestFocusOnTap: true,
//         initialSelection: _autorFiltro,
//         dropdownMenuEntries: <DropdownMenuEntry<int>>[
//           const DropdownMenuEntry<int>(
//             value: 0,
//             label: 'Todos os autores',
//           ),
//           ..._autores.map((autor) {
//             return DropdownMenuEntry<int>(
//               value: autor.idautor,
//               label: autor.nome,
//             );
//           }),
//         ],
//         onSelected: (value) {
//           setState(() {
//             _autorFiltro = value ?? 0;

//             if (_autorFiltro == 0) {
//               _autorFiltroController.text = 'Todos os autores';
//             }
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildPainelFiltros() {
//     return PainelBuscaFiltros(
//       controllerBusca: _pesquisaController,
//       titulo: 'Busca e filtros',
//       hintBusca: 'Digite título, ISBN, autor ou categoria',
//       textoResultado:
//           'Resultado: ${_livrosFiltrados.length} de ${_livros.length} livro(s)',
//       possuiBuscaDigitada: _textoPesquisa.trim().isNotEmpty,
//       onBuscaAlterada: (value) {
//         setState(() {
//           _textoPesquisa = value;
//         });
//       },
//       onLimparBusca: _limparBusca,
//       onLimparFiltros: _limparFiltros,
//       filtros: [
//         _buildFiltroCategoria(),
//         _buildFiltroAutor(),
//       ],
//       chipsAtivos: _buildChipsAtivos(),
//     );
//   }

//   Widget _buildStatusChip(Livro livro) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 7,
//       ),
//       decoration: BoxDecoration(
//         color: _corStatus(livro),
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Text(
//         _textoStatus(livro),
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w700,
//           fontSize: 13,
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoLinha({
//     required IconData icon,
//     required String texto,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 5),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 17,
//             color: const Color(0xFF696B78),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               texto,
//               style: const TextStyle(
//                 color: Color(0xFF4D4F5C),
//                 height: 1.25,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLivroCard(Livro livro) {
//     return Card(
//       elevation: 0.8,
//       color: Colors.white,
//       margin: const EdgeInsets.only(bottom: 14),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(22),
//         side: const BorderSide(
//           color: Color(0xFFE3E5EF),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 54,
//               height: 54,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE8EBFF),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Text(
//                 livro.quantidadeDisponivel.toString(),
//                 style: const TextStyle(
//                   color: Color(0xFF37448F),
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     livro.titulo,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF20212A),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _buildInfoLinha(
//                     icon: Icons.person_outline,
//                     texto: 'Autor: ${livro.autorNome}',
//                   ),
//                   _buildInfoLinha(
//                     icon: Icons.category_outlined,
//                     texto: 'Categoria: ${livro.categoriaNome}',
//                   ),
//                   _buildInfoLinha(
//                     icon: Icons.confirmation_number_outlined,
//                     texto:
//                         'ISBN: ${livro.isbn ?? '-'} | Ano: ${livro.anoPublicacao ?? '-'}',
//                   ),
//                   const SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       _buildMiniResumo(
//                         label: 'Disponíveis',
//                         valor: livro.quantidadeDisponivel.toString(),
//                         icon: Icons.inventory_2_outlined,
//                       ),
//                       _buildMiniResumo(
//                         label: 'Alugados',
//                         valor: livro.qtdEmprestada.toString(),
//                         icon: Icons.assignment_return_outlined,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 _buildStatusChip(livro),
//                 const SizedBox(height: 14),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton.filledTonal(
//                       tooltip: 'Editar',
//                       onPressed: () => _abrirFormulario(livro: livro),
//                       icon: const Icon(Icons.edit_outlined),
//                     ),
//                     const SizedBox(width: 6),
//                     IconButton.filledTonal(
//                       tooltip: 'Remover',
//                       onPressed: () => _excluirLivro(livro),
//                       icon: const Icon(Icons.delete_outline),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMiniResumo({
//     required String label,
//     required String valor,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//         vertical: 7,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF3F4FA),
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: const Color(0xFF55586A),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             '$label: $valor',
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF3F4150),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEstadoVazio() {
//     return const Padding(
//       padding: EdgeInsets.only(top: 80),
//       child: Column(
//         children: [
//           Icon(
//             Icons.search_off_outlined,
//             size: 76,
//             color: Colors.grey,
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Nenhum livro encontrado com os filtros informados.',
//             style: TextStyle(
//               fontSize: 16,
//               color: Color(0xFF696B78),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     final livrosFiltrados = _livrosFiltrados;

//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: _carregarDados,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
//           children: [
//             _buildCabecalho(),
//             _buildPainelFiltros(),
//             if (livrosFiltrados.isEmpty)
//               _buildEstadoVazio()
//             else
//               ...livrosFiltrados.map(_buildLivroCard),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _abrirFormulario(),
//         icon: const Icon(Icons.add),
//         label: const Text('Novo livro'),
//       ),
//     );
//   }
// }