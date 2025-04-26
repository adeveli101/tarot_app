// lib/services/notification_service.dart

// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:async';
import 'dart:io'; // Platform kontrolü için

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // AlertDialog ve Navigator için
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart'; // Dialog fontları için
import 'package:permission_handler/permission_handler.dart'; // İzin yönetimi
import 'package:shared_preferences/shared_preferences.dart'; // Payload ve izin durumu kaydı için
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Projenizdeki ilgili dosyaları import edin
import 'package:tarot_fal/main.dart'; // navigatorKey için (GLOBAL OLMALI)
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme için

// --- Constants ---
// SharedPreferences Keys
const String _exactAlarmPermissionRequestedKey =
    'exact_alarm_permission_requested_v1';
const String _tappedPayloadKey = 'tapped_notification_payload';

// Notification Channel Info (Android) - Bunları yerelleştirmek başlangıçta zor olabilir.
// Kanal oluşturma genellikle context olmadan yapılır. Bu yüzden sabit bırakmak daha güvenli olabilir
// Veya initialize metoduna bir context/S instance geçirin.
const String _androidChannelId = 'tarot_fal_rewards_channel';
// TODO: Bu anahtarları l10n dosyanıza ekleyin: 'androidChannelName', 'androidChannelDescription'
const String _androidChannelNameFallback = 'Tarot Fal Rewards'; // l10n.androidChannelName
const String _androidChannelDescriptionFallback =
    'Notifications for daily rewards and other app events.'; // l10n.androidChannelDescription

// Notification IDs
const int dailyRewardNotificationId = 0;
const int genericNotificationId = 1;

// App Icon Name (Android)
const String _appIconName = '@mipmap/launcher_icon';

