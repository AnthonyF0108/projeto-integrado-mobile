import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RespostaIA {
  final String texto;
  final List<Map<String, dynamic>> produtos;

  RespostaIA({required this.texto, required this.produtos});
}

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  final GenerativeModel _model;
  final FirebaseFirestore _firestore;
  final List<Content> _historico = [];
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
          '- ${p['nome']} | Preco: R\$ ${(p['preco'] as double).toStringAsFixed(2)}'
              '${(p['descricao'] as String).isNotEmpty ? ' | Descricao: ${p['descricao']}' : ''}',
        );
      }
      return buffer.toString();
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      return 'Nao foi possivel carregar o catalogo no momento.';
    }
  }

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
Voce e um assistente virtual especialista em vendas da loja AgroVale.
Seu objetivo e entender a necessidade do cliente e recomendar o(s) produto(s) mais adequado(s).

CATALOGO ATUAL:
$catalogo

INSTRUCOES:
- Recomende no maximo 2-3 produtos que melhor resolvam o problema.
- Sempre cite o nome exato do produto como esta no catalogo.
- Explique brevemente por que cada produto e indicado.
- Use linguagem amigavel, sem jargoes tecnicos.
- Se o cliente perguntar sobre preco, informe o valor do catalogo.
- Nunca invente produtos que nao estejam no catalogo.
- Responda sempre em portugues do Brasil.

MENSAGEM DO CLIENTE:
$mensagemCliente
''';

      _historico.add(Content.text(promptSistema));
      final response = await _model.generateContent(_historico);
      final textoResposta = response.text;

      // ── CAPTURA DE TOKENS (para atividade do Prof. Rodrigo) ──────────────
      final tokEntrada = response.usageMetadata?.promptTokenCount ?? 0;
      final tokSaida = response.usageMetadata?.candidatesTokenCount ?? 0;
      final tokTotal = response.usageMetadata?.totalTokenCount ?? 0;

      print('╔══════════════════════════════════════╗');
      print('║  CONSUMO DE TOKENS — GEMINI           ║');
      print('╠══════════════════════════════════════╣');
      print('║  Prompt: "$mensagemCliente"');
      print('║  Tokens entrada : $tokEntrada');
      print('║  Tokens saida   : $tokSaida');
      print('║  Tokens TOTAL   : $tokTotal');
      print('╚══════════════════════════════════════╝');
      // ─────────────────────────────────────────────────────────────────────

      if (textoResposta != null && textoResposta.isNotEmpty) {
        _historico.add(Content.model([TextPart(textoResposta)]));
        final produtos = _extrairProdutosRecomendados(textoResposta);
        return RespostaIA(texto: textoResposta, produtos: produtos);
      }

      return RespostaIA(
        texto: 'Desculpe, nao consegui processar sua mensagem. Tente novamente.',
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