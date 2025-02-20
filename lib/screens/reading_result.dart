import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import '../data/tarot_bloc.dart';


///resultScreen
class ReadingResultScreen extends StatefulWidget {
  const ReadingResultScreen({super.key});

  @override
  State<ReadingResultScreen> createState() => _ReadingResultScreenState();
}

class _ReadingResultScreenState extends State<ReadingResultScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[900]!.withOpacity(0.4),
              Colors.deepPurple[800]!.withOpacity(0.3),
              Colors.purple[700]!.withOpacity(0.5),
              Colors.black.withOpacity(0.9),
            ],
            stops: const [0.1, 0.4, 0.7, 0.9],
          ),
        ),
        child: BlocBuilder<TarotBloc, TarotState>(
          builder: (context, state) {
            if (state is TarotLoading) {
              return Center(
                child: Lottie.asset(
                  'assets/animations/tarot_loading.json',
                  width: 200,
                  height: 200,
                ),
              );
            } else if (state is SingleCardDrawn) {
              return Stack(
                children: [
                  // Tek kart yorumu için özel sayfa
                  _buildCardPage('Tek Kart Yorumu', state.card, null),
                  _buildCloseButton(context),
                ],
              );
            } else if (state is SpreadDrawn) {
              return Stack(
                children: [
                  // Yayılımda kartlar arasında sağa-sola geçiş
                  PageView.builder(
                    controller: _pageController,
                    itemCount: state.spread.length,
                    itemBuilder: (context, index) =>
                        _buildCardPage(
                          state.spread.keys.elementAt(index),
                          state.spread.values.elementAt(index),
                          state,
                        ),
                  ),
                  _buildCloseButton(context),
                ],
              );
            } else if (state is FalYorumuLoaded) {
              return Stack(
                children: [
                  // Kategorik yorumu içerik bölümüne ayırarak sayfa sayfa gösteriyoruz.
                  _buildFortuneTellingPage(state.yorum),
                  _buildCloseButton(context),
                ],
              );
            }
            return Center(child: Text("Bir hata oluştu"));
          },
        ),
      ),
    );
  }

  Widget _buildCardPage(String position, TarotCard card, SpreadDrawn? state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text(
            position,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrangeAccent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/tarot_card_images/${card.img}',
                        fit: BoxFit.contain,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state != null) ...[
                Positioned(
                  left: 16,
                  child: _currentPage > 0
                      ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.purple),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInCubic,
                      );
                    },
                  )
                      : SizedBox.shrink(),
                ),
                Positioned(
                  right: 16,
                  child: _currentPage < (state.spread.length - 1)
                      ? IconButton(
                    icon:
                    const Icon(Icons.arrow_forward, color: Colors.purple),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                      : SizedBox.shrink(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          if (state != null) _buildPageIndicator(state.spread.length),
          // Spacing before card name
          const SizedBox(height: 20),
          Text(
            card.name,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildKeywords(card.keywords),
          const SizedBox(height: 16),
          _buildFortuneTelling(card.fortuneTelling),
          const SizedBox(height: 16),
          _buildMeanings(card),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) =>
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              _currentPage == index ? Colors.deepOrangeAccent : Colors.white54,
            ),
          )),
    );
  }

  Widget _buildKeywords(List<String> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Anahtar Kelimeler:',
          style: TextStyle(
            fontSize: 18,
            color: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children:
          keywords.map((keyword) =>
              Chip(
                label: Text(keyword),
                backgroundColor: Colors.orange[700],
                labelStyle:
                const TextStyle(color: Colors.white),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildMeanings(TarotCard card) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.deepPurple.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Anlamlar:',
            style: TextStyle(
              fontSize: 20,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
          Card(
            color: Colors.transparent,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thumb_up, color: Colors.green[400]),
                      const SizedBox(width: 8),
                      Text(
                        'Olumlu:',
                        style: TextStyle(
                          color: Colors.green[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...card.meanings.light.map((meaning) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '* $meaning',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontFamily: 'Arial',
                          ),
                        ),
                      )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.thumb_down, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Text(
                        'Olumsuz:',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...card.meanings.shadow.map((meaning) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '* $meaning',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontFamily: 'Arial',
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTelling(List<String> fortuneTelling) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.withOpacity(0.8),
            Colors.black.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fal Yorumu:',
            style: TextStyle(
              fontSize: 20,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 12),
          ...fortuneTelling.map((fortune) =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '• $fortune',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontFamily: 'Arial',
                  ),
                ),
              )),
        ],
      ),
    );
  }


// Yorum metnini belirlenen ayırıcıya göre bölüp, her bölümü ayrı sayfada gösteren fonksiyon.
// Örneğin, yorum metni “\n### ” ifadesiyle bölünüyorsa her bölüm ayrı bir sayfa olarak sunulur.
  Widget _buildFortuneTellingPage(String yorum) {
    // Gelen yorum, belirlenen ayırıcıya göre bölünüyor.
    final sections = yorum.split(RegExp(r'\n### '));
    final PageController fortunePageController = PageController();

    return Stack(
      children: [
        PageView.builder(
          controller: fortunePageController,
          itemCount: sections.length,
          itemBuilder: (context, index) {
            // İlk bölümde ayırıcı yoksa metni aynen, diğer bölümlerde tekrar "###" ekleyerek gösteriyoruz.
            String sectionText = sections[index];
            if (index != 0) {
              sectionText = "### $sectionText";
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                // LayoutBuilder ile sayfanın mevcut yüksekliği kullanılarak içerik dinamik hale getiriliyor.
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // İlk sayfa ve metin kısa ise yönlendirici mesaj ekleniyor.
                          if (index == 0 && sectionText.length < 150)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                "Daha fazla bilgi için sağa/sola kaydırın.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepPurple.withOpacity(0.8),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                sectionText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  height: 1.5,
                                  fontFamily: 'Arial',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        // Kullanıcıya sağa/sola kaydırabileceğini hatırlatan alt bilgi.
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              "Sayfaları görmek için sağa/sola kaydırın",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        )
      ],
    );
  }


// Ekranı kapatmak için kullanılan buton.
  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: 40,
      right: 16,
      child: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }


}