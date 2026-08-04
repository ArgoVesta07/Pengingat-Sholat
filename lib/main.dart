import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui'; // Diperlukan untuk ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

// Dictionary Multi-Bahasa
final Map<String, Map<String, String>> _translations = {
  'id': {
    'app_title': 'JADWAL SHOLAT',
    'location': 'LOKASI',
    'towards': 'MENUJU',
    'fajr': 'Subuh',
    'dhuhr': 'Dzuhur',
    'asr': 'Ashar',
    'maghrib': 'Maghrib',
    'isha': 'Isya',
    'fajr_tomorrow': 'Subuh (Besok)',
    'search_title': 'Cari Kota / Wilayah',
    'search_hint': 'Misal: Bandung, Osaka, Tokyo...',
    'cancel': 'Batal',
    'calc_method': 'Metode Perhitungan',
    'settings': 'Pengaturan',
    'theme': 'Tema Tampilan',
    'language': 'Bahasa Aplikasi',
    'system_default': 'Sistem Perangkat',
    'light': 'Terang (Light)',
    'dark': 'Gelap (Dark)',
    'auto_device': 'Otomatis (Perangkat)',
    'gps_updated': 'Lokasi GPS diperbarui & disimpan',
    'gps_disabled': 'Layanan GPS tidak aktif',
    'gps_denied': 'Izin GPS ditolak',
    'gps_failed': 'Gagal mengambil GPS',
    'offline_notice': 'Anda sedang offline. Menampilkan lokasi tersimpan.',
    'search_offline': 'Koneksi internet diperlukan untuk mencari kota baru.',
    'time_label': 'Waktu',
    'language_search_hint': 'Cari bahasa...',
    'reminder_text': 'Jaga sholat tepat waktu. "Sesungguhnya sholat itu adalah kewajiban yang ditentukan waktunya atas orang-orang yang beriman."',
    'close': 'Tutup',
    'alarm_settings': 'Pengingat',
    'alarm_enabled': 'Alarm aktif',
    'alarm_mode_ring': 'Berdering',
    'alarm_mode_vibrate': 'Getar',
    'alarm_custom_pick': 'Import suara MP3/WAV',
    'alarm_selected_file': 'File terpilih',
    'alarm_current_ringtone': 'Nada Dering Saat Ini',
    'alarm_no_file_selected': 'Belum ada file dipilih',
    'alarm_change_file': 'Ganti File',
    'alarm_remove_file': 'Hapus nada dering',
    'alarm_volume': 'Volume Alarm',
    'alarm_test': 'Tes Suara',
    'alarm_hint': 'Ketuk ikon alarm di samping waktu sholat untuk aktifkan/matikan.',
    'alarm_select_prayers': 'Pilih waktu sholat',
    'ui_size': 'Ukuran UI',
    'ui_size_preview': 'Pratinjau Tampilan',
  },
  'en': {
    'app_title': 'PRAYER TIMES',
    'ui_size': 'UI Size',
    'location': 'LOCATION',
    'towards': 'NEXT PRAYER',
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
    'fajr_tomorrow': 'Fajr (Tomorrow)',
    'search_title': 'Search City / Area',
    'search_hint': 'E.g., London, Tokyo, New York...',
    'cancel': 'Cancel',
    'calc_method': 'Calculation Method',
    'settings': 'Settings',
    'theme': 'App Theme',
    'language': 'App Language',
    'system_default': 'System Default',
    'light': 'Light Mode',
    'dark': 'Dark Mode',
    'auto_device': 'Automatic (Device)',
    'gps_updated': 'GPS location updated & saved',
    'gps_disabled': 'GPS service disabled',
    'gps_denied': 'GPS permission denied',
    'gps_failed': 'Failed to get GPS location',
    'offline_notice': 'You are offline. Showing saved location.',
    'search_offline': 'Internet connection required to search new cities.',
    'time_label': 'Time',
    'language_search_hint': 'Search languages...',
    'reminder_text': 'Keep your prayers punctual. "Indeed, prayer has been enjoined upon the believers at fixed times."',
    'close': 'Close',
    'alarm_settings': 'Alarm',
    'alarm_enabled': 'Alarm enabled',
    'alarm_mode_ring': 'Ring',
    'alarm_mode_vibrate': 'Vibrate',
    'alarm_custom_pick': 'Import MP3/WAV file',
    'alarm_selected_file': 'Selected file',
    'alarm_current_ringtone': 'Current Ringtone',
    'alarm_no_file_selected': 'No file selected',
    'alarm_change_file': 'Change File',
    'alarm_remove_file': 'Remove ringtone',
    'alarm_volume': 'Alarm Volume',
    'alarm_test': 'Test Sound',
    'alarm_hint': 'Tap the alarm icon beside each prayer time to toggle it on/off.',
    'alarm_select_prayers': 'Select prayer times',
    'ui_size_preview': 'Live Preview',
  },
  'ja': {
    'app_title': '礼 拝 時 間',
    'location': '現在地',
    'towards': '次の礼拝まで',
    'fajr': 'ファジュル',
    'dhuhr': 'ズフル',
    'asr': 'アスル',
    'maghrib': 'マグリブ',
    'isha': 'イシャー',
    'fajr_tomorrow': 'ファジュル (明日)',
    'search_title': '都市・地域を検索',
    'search_hint': '例：東京、大阪、岡山市...',
    'cancel': 'キャンセル',
    'calc_method': '計算方法',
    'settings': '設定',
    'theme': 'テーマ',
    'language': '言語',
    'system_default': 'システム設定に従う',
    'light': 'ライト',
    'dark': 'ダーク',
    'auto_device': '自動 (デバイス設定)',
    'gps_updated': 'GPS位置情報を更新・保存しました',
    'gps_disabled': 'GPSが無効です',
    'gps_denied': 'GPS権限が拒否されました',
    'gps_failed': 'GPS情報の取得に失敗しました',
    'offline_notice': 'オフラインです。保存された位置情報を表示しています。',
    'search_offline': '新しい都市の検索にはインターネット接続が必要です。',
    'time_label': '時間',
    'language_search_hint': '言語を検索...',
    'reminder_text': '礼拝の時間を守りましょう。"本当に、礼拝は信仰する者たちに定められた時に行うべき義務である。"',
    'close': '閉じる',
    'alarm_settings': 'アラーム',
    'alarm_enabled': 'アラームを有効にする',
    'alarm_mode_ring': 'ベル',
    'alarm_mode_vibrate': 'バイブ',
    'alarm_custom_pick': 'MP3/WAVを選択',
    'alarm_selected_file': '選択されたファイル',
    'alarm_current_ringtone': '現在の着信音',
    'alarm_no_file_selected': 'ファイルが選択されていません',
    'alarm_change_file': 'ファイルを変更',
    'alarm_remove_file': '着信音を削除',
    'alarm_volume': 'アラーム音量',
    'alarm_test': 'サウンドをテスト',
    'alarm_hint': '各礼拝時間の横にあるアラームアイコンをタップしてオン/オフを切り替えます。',
    'alarm_select_prayers': '礼拝時間を選択',
    'ui_size': 'UIサイズ',
    'ui_size_preview': 'リアルタイムプレビュー',
  },
  'zh': {
    'app_title': '祈祷时间',
    'location': '位置',
    'towards': '下一次祈祷',
    'fajr': '黎明礼拜',
    'dhuhr': '中午礼拜',
    'asr': '下午礼拜',
    'maghrib': '黄昏礼拜',
    'isha': '夜礼拜',
    'fajr_tomorrow': '黎明礼拜（明天）',
    'search_title': '搜索城市/区域',
    'search_hint': '例如：北京、东京、纽约...',
    'cancel': '取消',
    'calc_method': '计算方法',
    'settings': '设置',
    'theme': '主题',
    'language': '语言',
    'system_default': '系统默认',
    'light': '浅色模式',
    'dark': '深色模式',
    'auto_device': '自动（设备）',
    'gps_updated': 'GPS位置已更新并保存',
    'gps_disabled': 'GPS服务已禁用',
    'gps_denied': 'GPS权限被拒绝',
    'gps_failed': '获取GPS位置失败',
    'offline_notice': '您处于离线状态。正在显示保存的位置。',
    'search_offline': '搜索新城市需要互联网连接。',
    'time_label': '时间',
    'language_search_hint': '搜索语言...',
    'reminder_text': '保持祷告准时。“确实，祷告已被规定在固定的时间点要求信士们遵守。”',
    'close': '关闭',
    'alarm_settings': '提醒',
    'alarm_enabled': '启用闹钟',
    'alarm_mode_ring': '响铃',
    'alarm_mode_vibrate': '振动',
    'alarm_custom_pick': '导入 MP3/WAV 文件',
    'alarm_selected_file': '已选择文件',
    'alarm_current_ringtone': '当前铃声',
    'alarm_no_file_selected': '尚未选择文件',
    'alarm_change_file': '更换文件',
    'alarm_remove_file': '删除铃声',
    'alarm_volume': '闹钟音量',
    'alarm_test': '测试声音',
    'alarm_hint': '点击祷告时间旁边的闹钟图标可打开/关闭提醒。',
    'alarm_select_prayers': '选择祷告时间',
    'ui_size': 'UI 大小',
    'ui_size_preview': '实时预览',
  },
};

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    final savedTheme = widget.prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[savedTheme];
    _selectedLanguageCode = widget.prefs.getString('language_code');
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.prefs.setInt('theme_mode', mode.index);
  }

  void _setLanguageCode(String? code) {
    setState(() => _selectedLanguageCode = code);
    if (code == null) {
      widget.prefs.remove('language_code');
    } else {
      widget.prefs.setString('language_code', code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PrayTime',
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1C1C1E),
          surface: Colors.white,
          onSurface: Color(0xFF1C1C1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F5F7),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: JadwalSholatScreen(
        prefs: widget.prefs,
        currentThemeMode: _themeMode,
        currentLanguageCode: _selectedLanguageCode,
        onThemeChanged: _setThemeMode,
        onLanguageChanged: _setLanguageCode,
      ),
    );
  }
}

class JadwalSholatScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final ThemeMode currentThemeMode;
  final String? currentLanguageCode;
  final Function(ThemeMode) onThemeChanged;
  final Function(String?) onLanguageChanged;

  const JadwalSholatScreen({
    super.key,
    required this.prefs,
    required this.currentThemeMode,
    required this.currentLanguageCode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  @override
  State<JadwalSholatScreen> createState() => _JadwalSholatScreenState();
}

class _JadwalSholatScreenState extends State<JadwalSholatScreen> {
  final Map<String, CalculationMethod> _calcMethods = {
    'Muslim World League (Global / Jepang)': CalculationMethod.muslim_world_league,
    'Kemenag / Singapore (SE Asia)': CalculationMethod.singapore,
    'Umm Al-Qura (Makkah / Arab)': CalculationMethod.umm_al_qura,
    'Egyptian Authority': CalculationMethod.egyptian,
    'ISNA (Amerika Utara)': CalculationMethod.north_america,
  };

  late String _currentCityName;
  late Coordinates _currentCoordinates;
  late CalculationMethod _selectedMethod;
  late PrayerTimes _prayerTimes;

  Timer? _timer;
  Duration _timeToNextPrayer = Duration.zero;
  String _nextPrayerKey = 'fajr';
  bool _isNextDay = false;
  bool _isLoadingGps = false;
  String _alarmMode = 'ring';
  String? _customAlarmPath;
  String? _customAlarmFileName;
  Uint8List? _customAlarmBytes;
  double _alarmVolume = 1.0;
  int _uiScalePercentage = 50;
  Set<String> _alarmPrayerTimes = {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'};
  AudioPlayer? _audioPlayer;
  DateTime? _lastAlarmPlayedAt;
  DateTime _lastCalculatedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSavedLocationAndMethod();
    _loadSavedAlarmSettings();
    _loadSavedUiScale();
    _audioPlayer = AudioPlayer();
    _calculatePrayers();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _loadSavedAlarmSettings() {
    _alarmMode = widget.prefs.getString('alarm_mode') ?? 'ring';
    _customAlarmPath = widget.prefs.getString('custom_alarm_path');
    _customAlarmFileName = widget.prefs.getString('custom_alarm_filename');
    if (kIsWeb) {
      // Di web, isi file (bytes) tidak bisa disimpan permanen antar sesi/reload,
      // jadi nama file lama dianggap tidak valid lagi sampai dipilih ulang.
      _customAlarmFileName = null;
      _customAlarmPath = null;
    }
    _alarmVolume = widget.prefs.getDouble('alarm_volume') ?? 1.0;
    _alarmPrayerTimes = {
      if (widget.prefs.getBool('alarm_fajr') ?? true) 'fajr',
      if (widget.prefs.getBool('alarm_dhuhr') ?? true) 'dhuhr',
      if (widget.prefs.getBool('alarm_asr') ?? true) 'asr',
      if (widget.prefs.getBool('alarm_maghrib') ?? true) 'maghrib',
      if (widget.prefs.getBool('alarm_isha') ?? true) 'isha',
    };
  }

  void _saveAlarmSettings() {
    widget.prefs.setString('alarm_mode', _alarmMode);
    if (_customAlarmPath != null) {
      widget.prefs.setString('custom_alarm_path', _customAlarmPath!);
    }
    if (_customAlarmFileName != null) {
      widget.prefs.setString('custom_alarm_filename', _customAlarmFileName!);
    }
    widget.prefs.setDouble('alarm_volume', _alarmVolume);
    widget.prefs.setBool('alarm_fajr', _alarmPrayerTimes.contains('fajr'));
    widget.prefs.setBool('alarm_dhuhr', _alarmPrayerTimes.contains('dhuhr'));
    widget.prefs.setBool('alarm_asr', _alarmPrayerTimes.contains('asr'));
    widget.prefs.setBool('alarm_maghrib', _alarmPrayerTimes.contains('maghrib'));
    widget.prefs.setBool('alarm_isha', _alarmPrayerTimes.contains('isha'));
  }

  void _loadSavedUiScale() {
    final saved = widget.prefs.getInt('ui_scale_percentage') ?? 50;
    _uiScalePercentage = saved.clamp(0, 100);
  }

  void _saveUiScale() {
    widget.prefs.setInt('ui_scale_percentage', _uiScalePercentage);
  }

  String _guessAlarmMimeType(String? fileName) {
    final ext = (fileName ?? '').split('.').last.toLowerCase();
    switch (ext) {
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'aac':
        return 'audio/aac';
      case 'mp3':
      default:
        return 'audio/mpeg';
    }
  }

  // Mapping non-linear: 50% = ukuran normal device (1x), 100% = 1.5x (masih nyaman
  // dibaca, nggak kegedean), 0% = 0.75x (masih nyaman dibaca, nggak kekecilan).
  double get _uiScale {
    if (_uiScalePercentage <= 50) {
      // 0% -> 0.75x ... 50% -> 1.0x
      return 0.75 + (_uiScalePercentage / 50) * 0.25;
    } else {
      // 50% -> 1.0x ... 100% -> 1.5x
      return 1.0 + ((_uiScalePercentage - 50) / 50) * 0.5;
    }
  }

  Future<void> _playAlarmSound() async {
    if (_alarmPrayerTimes.isEmpty) return;
    if (_alarmMode == 'ring') {
      await _previewAlarmSound();
    } else if (_alarmMode == 'vibrate') {
      HapticFeedback.vibrate();
    }
  }

  Future<void> _previewAlarmSound() async {
    try {
      if (_customAlarmBytes != null) {
        final uri = Uri.dataFromBytes(
          _customAlarmBytes!,
          mimeType: _guessAlarmMimeType(_customAlarmFileName),
        );
        await _audioPlayer?.setAudioSource(AudioSource.uri(uri));
      } else if (_customAlarmPath != null) {
        await _audioPlayer?.setFilePath(_customAlarmPath!);
      } else {
        return;
      }
      await _audioPlayer?.setVolume(_alarmVolume);
      await _audioPlayer?.play();
    } catch (_) {
      // Abaikan error playback (mis. file tidak valid / tidak didukung browser)
    }
  }

  void _maybePlayPrayerAlarm(DateTime now) {
    if (_alarmPrayerTimes.isEmpty) return;

    final prayerTimes = {
      'fajr': _prayerTimes.fajr,
      'dhuhr': _prayerTimes.dhuhr,
      'asr': _prayerTimes.asr,
      'maghrib': _prayerTimes.maghrib,
      'isha': _prayerTimes.isha,
    };

    for (final entry in prayerTimes.entries) {
      if (!_alarmPrayerTimes.contains(entry.key)) continue;
      final target = entry.value;
      if (now.hour == target.hour && now.minute == target.minute && now.second == target.second) {
        if (_lastAlarmPlayedAt == null || now.difference(_lastAlarmPlayedAt!).inSeconds >= 60) {
          _playAlarmSound();
          _lastAlarmPlayedAt = now;
        }
      }
    }
  }

  void _loadSavedLocationAndMethod() {
    _currentCityName = widget.prefs.getString('city_name') ?? 'Takahashi, Okayama (Jepang)';
    final lat = widget.prefs.getDouble('latitude') ?? 34.7933;
    final lng = widget.prefs.getDouble('longitude') ?? 133.6190;
    _currentCoordinates = Coordinates(lat, lng);

    final methodIndex = widget.prefs.getInt('calc_method_index') ?? 0;
    _selectedMethod = _calcMethods.values.elementAt(methodIndex);
  }

  void _saveLocation(String city, double lat, double lng) {
    widget.prefs.setString('city_name', city);
    widget.prefs.setDouble('latitude', lat);
    widget.prefs.setDouble('longitude', lng);
  }

  void _saveCalcMethod(CalculationMethod method) {
    final index = _calcMethods.values.toList().indexOf(method);
    widget.prefs.setInt('calc_method_index', index);
  }

  String _resolveLanguageCode(String localeCode) {
    if (_translations.containsKey(localeCode)) return localeCode;
    final baseCode = localeCode.split(RegExp(r'[-_]')).first;
    if (_translations.containsKey(baseCode)) return baseCode;
    return 'en';
  }

  String _t(String key) {
    final locale = View.of(context).platformDispatcher.locale;
    final rawLang = widget.currentLanguageCode ?? locale.toLanguageTag();
    final lang = _resolveLanguageCode(rawLang);
    return _translations[lang]?[key] ?? key;
  }

  void _calculatePrayers() {
    final params = _selectedMethod.getParameters();
    _prayerTimes = PrayerTimes.today(_currentCoordinates, params);
    _lastCalculatedDate = DateTime.now();
    _updateCountdown();
  }

  void _updateCountdown() {
    final now = DateTime.now();

    // Reset perhitungan otomatis jika hari berganti lewat tengah malam
    if (now.day != _lastCalculatedDate.day ||
        now.month != _lastCalculatedDate.month ||
        now.year != _lastCalculatedDate.year) {
      _calculatePrayers();
      return;
    }

    final next = _prayerTimes.nextPrayer();

    if (next == Prayer.none) {
      final params = _selectedMethod.getParameters();
      final tomorrowPrayers = PrayerTimes(
        _currentCoordinates,
        DateComponents.from(now.add(const Duration(days: 1))),
        params,
      );
      if (mounted) {
        setState(() {
          _nextPrayerKey = 'fajr';
          _isNextDay = true;
          _timeToNextPrayer = tomorrowPrayers.fajr.difference(now);
        });
      }
    } else {
      final nextTime = _prayerTimes.timeForPrayer(next);
      if (nextTime != null && mounted) {
        setState(() {
          _nextPrayerKey = _getPrayerKey(next);
          _isNextDay = false;
          _timeToNextPrayer = nextTime.difference(now);
        });
      }
    }
    if (mounted) {
      _maybePlayPrayerAlarm(now);
    }
  }

  String _getPrayerKey(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'fajr';
      case Prayer.dhuhr: return 'dhuhr';
      case Prayer.asr: return 'asr';
      case Prayer.maghrib: return 'maghrib';
      case Prayer.isha: return 'isha';
      default: return 'fajr';
    }
  }

  Prayer _prayerFromKey(String key) {
    switch (key) {
      case 'fajr': return Prayer.fajr;
      case 'dhuhr': return Prayer.dhuhr;
      case 'asr': return Prayer.asr;
      case 'maghrib': return Prayer.maghrib;
      case 'isha': return Prayer.isha;
      default: return Prayer.fajr;
    }
  }

  // --- POPUP INTERAKTIF BERSAMA EFEK BLUR (LONG PRESS) ---
  void _showPrayerDetailPopup({
    required String prayerName,
    required DateTime prayerTime,
    bool isCountdown = false,
  }) {
    final formattedTime = DateFormat.Hm().format(prayerTime);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha((0.3 * 255).round()),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
    final neutralIconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final neutralIconBackground = isDark ? Colors.white12 : const Color(0xFFF2F2F7);
    final neutralTimeColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

        if (isCountdown) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: _CountdownPopupContent(
                  targetTime: prayerTime,
                  prayerName: prayerName,
                  isDark: isDark,
                  closeLabel: _t('close'),
                ),
              ),
            ),
          );
        }

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2E).withAlpha((0.85 * 255).round())
                      : Colors.white.withAlpha((0.85 * 255).round()),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.15 * 255).round()),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha((0.1 * 255).round())
                        : Colors.black.withAlpha((0.05 * 255).round()),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: neutralIconBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time_filled_rounded,
                        size: 40,
                        color: neutralIconColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      prayerName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_t("time_label")}: $formattedTime',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: neutralTimeColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _t('reminder_text'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.grey[300] : const Color(0xFF1C1C1E),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          _t('close'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildSlideUpDialogTransition(
    BuildContext context,
    Animation<double> anim1,
    Animation<double> anim2,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.24), end: Offset.zero).animate(
      CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: anim1,
        child: child,
      ),
    );
  }

  void _openSearchDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha((0.3 * 255).round()),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Align(
            alignment: Alignment(0, 0.75),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _CitySearchDialog(
                  t: _t,
                  currentLanguageCode: widget.currentLanguageCode,
                  onCitySelected: (String name, double lat, double lng) {
                    setState(() {
                      _currentCityName = name;
                      _currentCoordinates = Coordinates(lat, lng);
                      _calculatePrayers();
                    });
                    _saveLocation(name, lat, lng);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return _buildSlideUpDialogTransition(context, anim1, anim2, child);
      },
    );
  }

  void _openSettingsBottomSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha((0.3 * 255).round()),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        ThemeMode localThemeMode = widget.currentThemeMode;
        String? localLanguageCode = widget.currentLanguageCode;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Align(
            alignment: Alignment(0, 0.75),
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  final isDark = localThemeMode == ThemeMode.dark ||
                      (localThemeMode == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness == Brightness.dark);

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E).withAlpha((0.95 * 255).round()) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('settings'),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 20),
                        Text(_t('theme'), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(value: ThemeMode.system, label: Text(_t('system_default'))),
                            ButtonSegment(value: ThemeMode.light, label: Text(_t('light'))),
                            ButtonSegment(value: ThemeMode.dark, label: Text(_t('dark'))),
                          ],
                          selected: {localThemeMode},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            setDialogState(() {
                              localThemeMode = newSelection.first;
                            });
                            widget.onThemeChanged(newSelection.first);
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(_t('language'), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1B1B1D) : const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(_t('auto_device')),
                                  subtitle: Text(_t('system_default')),
                                  selected: localLanguageCode == null,
                                  onTap: () {
                                    setDialogState(() {
                                      localLanguageCode = null;
                                    });
                                    widget.onLanguageChanged(null);
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  title: const Text('Bahasa Indonesia'),
                                  selected: localLanguageCode == 'id',
                                  trailing: localLanguageCode == 'id'
                                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                                      : null,
                                  onTap: () {
                                    setDialogState(() {
                                      localLanguageCode = 'id';
                                    });
                                    widget.onLanguageChanged('id');
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  title: const Text('English'),
                                  selected: localLanguageCode == 'en',
                                  trailing: localLanguageCode == 'en'
                                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                                      : null,
                                  onTap: () {
                                    setDialogState(() {
                                      localLanguageCode = 'en';
                                    });
                                    widget.onLanguageChanged('en');
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  title: const Text('日本語 (Japanese)'),
                                  selected: localLanguageCode == 'ja',
                                  trailing: localLanguageCode == 'ja'
                                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                                      : null,
                                  onTap: () {
                                    setDialogState(() {
                                      localLanguageCode = 'ja';
                                    });
                                    widget.onLanguageChanged('ja');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.grey[300] : const Color(0xFF1C1C1E),
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: Text(
                              _t('close'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return _buildSlideUpDialogTransition(context, anim1, anim2, child);
      },
    );
  }

  void _openAlarmSettingsBottomSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha((0.3 * 255).round()),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        String localAlarmMode = _alarmMode;
        String? localAlarmFileName = _customAlarmFileName;
        double localVolume = _alarmVolume;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Align(
            alignment: Alignment(0, 0.75),
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E).withAlpha((0.95 * 255).round()) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('alarm_settings'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _t('alarm_hint'),
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
                        ),
                        const SizedBox(height: 18),
                        RadioGroup<String>(
                          groupValue: localAlarmMode,
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              localAlarmMode = value;
                            });
                            setState(() {
                              _alarmMode = value;
                            });
                            _saveAlarmSettings();
                          },
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: Text(_t('alarm_mode_ring')),
                                value: 'ring',
                              ),
                              RadioListTile<String>(
                                title: Text(_t('alarm_mode_vibrate')),
                                value: 'vibrate',
                              ),
                            ],
                          ),
                        ),
                        if (localAlarmMode == 'ring') ...[
                          Text(
                            _t('alarm_current_ringtone'),
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B1B1D) : const Color(0xFFF5F5F7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: localAlarmFileName != null
                                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                                    : (isDark ? Colors.white12 : Colors.black12),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                leading: Icon(
                                  localAlarmFileName != null ? Icons.music_note_rounded : Icons.music_off_rounded,
                                  color: localAlarmFileName != null
                                      ? Theme.of(context).colorScheme.primary
                                      : (isDark ? Colors.white38 : Colors.black38),
                                ),
                                title: Text(
                                  localAlarmFileName ?? _t('alarm_no_file_selected'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: localAlarmFileName != null
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : (isDark ? Colors.white54 : Colors.black45),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: localAlarmFileName != null
                                    ? Text(
                                        _t('alarm_selected_file'),
                                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11),
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (localAlarmFileName != null)
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        tooltip: _t('alarm_remove_file'),
                                        color: isDark ? Colors.white54 : Colors.black45,
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                        onPressed: () {
                                          setDialogState(() {
                                            localAlarmFileName = null;
                                          });
                                          if (!mounted) return;
                                          setState(() {
                                            _customAlarmFileName = null;
                                            _customAlarmPath = null;
                                            _customAlarmBytes = null;
                                          });
                                          widget.prefs.remove('custom_alarm_filename');
                                          widget.prefs.remove('custom_alarm_path');
                                        },
                                      ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.folder_open, size: 18),
                                      label: Text(
                                        localAlarmFileName != null ? _t('alarm_change_file') : _t('alarm_custom_pick'),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      // FIX: dulu di sini manggil _pickCustomAlarmSound() lalu baca ulang
                                      // _customAlarmFileName lewat field luar -> ada celah async yang
                                      // bikin sheet ini nggak ke-refresh sampai ditutup & dibuka lagi.
                                      // Sekarang pick file langsung di sini, dan begitu hasilnya didapat,
                                      // langsung dipakai untuk update sheet (setDialogState) & state utama
                                      // (setState) di saat yang sama, tanpa lewat perantara.
                                      onPressed: () async {
                                        final result = await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['mp3', 'wav', 'ogg', 'aac'],
                                          withData: kIsWeb, // di web hanya ada bytes, tidak ada path filesystem
                                        );
                                        if (result == null || result.files.isEmpty) return;
                                        final file = result.files.single;

                                        setDialogState(() {
                                          localAlarmFileName = file.name;
                                        });

                                        if (!mounted) return;
                                        setState(() {
                                          _customAlarmFileName = file.name;
                                          _customAlarmPath = file.path;
                                          _customAlarmBytes = file.bytes;
                                        });

                                        widget.prefs.setString('custom_alarm_filename', file.name);
                                        if (file.path != null) {
                                          widget.prefs.setString('custom_alarm_path', file.path!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _t('alarm_volume'),
                                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${(localVolume * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                localVolume == 0
                                    ? Icons.volume_off_rounded
                                    : (localVolume < 0.5 ? Icons.volume_down_rounded : Icons.volume_up_rounded),
                                size: 20,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              Expanded(
                                child: Slider(
                                  value: localVolume,
                                  min: 0,
                                  max: 1,
                                  divisions: 20,
                                  label: '${(localVolume * 100).round()}%',
                                  onChanged: (value) {
                                    setDialogState(() {
                                      localVolume = value;
                                    });
                                    setState(() {
                                      _alarmVolume = value;
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    _saveAlarmSettings();
                                  },
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                label: Text(_t('alarm_test'), style: const TextStyle(fontSize: 12)),
                                onPressed: localAlarmFileName == null
                                    ? null
                                    : () async {
                                        _alarmVolume = localVolume;
                                        await _previewAlarmSound();
                                      },
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.grey[300] : const Color(0xFF1C1C1E),
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: Text(
                              _t('close'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return _buildSlideUpDialogTransition(context, anim1, anim2, child);
      },
    );
  }

  void _openUiSizeDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      // Dibikin lebih transparan drpd dialog lain, biar app asli di belakangnya
      // masih kelihatan jelas & bisa dipantau berubah live pas slider di-drag
      // (kayak slider brightness di iOS/OneUI).
      barrierColor: Colors.black.withAlpha((0.12 * 255).round()),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        int localScale = _uiScalePercentage;

        return Align(
            alignment: Alignment(0, 0.85),
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E).withAlpha((0.97 * 255).round()) : Colors.white.withAlpha((0.97 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.25 * 255).round()),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.format_size,
                                  size: 18,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _t('ui_size'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$localScale%',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                          ),
                          child: Slider(
                            value: localScale.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: '$localScale%',
                            // Update LANGSUNG ke state utama tiap drag, biar seluruh tampilan
                            // app (di belakang dialog ini) ikut membesar/mengecil real-time —
                            // bukan cuma preview mini di dalam dialog.
                            onChanged: (value) {
                              final scale = value.toInt();
                              setDialogState(() {
                                localScale = scale;
                              });
                              setState(() {
                                _uiScalePercentage = scale;
                              });
                            },
                            onChangeEnd: (value) {
                              _saveUiScale();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return _buildSlideUpDialogTransition(context, anim1, anim2, child);
      },
    );
  }

  Future<void> _getLocationFromGPS() async {
    setState(() => _isLoadingGps = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar(_t('gps_disabled'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar(_t('gps_denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(_t('gps_denied'));
        await Geolocator.openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final lat = position.latitude.toStringAsFixed(2);
      final lng = position.longitude.toStringAsFixed(2);
      final cityName = 'GPS ($lat, $lng)';

      if (mounted) {
        setState(() {
          _currentCoordinates = Coordinates(position.latitude, position.longitude);
          _currentCityName = cityName;
          _calculatePrayers();
        });
      }

      _saveLocation(cityName, position.latitude, position.longitude);
      _showSnackBar(_t('gps_updated'));
    } catch (e) {
      _showSnackBar(_t('gps_failed'));
    } finally {
      if (mounted) setState(() => _isLoadingGps = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: TextStyle(color: isDark ? Colors.black : Colors.white)),
          backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openNextPrayerPopup() {
    DateTime prayerTime;
    String nextName = _t(_nextPrayerKey);
    if (_isNextDay && _nextPrayerKey == 'fajr') {
      final params = _selectedMethod.getParameters();
      final tomorrowPrayers = PrayerTimes(
        _currentCoordinates,
        DateComponents.from(DateTime.now().add(const Duration(days: 1))),
        params,
      );
      prayerTime = tomorrowPrayers.fajr;
      nextName = _t('fajr_tomorrow');
    } else {
      final prayer = _prayerFromKey(_nextPrayerKey);
      prayerTime = _prayerTimes.timeForPrayer(prayer) ?? DateTime.now();
    }

    // Provide light haptic feedback when opening countdown popup
    HapticFeedback.selectionClick();
    _showPrayerDetailPopup(prayerName: nextName, prayerTime: prayerTime, isCountdown: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    String nextName = _t(_nextPrayerKey);
    if (_isNextDay && _nextPrayerKey == 'fajr') {
      nextName = _t('fajr_tomorrow');
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_uiScale)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_t('app_title')),
          actions: [
            PopupMenuButton<CalculationMethod>(
              tooltip: _t('calc_method'),
              icon: const Icon(Icons.tune),
              onSelected: (CalculationMethod method) {
                setState(() {
                  _selectedMethod = method;
                  _calculatePrayers();
                });
                _saveCalcMethod(method);
              },
              itemBuilder: (context) {
                return _calcMethods.entries.map((entry) {
                  return PopupMenuItem<CalculationMethod>(
                    value: entry.value,
                    child: Text(entry.key, style: const TextStyle(fontSize: 13)),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Center(
          child: SizedBox(
            width: 420,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
              children: [
                // Bar Lokasi
                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _openSearchDialog();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: primaryTextColor.withAlpha((0.7 * 255).round()), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('location'),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: primaryTextColor.withAlpha((0.4 * 255).round()),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentCityName,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primaryTextColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: _isLoadingGps
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryTextColor),
                                  )
                                : Icon(Icons.my_location, color: primaryTextColor.withAlpha((0.7 * 255).round()), size: 20),
                            onPressed: _isLoadingGps ? null : _getLocationFromGPS,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Countdown (tap or long-press to show prayer detail popup)
                GestureDetector(
                  onTap: _openNextPrayerPopup,
                  onLongPress: _openNextPrayerPopup,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252525) : const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_t("towards")} ${nextName.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDuration(_timeToNextPrayer),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // List Jadwal Sholat (Bisa di-Long Press)
                Expanded(
                  child: ListView(
                    children: [
                      _buildTimeCard(_t('fajr'), _prayerTimes.fajr, 'fajr', cardBgColor, primaryTextColor, isDark),
                      _buildTimeCard(_t('dhuhr'), _prayerTimes.dhuhr, 'dhuhr', cardBgColor, primaryTextColor, isDark),
                      _buildTimeCard(_t('asr'), _prayerTimes.asr, 'asr', cardBgColor, primaryTextColor, isDark),
                      _buildTimeCard(_t('maghrib'), _prayerTimes.maghrib, 'maghrib', cardBgColor, primaryTextColor, isDark),
                      _buildTimeCard(_t('isha'), _prayerTimes.isha, 'isha', cardBgColor, primaryTextColor, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.black12,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMenuIcon(
                        icon: Icons.alarm,
                        label: _t('alarm_settings'),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _openAlarmSettingsBottomSheet();
                        },
                      ),
                      _buildMenuIcon(
                        icon: Icons.palette_outlined,
                        label: _t('settings'),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _openSettingsBottomSheet();
                        },
                      ),
                      _buildMenuIcon(
                        icon: Icons.format_size,
                        label: _t('ui_size'),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _openUiSizeDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildMenuIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(icon, size: 26, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard(String name, DateTime time, String prayerKey, Color cardBg, Color textColor, bool isDark) {
    final alarmActive = _alarmPrayerTimes.contains(prayerKey);
    final iconColor = alarmActive
        ? Theme.of(context).colorScheme.primary
        : isDark
            ? Colors.white38
            : Colors.black38;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.transparent : Colors.black.withAlpha((0.05 * 255).round())),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          // Trigger Long-Press Popup di sini
          onLongPress: () {
            HapticFeedback.selectionClick();
            _showPrayerDetailPopup(
              prayerName: name,
              prayerTime: time,
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            title: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textColor.withAlpha((0.8 * 255).round())),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.Hm().format(time),
                  style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      if (alarmActive) {
                        _alarmPrayerTimes.remove(prayerKey);
                      } else {
                        _alarmPrayerTimes.add(prayerKey);
                      }
                      _saveAlarmSettings();
                    });
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: alarmActive
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.16)
                          : isDark
                              ? const Color(0xFF2C2C2E)
                              : const Color(0xFFF0F0F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      alarmActive ? Icons.alarm_on_rounded : Icons.alarm_outlined,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog Pencarian
class _CitySearchDialog extends StatefulWidget {
  final String Function(String) t;
  final String? currentLanguageCode;
  final Function(String name, double lat, double lng) onCitySelected;

  const _CitySearchDialog({
    required this.t,
    required this.currentLanguageCode,
    required this.onCitySelected,
  });

  @override
  State<_CitySearchDialog> createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends State<_CitySearchDialog> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _searching = false;
  String? _errorMessage;

  Future<void> _searchCity(String query) async {
    if (query.trim().length < 2) return;

    if (mounted) {
      setState(() {
        _searching = true;
        _errorMessage = null;
      });
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'PrayTimeApp/1.0 (contact@yourdomain.com)',
          'Accept-Language': widget.currentLanguageCode ?? 'id',
        },
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _results = json.decode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = widget.t('search_offline');
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = widget.t('search_offline');
        });
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.t('search_title'), style: const TextStyle(fontSize: 16)),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.t('search_hint'),
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchCity(_controller.text),
                ),
              ),
              onSubmitted: _searchCity,
            ),
            const SizedBox(height: 12),
            if (_searching) const CircularProgressIndicator(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            if (!_searching && _results.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    final displayName = item['display_name'] ?? '';
                    final shortName = displayName.split(',').take(2).join(',');
                    final lat = double.parse(item['lat']);
                    final lon = double.parse(item['lon']);

                    return ListTile(
                      dense: true,
                      title: Text(shortName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => widget.onCitySelected(shortName, lat, lon),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.t('cancel')),
        ),
      ],
    );
  }
}


class _CountdownPopupContent extends StatefulWidget {
  final DateTime targetTime;
  final String prayerName;
  final bool isDark;
  final String closeLabel;

  const _CountdownPopupContent({
    required this.targetTime,
    required this.prayerName,
    required this.isDark,
    required this.closeLabel,
  });

  @override
  State<_CountdownPopupContent> createState() => _CountdownPopupContentState();
}

class _CountdownPopupContentState extends State<_CountdownPopupContent> {
  late Duration _remaining;
  Timer? _localTimer;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _updateRemaining() {
    final now = DateTime.now();
    setState(() => _remaining = widget.targetTime.difference(now));
  }

  void _tick() {
    if (!mounted) return;
    final now = DateTime.now();
    final diff = widget.targetTime.difference(now);
    if (diff.inSeconds <= 0) {
      _localTimer?.cancel();
      setState(() => _remaining = Duration.zero);
    } else {
      setState(() => _remaining = diff);
    }
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final hours = d.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final neutralAccent = widget.isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF2C2C2E).withAlpha((0.85 * 255).round())
            : Colors.white.withAlpha((0.85 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.15 * 255).round()),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: widget.isDark ? Colors.white.withAlpha((0.1 * 255).round()) : Colors.black.withAlpha((0.05 * 255).round()),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _format(_remaining),
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w300,
              color: neutralAccent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.prayerName.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDark ? Colors.grey[300] : const Color(0xFF1C1C1E),
                foregroundColor: widget.isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                widget.closeLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}