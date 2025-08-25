import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final List<String> _gallery = const [
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=1200',
    'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66?q=80&w=1200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1200',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1200',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?q=80&w=1200',
  ];

  @override
  void didChangeDependencies() {
    // Pré-cache das imagens locais
    precacheImage(const AssetImage('assets/images/eusilvio.png'), context);
    precacheImage(const AssetImage('assets/images/traos.png'), context);
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
                  SizedBox(
                    height: isPhone ? 160 : 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isPhone ? 4 : 8),
                      itemCount: _gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _gallery[i],
                            width: isPhone ? 140 : 220,
                            height: isPhone ? 160 : 180,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
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
                          child: AnimatedScale(
                            scale: hovered ? 1.0 : 0.85,
                            duration: const Duration(milliseconds: 420),
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
                constraints: const BoxConstraints(maxWidth: 240),
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
    );
  }
}
