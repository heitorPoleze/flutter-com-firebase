class Livro {
  final String id;
  final String titulo;
  final String? isbn;
  final int? anoPublicacao;
  final int quantidade;
  final int quantidadeDisponivel;
  
  final String categoriaNome;
  final String autorNome;
  final String categoriaId;
  final String autorId;

  Livro({
    required this.id,
    required this.titulo,
    this.isbn,
    this.anoPublicacao,
    required this.quantidade,
    required this.quantidadeDisponivel, 
    required this.categoriaNome,
    required this.autorNome,
    required this.categoriaId,
    required this.autorId,
  });

  factory Livro.fromFirestore(Map<String, dynamic> data, String id) {
    return Livro(
      id: id,
      titulo: data['titulo'] ?? '',
      isbn: data['isbn'],
      anoPublicacao: data['anoPublicacao'],
      quantidade: data['quantidade'] ?? 0,
      quantidadeDisponivel: data['quantidade_disponivel'] ?? 0, // Adicionado
      categoriaNome: data['categoriaNome'] ?? '',
      autorNome: data['autorNome'] ?? '',
      categoriaId: data['categoriaId'] ?? '',
      autorId: data['autorId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'isbn': isbn,
      'anoPublicacao': anoPublicacao,
      'quantidade': quantidade,
      'quantidade_disponivel': quantidadeDisponivel, // Adicionado
      'categoriaNome': categoriaNome,
      'autorNome': autorNome,
      'categoriaId': categoriaId,
      'autorId': autorId,
    };
  }
}