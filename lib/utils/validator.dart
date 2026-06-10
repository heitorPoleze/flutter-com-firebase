class Validador {
  
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o seu e-mail';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Insira um e-mail válido';
    }
    
    return null;
  }
}