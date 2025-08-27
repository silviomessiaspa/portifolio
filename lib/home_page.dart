import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:ui' show PointerDeviceKind; // para habilitar drag com mouse na galeria
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

  // Lista dinâmica da galeria (primeiro item é destaque fixo se existir)
  List<String> _gallery = [];

  static const String _highlight = 'assets/images/graphic_design.png';
  static const Set<String> _exclude = {
    'assets/images/eusilvio.png',
    'assets/images/traos.png',
  }; // imagens usadas no herói e que não devem aparecer no carrossel

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    try {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestRaw) as Map<String, dynamic>;
      final List<String> all = manifestMap.keys
          .where((k) => k.startsWith('assets/images/'))
          .toList();
      // Filtra excluídas e separa lista sem highlight
      final List<String> others = all.where((a) => !_exclude.contains(a) && a != _highlight).toList();

      int _extractPrefix(String path) {
        final file = path.split('/').last; // ex: 001_cartaz.png
        final match = RegExp(r'^(\d{1,6})').firstMatch(file);
        if (match != null) {
          return int.tryParse(match.group(1)!) ?? 999999; // fallback grande
        }
        return 999999; // sem prefixo vai para o fim mantendo ordem relativa
      }

      others.sort((a, b) {
        final pa = _extractPrefix(a);
        final pb = _extractPrefix(b);
        if (pa != pb) return pa.compareTo(pb);
        return a.compareTo(b); // desempate alfabético
      });

      final List<String> built = [];
      if (all.contains(_highlight)) built.add(_highlight); // destaque primeiro sempre
      built.addAll(others);

      if (mounted) {
        setState(() => _gallery = built);
        // Pre-cache diferido (após frame) para demais imagens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final a in built.where((e) => e != _highlight)) {
            precacheImage(AssetImage(a), context);
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('[GALERIA] Falha ao carregar manifest: $e');
    }
  }

  @override
  void didChangeDependencies() {
    // Pré-cache das imagens locais
    precacheImage(const AssetImage('assets/images/eusilvio.png'), context);
    precacheImage(const AssetImage('assets/images/traos.png'), context);
    // Destaque (se existir)
    precacheImage(const AssetImage('assets/images/graphic_design.png'), context,
        onError: (e, _) {
      // ignore: avoid_print
      print('[HIGHLIGHT] Erro ao precache graphic_design.png: $e');
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isPhone = width < _bpSmall;
    final double hPad = isPhone ? 12 : 24; // padding padrão do conteúdo

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
            constraints: const BoxConstraints(maxWidth: 1080), // igual ao body
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad), // antes (isPhone ? 8 : 100)
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Pílula com e-mail + Copy + CV
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
                                  await Clipboard.setData(const ClipboardData(
                                      text: 'silviomessiaspa@gmail.com'));
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('E-mail copiado!'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(milliseconds: 1200),
                                    ),
                                  );
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
                            Container(
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
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// Sociais
                  Row(
                    children: [
                      Text(
                        'LinkedIn',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 12,
                        width: 2,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'X',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      /// Corpo
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
            child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad), // mantém silvio/graphic
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment:
                    isPhone ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  /// Título
                  Align(
                    alignment: Alignment(isPhone ? 0 : -1, 0),
                    child: GradientText(
                      'SILVIO DUARTE',
                      gradient: kTitleGradient,
                      style: (theme.textTheme.displaySmall ?? const TextStyle()).copyWith(
                        // Apenas ajuste responsivo básico; sem forçar peso máximo
                        fontSize: isPhone ? 34 : 64,
                        fontWeight: FontWeight.w800, // permite contraste com outros pesos
                        // remove letterSpacing / height custom se quiser herdar
                      ),
                      textAlign: isPhone ? TextAlign.center : TextAlign.left,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Subtítulo
                  Align(
                    alignment: Alignment(isPhone ? 0 : -1, 0),
                    child: Text(
                      'Graphic Designer e Artist 2D•3D',
                      textAlign: isPhone ? TextAlign.center : TextAlign.left,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4E5E58),
                        fontWeight: FontWeight.w600, // antes 800
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// Citação (exibia só em desktop; agora também no mobile, com layout adaptado)
                  if (isPhone) _QuoteMobile(),

                  /// Herói
                  _HeroSection(
                    isPhone: isPhone,
                    hovered: _photoHovered,
                    onHoverChanged: (v) => setState(() => _photoHovered = v),
                  ),

                  const SizedBox(height: 24),

                  /// Galeria
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
                      // Definição de alturas por item: assets (verticais) podem pedir mais altura.
                      double itemHeightFor(String path) {
                        final bool isAsset = path.startsWith('assets/');
                        if (isAsset) return isPhone ? 240 : 320; // altura maior para o asset vertical
                        return isPhone ? 160 : 180; // padrão dos placeholders
                      }
                      final double galleryHeight = _gallery
                          .map(itemHeightFor)
                          .fold<double>(0, (m, h) => math.max(m, h));
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
                            itemCount: _gallery.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              if (_gallery.isEmpty) {
                                return const SizedBox();
                              }
                              final path = _gallery[i];
                              final bool isAsset = path.startsWith('assets/');
                              final double targetHeight = itemHeightFor(path);
                              // Novo comportamento: preservar altura total e permitir que a largura
                              // se expanda conforme proporção (sem recorte vertical).
                              final Widget imageWidget = isAsset
                                  ? Image.asset(
                                      path,
                                      height: targetHeight,
                                      fit: BoxFit.fitHeight,
                                      errorBuilder: (c, err, st) => Container(
                                        color: Colors.red.withOpacity(.1),
                                        alignment: Alignment.center,
                                        height: targetHeight,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: const Text(
                                          'Erro ao carregar',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 10, color: Colors.red),
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      path,
                                      height: targetHeight,
                                      fit: BoxFit.fitHeight,
                                    );
                              return InkWell(
                                // Mantém regra: primeira é destaque e não abre; demais abrem pilha
                                onTap: (i == 0 || _gallery.length <= 1)
                                    ? null
                                    : () {
                                        final filtered = _gallery.sublist(1); // sem destaque
                                        final openIndex = i - 1;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => FullGalleryPage(
                                              images: filtered,
                                              initialIndex: openIndex.clamp(0, filtered.length - 1),
                                            ),
                                          ),
                                        );
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: imageWidget,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),
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
                        child: Transform(
                          alignment: Alignment.topCenter,
                          transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0), // flip horizontal
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
                  child: Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
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
class FullGalleryPage extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  const FullGalleryPage({super.key, required this.images, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Icon(Icons.arrow_back),
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                sliver: SliverList.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final path = images[index];
                    final isAsset = path.startsWith('assets/');
                    final Widget child = isAsset
                        ? Image.asset(path, fit: BoxFit.contain)
                        : Image.network(path, fit: BoxFit.cover);
                    return Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ColoredBox(
                          color: Colors.grey.shade100,
                          child: child,
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
    );
  }
}
