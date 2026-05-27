class Autor {
  final int idautor;
  final String nome;
  final String? nacionalidade;

  Autor({
    required this.idautor,
    required this.nome,
    this.nacionalidade,
  });

  factory Autor.fromJson(Map<String, dynamic> json) {
    return Autor(
      idautor: json['idautor'],
      nome: json['nome'] ?? '',
      nacionalidade: json['nacionalidade'],
    );
  }
}

class AutorPayload {
  final String nome;
  final String nacionalidade;

  AutorPayload({
    required this.nome,
    required this.nacionalidade,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'nacionalidade': nacionalidade,
    };
  }
}