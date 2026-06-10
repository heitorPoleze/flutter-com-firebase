// import 'package:flutter/material.dart';

// import '../../models/categoria.dart';
// import '../../services/api_service.dart';
// import 'categoria_form_dialog.dart';

// class CategoriasPage extends StatefulWidget {
//   const CategoriasPage({super.key});

//   @override
//   State<CategoriasPage> createState() => _CategoriasPageState();
// }

// class _CategoriasPageState extends State<CategoriasPage> {
//   final ApiService _apiService = ApiService();

//   List<Categoria> _categorias = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _carregar();
//   }

//   Future<void> _carregar() async {
//     setState(() {
//       _loading = true;
//     });

//     try {
//       final categorias = await _apiService.getCategorias();

//       setState(() {
//         _categorias = categorias;
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

//   Future<void> _abrirFormulario({Categoria? categoria}) async {
//     final payload = await showDialog<CategoriaPayload>(
//       context: context,
//       builder: (_) => CategoriaFormDialog(categoria: categoria),
//     );

//     if (payload == null) {
//       return;
//     }

//     try {
//       if (categoria == null) {
//         await _apiService.criarCategoria(payload);
//       } else {
//         await _apiService.atualizarCategoria(categoria.idcategoria, payload);
//       }

//       await _carregar();
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

//   Future<void> _excluir(Categoria categoria) async {
//     final confirmar = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Excluir categoria'),
//         content: Text('Deseja excluir "${categoria.nome}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancelar'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Excluir'),
//           ),
//         ],
//       ),
//     );

//     if (confirmar != true) {
//       return;
//     }

//     try {
//       await _apiService.excluirCategoria(categoria.idcategoria);
//       await _carregar();
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

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: _carregar,
//         child: _categorias.isEmpty
//             ? ListView(
//                 children: const [
//                   SizedBox(height: 120),
//                   Icon(
//                     Icons.category_outlined,
//                     size: 72,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 16),
//                   Center(
//                     child: Text('Nenhuma categoria cadastrada.'),
//                   ),
//                 ],
//               )
//             : ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: _categorias.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final categoria = _categorias[index];

//                   return Card(
//                     child: ListTile(
//                       leading: const Icon(Icons.category_outlined),
//                       title: Text(categoria.nome),
//                       subtitle: Text(categoria.descricao ?? 'Sem descrição'),
//                       trailing: Wrap(
//                         children: [
//                           IconButton(
//                             onPressed: () =>
//                                 _abrirFormulario(categoria: categoria),
//                             icon: const Icon(Icons.edit_outlined),
//                           ),
//                           IconButton(
//                             onPressed: () => _excluir(categoria),
//                             icon: const Icon(Icons.delete_outline),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _abrirFormulario(),
//         icon: const Icon(Icons.add),
//         label: const Text('Nova categoria'),
//       ),
//     );
//   }
// }