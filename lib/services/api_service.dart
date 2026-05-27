import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/categoria.dart';
import '../models/autor.dart';
import '../models/livro.dart';
import '../models/emprestimo.dart';

class ApiService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  String _decodeBody(http.Response response) {
    return utf8.decode(response.bodyBytes);
  }

  String _extractError(http.Response response) {
    final body = _decodeBody(response);

    if (body.isEmpty) {
      return 'Erro ${response.statusCode}';
    }

    try {
      final json = jsonDecode(body);

      if (json is Map<String, dynamic>) {
        if (json['mensagem'] != null) {
          return json['mensagem'].toString();
        }

        if (json['detail'] != null) {
          return json['detail'].toString();
        }

        return json.toString();
      }

      return body;
    } catch (_) {
      return body;
    }
  }

  Future<List<Categoria>> getCategorias() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categorias/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(_decodeBody(response));
      return jsonList.map((item) => Categoria.fromJson(item)).toList();
    }

    throw Exception('Erro ao carregar categorias: ${_extractError(response)}');
  }

  Future<void> criarCategoria(CategoriaPayload payload) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/categorias/'),
      headers: _headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao cadastrar categoria: ${_extractError(response)}');
    }
  }

  Future<void> atualizarCategoria(int id, CategoriaPayload payload) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/categorias/$id/'),
      headers: _headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar categoria: ${_extractError(response)}');
    }
  }

  Future<void> excluirCategoria(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/categorias/$id/'),
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir categoria: ${_extractError(response)}');
    }
  }

  Future<List<Autor>> getAutores() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/autores/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(_decodeBody(response));
      return jsonList.map((item) => Autor.fromJson(item)).toList();
    }

    throw Exception('Erro ao carregar autores: ${_extractError(response)}');
  }

  Future<void> criarAutor(AutorPayload payload) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/autores/'),
      headers: _headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao cadastrar autor: ${_extractError(response)}');
    }
  }

  Future<void> atualizarAutor(int id, AutorPayload payload) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/autores/$id/'),
      headers: _headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar autor: ${_extractError(response)}');
    }
  }

  Future<void> excluirAutor(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/autores/$id/'),
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir autor: ${_extractError(response)}');
    }
  }

  Future<List<Livro>> getLivros() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/livros/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(_decodeBody(response));
      return jsonList.map((item) => Livro.fromJson(item)).toList();
    }

    throw Exception('Erro ao carregar livros: ${_extractError(response)}');
  }

  Future<void> criarLivro(LivroPayload payload) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/livros/'),
      headers: _headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao cadastrar livro: ${_extractError(response)}');
    }
  }

  Future<void> atualizarLivro(int id, LivroPayload payload) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/livros/$id/'),
      headers: _headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar livro: ${_extractError(response)}');
    }
  }

  Future<void> excluirLivro(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/livros/$id/'),
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir livro: ${_extractError(response)}');
    }
  }

  Future<List<Emprestimo>> getEmprestimos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/emprestimos/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(_decodeBody(response));
      return jsonList.map((item) => Emprestimo.fromJson(item)).toList();
    }

    throw Exception('Erro ao carregar empréstimos: ${_extractError(response)}');
  }

  Future<void> criarEmprestimo(EmprestimoPayload payload) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/emprestimos/'),
      headers: _headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar empréstimo: ${_extractError(response)}');
    }
  }

  Future<void> devolverEmprestimo(int id) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/emprestimos/$id/devolver/'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao devolver empréstimo: ${_extractError(response)}');
    }
  }
}