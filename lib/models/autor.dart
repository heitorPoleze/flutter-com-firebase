class Autor {
  final String? id; 
  final String nome;
  final String? nacionalidade;

  Autor({
    required this.id,
    required this.nome,
    this.nacionalidade,
  });

  factory Autor.fromFirestore(Map<String, dynamic> data, String id) {
    return Autor(
      id: id,
      nome: data['nome'] ?? '',
      nacionalidade: data['nacionalidade'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'nacionalidade': nacionalidade,
    };
  }
}