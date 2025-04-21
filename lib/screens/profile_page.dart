// lib/screens/profile_page.dart

import 'dart:ui'; // BackdropFilter için
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // kDebugMode için
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme
// --- HATA DÜZELTME: Doğru ve tek TapAnimatedScale importu ---
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';
// --- Bitiş: HATA DÜZELTME ---
import 'package:tarot_fal/screens/reading_detail_screen.dart'; // Detay ekranı

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Arka plan widget'ı
  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset( 'assets/image_fx_c.jpg', fit: BoxFit.cover, gaplessPlayback: true,),
        Container( // Gradient
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [ Colors.deepPurple[900]!.withOpacity(0.7), Colors.black.withOpacity(0.9),],
              stops: const [0.0, 0.8],
            ),
          ),
        ),
      ],
    );
  }

  // Özel AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context, S loc) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        loc.profile, // VEYA loc.readingHistory (yerelleştirme anahtarı mevcutsa)
        style: GoogleFonts.cinzelDecorative( color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,),
      ),
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(color: Colors.black.withOpacity(0.1)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final bloc = context.read<TarotBloc>();
    final userId = bloc.userId;

    if (userId == null || userId.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(context, loc!),
        body: Center(
          child: Text(
            loc.errorMessage("User not logged in."), // TODO: Yerelleştir
            style: GoogleFonts.lato(color: Colors.redAccent),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, loc!),
      body: Stack(
        children: [
          _buildBackground(),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('readings')
                .doc(userId)
                .collection('history')
                .orderBy('pinned', descending: true)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
              }
              if (snapshot.hasError) {
                if (kDebugMode) { print("Profil Sayfası - Firestore Hata: ${snapshot.error}"); }
                return Center(
                  child: Text(
                    // TODO: Yerelleştir (loc.errorLoadingReadings)
                    "Error loading readings.",
                    style: GoogleFonts.lato(color: Colors.redAccent[100], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                if (kDebugMode) { print("Profil Sayfası: Kullanıcı ($userId) için geçmiş okuma bulunamadı."); }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_edu_outlined, size: 60, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text(
                        // TODO: Yerelleştir (loc.noReadingsYet)
                        "No past readings found yet.",
                        style: GoogleFonts.cinzel( color: Colors.white.withOpacity(0.6), fontSize: 16,),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                // AppBar + üst boşluk kadar padding
                padding: EdgeInsets.only(top: (Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight) + 30, left: 12, right: 12, bottom: 20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final readingData = doc.data() as Map<String, dynamic>;
                  final docId = doc.id;
                  return _buildReadingListItem(context, loc, readingData, docId, userId);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Tek bir geçmiş okuma kartını oluşturan yardımcı metot
  Widget _buildReadingListItem(BuildContext context, S loc, Map<String, dynamic> readingData, String docId, String userId) {
    final timestamp = (readingData['timestamp'] as Timestamp?)?.toDate();
    final formattedDate = timestamp != null
    // TODO: Yerelleştir (loc.unknownDate)
        ? DateFormat.yMd(Localizations.localeOf(context).toString()).add_jm().format(timestamp) : "Unknown Date";

    // TODO: Yerelleştir (loc.unknownSpread)
    final spreadType = readingData['spreadType'] as String? ?? "Unknown Spread";
    // TODO: Yerelleştir (loc.noInterpretationAvailable)
    final yorum = readingData['yorum'] as String? ?? "No interpretation available.";
    final spreadMap = readingData['spread'] as Map<String, dynamic>? ?? {};
    final cardCount = spreadMap.length;
    final pinned = readingData['pinned'] as bool? ?? false;

    final List<Widget> cardImages = spreadMap.entries.map((entry) {
      final cardData = entry.value as Map<String, dynamic>? ?? {};
      final img = cardData['img'] as String?;
      if (img != null) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Image.asset(
            'assets/tarot_card_images/$img', height: 30,
            errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 20, color: Colors.white24),
          ),
        );
      }
      return const SizedBox.shrink();
    }).toList();


    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: pinned ? Colors.yellowAccent.shade100.withOpacity(0.6) : Colors.purpleAccent.withOpacity(0.3),
          width: pinned ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push( context, MaterialPageRoute( builder: (context) => ReadingDetailScreen(
            spreadType: spreadType, yorum: yorum, spread: spreadMap, timestamp: timestamp ?? DateTime.now(),
          ),),);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      spreadType.replaceAllMapped(RegExp(r'(?=[A-Z])'), (match) => ' '),
                      style: GoogleFonts.cinzel( color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold,),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // --- HATA DÜZELTME: TapAnimatedScale doğru kullanıldı ---
                  TapAnimatedScale(
                    onTap: () => _togglePinStatus(context, userId, docId, !pinned),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon( pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, color: pinned ? Colors.yellowAccent.shade100 : Colors.white60, size: 22,),
                    ),
                  ),
                  TapAnimatedScale(
                    onTap: () => _deleteReading(context, loc, userId, docId),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon( Icons.delete_outline_rounded, color: Colors.redAccent[100], size: 22,),
                    ),
                  ),
                  // --- Bitiş: HATA DÜZELTME ---
                ],
              ),
              const SizedBox(height: 6),
              Text( formattedDate, style: GoogleFonts.lato( color: Colors.white.withOpacity(0.6), fontSize: 12,),),
              Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 20),
              Text(
                yorum.length > 120 ? "${yorum.substring(0, 120)}..." : yorum,
                style: GoogleFonts.lato( color: Colors.white.withOpacity(0.85), fontSize: 14, height: 1.4,),
                maxLines: 3, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (cardImages.isNotEmpty)
                SingleChildScrollView( scrollDirection: Axis.horizontal, child: Row(children: cardImages),),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row( children: [
                    Icon(Icons.style_outlined, size: 16, color: Colors.purpleAccent[100]),
                    const SizedBox(width: 6),
                    Text(
                      // TODO: Yerelleştir (loc.cardCount(cardCount))
                      "$cardCount Cards",
                      style: GoogleFonts.lato( color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500 ),
                    ),
                  ],),
                  // --- HATA DÜZELTME: TapAnimatedScale doğru kullanıldı ---
                  TapAnimatedScale(
                    onTap: () {
                      Navigator.push( context, MaterialPageRoute( builder: (context) => ReadingDetailScreen(
                        spreadType: spreadType, yorum: yorum, spread: spreadMap, timestamp: timestamp ?? DateTime.now(),
                      ),),);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.deepPurple.shade700.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.purpleAccent.withOpacity(0.4))
                      ),
                      child: Row( mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            // TODO: Yerelleştir (loc.viewDetails)
                            "View Details",
                            style: GoogleFonts.cinzel(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white70),
                        ],),
                    ),
                  ),
                  // --- Bitiş: HATA DÜZELTME ---
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bir okumayı sabitleme durumunu değiştirir.
  Future<void> _togglePinStatus(BuildContext context, String userId, String docId, bool newPinStatus) async {
    try {
      await FirebaseFirestore.instance.collection('readings').doc(userId).collection('history').doc(docId).update({'pinned': newPinStatus});
      if (kDebugMode) { print("Okuma ($docId) sabitlenme durumu güncellendi: $newPinStatus"); }
      // Opsiyonel: Başarı mesajı
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(newPinStatus ? "Okuma sabitlendi." : "Sabitleme kaldırıldı."), duration: Duration(seconds: 1),));
    } catch (e) {
      if (kDebugMode) { print("Sabitleme durumu güncellenirken hata: $e"); }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarısız oldu."))); // TODO: Yerelleştir
    }
  }

  /// Bir okumayı Firestore'dan siler (onay aldıktan sonra).
  Future<void> _deleteReading(BuildContext context, S loc, String userId, String docId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            // TODO: Yerelleştir (loc.confirmDeletion)
              "Confirm Deletion",
              style: GoogleFonts.cinzel(color: Colors.white)),
          content: Text(
            // TODO: Yerelleştir (loc.confirmDeletionMessage)
              "Are you sure you want to delete this reading permanently?",
              style: GoogleFonts.lato(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: Text(loc.cancel, style: GoogleFonts.cinzel(color: Colors.white70)),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(
                // TODO: Yerelleştir (loc.delete)
                  "Delete",
                  style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('readings').doc(userId).collection('history').doc(docId).delete();
        if (kDebugMode) { print("Okuma ($docId) silindi."); }
        ScaffoldMessenger.of(context).showSnackBar(
          // TODO: Yerelleştir (loc.readingDeleted)
          SnackBar(content: Text("Reading deleted."), duration: Duration(seconds: 2)),
        );
      } catch (e) {
        if (kDebugMode) { print("Okuma silinirken hata: $e"); }
        ScaffoldMessenger.of(context).showSnackBar(
          // TODO: Yerelleştir (loc.errorDeletingReading)
          SnackBar(content: Text("Error deleting reading.")),
        );
      }
    }
  }
}