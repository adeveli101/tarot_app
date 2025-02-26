import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/reading_detail_screen.dart'; // Yeni ekran için import

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
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

          final readings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: readings.length,
            itemBuilder: (context, index) {
              final reading = readings[index].data() as Map<String, dynamic>;
              final timestamp = (reading['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final spreadType = reading['spreadType'] as String? ?? "Unknown Spread";
              final yorum = reading['yorum'] as String? ?? "No interpretation available";
              final spread = reading['spread'] as Map<String, dynamic>? ?? {};

              return Card(
                color: Colors.black54,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    spreadType,
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date: ${timestamp.toString().substring(0, 16)}",
                        style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        yorum.length > 100 ? "${yorum.substring(0, 100)}..." : yorum,
                        style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Tıklandığında ReadingDetailScreen'e yönlendir
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}