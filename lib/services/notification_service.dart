// lib/services/notification_service.dart

// ignore_for_file: depend_on_referenced_packages

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
import 'package:tarot_fal/main.dart'; // navigatorKey için
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme için

// --- Constants ---
// SharedPreferences Anahtarları
const String _exactAlarmPermissionRequestedKey = 'exact_alarm_permission_requested_v1'; // İzin daha önce soruldu mu?
const String _tappedPayloadKey = 'tapped_notification_payload'; // Uygulama kapalıyken tıklanan bildirim payload'ı

// Bildirim Kanalı Bilgileri (Android)
const String _androidChannelId = 'tarot_fal_rewards_channel'; // Kanal ID'si (benzersiz olmalı)
const String _androidChannelName = 'Tarot Fal Rewards'; // Kullanıcının ayarlarda göreceği kanal adı
const String _androidChannelDescription = 'Notifications for daily rewards and other app events.'; // Kanal açıklaması

// Bildirim ID'leri
const int dailyRewardNotificationId = 0;
const int genericNotificationId = 1; // Diğer bildirimler için farklı ID'ler kullanılabilir

// Uygulama İkon Adı (mipmap klasöründeki ad - uzantısız)
// !!! BU DEĞERİ KENDİ UYGULAMA İKONUNUZUN ADIYLA DEĞİŞTİRİN !!!
const String _appIconName = 'launcher_icon'; // Örn: 'ic_launcher' veya özel ikon adınız

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
        print("NotificationService: Başarıyla başlatıldı. Timezone: ${tz.local.name}");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("NotificationService Başlatma Hatası: $e\n$stackTrace");
      }
      // Burada daha kapsamlı bir hata loglama mekanizması kullanılabilir.
    }
  }

  /// Timezone veritabanını başlatır ve yerel saat dilimini ayarlar.
  Future<void> _initializeTimeZones() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      if (kDebugMode) print("Timezone başarıyla ayarlandı: $timeZoneName");
    } catch (e) {
      if (kDebugMode) print("Timezone başlatma hatası: $e");
      // Varsayılan bir timezone ayarlanabilir veya hata loglanabilir.
      tz.setLocalLocation(tz.getLocation('Etc/UTC')); // Fallback to UTC
    }
  }

  /// FlutterLocalNotifications eklentisini platforma özel ayarlarla başlatır.
  Future<void> _initializeNotifications() async {
    try {
      // Android Ayarları: Uygulama ikonunu kullanır.
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(_appIconName); // <<< UYGULAMA İKONU ADI

      // iOS Ayarları: İzinler ayrıca istenir.
      final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        // Eski iOS sürümleri için foreground bildirimlerini yakalama callback'i
        requestAlertPermission: false, // İzinleri burada isteme
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Linux Ayarları (varsa)
      // const LinuxInitializationSettings initializationSettingsLinux =
      //     LinuxInitializationSettings(defaultActionName: 'Open notification');

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        // linux: initializationSettingsLinux,
      );

      // Eklentiyi başlat ve bildirim tıklama callback'lerini ayarla
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        // Bildirime tıklandığında uygulama AÇIKKEN çağrılır
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        // Bildirime tıklandığında uygulama KAPALIYKEN/ARKA PLANDAYKEN çağrılır
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Android için bildirim kanalını oluştur (Android 8.0+)
      await _createAndroidNotificationChannel();

      if (kDebugMode) print("FlutterLocalNotifications başarıyla başlatıldı.");

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("FlutterLocalNotifications başlatma hatası: $e\n$stackTrace");
      }
    }
  }

  /// Android 8.0 ve üzeri için bildirim kanalını oluşturur.
  Future<void> _createAndroidNotificationChannel() async {
    // Sadece Android platformunda çalıştır
    if (!Platform.isAndroid) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _androidChannelId, // Kanal ID'si (sabit)
      _androidChannelName, // Kullanıcıya gösterilecek kanal adı
      description: _androidChannelDescription, // Kanal açıklaması
      importance: Importance.max, // Bildirimin önemi (ses, titreşim vb.)
      playSound: true,
      enableVibration: true,
      // Diğer ayarlar (ışık rengi vb.) eklenebilir
    );

    try {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      if (kDebugMode) print("Android bildirim kanalı oluşturuldu: $_androidChannelId");
    } catch (e) {
      if (kDebugMode) print("Android bildirim kanalı oluşturma hatası: $e");
    }
  }

  // --- İzin Yönetimi ---

  /// Gerekli bildirim izinlerini (temel ve isteğe bağlı olarak exact alarm)
  /// kontrol eder ve kullanıcıdan ister.
  /// Bu fonksiyon genellikle uygulamanın başlangıcında (örn. Splash Screen) çağrılmalıdır.
  Future<void> checkAndRequestPermissionsIfNeeded({bool requestExactAlarm = false}) async {
    if (kDebugMode) print("NotificationService: İzinler kontrol ediliyor (Exact Alarm: $requestExactAlarm)...");
    try {
      // 1. Temel Bildirim İzni
      bool notificationsGranted = await _checkAndRequestBasicNotificationPermission();
      if (!notificationsGranted && kDebugMode) {
        if (kDebugMode) {
          print("Temel bildirim izni verilmedi.");
        }
        // İzin verilmediyse kullanıcıya bilgi verilebilir (opsiyonel)
        // _showPermissionDeniedDialog('notification');
      }

      // 2. Tam Zamanlı Alarm İzni (Android)
      // Sadece istenirse, Android ise ve temel izin verildiyse kontrol et/iste
      if (requestExactAlarm && notificationsGranted && Platform.isAndroid) {
        await _checkAndRequestExactAlarmPermissionWithDialog();
      }

    } catch(e, stackTrace) {
      if (kDebugMode) print("Bildirim izinlerini isteme/kontrol etme hatası: $e\n$stackTrace");
    }
  }

  /// Temel bildirim iznini (Android 13+ POST_NOTIFICATIONS, iOS) kontrol eder ve ister.
  Future<bool> _checkAndRequestBasicNotificationPermission() async {
    PermissionStatus status = PermissionStatus.denied; // Başlangıç durumu
    bool wasDeniedPreviously = false;

    try {
      if (Platform.isIOS) {
        status = await Permission.notification.status;
        wasDeniedPreviously = status.isDenied || status.isPermanentlyDenied; // iOS'ta ilk seferde sormak yaygın
        if (status.isDenied || !status.isGranted) {
          if (kDebugMode) print(">>> iOS Notification Permission isteniyor (mevcut durum: $status)...");
          status = await Permission.notification.request();
          if (kDebugMode) print("<<< iOS bildirim izni sonucu: $status");
        }
      } else if (Platform.isAndroid) {
        // Android 13 (API 33) ve üzeri için kontrol
        status = await Permission.notification.status;
        wasDeniedPreviously = status.isDenied || status.isPermanentlyDenied;
        if (status.isDenied) {
          if (kDebugMode) print(">>> Android Notifications Permission isteniyor (mevcut durum: $status)...");
          status = await Permission.notification.request();
          if (kDebugMode) print("<<< Android bildirim izni sonucu: $status");
        }
      } else {
        status = PermissionStatus.granted; // Diğer platformlar için varsayılan
      }

      // İzin kalıcı olarak reddedildiyse kullanıcıyı bilgilendir/yönlendir
      if (status.isPermanentlyDenied && wasDeniedPreviously) {
        if (kDebugMode) print("Temel bildirim izni kalıcı olarak reddedilmiş.");
        _showPermissionDeniedDialog('notification');
      }

    } catch (e) {
      if (kDebugMode) print("Temel bildirim izni istenirken hata: $e");
      return false; // Hata durumunda izin verilmedi kabul et
    }
    return status.isGranted;
  }

  /// Tam zamanlı alarm iznini (Android 12+) kontrol eder ve gerekirse diyalogla ister.
  Future<void> _checkAndRequestExactAlarmPermissionWithDialog() async {
    // Sadece Android'de çalışır
    if (!Platform.isAndroid) return;

    PermissionStatus status = PermissionStatus.denied;
    bool shouldShowRationale = false; // Açıklama göstermek gerekli mi?

    try {
      status = await Permission.scheduleExactAlarm.status;
      shouldShowRationale = await Permission.scheduleExactAlarm.shouldShowRequestRationale;
      if (kDebugMode) print("Exact Alarm İzin Durumu (Kontrol): $status, Rationale Gerekli: $shouldShowRationale");

      // İzin zaten verilmişse veya platform desteklemiyorsa (shouldShowRequestRationale false dönerse) çık
      if (status.isGranted) {
        if (kDebugMode) print("Exact Alarm izni zaten verilmiş.");
        return;
      }
      if (status.isPermanentlyDenied) {
        if (kDebugMode) print("Exact Alarm izni kalıcı olarak reddedilmiş.");
        _showPermissionDeniedDialog('exact_alarm'); // Kullanıcıyı bilgilendir/yönlendir
        return;
      }

      // İzin reddedilmişse ve daha önce sorulmadıysa veya açıklama gerekiyorsa
      if (status.isDenied) {
        final prefs = await SharedPreferences.getInstance();
        final bool alreadyRequested = prefs.getBool(_exactAlarmPermissionRequestedKey) ?? false;

        // Daha önce sorulmadıysa VEYA sistem açıklama gösterilmesi gerektiğini söylüyorsa
        if (!alreadyRequested || shouldShowRationale) {
          if (kDebugMode) print("Exact Alarm izni için açıklama diyaloğu gösterilecek (alreadyRequested: $alreadyRequested, shouldShowRationale: $shouldShowRationale).");

          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            final bool userAgreed = await _showExactAlarmExplanationDialog(context);
            // Kullanıcı diyalogda ne seçerse seçsin, soruldu olarak işaretle
            await prefs.setBool(_exactAlarmPermissionRequestedKey, true);

            if (userAgreed && context.mounted) { // Tekrar mounted kontrolü
              if (kDebugMode) print("Kullanıcı kabul etti, sistem izni isteniyor...");
              status = await Permission.scheduleExactAlarm.request(); // Asıl sistem iznini iste
              if (kDebugMode) print("Sistem izni sonrası Exact Alarm Durumu: $status");
              if(status.isPermanentlyDenied){
                if (kDebugMode) print("Exact Alarm izni sistem tarafından kalıcı reddedildi.");
                _showPermissionDeniedDialog('exact_alarm');
              }
            } else {
              if (kDebugMode) print("Kullanıcı açıklama diyaloğunda kabul etmedi veya context kayboldu.");
            }
          } else {
            if (kDebugMode) print("Exact Alarm diyaloğu gösterilemedi: Geçerli context bulunamadı.");
          }
        } else {
          if (kDebugMode) print("Exact Alarm izni daha önce sorulmuş ve rationale gerekmiyor, tekrar sorulmuyor.");
        }
      }

    } catch (e, stackTrace) {
      if (kDebugMode) print("Exact Alarm izni istenirken hata: $e\n$stackTrace");
    }
  }

  /// Kullanıcı izni reddettiğinde veya kalıcı olarak reddettiğinde gösterilecek diyalog.
  /// Kullanıcıyı uygulama ayarlarına yönlendirmeyi teklif eder.
  Future<void> _showPermissionDeniedDialog(String permissionType) async {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      if (kDebugMode) print("İzin reddedildi diyaloğu için context bulunamadı.");
      return;
    }

    final loc = S.of(context);
    String title;
    String content;

    if (permissionType == 'notification') {
      title = loc!.notificationPermissionDeniedTitle;
      content = loc.notificationPermissionDeniedText;
    } else if (permissionType == 'exact_alarm') {
      title = loc!.exactAlarmPermissionDeniedTitle;
      content = loc.exactAlarmPermissionDeniedText;
    } else {
      return; // Bilinmeyen izin tipi
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900]?.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(children: [const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent), const SizedBox(width: 10), Expanded(child: Text(title, style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold)))]),
        content: Text(content, style: GoogleFonts.cabin(color: Colors.white70, fontSize: 15)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.later, style: GoogleFonts.cinzel(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent[100], foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(dialogContext);
              openAppSettings(); // Kullanıcıyı uygulama ayarlarına yönlendir
            },
            child: Text(loc.settings, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)), // Ayarlar butonu
          ),
        ],
      ),
    );
  }


  /// Exact alarm izni için açıklama diyaloğunu gösterir.
  Future<bool> _showExactAlarmExplanationDialog(BuildContext context) async {
    final loc = S.of(context);
    final String titleText = loc!.exactAlarmPermissionTitle;
    final String explanationText = loc.exactAlarmPermissionExplanation;
    final String laterText = loc.later;
    final String allowText = loc.allow;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Kullanıcı dışarı tıklayarak kapatamasın
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.deepPurple[900]?.withOpacity(0.95),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)) // Kenarlık rengi
        ),
        title: Row(
          children: [
            const Icon(Icons.alarm_add_rounded, color: Colors.cyanAccent),
            const SizedBox(width: 10),
            Expanded(child: Text(titleText, style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(explanationText, style: GoogleFonts.cabin(color: Colors.white70, fontSize: 15)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            onPressed: () => Navigator.pop(dialogContext, false), // Kullanıcı "Sonra" dedi
            child: Text(laterText, style: GoogleFonts.cinzel(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent[100],
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true), // Kullanıcı "İzin Ver" dedi
            child: Text(allowText, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false; // Dialog bir şekilde kapanırsa false döndür
  }


  // --- Bildirim Planlama ---

  /// Belirtilen zamanda günlük ödül bildirimini planlar.
  /// Başlık ve içerik için yerelleştirme anahtarları alır.
  Future<void> scheduleDailyRewardNotification({
    required DateTime scheduledTime,
    required String titleKey, // Örn: "dailyRewardNotificationTitle"
    required String bodyKey,  // Örn: "dailyRewardNotificationBody"
    String payload = 'daily_reward_available', // Bildirime tıklanınca kullanılacak payload
  }) async {
    // Geçmiş bir zamana bildirim planlama
    if (scheduledTime.isBefore(DateTime.now())) {
      if (kDebugMode) print("Geçmiş zamana bildirim planlanamaz: $scheduledTime");
      return;
    }

    // Yerelleştirilmiş metinleri al
    final context = navigatorKey.currentContext;
    if (context == null) {
      if (kDebugMode) print("Günlük ödül bildirimi için context alınamadı.");
      // Context yoksa belki varsayılan İngilizce metinler kullanılabilir
      // veya işlem iptal edilebilir. Şimdilik iptal edelim.
      return;
    }
    final loc = S.of(context);
    // Sınıfınızın bu anahtarları desteklediğinden emin olun
    final String title = _getLocalizedValue(loc!, titleKey, "Ödül Hazır!"); // Fallback eklendi
    final String body = _getLocalizedValue(loc, bodyKey, "Günlük ödülünü almayı unutma!"); // Fallback eklendi

    try {
      // Android Bildirim Detayları
      final AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        _androidChannelId, // Oluşturulan kanalın ID'si
        _androidChannelName, // Kanal adı
        channelDescription: _androidChannelDescription, // Kanal açıklaması
        importance: Importance.max, // En yüksek önem seviyesi
        priority: Priority.high, // En yüksek öncelik
        ticker: title, // Bildirim geldiğinde durum çubuğunda kısa süre görünen metin
        icon: _appIconName, // <<< UYGULAMA İKONU ADI
        // largeIcon: FilePathAndroidBitmap('drawable/app_logo_large'), // İsteğe bağlı büyük ikon
        playSound: true,
        enableVibration: true,
        // Bildirim rengi (isteğe bağlı)
        // color: Colors.purpleAccent,
        // Style bilgisi (varsayılan)
        styleInformation: DefaultStyleInformation(true, true),
      );

      // iOS Bildirim Detayları
      const DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true, // Bildirim gösterilsin mi?
        presentBadge: true, // Uygulama ikonu üzerinde sayı gösterilsin mi?
        presentSound: true, // Ses çalınsın mı?
        // threadIdentifier: 'daily_reward', // Bildirimleri gruplamak için (isteğe bağlı)
      );

      // Bildirimi planla
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        dailyRewardNotificationId, // Bildirim ID'si (aynı ID ile planlanırsa eskisi güncellenir)
        title, // Yerelleştirilmiş başlık
        body, // Yerelleştirilmiş içerik
        tz.TZDateTime.from(scheduledTime, tz.local), // Yerel saate göre planla
        NotificationDetails(
          android: androidNotificationDetails,
          iOS: darwinNotificationDetails,
        ),
        payload: payload, // Tıklanınca gönderilecek veri
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Cihaz uyku modundayken bile tam zamanında tetikle (izin gerektirir)
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // Zamanı mutlak olarak yorumla
      );
      if (kDebugMode) { print("Günlük ödül bildirimi planlandı: $scheduledTime"); }
    } catch (e, stackTrace) {
      if (kDebugMode) { print("Günlük ödül bildirimi planlama hatası: $e\n$stackTrace"); }
    }
  }

  /// Basit bir yerelleştirme anahtarı alma yardımcısı (fallback ile).
  String _getLocalizedValue(S loc, String key, String fallback) {
    try {
      // Yerelleştirme sınıfında anahtarın var olup olmadığını kontrol etmek
      // veya doğrudan çağırmak yerine daha güvenli bir yöntem kullanmak iyi olabilir.
      // Şimdilik doğrudan çağırıyoruz. Hata durumunda fallback dönecek.
      // Örneğin: loc.lookup(key) gibi bir metot varsa o kullanılabilir.
      // Veya S sınıfının generate ettiği yapıya göre dinamik erişim:
      switch (key) {
        case 'dailyRewardNotificationTitle': return loc.dailyRewardNotificationTitle;
        case 'dailyRewardNotificationBody': return loc.dailyRewardNotificationBody;
      // Diğer anahtarlar için case'ler eklenebilir...
        default: return fallback;
      }
    } catch (e) {
      if (kDebugMode) print("Yerelleştirme anahtarı '$key' alınamadı: $e");
      return fallback;
    }
  }

  // --- Bildirim İptal Etme ---

  /// Belirtilen ID'ye sahip planlanmış bildirimi iptal eder.
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      if (kDebugMode) print("Bildirim iptal edildi: ID $id");
    } catch (e) {
      if (kDebugMode) print("Bildirim iptal etme hatası (ID: $id): $e");
    }
  }

  /// Tüm planlanmış bildirimleri iptal eder.
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      if (kDebugMode) print("Tüm bildirimler iptal edildi.");
    } catch (e) {
      if (kDebugMode) print("Tüm bildirimleri iptal etme hatası: $e");
    }
  }

  // --- Bildirim Callback'leri ---

  /// iOS < 10 için foreground'da bildirim alındığında tetiklenir.
  /// Genellikle modern uygulamalarda çok kullanılmaz.
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Burada kullanıcıya bir dialog veya başka bir UI elemanı gösterilebilir.
    if (kDebugMode) print('Foreground iOS (<10) bildirimi alındı: $id, Payload: $payload');
    // Örnek: Dialog gösterme
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted && title != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(body ?? ''),
          actions: [ TextButton( child: const Text('Ok'), onPressed: () => Navigator.of(context).pop(),)],
        ),
      );
    }
  }

  /// Bildirime tıklandığında uygulama AÇIKKEN veya ARKA PLANDAYKEN tetiklenir.
  void onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (kDebugMode) print('Bildirim tıklandı (App Açık/Arka Plan): ID ${response.id}, Payload: $payload');

    if (payload != null) {
      // Payload'a göre yönlendirme yap
      _handlePayloadNavigation(payload);
    }
  }

  /// Bildirime tıklandığında uygulama KAPALIYKEN tetiklenir.
  /// Bu fonksiyon main isolate dışında çalışır, UI işlemleri yapılamaz.
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    // Uygulama kapalıyken çalışır.
    // Karmaşık işlemler veya UI güncellemeleri YAPILAMAZ.
    // Payload'ı kaydedip uygulama açıldığında kontrol etmek en iyi yöntemdir.
    if (kDebugMode) print('Bildirim tıklandı (App Kapalı): ID ${response.id}, Payload: ${response.payload}');
    if (response.payload != null) {
      // Payload'ı SharedPreferences'a kaydet
      NotificationPayloadHandler.saveTappedPayload(response.payload!);
    }
  }

  /// Payload değerine göre ilgili ekrana yönlendirme yapar.
  void _handlePayloadNavigation(String payload) {
    if (kDebugMode) print("Payload yönlendirmesi işleniyor: $payload");
    final context = navigatorKey.currentContext;
    final navigator = navigatorKey.currentState;

    if (context == null || navigator == null || !context.mounted) {
      if (kDebugMode) print("Payload yönlendirmesi için geçerli context/navigator bulunamadı.");
      return;
    }

    try {
      if (payload == 'daily_reward_available') {
        // Örnek: Ana ekrana git ve ödül sekmesini/alanını açtır
        // (Ana ekranınızda bu argümanı kontrol eden bir mantık olmalı)
        if (kDebugMode) print("Günlük ödül sayfasına yönlendiriliyor...");
        navigator.pushNamedAndRemoveUntil('/home', (route) => false, arguments: {'openRewardSection': true});
      } else if (payload.startsWith('reading_ready:')) {
        // Örnek: Belirli bir okuma detayına git
        // final readingId = payload.split(':')[1];
        // navigator.pushNamed(context, '/readingDetail', arguments: readingId);
        if (kDebugMode) print("Okuma detay sayfasına yönlendiriliyor (ID: ...)");
        // navigator.push(context, MaterialPageRoute(builder: (_) => ReadingDetailScreen(readingId: readingId)));
      }
      // Diğer payload türleri için else if blokları...
      else {
        if (kDebugMode) print("Bilinmeyen payload, ana ekrana yönlendiriliyor: $payload");
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) print("Payload yönlendirme hatası: $e\n$stackTrace");
    }
  }

} // NotificationService sonu

// --- Bildirim Payload İşleyici Yardımcı Sınıfı ---

/// Uygulama kapalıyken tıklanan bildirim payload'ını SharedPreferences'a
/// kaydetmek ve okumak için basit bir yardımcı sınıf.
class NotificationPayloadHandler {

  /// Uygulama kapalıyken tıklanan son payload'ı kaydeder.
  static Future<void> saveTappedPayload(String payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tappedPayloadKey, payload);
      if (kDebugMode) print("Kaydedilen tıklanmış payload: $payload");
    } catch (e) {
      if (kDebugMode) print("Payload kaydetme hatası: $e");
    }
  }

  /// Kaydedilmiş payload'ı alır ve SİLEREK döndürür (tek seferlik kullanım için).
  static Future<String?> getAndClearTappedPayload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? payload = prefs.getString(_tappedPayloadKey);
      if (payload != null) {
        await prefs.remove(_tappedPayloadKey); // Aldıktan sonra sil
        if (kDebugMode) print("Alınan ve temizlenen payload: $payload");
        return payload;
      }
    } catch (e) {
      if (kDebugMode) print("Payload alma/temizleme hatası: $e");
    }
    return null;
  }
}
