class Categoria {
  final String? id;
  final String nome;
  final String? descricao;

  Categoria({this.id, required this.nome, this.descricao});

  factory Categoria.fromFirestore(Map<String, dynamic> data, String id) {
    return Categoria(
      id: id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'descricao': descricao,
    };
  }
}