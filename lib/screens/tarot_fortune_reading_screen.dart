import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_repository.dart';

import '../data/tarot_bloc.dart';
import 'card_selection_animation.dart';



///mainScreen
class TarotReadingScreen extends StatefulWidget {
  const TarotReadingScreen({super.key});

  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TarotBloc(
        repository: TarotRepository(),
      )..add(LoadTarotCards()),
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: BlocBuilder<TarotBloc, TarotState>(
          builder: (context, state) {
            if (state is TarotLoading) {
              return Center(
                child: Lottie.asset('assets/animations/tarot_loading.json'),
              );
            }
            if (state is FalYorumuLoaded) {
              return  Stack(
                  children: [
                    _buildFortuneTellingPage(state.yorum),
                    _buildCloseButton(context)
                  ]
              );
            }
            return _buildMainContent();
          },
        ),
      ),
    );
  }

  Widget _buildFortuneTellingPage(String yorum) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child:  Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.deepPurple.withOpacity(0.7),
              ]
          ),
          borderRadius: BorderRadius.circular(12),
        ),

        padding: const EdgeInsets.all(16),

        child: Text(
          yorum,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        _buildBackground(),
        _buildGradientOverlay(),
        SafeArea(
          child: Column(
            children: [
              _buildTitle(),
              const SizedBox(height: 140),
              _buildMainCard(),
              const SizedBox(height: 20),
              _buildBottomInfo(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Lottie.asset(
          'assets/animations/tarot_shuffle.json',
          fit: BoxFit.contain,
        ),
        Container(
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
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple[200]!.withOpacity(0.2),
              Colors.transparent,
              Colors.indigo[300]!.withOpacity(0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.4, 0.6, 1.0],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 100,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.red.withOpacity(0.7),
                  Colors.yellow.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.3, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple[300]!.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple[200]!,
                    Colors.white.withOpacity(0.9),
                    Colors.purple[200]!,
                  ],
                  stops: const [0.2, 0.5, 0.8],
                ).createShader(bounds),
                child: const Text(
                  '⋆ TAROT ⋆',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 12,
                    height: 1.2,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.purple,
                        offset: Offset(0, 4),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 130),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.purple[200]!.withOpacity(0.2),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: Colors.purple[200]!.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              '✧ Mistik Yolculuk ✧',
              style: TextStyle(
                color: Colors.purple[100]!.withOpacity(0.8),
                fontSize: 14,
                letterSpacing: 8,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      decoration: _buildButtonDecoration(),
      child: ElevatedButton(
        onPressed: () => _showCategorySheet(context),
        style: _buildButtonStyle(),
        child: const Text(
          'Yolculuğa Başla',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 2,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  BoxDecoration _buildButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.deepPurple[800]!.withOpacity(0.5),
          Colors.purple[900]!.withOpacity(0.4),
        ],
      ),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.purple.withOpacity(0.1),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, color: Colors.white70),
          SizedBox(width: 8),
          Text(
            'Her seçimde farklı bir yorum sizi bekliyor',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TarotBloc>(context),
        child: const CategorySelectionSheet(),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(top:

    40, right:

    16, child:

    IconButton(icon:

    const Icon(Icons.close, color:

    Colors.white), onPressed:

        () => Navigator.of(context).pop(),),);}
}

class CategorySelectionSheet extends StatelessWidget {
  const CategorySelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[900]!.withOpacity(0.5),
              Colors.transparent,
              Colors.purpleAccent[700]!.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Lottie.asset(
              'assets/animations/tarot_loading.json',
              fit: BoxFit.cover,
            ),
            Column(
              children: [
                _buildSheetHeader('Kategori Seçimi', 'Fal baktırmak istediğiniz konuyu seçin'),
                _buildInfoBanner(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildCategoryTile(context, 'Aşk & İlişkiler',
                          'İlişkileriniz hakkında derinlemesine bilgi alın',
                          Icons.favorite, 'aşk'),
                      const SizedBox(height: 12),
                      _buildCategoryTile(context, 'Kariyer',
                          'İş hayatınız ve kariyeriniz hakkında rehberlik alın',
                          Icons.work, 'kariyer'),
                      const SizedBox(height: 12),
                      _buildCategoryTile(context, 'Para',
                          'Finansal konularda içgörü kazanın',
                          Icons.attach_money, 'para'),
                      const SizedBox(height: 12),
                      _buildCategoryTile(context, 'Genel',
                          'Genel yaşam rehberliği alın',
                          Icons.psychology, 'genel'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black45.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.info_outline_sharp, color: Colors.red[100]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seçtiğiniz kategoriye göre özel açılımlar sunulacaktır',
              style: TextStyle(color: Colors.red[100]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, String title, String description, IconData icon, String category) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<TarotBloc>(context),
            child: SpreadSelectionSheet(category: category),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[400]!.withOpacity(0.6),
              Colors.blueGrey[800]!.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.amber[200], size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[300],
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpreadSelectionSheet extends StatelessWidget {
  final String category;

  const SpreadSelectionSheet({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) =>
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildSheetHeader('Açılım Seçimi', 'Kartların nasıl açılacağını seçin'),
                _buildInfoBanner('Her açılım farklı sayıda kart ve yorum içerir'),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: _buildSpreadOptions(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSheetHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.purple[700]?.withOpacity(0.3),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.purple[100]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.purple[100]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpreadOptions(BuildContext context) {
    final List<Widget> options = [];

    if (category == 'aşk') {
      options.addAll([
        _buildSpreadTile(context, 'Tek Kart', 'Hızlı cevap için ideal', 1, DrawSingleCard()),
        const SizedBox(height: 12),
        _buildSpreadTile(
            context, 'İlişki Açılımı', 'İlişkinizin detaylı analizi', 7, DrawRelationshipSpread()),
      ]);
    } else if (category == 'kariyer') {
      options.addAll([
        _buildSpreadTile(
            context, 'Üçlü Açılım', 'Kariyer yolunuz için rehberlik', 3, DrawPastPresentFuture()),
        const SizedBox(height: 12),
        _buildSpreadTile(
            context, 'Beş Kart Yol Ayrımı', 'Kariyer seçimleriniz için detaylı analiz', 5,
            DrawFiveCardPath()),
      ]);
    } else {
      options.addAll([
        _buildSpreadTile(
            context, 'Celtic Cross', 'Detaylı ve kapsamlı analiz', 10, DrawCelticCross()),
        const SizedBox(height: 12),
        _buildSpreadTile(context, 'Yıllık Açılım', '12 ay için rehberlik', 12, DrawYearlySpread()),
      ]);
    }

    return options;
  }

  Widget _buildSpreadTile(BuildContext context, String title, String description, int cardCount,
      TarotEvent event) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Alttaki sheet'i kapat
        context.read<TarotBloc>().add(event); // Bloğa event'i ekle
        // Okuma sonucuna geçmeden önce animasyon sayfasına yönlendiriyoruz.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardSelectionAnimationScreen(cardCount: cardCount),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                      '$cardCount kart', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

}
