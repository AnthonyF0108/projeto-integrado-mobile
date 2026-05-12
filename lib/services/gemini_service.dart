import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Resultado da mensagem: texto + produtos recomendados
class RespostaIA {
  final String texto;
  final List<Map<String, dynamic>> produtos;

  RespostaIA({required this.texto, required this.produtos});
}

class GeminiService {
  static const _apiKey = 'AIzaSyBiferOjpHsXHciObG65BEoxDV_UV_tEWk';

  final GenerativeModel _model;
  final FirebaseFirestore _firestore;
  final List<Content> _historico = [];

  // Cache do catálogo para cruzar com a resposta
  List<Map<String, dynamic>> _catalogoCache = [];

  GeminiService()
      : _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.7,
      maxOutputTokens: 800,
    ),
  ),
        _firestore = FirebaseFirestore.instance;

  Future<String> _buscarCatalogoProdutos() async {
    try {
      final snapshot = await _firestore.collection('produtos').limit(50).get();

      if (snapshot.docs.isEmpty) {
        _catalogoCache = [];
        return 'Nenhum produto disponível no momento.';
      }

      _catalogoCache = snapshot.docs.map((doc) {
        final data = doc.data();
        final precoRaw = data['preco'];
        final preco = (precoRaw is int)
            ? precoRaw.toDouble()
            : (precoRaw as double? ?? 0.0);
        return {
          'id': doc.id,
          'nome': data['nome'] ?? '',
          'preco': preco,
          'descricao': data['descricao'] ?? '',
          'imagem': data['imagem'] ?? '',
        };
      }).toList();

      final buffer = StringBuffer();
      for (final p in _catalogoCache) {
        buffer.writeln(
          '- ${p['nome']} | Preço: R\$ ${(p['preco'] as double).toStringAsFixed(2)}'
              '${(p['descricao'] as String).isNotEmpty ? ' | Descrição: ${p['descricao']}' : ''}',
        );
      }
      return buffer.toString();
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      return 'Não foi possível carregar o catálogo no momento.';
    }
  }

  // Cruza os nomes citados na resposta da IA com o catálogo real
  List<Map<String, dynamic>> _extrairProdutosRecomendados(String textoResposta) {
    final recomendados = <Map<String, dynamic>>[];
    for (final produto in _catalogoCache) {
      final nome = (produto['nome'] as String).toLowerCase();
      if (nome.isNotEmpty && textoResposta.toLowerCase().contains(nome)) {
        recomendados.add(produto);
      }
    }
    return recomendados;
  }

  Future<RespostaIA> enviarMensagem(String mensagemCliente) async {
    try {
      final catalogo = await _buscarCatalogoProdutos();

      final promptSistema = '''
Você é um assistente virtual especialista em vendas da loja AgroVale.
Seu objetivo é entender a necessidade do cliente e recomendar o(s) produto(s) mais adequado(s).

CATÁLOGO ATUAL:
$catalogo

INSTRUÇÕES:
- Recomende no máximo 2-3 produtos que melhor resolvam o problema.
- Sempre cite o nome exato do produto como está no catálogo.
- Explique brevemente por que cada produto é indicado.
- Use linguagem amigável, sem jargões técnicos.
- Se o cliente perguntar sobre preço, informe o valor do catálogo.
- Nunca invente produtos que não estejam no catálogo.
- Responda sempre em português do Brasil.

MENSAGEM DO CLIENTE:
$mensagemCliente
''';

      _historico.add(Content.text(promptSistema));
      final response = await _model.generateContent(_historico);
      final textoResposta = response.text;

      if (textoResposta != null && textoResposta.isNotEmpty) {
        _historico.add(Content.model([TextPart(textoResposta)]));
        final produtos = _extrairProdutosRecomendados(textoResposta);
        return RespostaIA(texto: textoResposta, produtos: produtos);
      }

      return RespostaIA(
        texto: 'Desculpe, não consegui processar sua mensagem. Tente novamente.',
        produtos: [],
      );
    } catch (e) {
      print('Erro no GeminiService: $e');
      return RespostaIA(
        texto: 'Ocorreu um erro. Tente novamente em instantes.',
        produtos: [],
      );
    }
  }

  void limparHistorico() {
    _historico.clear();
  }
}