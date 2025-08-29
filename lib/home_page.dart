import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Abrir links no Web sem depender de plugin (url_launcher não adicionado)
// Abstrai abertura de URLs para evitar conflito com compilação WASM
import 'url_opener_stub.dart' if (dart.library.html) 'url_opener_web.dart';
import 'dart:convert'; // para ler AssetManifest
import 'dart:ui' show PointerDeviceKind, ImageFilter; // para blur e dispositivos
import 'dart:math' as math; // para calcular altura máxima dinamicamente

/// =======================
/// Identidade de cores
/// =======================
const kGradientStart = Color.fromARGB(0, 66, 206, 124); // verde claro (não mais usado)
const kGradientEnd   = Color.fromARGB(255, 43, 52, 172);  // azul profundo (não mais usado)
const kBrandGradient = kTitleGradient; // unifica: qualquer uso legado aponta para o gradiente principal

const kTitleGradient = LinearGradient(
  colors: [
    Color(0xFF23E3A2), // verde
    Color(0xFF08C4F9), // ciano
    Color(0xFF3D52FF), // azul
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Breakpoints simples
const double _bpSmall = 600;
// (reservado para usos futuros)

/// =======================
/// GradientText
/// =======================
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    required this.gradient,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// =======================
/// Página
/// =======================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _photoHovered = false;

  // Galeria A (sufixo -a) e Galeria B (sufixo -b)
  List<String> _galleryA = [];
  List<String> _galleryB = [];

  static const String _highlight = 'assets/images/graphic_design.png';
  static const String _highlightB = 'assets/images/roll2.png';
  static const Set<String> _exclude = {
    'assets/images/eusilvio.png',
    'assets/images/traos.png',
  }; // imagens usadas no herói e que não devem aparecer no carrossel

  @override
  void initState() {
    super.initState();
    _loadGalleryDynamic();
  }

  // Carrega dinamicamente usando AssetManifest para incluir novas imagens adicionadas na pasta.
  Future<void> _loadGalleryDynamic() async {
    try {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestRaw) as Map<String, dynamic>;
          // ===== SEPARAÇÃO POR SUFIXO -a / -b =====
          final allImageKeys = manifestMap.keys
              .where((k) => k.startsWith('assets/images/') && (k.endsWith('.png') || k.endsWith('.webp') || k.endsWith('.jpg') || k.endsWith('.jpeg')))
              .where((k) => !_exclude.contains(k))
              .toList();

          final regexTag = RegExp(r'^(\d{1,6})(?:[ _-]?)([ab])', caseSensitive: false);
          int extractNumber(String path) {
            final file = path.split('/').last.toLowerCase();
            if (file == 'graphic_design.png') return -1; // força destaque primeiro
            final m = regexTag.firstMatch(file);
            if (m != null) return int.tryParse(m.group(1)!) ?? 999999;
            final plain = RegExp(r'^(\d{1,6})').firstMatch(file);
            if (plain != null) return int.tryParse(plain.group(1)!) ?? 999999;
            return 999999;
          }

          final listA = <String>[];
          final listB = <String>[];
          for (final k in allImageKeys) {
            final file = k.split('/').last.toLowerCase();
            if (k == _highlight) { listA.add(k); continue; }
            final m = regexTag.firstMatch(file);
            if (m != null) {
              final tag = m.group(2)!.toLowerCase();
                if (tag == 'a') listA.add(k); else if (tag == 'b') listB.add(k);
              continue;
            }
          }

          listA.sort((a,b){final na=extractNumber(a);final nb=extractNumber(b); if(na!=nb) return na.compareTo(nb); return a.compareTo(b);} );
          listB.sort((a,b){final na=extractNumber(a);final nb=extractNumber(b); if(na!=nb) return na.compareTo(nb); return a.compareTo(b);} );

          // Monta com destaque fixo na A
          final builtA = <String>[];
          if (listA.contains(_highlight)) builtA.add(_highlight); else if (allImageKeys.contains(_highlight)) builtA.add(_highlight);
          builtA.addAll(listA.where((e) => e != _highlight));

          // Garante inclusão do destaque B (roll2.png) mesmo sem sufixo -b
          if (allImageKeys.contains(_highlightB) && !listB.contains(_highlightB)) {
            listB.insert(0, _highlightB);
          }
          // Escolha de destaque da B: prioridade roll2.png exato, depois qualquer contendo 'roll2', senão primeiro
          String roll2 = '';
          if (listB.contains(_highlightB)) {
            roll2 = _highlightB;
          } else {
            roll2 = listB.firstWhere(
              (p)=> p.split('/').last.toLowerCase().contains('roll2'),
              orElse: ()=> listB.isNotEmpty? listB.first : ''
            );
          }
          final builtB = <String>[];
          if (roll2.isNotEmpty) builtB.add(roll2);
          builtB.addAll(listB.where((e)=> e!= roll2));

          // Logs
          // ignore: avoid_print
          print('[GALERIA][DEBUG] A=${builtA.length} B=${builtB.length} sampleA=${builtA.take(4).join(', ')} sampleB=${builtB.take(4).join(', ')}');

      if (!mounted) return;
      setState(() {
        _galleryA = builtA;
        _galleryB = builtB;
      });
      // Logs de diagnóstico (aparecem apenas em debug)
      // ignore: avoid_print
  print('[GALERIA] listas => A=${_galleryA.length} B=${_galleryB.length}');

      // Fallback simples se nada carregou (evita tela vazia)
    if (_galleryA.isEmpty) {
        const fallback = [
          'assets/images/graphic_design.png',
          'assets/images/001_toca_pará_002.png',
          'assets/images/002_Ativo2.png',
        ];
        final filtered = fallback.where((e) => manifestMap.containsKey(e)).toList();
        if (filtered.isNotEmpty) {
      setState(() => _galleryA = filtered);
          // ignore: avoid_print
          print('[GALERIA][FALLBACK] Aplicado (${filtered.length} itens).');
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
  for (final a in builtA.skip(1)) { precacheImage(AssetImage(a), context); }
  for (final b in builtB.skip(1)) { precacheImage(AssetImage(b), context); }
      });
    } catch (e) {
      // ignore: avoid_print
      print('[GALERIA] Erro ao carregar manifest: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isPhone = width < _bpSmall;
    final double hPad = isPhone ? 12 : 24;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: theme.colorScheme.surface,
        toolbarHeight: 44,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: kBrandGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Text(
                              'silviomessiaspa@gmail.com',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 30,
                              width: 62,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  await Clipboard.setData(const ClipboardData(text: 'silviomessiaspa@gmail.com'));
                                  if (!mounted) return;
                                  messenger.showSnackBar(const SnackBar(
                                    content: Text('E-mail copiado!'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(milliseconds: 1200),
                                  ));
                                },
                                child: const Center(
                                  child: Text(
                                    'Copy',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Botão CV
              InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () async {
                openExternal('assets/pdf/curriculoSMD_25.pdf');
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Text(
                                    'cv',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Botão WhatsApp
              InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () async {
                openExternal('https://wa.me/5591983284550');
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/svg/wpp.svg',
                                    width: 18,
                                    height: 18,
                                    semanticsLabel: 'WhatsApp',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
            InkWell(
                        onTap: () async {
              openExternal('https://www.linkedin.com/in/silvioduartepa');
                        },
                        child: Text('LinkedIn', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87, decoration: TextDecoration.underline)),
                      ),
                      const SizedBox(width: 8),
                      Container(height: 12, width: 2, color: theme.colorScheme.outlineVariant),
                      const SizedBox(width: 8),
                      Text('X', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: isPhone ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment(isPhone ? 0 : -1, 0),
                    child: GradientText(
                      'SILVIO DUARTE',
                      gradient: kTitleGradient,
                      style: (theme.textTheme.displaySmall ?? const TextStyle()).copyWith(
                        fontSize: isPhone ? 34 : 64,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: isPhone ? TextAlign.center : TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment(isPhone ? 0 : -1, 0),
                    child: Text(
                      'graphic designer and 2d/ 3D Artist',
                      textAlign: isPhone ? TextAlign.center : TextAlign.left,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4E5E58),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (isPhone) _QuoteMobile(),
                  _HeroSection(
                    isPhone: isPhone,
                    hovered: _photoHovered,
                    onHoverChanged: (v) => setState(() => _photoHovered = v),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Confira meus trabalhos',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF4E5E58),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      if (_galleryA.isEmpty) {
                        return Column(
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              'Nenhuma imagem carregada. Faça HOT RESTART ou clique em RECARREGAR.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            GradientCircleButton(
                              onPressed: _loadGalleryDynamic,
                              size: 48,
                              tooltip: 'Recarregar',
                              child: const Icon(Icons.refresh, color: Colors.white),
                            ),
                          ],
                        );
                      }
                      double itemHeightFor(String path) {
                        final bool isAsset = path.startsWith('assets/');
                        if (isAsset) return isPhone ? 240 : 320;
                        return isPhone ? 160 : 180;
                      }
                      final double galleryHeight = _galleryA.map(itemHeightFor).fold<double>(0, (m, h) => math.max(m, h));
                      return SizedBox(
                        height: galleryHeight,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.stylus,
                              PointerDeviceKind.unknown,
                            },
                          ),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: isPhone ? 4 : 8),
                            itemCount: _galleryA.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final path = _galleryA[i];
                              final bool isAsset = path.startsWith('assets/');
                              final double targetHeight = itemHeightFor(path);
                              final Widget imageWidget = isAsset
                                  ? Image.asset(
                                      path,
                                      height: targetHeight,
                                      fit: BoxFit.fitHeight,
                                      errorBuilder: (c, err, st) => Container(
                                        color: const Color.fromARGB(26, 244, 67, 54),
                                        alignment: Alignment.center,
                                        height: targetHeight,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: const Text('Erro ao carregar', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.red)),
                                      ),
                                    )
                                  : Image.network(path, height: targetHeight, fit: BoxFit.fitHeight);
                              return InkWell(
        onTap: (i == 0 || _galleryA.length <= 1)
                                    ? null
                                    : () {
          final filtered = _galleryA.sublist(1);
                                        final openIndex = i - 1;
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (_) => FullGalleryPage(
                                            images: filtered,
                                            initialIndex: openIndex.clamp(0, filtered.length - 1),
                                          ),
                                        ));
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_galleryB.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        double itemHeightFor(String path) {
                          final bool isAsset = path.startsWith('assets/');
                          if (isAsset) return isPhone ? 240 : 320;
                          return isPhone ? 160 : 180;
                        }
                        final double galleryHeight = _galleryB.map(itemHeightFor).fold<double>(0, (m, h) => math.max(m, h));
                        return SizedBox(
                          height: galleryHeight,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.stylus,
                                PointerDeviceKind.unknown,
                              },
                            ),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: isPhone ? 4 : 8),
                              itemCount: _galleryB.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final path = _galleryB[i];
                                final bool isAsset = path.startsWith('assets/');
                                final double targetHeight = itemHeightFor(path);
                                final Widget imageWidget = isAsset
                                    ? Image.asset(
                                        path,
                                        height: targetHeight,
                                        fit: BoxFit.fitHeight,
                                        errorBuilder: (c, err, st) => Container(
                                          color: const Color.fromARGB(26, 244, 67, 54),
                                          alignment: Alignment.center,
                                          height: targetHeight,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: const Text('Erro ao carregar', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.red)),
                                        ),
                                      )
                                    : Image.network(path, height: targetHeight, fit: BoxFit.fitHeight);
                                return InkWell(
                                  onTap: (i == 0 || _galleryB.length <= 1)
                                      ? null
                                      : () {
                                          final filtered = _galleryB.sublist(1);
                                          final openIndex = i - 1;
                                          Navigator.of(context).push(MaterialPageRoute(
                                            builder: (_) => FullGalleryPage(
                                              images: filtered,
                                              initialIndex: openIndex.clamp(0, filtered.length - 1),
                                            ),
                                          ));
                                        },
                                  borderRadius: BorderRadius.circular(12),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                  ] else ...[
                    const SizedBox(height: 16),
                    if (_galleryA.isNotEmpty)
                      Text('Adicione arquivos 000-b.png para popular a segunda linha.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                    const SizedBox(height: 48),
                  ],
                  // Rodapé assinatura
                  Text('site developed by: Silvio Duarte', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================
/// Seção Herói
/// =======================
class _HeroSection extends StatelessWidget {
  final bool isPhone;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;

  const _HeroSection({
    required this.isPhone,
    required this.hovered,
    required this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    // Alturas base
    final double blobWidth  = isPhone ? 360 : 600;
    final double blobHeight = isPhone ? 250 : 300;
    // Foto (já definida dentro do Image.asset)
    final double photoHeight = isPhone ? 400 : 600;
    // Cálculo de altura mínima: parte do topo da citação até a base alinhada
    final double citationTop = isPhone ? 0 : 8;
    // Margem extra visual abaixo
    const double bottomExtra = 12;
    final double heroHeight = citationTop + (photoHeight * .78) + blobHeight / 3 + bottomExtra;
    // Mantém a base (blob + foto) tocando o fundo do Stack
    const double baseBottom = 0;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Listener(
        onPointerDown: (_) => onHoverChanged(true),
        onPointerUp: (_) => onHoverChanged(false),
        child: Transform.translate(
          // Eleva todo o conjunto (blob + imagens) um pouco para cima
          offset: Offset(0, isPhone ? -20 : -36),
          child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Blob (mantém como está)
          Positioned(
            bottom: baseBottom,
            child: AnimatedScale(
              alignment: Alignment.bottomCenter,
              scale: hovered ? 1.035 : 1.0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              child: SizedBox(
                width: blobWidth,
                height: blobHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedContainer(
                      width: blobWidth,
                      height: blobHeight,
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.easeInOutCubic,
                      decoration: BoxDecoration(
                        gradient: kTitleGradient,
                        borderRadius: BorderRadius.only(
                          // Topo muito circular (usa largura para forçar grande curvatura)
                          topLeft: Radius.circular(blobWidth),
                          topRight: Radius.circular(blobWidth),
                          // Base menos arredondada (ajuste valores se quiser mais “reta”)
                          bottomLeft: Radius.circular(
                            hovered
                                ? (isPhone ? 90 : 140)
                                : (isPhone ? 70 : 120),
                          ),
                          bottomRight: Radius.circular(
                            hovered
                                ? (isPhone ? 90 : 140)
                                : (isPhone ? 70 : 120),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: isPhone ? 10 : 18,
                      child: IgnorePointer(
                        ignoring: true,
                        child: AnimatedOpacity(
                          opacity: hovered ? 1 : 0.0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          child: AnimatedSlide(
                            offset: hovered ? const Offset(0, -0.05) : const Offset(0, 0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutQuad,
                            child: AnimatedScale(
                              alignment: Alignment.bottomCenter,
                // Escala diferenciada: mobile mantém efeito maior, desktop fica mais sutil
                scale: hovered
                  ? (isPhone ? 1.15 : 1.05)
                  : (isPhone ? 0.80 : 0.85),
                              duration: const Duration(milliseconds: 520),
                              curve: Curves.elasticOut,
                              child: Image.asset(
                                'assets/images/traos.png',
                                height: isPhone ? 320 : 540,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: MouseRegion(
                        onEnter: (_) => onHoverChanged(true),
                        onExit: (_) => onHoverChanged(false),
                        child: AnimatedSlide(
                          offset: hovered ? const Offset(0, -0.015) : Offset.zero,
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOut,
                          child: AnimatedRotation(
                            turns: hovered ? 0.002 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutQuad,
                            child: AnimatedScale(
                              alignment: Alignment.bottomCenter,
                              scale: hovered ? 1.03 : 1.0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.elasticOut,
                              child: Image.asset(
                                'assets/images/eusilvio.png',
                                height: isPhone ? 400 : 600,
                                fit: BoxFit.contain,
                                semanticLabel: 'Foto',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // === CITAÇÃO (agora acima do blob na hierarquia / z-order) ===
          if (!isPhone)
            Positioned(
              left: 0,
              top: 16,
              child: ConstrainedBox(
                // Reduz a largura para evitar que o texto vá por trás da imagem
                // Aumentado (antes 240) para dar mais respiro ao texto no desktop
                constraints: const BoxConstraints(maxWidth: 300),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aspas alinhadas ao topo do texto, menor espaçamento lateral
                    Transform.translate(
                      offset: const Offset(0, -21), // sobe 4px
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            kTitleGradient.createShader(Offset.zero & bounds.size),
                        blendMode: BlendMode.srcIn,
                        child: Transform.scale(
                          scaleX: -1.0,
                          scaleY: 1.0,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.format_quote,
                            size: 88,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Extremamente competente em várias frentes de conhecimento multimídia podendo entregar de ilustração 2d a complexas modelagens 3d, jogos, vídeos, animações e broadcast design.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w400, // volta peso base
                              height: 1.18,
                              color: Colors.black87,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
          ),
        ),
      ),
    );
  }
}

/// Versão da citação para mobile (fora do Stack para evitar sobreposição e permitir scroll natural)
class _QuoteMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.18,
          color: Colors.black87,
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ajuste de alinhamento vertical do ícone (levemente acima)
              Transform.translate(
                offset: const Offset(0, -6),
                child: ShaderMask(
                  shaderCallback: (bounds) => kTitleGradient.createShader(Offset.zero & bounds.size),
                  blendMode: BlendMode.srcIn,
                  child: Transform.scale(
                    scaleX: -1.0,
                    scaleY: 1.0,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.format_quote,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Extremamente competente em várias frentes de conhecimento multimídia podendo entregar de ilustração 2d a complexas modelagens 3d, jogos, vídeos, animações e broadcast design.',
                  // Removido justify no mobile; alinhamento padrão à esquerda para melhor legibilidade
                  textAlign: TextAlign.start,
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Página de visualização completa da galeria (todas as imagens em coluna)
class GradientCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double size;
  final String? tooltip;
  const GradientCircleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = 56,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      shape: const CircleBorder(),
      elevation: 6,
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: kTitleGradient,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: child),
          ),
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}

class FullGalleryPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const FullGalleryPage({super.key, required this.images, this.initialIndex = 0});
  @override
  State<FullGalleryPage> createState() => _FullGalleryPageState();
}

class _FullGalleryPageState extends State<FullGalleryPage> {
  int? _overlayIndex; // índice da imagem aberta em overlay

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 900;
    final double columnTargetWidth = isWide ? (size.width * 3 / 5) : size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: GradientCircleButton(
  onPressed: () => Navigator.of(context).maybePop(),
  size: 56,
  tooltip: 'Voltar',
  child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Scrollbar(
              thumbVisibility: true,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    sliver: SliverList.builder(
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        final path = widget.images[index];
                        final isAsset = path.startsWith('assets/');
                        final Widget child = GestureDetector(
                          onTap: () => setState(() => _overlayIndex = index),
                          child: Hero(
                            tag: 'gallery_$index',
                            child: isAsset
                                ? Image.asset(path, fit: BoxFit.contain)
                                : Image.network(path, fit: BoxFit.cover),
                          ),
                        );
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 0 : 16),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: columnTargetWidth),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ColoredBox(color: Colors.grey.shade100, child: child),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_overlayIndex != null) _buildOverlay(context, _overlayIndex!),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, int index) {
    final path = widget.images[index];
    final isAsset = path.startsWith('assets/');
    final rawImage = isAsset ? Image.asset(path) : Image.network(path);
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _overlayIndex = null),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: const Color.fromARGB(150, 0, 0, 0)),
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final maxH = constraints.maxHeight;
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 6,
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(320),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxW * 0.9,
                        maxHeight: maxH * 0.9,
                      ),
                      child: Hero(tag: 'gallery_$index', child: rawImage),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: GradientCircleButton(
              onPressed: () => setState(() => _overlayIndex = null),
              size: 48,
              tooltip: 'Fechar',
              child: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
