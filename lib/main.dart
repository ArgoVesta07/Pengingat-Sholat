import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
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
    'gps_updated': 'Lokasi GPS diperbarui',
    'gps_disabled': 'Layanan GPS tidak aktif',
    'gps_denied': 'Izin GPS ditolak',
    'gps_failed': 'Gagal mengambil GPS',
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
    'gps_updated': 'GPS location updated',
    'gps_disabled': 'GPS service disabled',
    'gps_denied': 'GPS permission denied',
    'gps_failed': 'Failed to get GPS location',
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
    'gps_updated': 'GPS位置情報を更新しました',
    'gps_disabled': 'GPSが無効です',
    'gps_denied': 'GPS権限が拒否されました',
    'gps_failed': 'GPS情報の取得に失敗しました',
  },
};

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String? _selectedLanguageCode; // null = mengikuti bahasa sistem

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void _setLanguageCode(String? code) {
    setState(() => _selectedLanguageCode = code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jadwal Sholat',
      themeMode: _themeMode,
      // Tema Terang (Light)
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
      // Tema Gelap (Dark)
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
        currentThemeMode: _themeMode,
        currentLanguageCode: _selectedLanguageCode,
        onThemeChanged: _setThemeMode,
        onLanguageChanged: _setLanguageCode,
      ),
    );
  }
}

class JadwalSholatScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final String? currentLanguageCode;
  final Function(ThemeMode) onThemeChanged;
  final Function(String?) onLanguageChanged;

  const JadwalSholatScreen({
    super.key,
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

  String _currentCityName = 'Takahashi, Okayama (Jepang)';
  Coordinates _currentCoordinates = Coordinates(34.7933, 133.6190);
  CalculationMethod _selectedMethod = CalculationMethod.muslim_world_league;
  late PrayerTimes _prayerTimes;

  Timer? _timer;
  Duration _timeToNextPrayer = Duration.zero;
  String _nextPrayerKey = 'fajr';
  bool _isNextDay = false;
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    _calculatePrayers();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  // Helper Lokalisasi Teks
  String _t(String key) {
    String lang = widget.currentLanguageCode ??
        View.of(context).platformDispatcher.locale.languageCode;
    if (!_translations.containsKey(lang)) lang = 'id';
    return _translations[lang]?[key] ?? key;
  }

  void _calculatePrayers() {
    final params = _selectedMethod.getParameters();
    _prayerTimes = PrayerTimes.today(_currentCoordinates, params);
    _updateCountdown();
  }

  void _updateCountdown() {
    final now = DateTime.now();
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

  void _openSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _CitySearchDialog(
        t: _t,
        onCitySelected: (String name, double lat, double lng) {
          setState(() {
            _currentCityName = name;
            _currentCoordinates = Coordinates(lat, lng);
            _calculatePrayers();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('settings'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Pilihan Tema
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
              // Pilihan Bahasa
              Text(_t('language'), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: widget.currentLanguageCode,
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final lat = position.latitude.toStringAsFixed(2);
      final lng = position.longitude.toStringAsFixed(2);

      setState(() {
        _currentCoordinates = Coordinates(position.latitude, position.longitude);
        _currentCityName = 'GPS ($lat, $lng)';
        _calculatePrayers();
      });

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
          // Tombol Pengaturan Tema & Bahasa
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: _t('settings'),
            onPressed: _openSettingsBottomSheet,
          ),
          // Tombol Metode Perhitungan
          PopupMenuButton<CalculationMethod>(
            icon: const Icon(Icons.tune),
            tooltip: _t('calc_method'),
            onSelected: (CalculationMethod method) {
              setState(() {
                _selectedMethod = method;
                _calculatePrayers();
              });
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
                // Minimal Bar Lokasi
                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _openSearchDialog,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: primaryTextColor.withOpacity(0.7), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('location'),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: primaryTextColor.withOpacity(0.4),
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
                                : Icon(Icons.my_location, color: primaryTextColor.withOpacity(0.7), size: 20),
                            onPressed: _isLoadingGps ? null : _getLocationFromGPS,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Countdown Minimalis Monokrom High-Contrast
                Container(
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
                const SizedBox(height: 20),

                // List Jadwal Sholat Minimalis
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
        border: Border.all(color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textColor.withOpacity(0.8)),
        ),
        trailing: Text(
          DateFormat.Hm().format(time),
          style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Dialog Pencarian
class _CitySearchDialog extends StatefulWidget {
  final String Function(String) t;
  final Function(String name, double lat, double lng) onCitySelected;

  const _CitySearchDialog({required this.t, required this.onCitySelected});

  @override
  State<_CitySearchDialog> createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends State<_CitySearchDialog> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _searching = false;

  Future<void> _searchCity(String query) async {
    if (query.trim().length < 2) return;
    setState(() => _searching = true);

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _results = json.decode(response.body);
        });
      }
    } catch (_) {} 
    finally {
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