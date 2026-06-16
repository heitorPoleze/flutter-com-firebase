import 'package:biblioteca_flutter/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cadastro_page.dart';
import 'package:biblioteca_flutter/utils/validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFieldKey = GlobalKey<FormFieldState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final senha = _passwordController.text;
      final authService = AuthService();

      try {
        final auth = await authService.fazerLogin(email: email, senha: senha);
        if (auth && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$email logado com sucesso!'),
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
          SnackBar(content: Text(mensagemErro), backgroundColor: Colors.red),
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

  _recuperarSenha() async {
    if (_emailFieldKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final authService = AuthService();
      try {
        await authService.recuperarSenhaViaEmail(email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifique sua caixa de entrada!')),
        );
      } on FirebaseAuthException catch (e) {
        String mensagem = 'Ocorreu um erro.';
        if (e.code == 'user-not-found') {
          mensagem = 'Email não cadastrado.';
        } else if (e.code == 'invalid-email') {
          mensagem = 'Formato de email inválido.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensagem)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone ou Logo do seu App
                const Icon(
                  Icons.local_library_rounded,
                  size: 100,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 48),

                const Text(
                  'Bem-vindo(a)',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF20212A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Campo de E-mail
                TextFormField(
                  key: _emailFieldKey,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validador.email,
                ),
                const SizedBox(height: 16),

                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botão de Login
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _fazerLogin,
                  child: const Text(
                    'ENTRAR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: _recuperarSenha,
                  child: const Text('Esqueci minha senha'),
                ),

                const SizedBox(height: 16),

                // Botão para ir para a tela de Cadastro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroPage(),
                      ),
                    );
                  },
                  child: const Text('Ainda não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
