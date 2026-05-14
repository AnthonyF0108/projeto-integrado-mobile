import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void abrirChatIA(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => const _ChatIASheet(),
  );
}

class _Mensagem {
  final String texto;
  final bool isCliente;
  final DateTime hora;
  final List<Map<String, dynamic>> produtos;

  _Mensagem({
    required this.texto,
    required this.isCliente,
    required this.hora,
    this.produtos = const [],
  });
}

class _ChatIASheet extends StatefulWidget {
  const _ChatIASheet();

  @override
  State<_ChatIASheet> createState() => _ChatIASheetState();
}

class _ChatIASheetState extends State<_ChatIASheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final GeminiService _gemini = GeminiService();

  final List<_Mensagem> _msgs = [];
  bool _carregando = false;

  static const _verde = Color(0xFF4CAF50);
  static const _fundo = Color(0xFF1A1A1A);
  static const _fundoBolhaIA = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _msgs.add(_Mensagem(
      texto: 'Olá! 👋 Me conta o que você precisa ou qual dificuldade está tendo — vou recomendar o melhor produto pra você!',
      isCliente: false,
      hora: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _carregando) return;
    _controller.clear();

    setState(() {
      _msgs.add(_Mensagem(texto: texto, isCliente: true, hora: DateTime.now()));
      _carregando = true;
    });
    _rolar();

    final resposta = await _gemini.enviarMensagem(texto);

    setState(() {
      _msgs.add(_Mensagem(
        texto: resposta.texto,
        isCliente: false,
        hora: DateTime.now(),
        produtos: resposta.produtos,
      ));
      _carregando = false;
    });
    _rolar();
  }

  void _rolar() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height * 0.88;
    return Container(
      height: altura,
      decoration: const BoxDecoration(
        color: _fundo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _Cabecalho(onFechar: () => Navigator.pop(context)),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _msgs.length + (_carregando ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _msgs.length) return const _BolhaDigitando();
                final m = _msgs[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bolha(mensagem: m),
                    if (!m.isCliente && m.produtos.isNotEmpty)
                      _ListaProdutos(
                        produtos: m.produtos,
                        onAdicionarCarrinho: _adicionarCarrinho,
                      ),
                  ],
                );
              },
            ),
          ),
          _Campo(
            controller: _controller,
            carregando: _carregando,
            onEnviar: _enviar,
          ),
        ],
      ),
    );
  }

  void _adicionarCarrinho(Map<String, dynamic> produto) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para adicionar ao carrinho')),
      );
      return;
    }
    await FirestoreService().adicionarAoCarrinho(user.uid, {
      'id': produto['id'],
      'nome': produto['nome'],
      'preco': produto['preco'],
      'imagem': produto['imagem'],
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${produto['nome']} adicionado ao carrinho!'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }
}

class _ListaProdutos extends StatelessWidget {
  final List<Map<String, dynamic>> produtos;
  final void Function(Map<String, dynamic>) onAdicionarCarrinho;

  const _ListaProdutos({required this.produtos, required this.onAdicionarCarrinho});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 34, bottom: 8),
      child: Column(
        children: produtos.map((p) => _CardProduto(
          produto: p,
          onAdicionar: () => onAdicionarCarrinho(p),
        )).toList(),
      ),
    );
  }
}

class _CardProduto extends StatelessWidget {
  final Map<String, dynamic> produto;
  final VoidCallback onAdicionar;

  const _CardProduto({required this.produto, required this.onAdicionar});

  static const _verde = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final preco = produto['preco'] as double;
    final imagem = produto['imagem'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _verde.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: imagem.isNotEmpty
                ? Image.network(
              imagem,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _semImagem(),
            )
                : _semImagem(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto['nome'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(color: _verde, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: onAdicionar,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_shopping_cart,
                    color: Colors.black, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _semImagem() => Container(
    width: 72, height: 72,
    color: Colors.black26,
    child: const Icon(Icons.image_not_supported, color: Colors.white24),
  );
}

class _Cabecalho extends StatelessWidget {
  final VoidCallback onFechar;
  const _Cabecalho({required this.onFechar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 6),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Color(0xFF4CAF50), size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assistente AgroVale',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Row(children: [
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFF4CAF50)),
                    SizedBox(width: 5),
                    Text('Online', style: TextStyle(color: Colors.green, fontSize: 11)),
                  ]),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: onFechar,
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white10, height: 1),
      ],
    );
  }
}

class _Bolha extends StatelessWidget {
  final _Mensagem mensagem;
  const _Bolha({required this.mensagem});

  static const _verde = Color(0xFF4CAF50);
  static const _fundoIA = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final isCliente = mensagem.isCliente;
    return Align(
      alignment: isCliente ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4, bottom: 4,
          left: isCliente ? 56 : 0,
          right: isCliente ? 0 : 56,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCliente) ...[
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                    color: _verde.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: _verde, size: 14),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isCliente
                    ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                    decoration: BoxDecoration(
                      color: isCliente ? _verde : _fundoIA,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isCliente ? 16 : 4),
                        bottomRight: Radius.circular(isCliente ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      mensagem.texto,
                      style: TextStyle(
                        color: isCliente ? Colors.black : Colors.white70,
                        fontSize: 13.5, height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(_hora(mensagem.hora),
                      style: const TextStyle(fontSize: 10, color: Colors.white38)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _hora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _BolhaDigitando extends StatelessWidget {
  const _BolhaDigitando();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4, left: 34),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16),
            bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [_Ponto(delay: 0), const SizedBox(width: 5),
            _Ponto(delay: 180), const SizedBox(width: 5), _Ponto(delay: 360)],
        ),
      ),
    );
  }
}

class _Ponto extends StatefulWidget {
  final int delay;
  const _Ponto({required this.delay});
  @override State<_Ponto> createState() => _PontoState();
}

class _PontoState extends State<_Ponto> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _anim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay),
            () { if (mounted) _ctrl.repeat(reverse: true); });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 7, height: 7,
      decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
    ),
  );
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final bool carregando;
  final VoidCallback onEnviar;

  const _Campo({required this.controller, required this.carregando, required this.onEnviar});

  static const _verde = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !carregando,
              maxLines: 4, minLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onEnviar(),
              decoration: InputDecoration(
                hintText: 'Descreva sua necessidade...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: carregando ? null : onEnviar,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: carregando ? Colors.white12 : _verde,
                shape: BoxShape.circle,
              ),
              child: carregando
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}