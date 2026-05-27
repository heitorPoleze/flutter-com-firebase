import 'package:flutter/material.dart';

class PainelBuscaFiltros extends StatelessWidget {
  final TextEditingController controllerBusca;
  final String titulo;
  final String hintBusca;
  final String textoResultado;
  final bool possuiBuscaDigitada;
  final ValueChanged<String> onBuscaAlterada;
  final VoidCallback onLimparBusca;
  final VoidCallback onLimparFiltros;
  final List<Widget> filtros;
  final List<Widget> chipsAtivos;

  const PainelBuscaFiltros({
    super.key,
    required this.controllerBusca,
    required this.titulo,
    required this.hintBusca,
    required this.textoResultado,
    required this.possuiBuscaDigitada,
    required this.onBuscaAlterada,
    required this.onLimparBusca,
    required this.onLimparFiltros,
    required this.filtros,
    required this.chipsAtivos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: Color(0xFFE3E5EF),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.tune_outlined,
                  size: 22,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controllerBusca,
              decoration: InputDecoration(
                labelText: 'Pesquisar',
                hintText: hintBusca,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: possuiBuscaDigitada
                    ? IconButton(
                        tooltip: 'Limpar pesquisa',
                        onPressed: onLimparBusca,
                        icon: const Icon(Icons.close),
                      )
                    : null,
              ),
              onChanged: onBuscaAlterada,
            ),
            if (filtros.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4D4F5C),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: filtros,
              ),
            ],
            if (chipsAtivos.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chipsAtivos,
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    textoResultado,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3F4150),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onLimparFiltros,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: const Text('Limpar filtros'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}