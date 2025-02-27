import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/reading_detail_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final bloc = context.read<TarotBloc>();
    final userId = bloc.userId;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        title: Text(
          loc!.profile,
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('readings')
            .doc(userId)
            .collection('history')
            .orderBy('pinned', descending: true)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            if (kDebugMode) {
              print("Firestore Error: ${snapshot.error}");
            }
            return Center(
              child: Text(
                "Error loading readings: ${snapshot.error}",
                style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 16),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            if (kDebugMode) {
              print("No data or empty snapshot for userId: $userId");
            }
            return Center(
              child: Text(
                loc.noReadings,
                style: GoogleFonts.cinzel(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            );
          }

          // Yinelenen falları filtrele ve log ekle
          final readings = <Map<String, dynamic>>[];
          final seenEntries = <String>{}; // timestamp (saniye), spreadType ve docId ile benzersizlik
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            final timestampStr = timestamp != null ? timestamp.toIso8601String().split('.')[0] : ''; // Milisaniyeleri kaldır
            final spreadType = data['spreadType'] as String? ?? "Unknown Spread";
            final docId = doc.id;
            final yorum = data['yorum'] as String? ?? "";
            final uniqueKey = "$timestampStr-$spreadType-${yorum.substring(0, 100)}-$docId"; // İlk 100 karakter ile kontrol
            if (kDebugMode) {
              print("Processing document: $uniqueKey - Yorum: ${data['yorum']}");
            }
            if (timestampStr.isNotEmpty && !seenEntries.contains(uniqueKey)) {
              seenEntries.add(uniqueKey);
              readings.add(data);
            }
          }

          if (readings.isEmpty) {
            if (kDebugMode) {
              print("Filtered readings list is empty");
            }
            return Center(
              child: Text(
                loc.noReadings,
                style: GoogleFonts.cinzel(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: readings.length,
            itemBuilder: (context, index) {
              final reading = readings[index];
              final timestamp = (reading['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final spreadType = reading['spreadType'] as String? ?? "Unknown Spread";
              final yorum = reading['yorum'] as String? ?? "No interpretation available";
              final spread = reading['spread'] as Map<String, dynamic>? ?? {};
              final cardCount = spread.length;
              final pinned = reading['pinned'] as bool? ?? false;
              final docId = snapshot.data!.docs[index].id;

              return Card(
                color: Colors.black54,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple[900]!, Colors.purple[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            spreadType,
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            timestamp.toString().substring(0, 16),
                            style: GoogleFonts.cinzel(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        yorum.length > 100 ? "${yorum.substring(0, 100)}..." : yorum,
                        style: GoogleFonts.cinzel(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$cardCount Cards",
                        style: GoogleFonts.cinzel(
                          color: Colors.amber[200],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReadingDetailScreen(
                                    spreadType: spreadType,
                                    yorum: yorum,
                                    spread: spread,
                                    timestamp: timestamp,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple[900],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              loc.viewResults,
                              style: GoogleFonts.cinzel(color: Colors.white),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  pinned ? Icons.push_pin : Icons.push_pin_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('readings')
                                      .doc(userId)
                                      .collection('history')
                                      .doc(docId)
                                      .update({'pinned': !pinned});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('readings')
                                      .doc(userId)
                                      .collection('history')
                                      .doc(docId)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}