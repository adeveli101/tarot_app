// lib/services/notification_service.dart

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io'; // Platform kontrolü için
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // AlertDialog için gerekli
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart'; // Dialog fontları için
import 'package:permission_handler/permission_handler.dart'; // permission_handler import et
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import et
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tarot_fal/main.dart'; // <<< navigatorKey'i import et

// SharedPreferences anahtarı
const String _exactAlarmPermissionRequestedKey = 'exact_alarm_permission_requested';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ignore: unused_field
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const int dailyRewardNotificationId = 0;

  Future<void> initialize() async {
    try {
      await _initializeTimeZones();
      await _initializeNotifications();
      // İzin istemeyi initialize'dan kaldırıyoruz, splash screen tetikleyecek.
      // await requestPermissionsIfNeeded(requestExactAlarm: true);

      if (kDebugMode) {
        print("NotificationService: Başarıyla başlatıldı. Timezone: ${tz.local.name}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("NotificationService Başlatma Hatası: $e");
      }
    }
  }

  // Timezone başlatma (aynı)
  Future<void> _initializeTimeZones() async { /* ... önceki kod ... */ }

  // Bildirimleri başlatma (aynı, onDidReceiveLocalNotification satırı yorumlu/silinmiş olmalı)
  Future<void> _initializeNotifications() async { /* ... önceki kod ... */ }

  // --- YENİ: İzin Kontrol ve İsteme Mantığı ---
  Future<void> checkAndRequestPermissionsIfNeeded({bool requestExactAlarm = false}) async {
    if (kDebugMode) print("NotificationService: İzinler kontrol ediliyor...");
    try {
      // 1. Normal Bildirim İzni (POST_NOTIFICATIONS - Android 13+)
      bool notificationsGranted = await _checkAndRequestBasicNotificationPermission();

      // 2. Tam Zamanlı Alarm İzni (SCHEDULE_EXACT_ALARM - Android 12+)
      // Sadece istenirse ve normal bildirim izni verildiyse kontrol et/iste
      if (requestExactAlarm && notificationsGranted && Platform.isAndroid) {
        await _checkAndRequestExactAlarmPermissionWithDialog();
      }

    } catch(e) {
      if (kDebugMode) print("Bildirim izinlerini isteme/kontrol etme hatası: $e");
    }
  }

  // Temel bildirim iznini kontrol eder ve ister
  Future<bool> _checkAndRequestBasicNotificationPermission() async {
    PermissionStatus status;
    if (Platform.isIOS) {
      status = await Permission.notification.status;
      if (status.isDenied) { // iOS'ta genellikle ilk seferde sorulur
        if (kDebugMode) print(">>> iOS Notification Permission isteniyor...");
        status = await Permission.notification.request();
        if (kDebugMode) print("<<< iOS bildirim izni sonucu: $status");
      }
    } else if (Platform.isAndroid) {
      // Android 13+ için (permission_handler Tiramisu ve üzerini anlar)
      status = await Permission.notification.status;
      if (status.isDenied) {
        if (kDebugMode) print(">>> Android Notifications Permission isteniyor...");
        status = await Permission.notification.request();
        if (kDebugMode) print("<<< Android bildirim izni sonucu: $status");
      }
    } else {
      status = PermissionStatus.granted; // Diğer platformlar için varsayılan
    }
    return status.isGranted;
  }

  // Exact Alarm iznini kontrol eder, gerekirse diyalogla ister
  Future<void> _checkAndRequestExactAlarmPermissionWithDialog() async {
    var status = await Permission.scheduleExactAlarm.status;
    if (kDebugMode) print("Exact Alarm İzin Durumu (Kontrol): $status");

    // İzin zaten verilmişse veya platform desteklemiyorsa çık
    if (status.isGranted || !await Permission.scheduleExactAlarm.shouldShowRequestRationale) {
      if(!status.isGranted && kDebugMode) {
        if (kDebugMode) {
        print("Exact Alarm izni verilmemiş veya platform desteklemiyor.");
      }
      return;
    }}


    // Daha önce soruldu mu?
    final prefs = await SharedPreferences.getInstance();
    final bool alreadyRequested = prefs.getBool(_exactAlarmPermissionRequestedKey) ?? false;

    if (status.isDenied && !alreadyRequested) {
      if (kDebugMode) print("Exact Alarm izni için açıklama diyaloğu gösterilecek.");

      // Diyalog göstermek için navigatorKey'i kullan
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) { // Context var mı ve bağlı mı?
        final bool userAgreed = await _showExactAlarmExplanationDialog(context);

        // Soruldu olarak işaretle
        await prefs.setBool(_exactAlarmPermissionRequestedKey, true);

        if (userAgreed && context.mounted) { // Tekrar mounted kontrolü
          if (kDebugMode) print("Kullanıcı kabul etti, sistem izni isteniyor...");
          status = await Permission.scheduleExactAlarm.request(); // Asıl izni iste
          if (kDebugMode) print("Sistem izni sonrası Exact Alarm Durumu: $status");
        } else {
          if (kDebugMode) print("Kullanıcı açıklama diyaloğunda kabul etmedi veya context kayboldu.");
        }
      } else {
        if (kDebugMode) print("Exact Alarm diyaloğu gösterilemedi: Geçerli context bulunamadı.");
      }
    } else if (alreadyRequested) {
      if (kDebugMode) print("Exact Alarm izni daha önce sorulmuş, tekrar sorulmuyor.");
    } else if (status.isPermanentlyDenied){
      if (kDebugMode) print("Exact Alarm izni kalıcı olarak reddedilmiş.");
      // Burada kullanıcıyı ayarlara yönlendirme mantığı eklenebilir (openAppSettings())
    }
  }

  // Açıklama Diyaloğu (NotificationService içine taşındı, Context parametresi aldı)
  Future<bool> _showExactAlarmExplanationDialog(BuildContext context) async {
    // TODO: Yerelleştirme metinlerini l10n'dan almak için S.of(context) kullan
    // veya sabit metinleri kullanmaya devam et.
    const String titleText = "Bildirim İzni Gerekli";
    const String explanationText = "Günlük ödülünüz hazır olduğunda size tam zamanında bildirim gönderebilmemiz için 'Alarmlar ve hatırlatıcılar' iznine ihtiyacımız var. Bu izin verilmezse bildirimler gecikebilir veya hiç gelmeyebilir.";
    const String laterText = "Sonra";
    const String allowText = "İzin Ver";

    return await showDialog<bool>(
      context: context, // Parametre olarak gelen context'i kullan
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.deepPurple[900]?.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row( /* ... (önceki kod) ... */ children: [const Icon(Icons.alarm_add_rounded, color: Colors.cyanAccent), const SizedBox(width: 10), Expanded(child: Text(titleText,style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold),),),],),
        content: Text(explanationText, style: GoogleFonts.cabin(color: Colors.white70, fontSize: 15),),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(style: TextButton.styleFrom(foregroundColor: Colors.white70), onPressed: () => Navigator.pop(dialogContext, false), child: Text(laterText, style: GoogleFonts.cinzel(fontWeight: FontWeight.w600)),),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent[100], foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),), onPressed: () => Navigator.pop(dialogContext, true), child: Text(allowText, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),),
        ],
      ),
    ) ?? false;
  }


  // Bildirim planlama ve iptal metotları (öncekiyle aynı)
  Future<void> scheduleDailyRewardNotification({ required DateTime scheduledTime, required String titleKey, required String bodyKey, String payload = 'daily_reward_available',}) async { /* ... önceki kod ... */ }
  Future<void> cancelNotification(int id) async { /* ... önceki kod ... */ }
  Future<void> cancelAllNotifications() async { /* ... önceki kod ... */ }

  // Bildirim callback'leri (öncekiyle aynı)
  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async { /* ... */ }
  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async { /* ... */ }
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse notificationResponse) { /* ... */ }

} // NotificationService sonu