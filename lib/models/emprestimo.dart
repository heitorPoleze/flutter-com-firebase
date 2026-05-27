class EmprestimoItem {
  final int idemprestimolivro;
  final int livroId;
  final String livroNome;
  final int qtd;

  EmprestimoItem({
    required this.idemprestimolivro,
    required this.livroId,
    required this.livroNome,
    required this.qtd,
  });

  factory EmprestimoItem.fromJson(Map<String, dynamic> json) {
    return EmprestimoItem(
      idemprestimolivro: json['idemprestimolivro'] ?? 0,
      livroId: json['livro_idlivro'] ?? 0,
      livroNome: json['livro_nome'] ?? '',
      qtd: json['qtd'] ?? 0,
    );
  }
}

class Emprestimo {
  final int idemprestimo;

  final String nomePessoa;
  final String? telefonePessoa;
  final String? documentoPessoa;

  final String dataEmprestimo;
  final String dataPrevistaDevolucao;
  final String? dataDevolucao;
  final String status;
  final List<EmprestimoItem> itens;

  Emprestimo({
    required this.idemprestimo,
    required this.nomePessoa,
    this.telefonePessoa,
    this.documentoPessoa,
    required this.dataEmprestimo,
    required this.dataPrevistaDevolucao,
    this.dataDevolucao,
    required this.status,
    required this.itens,
  });

  bool get devolvido => status == 'DEVOLVIDO';

  factory Emprestimo.fromJson(Map<String, dynamic> json) {
    final itensJson = json['itens'] as List<dynamic>? ?? [];

    return Emprestimo(
      idemprestimo: json['idemprestimo'] ?? 0,
      nomePessoa: json['nomePessoa'] ?? '',
      telefonePessoa: json['telefonePessoa'],
      documentoPessoa: json['documentoPessoa'],
      dataEmprestimo: json['dataEmprestimo'] ?? '',
      dataPrevistaDevolucao: json['dataPrevistaDevolucao'] ?? '',
      dataDevolucao: json['dataDevolucao'],
      status: json['status'] ?? '',
      itens: itensJson
          .map((item) => EmprestimoItem.fromJson(item))
          .toList(),
    );
  }
}

class EmprestimoPayload {
  final int livroId;
  final int qtd;
  final String dataPrevistaDevolucao;

  final String nomePessoa;
  final String telefonePessoa;
  final String documentoPessoa;

  EmprestimoPayload({
    required this.livroId,
    required this.qtd,
    required this.dataPrevistaDevolucao,
    required this.nomePessoa,
    required this.telefonePessoa,
    required this.documentoPessoa,
  });

  Map<String, dynamic> toJson() {
    return {
      'nomePessoa': nomePessoa,
      'telefonePessoa': telefonePessoa,
      'documentoPessoa': documentoPessoa,
      'dataPrevistaDevolucao': dataPrevistaDevolucao,
      'status': 'ABERTO',
      'itens_payload': [
        {
          'livro_idlivro': livroId,
          'qtd': qtd,
        }
      ],
    };
  }
}