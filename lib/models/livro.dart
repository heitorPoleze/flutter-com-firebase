class Livro {
  final int idlivro;
  final String titulo;
  final String? isbn;
  final int? anoPublicacao;
  final int quantidade;

  final int qtdEmprestada;
  final int quantidadeDisponivel;
  final String statusEstoque;

  final int categoriaId;
  final String categoriaNome;
  final int autorId;
  final String autorNome;

  Livro({
    required this.idlivro,
    required this.titulo,
    this.isbn,
    this.anoPublicacao,
    required this.quantidade,
    required this.qtdEmprestada,
    required this.quantidadeDisponivel,
    required this.statusEstoque,
    required this.categoriaId,
    required this.categoriaNome,
    required this.autorId,
    required this.autorNome,
  });

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      idlivro: json['idlivro'] ?? 0,
      titulo: json['titulo'] ?? '',
      isbn: json['isbn'],
      anoPublicacao: json['anoPublicacao'],
      quantidade: json['quantidade'] ?? 0,
      qtdEmprestada: json['qtd_emprestada'] ?? 0,
      quantidadeDisponivel:
          json['quantidade_disponivel'] ?? json['quantidade'] ?? 0,
      statusEstoque: json['status_estoque'] ?? 'SEM_ESTOQUE',
      categoriaId: json['categoria_idcategoria'] ?? 0,
      categoriaNome: json['categoria_nome'] ?? '',
      autorId: json['autor_idautor'] ?? 0,
      autorNome: json['autor_nome'] ?? '',
    );
  }
}

class LivroPayload {
  final String titulo;
  final String isbn;
  final int anoPublicacao;
  final int quantidade;
  final int categoriaId;
  final int autorId;

  LivroPayload({
    required this.titulo,
    required this.isbn,
    required this.anoPublicacao,
    required this.quantidade,
    required this.categoriaId,
    required this.autorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'isbn': isbn,
      'anoPublicacao': anoPublicacao,
      'quantidade': quantidade,
      'categoria_idcategoria': categoriaId,
      'autor_idautor': autorId,
    };
  }
}