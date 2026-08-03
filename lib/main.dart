import 'dart:async';
import 'dart:convert';
import 'dart:ui'; // Diperlukan untuk ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
    'reminder_text': 'Jaga sholat tepat waktu. "Sesungguhnya sholat itu adalah kewajiban yang ditentukan waktunya atas orang-orang yang beriman."',
    'close': 'Tutup',
  },
  'en': {
    'app_title': 'PRAYER TIMES',
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
    'reminder_text': 'Keep your prayers punctual. "Indeed, prayer has been enjoined upon the believers at fixed times."',
    'close': 'Close',
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
    'reminder_text': '礼拝の時間を守りましょう。"本当に、礼拝は信仰する者たちに定められた時に行うべき義務である。"',
    'close': '閉じる',
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
  DateTime _lastCalculatedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSavedLocationAndMethod();
    _calculatePrayers();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
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

  String _t(String key) {
    String lang = widget.currentLanguageCode ??
        View.of(context).platformDispatcher.locale.languageCode;
    if (!_translations.containsKey(lang)) lang = 'id';
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
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        color: Theme.of(context).primaryColor.withAlpha((0.15 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time_filled_rounded,
                        size: 40,
                        color: Theme.of(context).primaryColor,
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
                      'Waktu: $formattedTime',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
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
          child: Center(
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

  void _openSettingsBottomSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha((0.3 * 255).round()),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      selected: {widget.currentThemeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        widget.onThemeChanged(newSelection.first);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(_t('language'), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      initialValue: widget.currentLanguageCode,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text(_t('auto_device'))),
                        const DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
                        const DropdownMenuItem(value: 'en', child: Text('English')),
                        const DropdownMenuItem(value: 'ja', child: Text('日本語 (Japanese)')),
                      ],
                      onChanged: (code) {
                        widget.onLanguageChanged(code);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 12),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: _t('settings'),
            onPressed: () {
              HapticFeedback.selectionClick();
              _openSettingsBottomSheet();
            },
          ),
          PopupMenuButton<CalculationMethod>(
            icon: const Icon(Icons.tune),
            tooltip: _t('calc_method'),
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
                          '${_t('towards')} ${nextName.toUpperCase()}',
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
                      _buildTimeCard(_t('fajr'), _prayerTimes.fajr, cardBgColor, primaryTextColor, isDark),
                      _buildTimeCard(_t('dhuhr'), _prayerTimes.dhuhr, cardBgColor, primaryTextColor, isDark),
                      _buildTimeCard(_t('asr'), _prayerTimes.asr, cardBgColor, primaryTextColor, isDark),
                      _buildTimeCard(_t('maghrib'), _prayerTimes.maghrib, cardBgColor, primaryTextColor, isDark),
                      _buildTimeCard(_t('isha'), _prayerTimes.isha, cardBgColor, primaryTextColor, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String name, DateTime time, Color cardBg, Color textColor, bool isDark) {
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
            trailing: Text(
              DateFormat.Hm().format(time),
              style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold),
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