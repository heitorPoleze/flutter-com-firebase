class Categoria {
  final int idcategoria;
  final String nome;
  final String? descricao;

  Categoria({
    required this.idcategoria,
    required this.nome,
    this.descricao,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idcategoria: json['idcategoria'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
    );
  }
}

class CategoriaPayload {
  final String nome;
  final String descricao;

  CategoriaPayload({
    required this.nome,
    required this.descricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
    };
  }
}