import 'package:biblioteca_flutter/services/auth.dart';
import 'package:biblioteca_flutter/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _cadastrar() async{
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final senha = _senhaController.text;
      final authService = AuthService();
      try{
        final auth = await authService.cadastrarUsuario(email: email, senha: senha);

        if(auth && mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$email cadastrado com sucesso!'),
            backgroundColor: Colors.indigo,
          ),
        );

      }
    } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        String mensagemErro = 'Ocorreu um erro ao realizar o cadastro.';
        
        if (e.code == 'email-already-in-use') {
          mensagemErro = 'Este e-mail já está cadastrado em outra conta.';
        } else if (e.code == 'weak-password') {
          mensagemErro = 'A senha digitada é muito fraca.';
        } else if (e.code == 'invalid-email') {
          mensagemErro = 'O formato do e-mail digitado é inválido.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagemErro),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    size: 80,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 32),

                  //email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'Digite seu e-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validador.email
                  ),
                  const SizedBox(height: 16),

                  // Campo de Senha
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true, // Esconde os caracteres
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      hintText: 'Crie uma senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma senha.';
                      }
                      if (value.length < 6) {
                        // O Firebase exige senhas de no mínimo 6 caracteres por padrão
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botão de Cadastro
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _cadastrar,
                    child: const Text(
                      'CADASTRAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