/// Uygulama genelinde bildirimleri yönetmek için servis sınıfı.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Servisi başlatır: Timezone ayarları, bildirim ayarları.
  /// İzin isteme işlemi bu fonksiyondan ayrılmıştır.
  Future<void> initialize() async {
    try {
      await _initializeTimeZones();
      await _initializeNotifications();
      if (kDebugMode) {
        print(
            "NotificationService: Successfully initialized. Timezone: ${tz.local.name}");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("NotificationService Initialization Error: $e\n$stackTrace");
      }
    }
  }

  /// Timezone veritabanını başlatır ve yerel saat dilimini ayarlar.
  Future<void> _initializeTimeZones() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      if (kDebugMode) print("Timezone successfully set: $timeZoneName");
    } catch (e) {
      if (kDebugMode) print("Timezone initialization error: $e");
      tz.setLocalLocation(tz.getLocation('Etc/UTC')); // Fallback to UTC
    }
  }

  /// FlutterLocalNotifications eklentisini platforma özel ayarlarla başlatır.
  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(_appIconName);

      final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        // Eski iOS < 10 için callback (yeni callback'ler tercih edilir)
        // onDidReceiveLocalNotification: onDidReceiveLocalNotification, // Genellikle kullanılmaz
      );

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      await _createAndroidNotificationChannel();

      if (kDebugMode) print("FlutterLocalNotifications successfully initialized.");
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("FlutterLocalNotifications initialization error: $e\n$stackTrace");
      }
    }
  }

  /// Android 8.0 ve üzeri için bildirim kanalını oluşturur.
  /// Not: Kanal adı ve açıklaması için yerelleştirme burada zordur, fallback kullanıldı.
  Future<void> _createAndroidNotificationChannel() async {
    if (!Platform.isAndroid) return;

    // Context burada genellikle olmaz, fallback kullanıyoruz.
    // Eğer context alabiliyorsanız:
    // final context = navigatorKey.currentContext;
    // final S? loc = context != null ? S.of(context) : null;
    // final channelName = loc?.androidChannelName ?? _androidChannelNameFallback;
    // final channelDesc = loc?.androidChannelDescription ?? _androidChannelDescriptionFallback;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelNameFallback, // Yerelleştirilmiş adı kullanın (eğer context varsa)
      description: _androidChannelDescriptionFallback, // Yerelleştirilmiş açıklamayı kullanın
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    try {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      if (kDebugMode) {
        print("Android notification channel created: $_androidChannelId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Android notification channel creation error: $e");
      }
    }
  }

  // --- Permission Management ---

  /// Gerekli bildirim izinlerini kontrol eder ve ister.
  Future<void> checkAndRequestPermissionsIfNeeded(
      {bool requestExactAlarm = false}) async {
    if (kDebugMode) {
      print(
          "NotificationService: Checking permissions (Exact Alarm: $requestExactAlarm)...");
    }
    try {
      bool notificationsGranted =
      await _checkAndRequestBasicNotificationPermission();
      if (!notificationsGranted && kDebugMode) {
        print("Basic notification permission not granted.");
        // İzin reddedildiyse _showPermissionDeniedDialog çağrılır (iç kontrol)
      }

      if (requestExactAlarm && notificationsGranted && Platform.isAndroid) {
        await _checkAndRequestExactAlarmPermissionWithDialog();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error checking/requesting permissions: $e\n$stackTrace");
      }
    }
  }

  /// Temel bildirim iznini kontrol eder ve ister.
  Future<bool> _checkAndRequestBasicNotificationPermission() async {
    PermissionStatus status = PermissionStatus.denied;
    bool wasDeniedPreviously = false;

    try {
      if (Platform.isIOS) {
        status = await Permission.notification.status;
        wasDeniedPreviously = status.isDenied || status.isPermanentlyDenied;
        if (status.isDenied || !status.isGranted) {
          if (kDebugMode) print(">>> Requesting iOS Notification Permission (current: $status)...");
          status = await Permission.notification.request();
          if (kDebugMode) print("<<< iOS notification permission result: $status");
        }
      } else if (Platform.isAndroid) {
        status = await Permission.notification.status;
        wasDeniedPreviously = status.isDenied || status.isPermanentlyDenied;
        if (status.isDenied) {
          if (kDebugMode) print(">>> Requesting Android Notifications Permission (current: $status)...");
          status = await Permission.notification.request();
          if (kDebugMode) print("<<< Android notification permission result: $status");
        }
      } else {
        status = PermissionStatus.granted;
      }

      if (status.isPermanentlyDenied && wasDeniedPreviously) {
        if (kDebugMode) print("Basic notification permission permanently denied.");
        _showPermissionDeniedDialog('notification'); // Kullanıcıyı bilgilendir
      }
    } catch (e) {
      if (kDebugMode) print("Error requesting basic notification permission: $e");
      return false;
    }
    return status.isGranted;
  }

  /// Tam zamanlı alarm iznini (Android 12+) kontrol eder ve gerekirse diyalogla ister.
  Future<void> _checkAndRequestExactAlarmPermissionWithDialog() async {
    if (!Platform.isAndroid) return;

    PermissionStatus status = PermissionStatus.denied;
    bool shouldShowRationale = false;

    try {
      status = await Permission.scheduleExactAlarm.status;
      // shouldShowRequestRationale Android 12 ve altında false dönebilir,
      // bu yüzden SharedPreferences ile kendi takibimizi de yapıyoruz.
      // shouldShowRationale = await Permission.scheduleExactAlarm.shouldShowRequestRationale; // Bu direkt kullanılmayabilir.

      if (kDebugMode) print("Exact Alarm Permission Status (Check): $status");

      if (status.isGranted) {
        if (kDebugMode) print("Exact Alarm permission already granted.");
        return;
      }
      if (status.isPermanentlyDenied) {
        if (kDebugMode) print("Exact Alarm permission permanently denied.");
        _showPermissionDeniedDialog('exact_alarm');
        return;
      }

      // İzin reddedilmişse (Denied)
      if (status.isDenied) {
        final prefs = await SharedPreferences.getInstance();
        final bool alreadyRequested = prefs.getBool(_exactAlarmPermissionRequestedKey) ?? false;

        // Daha önce hiç sorulmadıysa veya sistem rationale önermese bile
        // (çünkü kullanıcı önceden reddetmiş olabilir), bir diyalog gösterelim.
        if (!alreadyRequested) {
          if (kDebugMode) print("Showing Exact Alarm explanation dialog (first time asking or previously denied).");

          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            // Kullanıcıya neden bu izne ihtiyaç duyduğumuzu açıklayan bir diyalog göster
            final bool userAgreed = await _showExactAlarmExplanationDialog(context);
            // Diyalog gösterildiği için soruldu olarak işaretle
            await prefs.setBool(_exactAlarmPermissionRequestedKey, true);

            if (userAgreed && context.mounted) { // mounted kontrolü önemli
              if (kDebugMode) print("User agreed, requesting system permission...");
              status = await Permission.scheduleExactAlarm.request();
              if (kDebugMode) print("Exact Alarm Status after system request: $status");
              if (status.isPermanentlyDenied) {
                if (kDebugMode) print("Exact Alarm permission permanently denied by system.");
                _showPermissionDeniedDialog('exact_alarm');
              }
            } else {
              if (kDebugMode) print("User did not agree in explanation dialog or context lost.");
            }
          } else {
            if (kDebugMode) print("Cannot show Exact Alarm dialog: Valid context not found.");
          }
        } else {
          if (kDebugMode) print("Exact Alarm permission already requested before, not asking again via dialog.");
          // İsteğe bağlı: Burada direkt sistem iznini tekrar isteyebilirsiniz, ancak önerilmez.
          // status = await Permission.scheduleExactAlarm.request();
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) print("Error requesting Exact Alarm permission: $e\n$stackTrace");
    }
  }

  /// Kullanıcı izni reddettiğinde gösterilecek diyalog (Yerelleştirilmiş).
  Future<void> _showPermissionDeniedDialog(String permissionType) async {
    // Global navigatorKey kullanarak context alınıyor
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      if (kDebugMode) print("Cannot show permission denied dialog: Context is null or not mounted.");
      return;
    }

    // Yerelleştirme nesnesini al (null check ile)
    final S loc = S.of(context)!; // ! Kullanımı istendi
    String title;
    String content;

    if (permissionType == 'notification') {
      title = loc.notificationPermissionDeniedTitle;
      content = loc.notificationPermissionDeniedText;
    } else if (permissionType == 'exact_alarm') {
      title = loc.exactAlarmPermissionDeniedTitle;
      content = loc.exactAlarmPermissionDeniedText;
    } else {
      if (kDebugMode) print("Unknown permission type for dialog: $permissionType");
      return;
    }

    // Yerelleştirilmiş metinlerle diyalog göster
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900]?.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
          const SizedBox(width: 10),
          Expanded(
              child: Text(title,
                  style: GoogleFonts.cinzel(
                      color: Colors.white, fontWeight: FontWeight.bold)))
        ]),
        content: Text(content,
            style: GoogleFonts.cabin(color: Colors.white70, fontSize: 15)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.later, // Yerelleştirilmiş "Later"
                style: GoogleFonts.cinzel(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent[100],
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(dialogContext);
              openAppSettings(); // Kullanıcıyı uygulama ayarlarına yönlendir
            },
            child: Text(loc.settings, // Yerelleştirilmiş "Settings"
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Exact alarm izni için açıklama diyaloğunu gösterir (Yerelleştirilmiş).
  Future<bool> _showExactAlarmExplanationDialog(BuildContext context) async {
    // Context zaten parametre olarak geliyor
    if (!context.mounted) return false; // Ekstra güvenlik kontrolü
    final S loc = S.of(context)!; // ! Kullanımı istendi

    // Diyalog göster ve sonucunu dön (true/false)
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.deepPurple[900]?.withOpacity(0.95),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.cyanAccent.withOpacity(0.5))),
        title: Row(
          children: [
            const Icon(Icons.alarm_add_rounded, color: Colors.cyanAccent),
            const SizedBox(width: 10),
            Expanded(
                child: Text(loc.exactAlarmPermissionTitle, // Yerelleştirilmiş Title
                    style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(loc.exactAlarmPermissionExplanation, // Yerelleştirilmiş Açıklama
            style: GoogleFonts.cabin(color: Colors.white70, fontSize: 15)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(loc.later, // Yerelleştirilmiş "Later"
                style: GoogleFonts.cinzel(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent[100],
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(loc.allow, // Yerelleştirilmiş "Allow"
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ??
        false; // Diyalog kapatılırsa false dön
  }

  // --- Notification Scheduling ---

  /// Belirtilen zamanda günlük ödül bildirimini planlar (Yerelleştirilmiş).
  /// Artık `titleKey` ve `bodyKey` yerine doğrudan yerelleştirilmiş metinler beklenir.
  Future<void> scheduleDailyRewardNotification({
    required DateTime scheduledTime,
    // GÜNCELLENDİ: Artık yerelleştirme anahtarları yerine doğrudan metinler alınır
    required String localizedTitle,
    required String localizedBody,
    String payload = 'daily_reward_available',
  }) async {
    // Geçmiş zaman kontrolü aynı kalır
    if (scheduledTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        print("Cannot schedule notification for a past time: $scheduledTime");
      }
      return;
    }

    // Yerelleştirilmiş metinler zaten parametre olarak geldiği için
    // context'e veya S sınıfına burada gerek yok.

    try {
      final AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelNameFallback, // Kanal adı (init'te sabit kalabilir)
        channelDescription: _androidChannelDescriptionFallback, // Kanal açıklaması
        importance: Importance.max,
        priority: Priority.high,
        ticker: localizedTitle, // Yerelleştirilmiş başlık ticker'a da eklendi
        icon: _appIconName,
        playSound: true,
        enableVibration: true,
        styleInformation: const DefaultStyleInformation(true, true),
      );

      const DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Bildirimi planla
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        dailyRewardNotificationId,
        localizedTitle, // <<< Yerelleştirilmiş başlık kullanıldı
        localizedBody, // <<< Yerelleştirilmiş içerik kullanıldı
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: androidNotificationDetails,
          iOS: darwinNotificationDetails,
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      if (kDebugMode) {
        print("Daily reward notification scheduled for: $scheduledTime");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error scheduling daily reward notification: $e\n$stackTrace");
      }
    }
  }

  /*
  // GÜNCELLENDİ: Bu yardımcı metoda artık gerek yok, kaldırıldı.
  /// Basit bir yerelleştirme anahtarı alma yardımcısı (fallback ile).
  String _getLocalizedValue(S loc, String key, String fallback) { ... }
  */

  // --- Notification Cancellation ---

  /// Belirtilen ID'ye sahip planlanmış bildirimi iptal eder.
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      if (kDebugMode) print("Notification cancelled: ID $id");
    } catch (e) {
      if (kDebugMode) print("Error cancelling notification (ID: $id): $e");
    }
  }

  /// Tüm planlanmış bildirimleri iptal eder.
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      if (kDebugMode) print("All notifications cancelled.");
    } catch (e) {
      if (kDebugMode) print("Error cancelling all notifications: $e");
    }
  }

  // --- Notification Callbacks ---

  /// iOS < 10 için foreground'da bildirim alındığında tetiklenir (Yerelleştirilmiş Dialog).
  /// Genellikle modern uygulamalarda çok kullanılmaz.
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    if (kDebugMode) {
      print('Foreground iOS (<10) notification received: $id, Payload: $payload');
    }
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted && title != null) {
      final S loc = S.of(context)!; // Yerelleştirme
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title), // Bildirimden gelen başlık
          content: Text(body ?? ''), // Bildirimden gelen içerik
          actions: [
            TextButton(
              child: Text(loc.close), // Yerelleştirilmiş "Close"
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  /// Bildirime tıklandığında uygulama AÇIKKEN veya ARKA PLANDAYKEN tetiklenir.
  void onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (kDebugMode) {
      print(
          'Notification tapped (App Open/Background): ID ${response.id}, Payload: $payload');
    }
    if (payload != null) {
      _handlePayloadNavigation(payload);
    }
  }

  /// Bildirime tıklandığında uygulama KAPALIYKEN tetiklenir.
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    if (kDebugMode) {
      print(
          'Notification tapped (App Closed): ID ${response.id}, Payload: ${response.payload}');
    }
    if (response.payload != null) {
      // Payload'ı SharedPreferences'a kaydet (UI işlemi yok)
      NotificationPayloadHandler.saveTappedPayload(response.payload!);
    }
  }

  /// Payload değerine göre ilgili ekrana yönlendirme yapar.
  void _handlePayloadNavigation(String payload) {
    if (kDebugMode) print("Handling payload navigation for: $payload");
    // Context ve Navigator'ı global key ile al
    final context = navigatorKey.currentContext;
    final navigator = navigatorKey.currentState;

    // Context veya navigator null ise veya widget ağaçtan kaldırıldıysa işlem yapma
    if (context == null || navigator == null || !context.mounted) {
      if (kDebugMode) {
        print(
            "Cannot handle payload navigation: Valid context/navigator not found or widget not mounted.");
      }
      return;
    }

    try {
      if (payload == 'daily_reward_available') {
        if (kDebugMode) print("Navigating to home screen for daily reward...");
        navigator.pushNamedAndRemoveUntil('/home', (route) => false,
            arguments: {'openRewardSection': true});
      }
      // Diğer payload türleri için yönlendirmeler buraya eklenebilir
      // else if (payload.startsWith('some_other_action:')) { ... }
      else {
        if (kDebugMode) {
          print("Unknown payload, navigating to home screen: $payload");
        }
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) print("Payload navigation error: $e\n$stackTrace");
    }
  }
} // NotificationService sonu

// --- Notification Payload Handler Helper Class ---
// Bu sınıf UI veya yerelleştirme içermediği için aynı kalır.
class NotificationPayloadHandler {
  static Future<void> saveTappedPayload(String payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tappedPayloadKey, payload);
      if (kDebugMode) print("Saved tapped payload: $payload");
    } catch (e) {
      if (kDebugMode) print("Error saving payload: $e");
    }
  }

  static Future<String?> getAndClearTappedPayload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? payload = prefs.getString(_tappedPayloadKey);
      if (payload != null) {
        await prefs.remove(_tappedPayloadKey); // Aldıktan sonra sil
        if (kDebugMode) print("Retrieved and cleared payload: $payload");
        return payload;
      }
    } catch (e) {
      if (kDebugMode) print("Error retrieving/clearing payload: $e");
    }
    return null;
  }
}