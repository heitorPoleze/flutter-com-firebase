class EmprestimoItem {
  final String livroId;
  final String livroNome;
  final int qtd;

  EmprestimoItem({required this.livroId, required this.livroNome, required this.qtd});

  factory EmprestimoItem.fromMap(Map<String, dynamic> map) {
    return EmprestimoItem(
      livroId: map['livroId'] ?? '',
      livroNome: map['livroNome'] ?? '',
      qtd: map['qtd'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'livroId': livroId, 'livroNome': livroNome, 'qtd': qtd};
  }
}

class Emprestimo {
  final String? id;
  final String nomePessoa;
  final String? telefonePessoa;
  final String? documentoPessoa;
  final String dataEmprestimo;
  final String dataPrevistaDevolucao;
  final String? dataDevolucao;
  final String status;
  final List<EmprestimoItem> itens;

  Emprestimo({
    this.id,
    required this.nomePessoa,
    this.telefonePessoa,
    this.documentoPessoa,
    required this.dataEmprestimo,
    required this.dataPrevistaDevolucao,
    this.dataDevolucao,
    required this.status,
    required this.itens,
  });

  factory Emprestimo.fromFirestore(Map<String, dynamic> data, String id) {
    var listaItens = (data['itens'] as List<dynamic>?) ?? [];
    return Emprestimo(
      id: id,
      nomePessoa: data['nomePessoa'] ?? '',
      telefonePessoa: data['telefonePessoa'],
      documentoPessoa: data['documentoPessoa'],
      dataEmprestimo: data['dataEmprestimo'] ?? '',
      dataPrevistaDevolucao: data['dataPrevistaDevolucao'] ?? '',
      dataDevolucao: data['dataDevolucao'],
      status: data['status'] ?? 'ABERTO',
      itens: listaItens.map((i) => EmprestimoItem.fromMap(i)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nomePessoa': nomePessoa,
      'telefonePessoa': telefonePessoa,
      'documentoPessoa': documentoPessoa,
      'dataEmprestimo': dataEmprestimo,
      'dataPrevistaDevolucao': dataPrevistaDevolucao,
      'dataDevolucao': dataDevolucao,
      'status': status,
      'itens': itens.map((item) => item.toMap()).toList(),
    };
  }
}