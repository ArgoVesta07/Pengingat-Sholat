import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math; // Diperlukan untuk animasi flip (rotateX)
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
    'theme_system_short': 'Sistem',
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
    'alarm_play_error': 'Gagal memutar suara alarm. Coba pilih ulang file-nya.',
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
    'theme_system_short': 'System',
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
    'alarm_play_error': 'Failed to play the alarm sound. Try selecting the file again.',
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
    'theme_system_short': 'システム',
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
    'alarm_play_error': 'アラーム音の再生に失敗しました。ファイルを選び直してください。',
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
    'theme_system_short': '系统',
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
    'alarm_play_error': '播放闹钟声音失败，请重新选择文件。',
    'alarm_select_prayers': '选择祷告时间',
    'ui_size': 'UI 大小',
    'ui_size_preview': '实时预览',
  },
};

// Data next-prayer yang di-tick tiap detik lewat ValueNotifier (lihat penjelasan
// di field _nextPrayerNotifier pada _JadwalSholatScreenState).
class _NextPrayerInfo {
  final Duration remaining;
  final String prayerKey;
  final bool isNextDay;
  const _NextPrayerInfo({required this.remaining, required this.prayerKey, required this.isNextDay});
}

// Widget flip generik: dipakai buat animasi "kebalik" (rotateX) tiap kali
// `child`-nya ganti (dideteksi lewat Key bawaan Flutter di dalam `child`).
// Dipakai khusus buat kartu digit countdown (lihat _buildFlipDigitCard).
class _FlipSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  const _FlipSwitcher({required this.child, this.duration = const Duration(milliseconds: 380)});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: math.pi / 2, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              // setEntry(3,2,...) ngasih efek perspective, biar rotasinya
              // kerasa "3D" (kayak kartu kebalik), bukan cuma di-squash flat.
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0025)
                ..rotateX(rotate.value),
              child: child,
            );
          },
        );
      },
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.center,
        children: [...previousChildren, if (currentChild != null) currentChild],
      ),
      child: child,
    );
  }
}

// Widget switcher khusus buat TEKS (bukan kartu digit) — dipakai buat baris
// tanggal Masehi<->Hijriyah. Sebelumnya baris tanggal ini pakai _FlipSwitcher
// yang sama dengan kartu digit (rotateX 90 derajat), tapi buat 1 baris teks
// panjang efeknya kerasa "patah"/nggak flow: teksnya lompat mendadak begitu
// animasi lewat setengah jalan, karena rotateX pada teks lebar itu nggak
// simetris kayak pada kotak digit kecil.
//
// Fix: dipisah jadi switcher sendiri yang pakai fade + slide vertikal tipis
// (kayak transisi jam digital / odometer teks) — teks lama fade-out sambil
// geser turun dikit, teks baru fade-in sambil geser naik dari bawah. Efeknya
// jauh lebih halus & "mengalir" buat baris teks, sementara kartu digit
// countdown tetap pakai _FlipSwitcher yang lama (nggak diubah, karena
// efek flip-nya emang pas buat kartu kecil).
class _SmoothTextSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  const _SmoothTextSwitcher({required this.child, this.duration = const Duration(milliseconds: 420)});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slideIn = Tween<Offset>(
          begin: const Offset(0, 0.35),
          end: Offset.zero,
        ).animate(animation);
        return ClipRect(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideIn, child: child),
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.center,
        children: [...previousChildren, if (currentChild != null) currentChild],
      ),
      child: child,
    );
  }
}

// Bikin 1 "kartu" digit -> background + border + shadow tipis + garis seam di
// tengah (khas kartu split-flap/flip clock beneran). Dipakai per-digit di
// _buildFlipTimeRow, supaya yang keliatan "flip" itu SELURUH kartunya (bukan
// cuma teks polos ngambang doang kayak sebelumnya).
//
// FIX PENGATURAN VERTIKAL DIGIT: sebelumnya digit kelihatan "turun" dikit dari
// titik tengah kartu (nggak pas ketemu garis seam di tengah), padahal sudah
// dibungkus Stack(alignment: Alignment.center). Ini bukan soal alignment,
// tapi soal font metrics -> font custom (MontserratAlternates) punya ruang
// ascent/descent bawaan yang nggak simetris terhadap baseline, jadi Flutter
// nyisain sedikit ruang ekstra di atas/bawah glyph sesuai metrik font, bukan
// sesuai bounding box digit itu sendiri. Efeknya digit kelihatan nggak
// benar-benar center walau container-nya sudah center.
//
// Fix: bungkus Text dalam Center eksplisit + kasih `strutStyle` dengan
// `forceStrutHeight: true`. Strut memaksa tinggi baris teks mengikuti
// fontSize secara ketat (height: 1.0), jadi ruang ekstra dari font metrics
// dibuang dan glyph digit jadi betul-betul center secara vertikal terhadap
// kartu & garis seam.
Widget _buildFlipDigitCard(
  String char,
  TextStyle style, {
  Key? key,
  required Color cardColor,
  required Color borderColor,
  required Color seamColor,
  required double width,
  required double height,
}) {
  // Versi simpel: flat, tanpa shadow, border tipis banget — cuma seam tengah
  // yang nunjukin ini "kartu 2 bagian" ala flip clock, sisanya polos.
  return Container(
    key: key,
    width: width,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: borderColor, width: 1),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Text(
            char,
            textAlign: TextAlign.center,
            style: style,
            strutStyle: StrutStyle(
              fontSize: style.fontSize,
              fontFamily: style.fontFamily,
              height: 1.0,
              forceStrutHeight: true,
            ),
          ),
        ),
        // Garis seam horizontal di tengah kartu -> ini yang bikin dia keliatan
        // "kartu fisik kebelah 2" kayak flip clock jadul, bukan cuma teks.
        Positioned(
          left: 0,
          right: 0,
          top: height / 2 - 0.5,
          child: Container(height: 1, color: seamColor),
        ),
      ],
    ),
  );
}

// Susun 1 baris digit/karakter countdown, tiap karakter dibungkus _FlipSwitcher
// sendiri-sendiri -> yang beneran "flip" cuma digit yang nilainya BERUBAH
// (misal detik tiap 1 detik), digit lain yang belum berubah diam aja. Lebar
// tiap karakter di-fix (SizedBox) biar nggak ada goyangan layout pas flip.
//
// UPDATE: sekarang tiap digit (bukan ":") dibungkus _buildFlipDigitCard, jadi
// yang di-rotateX itu SELURUH kartunya (background+border+seam ikut kebalik),
// bukan cuma teks polos ngambang. Colon tetap teks biasa tanpa kartu, sama
// kayak tampilan flip-clock beneran.
//
// UPDATE margin: jarak antar kartu digit sebelumnya kerapetan (padding
// horizontal cuma 0.045x fontSize per sisi). Sekarang di-lebarin jadi 0.09x
// fontSize per sisi (2x lipat) biar kartu-kartunya nggak nempel-nempel, dan
// colon juga dikasih padding kiri-kanan tipis (0.05x) biar spacing-nya
// konsisten & seimbang di kedua sisi, bukan cuma digitnya doang yang dikasih
// jarak.
Widget _buildFlipTimeRow(
  String text,
  TextStyle style, {
  Color? cardColor,
  Color? cardBorderColor,
  Color? seamColor,
}) {
  final fontSize = style.fontSize ?? 42;
  final chars = text.split('');
  final resolvedCardColor = cardColor ?? Colors.black.withValues(alpha: 0.25);
  final resolvedBorderColor = cardBorderColor ?? Colors.white24;
  final resolvedSeamColor = seamColor ?? Colors.black.withValues(alpha: 0.35);
  final digitWidth = fontSize * 0.68;
  final digitHeight = fontSize * 1.22;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(chars.length, (i) {
      final c = chars[i];
      final isColon = c == ':';

      if (isColon) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: fontSize * 0.05),
          child: SizedBox(
            width: fontSize * 0.32,
            child: Center(
              child: Text(
                c,
                textAlign: TextAlign.center,
                style: style,
                strutStyle: StrutStyle(
                  fontSize: style.fontSize,
                  fontFamily: style.fontFamily,
                  height: 1.0,
                  forceStrutHeight: true,
                ),
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: fontSize * 0.09),
        child: SizedBox(
          width: digitWidth,
          height: digitHeight,
          child: _FlipSwitcher(
            // Key gabungan posisi + nilai karakter -> AnimatedSwitcher cuma
            // trigger flip kalau NILAI di posisi itu berubah, bukan asal beda
            // karakter di posisi lain (bug sebelumnya pakai indexOf yang keliru
            // ambil posisi kemunculan PERTAMA karakter itu di seluruh string).
            child: _buildFlipDigitCard(
              c,
              style,
              cardColor: resolvedCardColor,
              borderColor: resolvedBorderColor,
              seamColor: resolvedSeamColor,
              width: digitWidth,
              height: digitHeight,
              key: ValueKey('$i-$c'),
            ),
          ),
        ),
      );
    }),
  );
}

// --- Konversi & format tanggal Masehi <-> Hijriyah ---
// Konversi pakai algoritma "Tabular Islamic Calendar" (basis Julian Day
// Number) — nggak butuh package/dependency tambahan, cukup akurat buat
// tampilan tanggal (bisa selisih ±1 hari dari rukyat/hisab resmi setempat).
int _gregorianToJulianDay(int year, int month, int day) {
  final a = ((14 - month) / 12).floor();
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      ((153 * m + 2) / 5).floor() +
      365 * y +
      (y / 4).floor() -
      (y / 100).floor() +
      (y / 400).floor() -
      32045;
}

// Return [tahunHijriyah, bulanHijriyah(1-12), tanggalHijriyah]
List<int> _gregorianToHijri(DateTime date) {
  final jd = _gregorianToJulianDay(date.year, date.month, date.day);
  var l = jd - 1948440 + 10632;
  final n = ((l - 1) / 10631).floor();
  l = l - 10631 * n + 354;
  final j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
      (l / 5670).floor() * ((43 * l) / 15238).floor();
  l = l -
      ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
      (j / 16).floor() * ((15238 * j) / 43).floor() +
      29;
  final month = ((24 * l) / 709).floor();
  final day = l - ((709 * month) / 24).floor();
  final year = 30 * n + j - 30;
  return [year, month, day];
}

// Nama bulan Hijriyah — dipakai apa adanya (transliterasi Latin) buat semua
// bahasa, karena ini yang paling umum dikenali lintas bahasa di app sejenis.
const List<String> _hijriMonthNames = [
  'Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir',
  'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Syaban',
  'Ramadhan', 'Syawal', 'Dzulkaidah', 'Dzulhijjah',
];

String _formatHijriDate(DateTime date) {
  final h = _gregorianToHijri(date);
  return '${h[2]} ${_hijriMonthNames[h[1] - 1]} ${h[0]} H';
}

// Nama hari & bulan Masehi per bahasa (bukan lewat intl.DateFormat locale,
// karena app ini belum inisialisasi date-symbol-data buat locale non-en —
// jadi dibikin tabel manual sendiri, konsisten sama pola _translations).
String _formatGregorianDate(DateTime date, String lang) {
  const idDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const idMonths = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  const enDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const enMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  const jaMonths = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
  const jaDays = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
  const zhMonths = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];
  const zhDays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];

  final wd = date.weekday - 1; // Senin=0
  final mo = date.month - 1;

  switch (lang) {
    case 'id':
      return '${idDays[wd]}, ${date.day} ${idMonths[mo]} ${date.year}';
    case 'ja':
      return '${date.year}年${jaMonths[mo]}${date.day}日 ${jaDays[wd]}';
    case 'zh':
      return '${date.year}年${zhMonths[mo]}${date.day}日 ${zhDays[wd]}';
    case 'en':
    default:
      return '${enDays[wd]}, ${enMonths[mo]} ${date.day}, ${date.year}';
  }
}

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
      // FIX: ThemeData.light().copyWith(fontFamily: ...) ERROR karena copyWith()
      // pada ThemeData tidak menyediakan parameter fontFamily (keterbatasan
      // bawaan Flutter). Solusinya: bangun ThemeData langsung lewat constructor
      // biasa (bukan .light().copyWith()/.dark().copyWith()), karena constructor
      // ThemeData() punya parameter fontFamily.
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'MontserratAlternates',
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
            fontFamily: 'MontserratAlternates',
            color: Color(0xFF1C1C1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'MontserratAlternates',
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
            fontFamily: 'MontserratAlternates',
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

class _JadwalSholatScreenState extends State<JadwalSholatScreen> with SingleTickerProviderStateMixin {
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
  // Data next-prayer/countdown dipindah ke ValueNotifier: update tiap detik lewat
  // notifier ini TIDAK memanggil setState() layar penuh, jadi cuma widget yang
  // dengar (ValueListenableBuilder di kartu countdown) yang rebuild tiap detik —
  // bukan seluruh layar (list waktu sholat, bar lokasi, menu bawah, dst).
  final ValueNotifier<_NextPrayerInfo> _nextPrayerNotifier =
      ValueNotifier(const _NextPrayerInfo(remaining: Duration.zero, prayerKey: 'fajr', isNextDay: false));
  // Notifier terpisah khusus buat penanda kartu "waktu sholat berikutnya" (ambient
  // glow). Dipisah dari _nextPrayerNotifier supaya list waktu sholat TIDAK ikut
  // rebuild tiap detik — ValueNotifier hanya notify listener kalau value-nya
  // benar-benar berubah (lihat setter bawaan Flutter), jadi walau kita assign
  // string yang sama tiap detik, UI cuma rebuild pas prayer key-nya ganti.
  final ValueNotifier<String> _highlightedPrayerKeyNotifier = ValueNotifier('fajr');
  bool _isLoadingGps = false;
  // Toggle tampilan tanggal: false = Masehi, true = Hijriyah. Nggak disimpan
  // ke prefs (reset ke Masehi tiap buka app) — sengaja simpel dulu.
  bool _showHijri = false;
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
  // Controller buat efek "liquid glass shine" di kartu waktu sholat berikutnya.
  // Sekarang dipecah jadi 2 fase dalam 1 siklus: fase sapuan (kilapan beneran
  // lewat, kecepatannya TETAP sama kayak sebelumnya — lihat _shineSweepMs) lalu
  // fase diam/nunggu (nggak kelihatan sama sekali) sampai siklus abis. Total
  // siklus (jarak antar kilapan) sekarang 6.5 detik, di rentang 5-7.5 detik.
  late AnimationController _glowPulseController;
  static const int _shineCycleMs = 5000; // jarak antar kilapan (5-7.5 dtk)
  static const int _shineSweepMs = 2200; // durasi 1x sapuan — kecepatan shine, jangan diubah

  @override
  void initState() {
    super.initState();
    _loadSavedLocationAndMethod();
    _loadSavedAlarmSettings();
    _loadSavedUiScale();
    _audioPlayer = AudioPlayer();
    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _shineCycleMs),
    )..repeat();
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
      await _audioPlayer?.stop();
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
    } catch (e) {
      // Dulu error di sini ditelan diam-diam (catch (_) {}), jadi kalau file
      // gagal diputar (format tidak didukung, path tidak valid, dll) tidak ada
      // tanda apa pun ke user — kelihatan seperti tombolnya tidak berfungsi.
      // Sekarang errornya ditampilkan lewat SnackBar + dicatat ke console.
      debugPrint('Alarm playback error: $e');
      _showSnackBar(_t('alarm_play_error'));
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
      // FIX: sebelumnya syaratnya `now.second == target.second` (harus PAS di
      // detik yang sama). Timer kita jalan tiap ~1 detik tapi tidak dijamin
      // presisi ke detik yang exact sama dengan target (bisa drift dikit),
      // jadi alarm gampang kelewat & tidak pernah bunyi. Sekarang dicek pakai
      // jendela toleransi: 0-2 detik SETELAH waktu sholat, jauh lebih andal.
      final diffSeconds = now.difference(target).inSeconds;
      if (diffSeconds >= 0 && diffSeconds <= 2) {
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

  String _currentLangCode() {
    final locale = View.of(context).platformDispatcher.locale;
    final rawLang = widget.currentLanguageCode ?? locale.toLanguageTag();
    return _resolveLanguageCode(rawLang);
  }

  String _t(String key) {
    final lang = _currentLangCode();
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
        _nextPrayerNotifier.value = _NextPrayerInfo(
          remaining: tomorrowPrayers.fajr.difference(now),
          prayerKey: 'fajr',
          isNextDay: true,
        );
        _highlightedPrayerKeyNotifier.value = 'fajr';
      }
    } else {
      final nextTime = _prayerTimes.timeForPrayer(next);
      if (nextTime != null && mounted) {
        final key = _getPrayerKey(next);
        _nextPrayerNotifier.value = _NextPrayerInfo(
          remaining: nextTime.difference(now),
          prayerKey: key,
          isNextDay: false,
        );
        _highlightedPrayerKeyNotifier.value = key;
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
                        _AnimatedSegmentedToggle<ThemeMode>(
                          isDark: isDark,
                          value: localThemeMode,
                          options: [
                            _SegmentOption(value: ThemeMode.system, label: _t('theme_system_short'), icon: Icons.smartphone_rounded),
                            _SegmentOption(value: ThemeMode.light, label: _t('light'), icon: Icons.light_mode_rounded),
                            _SegmentOption(value: ThemeMode.dark, label: _t('dark'), icon: Icons.dark_mode_rounded),
                          ],
                          onChanged: (mode) {
                            setDialogState(() {
                              localThemeMode = mode;
                            });
                            widget.onThemeChanged(mode);
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
                                _buildLanguageOption(
                                  isDark: isDark,
                                  selected: localLanguageCode == null,
                                  title: _t('auto_device'),
                                  subtitle: _t('system_default'),
                                  onTap: () {
                                    setDialogState(() {
                                      localLanguageCode = null;
                                    });
                                    widget.onLanguageChanged(null);
                                  },
                                ),
                                const Divider(height: 1),
                                _buildLanguageOption(
                                  isDark: isDark,
                                  selected: localLanguageCode == 'id',
                                  title: 'Bahasa Indonesia',
                                  onTap: () {
                                    setDialogState(() {
                                      localLanguageCode = 'id';
                                    });
                                    widget.onLanguageChanged('id');
                                  },
                                ),
                                const Divider(height: 1),
                                _buildLanguageOption(
                                  isDark: isDark,
                                  selected: localLanguageCode == 'en',
                                  title: 'English',
                                  onTap: () {
                                    setDialogState(() {
                                      localLanguageCode = 'en';
                                    });
                                    widget.onLanguageChanged('en');
                                  },
                                ),
                                const Divider(height: 1),
                                _buildLanguageOption(
                                  isDark: isDark,
                                  selected: localLanguageCode == 'ja',
                                  title: '日本語 (Japanese)',
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
                        _AnimatedSegmentedToggle<String>(
                          isDark: isDark,
                          value: localAlarmMode,
                          options: [
                            _SegmentOption(value: 'ring', label: _t('alarm_mode_ring'), icon: Icons.notifications_active_rounded),
                            _SegmentOption(value: 'vibrate', label: _t('alarm_mode_vibrate'), icon: Icons.vibration_rounded),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              localAlarmMode = value;
                            });
                            setState(() {
                              _alarmMode = value;
                            });
                            _saveAlarmSettings();
                          },
                        ),
                        const SizedBox(height: 18),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SizeTransition(
                                sizeFactor: anim,
                                axisAlignment: -1,
                                child: child,
                              ),
                            ),
                            child: localAlarmMode != 'ring'
                                ? const SizedBox(key: ValueKey('no_ring_options'))
                                : Column(
                                    key: const ValueKey('ring_options'),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                                ),
                          ),
                        ),
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
    _nextPrayerNotifier.dispose();
    _highlightedPrayerKeyNotifier.dispose();
    _glowPulseController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _openNextPrayerPopup() {
    final info = _nextPrayerNotifier.value;
    DateTime prayerTime;
    String nextName = _t(info.prayerKey);
    if (info.isNextDay && info.prayerKey == 'fajr') {
      final params = _selectedMethod.getParameters();
      final tomorrowPrayers = PrayerTimes(
        _currentCoordinates,
        DateComponents.from(DateTime.now().add(const Duration(days: 1))),
        params,
      );
      prayerTime = tomorrowPrayers.fajr;
      nextName = _t('fajr_tomorrow');
    } else {
      final prayer = _prayerFromKey(info.prayerKey);
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
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
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                              child: _isLoadingGps
                                  ? SizedBox(
                                      key: const ValueKey('gps_loading'),
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryTextColor),
                                    )
                                  : Icon(
                                      Icons.my_location,
                                      key: const ValueKey('gps_icon'),
                                      color: primaryTextColor.withAlpha((0.7 * 255).round()),
                                      size: 20,
                                    ),
                            ),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      // FIX color harmony: sebelumnya di mode terang card ini
                      // SELALU hitam pekat (0xFF1C1C1E) di tengah tema yang
                      // full putih/abu — jadi nongol sendiri, nggak nyatu.
                      // Sekarang di mode terang dia ikut keluarga warna card
                      // lain (putih, cardBgColor) + border tipis buat tetap
                      // kelihatan sebagai elemen tersendiri, TANPA perlu invert
                      // jadi kotak hitam. Mode gelap nggak diubah.
                      color: isDark ? const Color(0xFF252525) : cardBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark
                          ? null
                          : Border.all(color: Colors.black12, width: 1),
                    ),
                    child: ValueListenableBuilder<_NextPrayerInfo>(
                      valueListenable: _nextPrayerNotifier,
                      builder: (context, info, _) {
                        final nextName = (info.isNextDay && info.prayerKey == 'fajr')
                            ? _t('fajr_tomorrow')
                            : _t(info.prayerKey);
                        return Column(
                          children: [
                            // Baris tanggal — dulu di bar lokasi, sekarang dipindah
                            // ke sini (posisi yang dulu ditempatin label "NEXT
                            // PRAYER"). Tap buat toggle Masehi <-> Hijriyah.
                            // UPDATE: sekarang pakai _SmoothTextSwitcher (fade +
                            // slide vertikal tipis), bukan _FlipSwitcher lagi —
                            // pergantian teksnya kerasa lebih flow/halus,
                            // sebelumnya rotateX 90 derajat pada 1 baris teks
                            // panjang kerasa patah-patah.
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _showHijri = !_showHijri);
                              },
                              child: _SmoothTextSwitcher(
                                child: Text(
                                  _showHijri
                                      ? _formatHijriDate(DateTime.now())
                                      : _formatGregorianDate(DateTime.now(), _currentLangCode()),
                                  key: ValueKey(_showHijri),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : primaryTextColor.withValues(alpha: 0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // FIX FONT (lihat catatan lama): fontFamily di-set
                            // eksplisit + fontWeight w600 biar konsisten sama
                            // font app, nggak fallback ke font sistem.
                            //
                            // UPDATE animasi: sekarang tiap digit dibungkus
                            // dalam kartu (_buildFlipDigitCard) sebelum di-flip,
                            // jadi kelihatan kayak kartu fisik yang kebalik
                            // (ada background tipis + seam tengah), bukan cuma
                            // teks yang muter. Warna kartu ikut nyesuain dark/light.
                            _buildFlipTimeRow(
                              _formatDuration(info.remaining),
                              TextStyle(
                                fontFamily: 'MontserratAlternates',
                                color: isDark ? Colors.white : primaryTextColor,
                                fontSize: 42,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                              cardColor: isDark ? const Color(0xFF303032) : const Color(0xFFF5F5F7),
                              cardBorderColor: isDark ? Colors.white12 : Colors.black12,
                              seamColor: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.08),
                            ),
                            const SizedBox(height: 10),
                            // Label "NEXT PRAYER X" — dulu di atas, sekarang
                            // dipindah ke bawah digit countdown.
                            Text(
                              '${_t("towards")} ${nextName.toUpperCase()}',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : primaryTextColor.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
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

  Widget _buildLanguageOption({
    required bool selected,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final highlightColor = Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.1);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      color: selected ? highlightColor : Colors.transparent,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: selected
              ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, key: const ValueKey('checked'))
              : const SizedBox(width: 24, key: ValueKey('unchecked')),
        ),
        onTap: onTap,
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

    return ValueListenableBuilder<String>(
      valueListenable: _highlightedPrayerKeyNotifier,
      builder: (context, highlightedKey, _) {
        final isNext = highlightedKey == prayerKey;

        final cardInner = Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onLongPress: () {
              HapticFeedback.selectionClick();
              _showPrayerDetailPopup(
                prayerName: name,
                prayerTime: time,
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              minLeadingWidth: 0,
              horizontalTitleGap: isNext ? 6 : 0,
              leading: isNext
                  ? Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: isDark ? Colors.white60 : const Color(0xFF8A8F98),
                    )
                  : null,
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
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
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: Icon(
                          alarmActive ? Icons.alarm_on_rounded : Icons.alarm_outlined,
                          key: ValueKey(alarmActive),
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (!isNext) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.transparent : Colors.black.withAlpha((0.05 * 255).round()),
              ),
            ),
            child: cardInner,
          );
        }

        // Kartu next-prayer: efek "liquid glass" — dasar kartu dikasih tint kaca
        // tipis netral, lalu ada cahaya putih tipis yang menyapu diagonal
        // berulang terus. Siklus dipecah 2 fase (lihat builder di bawah):
        // fase sapuan (kilapan beneran lewat + fade in/out di ujungnya) lalu
        // fase diam (nggak kelihatan sama sekali) sampai siklus berikutnya.
        //
        // FIX clipping: sebelumnya margin ada DI DALAM ClipRRect (nempel di
        // Container yang di-clip), jadi kotak yang di-clip lebih besar dari
        // kartu yang kelihatan (karena margin ikut dihitung), sementara sapuan
        // cahaya mengisi penuh kotak konten yang PERSIS sama luasnya dengan
        // kartu -> sudut sapuan cahaya yang lurus/kotak nongol melewati sudut
        // tumpul kartu. Sekarang margin dipindah ke Padding DI LUAR ClipRRect,
        // supaya area yang di-clip presis sama dengan bentuk kartu (radius 12),
        // dan AnimatedBuilder pakai parameter `child` biar cardInner (yang
        // nggak berubah tiap frame) nggak ikut dibangun ulang tiap tick animasi.
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          // Shadow dihapus lagi atas permintaan — border tipis aja udah cukup
          // buat nandain kartu ini beda dari yang lain, nggak perlu efek
          // "keangkat". Jadi balik ke ClipRRect langsung, nggak usah dibungkus
          // Container tambahan buat shadow.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedBuilder(
              animation: _glowPulseController,
              builder: (context, child) {
                // Siklus dipecah 2 fase: 0..sweepMs = kilapan beneran lewat
                // (progress 0->1, shift jalan penuh kayak sebelumnya, kecepatan
                // TIDAK berubah), sisanya = fase diam, shine nggak digambar
                // sama sekali sampai siklus berikutnya mulai.
                final elapsedMs = _glowPulseController.value * _shineCycleMs;
                double progress;
                double envelope; // 0..1, buat fade in/out si kilapan
                if (elapsedMs <= _shineSweepMs) {
                  progress = elapsedMs / _shineSweepMs;
                  if (progress < 0.18) {
                    envelope = progress / 0.18; // fade in cepat di awal
                  } else if (progress > 0.55) {
                    // fade out landai di ekor kilapan biar nggak putus mendadak
                    envelope = (1 - (progress - 0.55) / 0.45).clamp(0.0, 1.0);
                  } else {
                    envelope = 1.0;
                  }
                } else {
                  progress = 1.0;
                  envelope = 0.0; // fase diam
                }
                // Garis gradient (begin/end) digeser bareng dari jauh di kiri ke
                // jauh di kanan, jadi highlight-nya "menyapu" lewat seluruh kartu.
                final shift = -2.2 + 4.4 * progress;

                // FIX MODE TERANG: card highlight versi lama warnanya krem/gold
                // (0xFBF8F2) yang bikin dia kelihatan "keemasan" & nggak
                // nyambung sama tema app (yang monokrom hitam-putih-abu).
                //
                // UPDATE color harmony: sekarang backgroundnya di-blend ke arah
                // GOLD HANGAT (bukan ke textColor/hitam lagi) dengan opacity
                // rendah (4%) — biar card ini kerasa "satu keluarga warna" sama
                // prism sweep-nya (yang emang ada sisi gold/pink), bukan cuma
                // card netral yang kebetulan ditumpangin kilau warna-warni.
                // Border-nya juga ikut dihangatkan senada.
                //
                // UPDATE (fix mode terang, v3 — PRISMA REDUP, dipilih user):
                // Percobaan pertama (mono gelap tipis) aman tapi kerasa datar.
                // Sekarang balik ke konsep PRISMA kayak semula (cyan -> putih
                // -> pink, efek dispersi kaca), TAPI opacity-nya jauh
                // diturunin dibanding versi paling awal yang kelewat
                // mencolok: puncak putih dari 0.55 -> 0.35, fringe cyan/pink
                // dari 0.06 -> 0.10 (sedikit dinaikkan drpd versi awal krn di
                // atas background terang warnanya lebih gampang "hilang").
                // Rentang stop juga dilebarin (26%-70% vs sebelumnya
                // 38%-62%) biar transisinya lebih landai/halus, nggak
                // berasa nge-blok.
                if (!isDark) {
                  final tintedBg = Color.lerp(cardBg, textColor, 0.035)!;
                  final tintedBorder = textColor.withValues(alpha: 0.14);

                  return Container(
                    decoration: BoxDecoration(
                      color: tintedBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: tintedBorder, width: 1.2),
                    ),
                    child: Stack(
                      children: [
                        child!,
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(-1 + shift, -1),
                                  end: Alignment(1 + shift, 1),
                                  stops: const [0.26, 0.38, 0.48, 0.58, 0.70],
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF8FE9FF).withValues(alpha: 0.10 * envelope), // fringe cyan
                                    Colors.white.withValues(alpha: 0.35 * envelope), // hotspot putih (puncak, diredupkan)
                                    const Color(0xFFFF9ED2).withValues(alpha: 0.10 * envelope), // fringe pink
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Offset dikit buat 2 lapis fringe warna (cyan & magenta) di
                // kiri-kanan sapuan utama -> efek dispersi cahaya ala kaca
                // prisma (lihat referensi). Jaraknya sengaja kecil (0.05) &
                // alpha-nya rendah banget supaya cuma kerasa "dikit" di tepi,
                // bukan pelangi mencolok. Ini CUMA dipakai di mode gelap.
                final cyanShift = shift - 0.05;
                final magentaShift = shift + 0.05;

                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    // FIX: dulu Container ini nggak punya borderRadius sama
                    // sekali, padahal dia dibungkus ClipRRect(radius 12) di
                    // luar. Border-nya jadinya digambar KOTAK LURUS dulu baru
                    // dipotong paksa sama ClipRRect di keempat sudut -> muncul
                    // notch/celah kecil pas ketemu kartu tetangga (Dhuhr &
                    // Maghrib). Sekarang borderRadius disamakan (12) biar
                    // border ikut melengkung dari awal, nggak kepotong lagi.
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1.2,
                    ),
                    // Tint kaca tipis netral, konstan (nggak ikut animasi)
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      child!,
                      // Overlay sapuan cahaya (shine) - IgnorePointer biar nggak
                      // ganggu tap/long-press di kartu. Ke-clip presis sesuai
                      // bentuk kartu lewat ClipRRect di luar, dan memudar
                      // (fade in/out) lewat `envelope`. Sekarang ada 3 lapis:
                      // fringe cyan, band utama (gold pucat), fringe magenta —
                      // biar kerasa dispersi kaca kayak referensi, tapi tetep
                      // tipis banget. (Khusus mode gelap — tidak diubah.)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-1 + cyanShift, -1),
                                end: Alignment(1 + cyanShift, 1),
                                stops: const [0.4, 0.5, 0.6],
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF8FE9FF).withValues(alpha: 0.06 * envelope),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-1 + shift, -1),
                                end: Alignment(1 + shift, 1),
                                stops: const [0.35, 0.5, 0.65],
                                colors: [
                                  Colors.transparent,
                                  Color.lerp(
                                    Colors.white,
                                    const Color(0xFFFFE3B0),
                                    0.12,
                                  )!.withValues(alpha: 0.14 * envelope),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-1 + magentaShift, -1),
                                end: Alignment(1 + magentaShift, 1),
                                stops: const [0.4, 0.5, 0.6],
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFFFF9ED2).withValues(alpha: 0.06 * envelope),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              // `child` di sini = cardInner. AnimatedBuilder cuma manggil ulang
              // `builder` tiap tick, TAPI `child` (ListTile/InkWell/Material)
              // dibangun sekali dan dipakai ulang terus — jadi animasi shine
              // murah, nggak ikut rebuild seluruh konten kartu tiap frame.
              child: cardInner,
            ),
          ),
        );
      },
    );
  }
}

// Opsi satu segmen untuk _AnimatedSegmentedToggle
class _SegmentOption<T> {
  final T value;
  final String label;
  final IconData icon;
  const _SegmentOption({required this.value, required this.label, required this.icon});
}

// Toggle N-opsi dengan indikator pill yang meluncur (dipakai utk Ring/Vibrate & Tema)
class _AnimatedSegmentedToggle<T> extends StatelessWidget {
  final bool isDark;
  final T value;
  final List<_SegmentOption<T>> options;
  final ValueChanged<T> onChanged;

  const _AnimatedSegmentedToggle({
    required this.isDark,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = options.indexWhere((o) => o.value == value).clamp(0, options.length - 1);
    final trackColor = isDark ? const Color(0xFF1B1B1D) : const Color(0xFFF5F5F7);
    final pillColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final activeTextColor = isDark ? Colors.black : Colors.white;
    final inactiveTextColor = isDark ? Colors.white70 : Colors.black54;
    final n = options.length;
    final alignX = n > 1 ? (2 * selectedIndex / (n - 1) - 1) : 0.0;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / n;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment(alignX, 0),
                child: Container(
                  width: segmentWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Row(
                children: options.map((opt) {
                  final selected = opt.value == value;
                  return _buildSegment(
                    icon: opt.icon,
                    label: opt.label,
                    selected: selected,
                    activeColor: activeTextColor,
                    inactiveColor: inactiveTextColor,
                    onTap: () => onChanged(opt.value),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegment({
    required IconData icon,
    required String label,
    required bool selected,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    final color = selected ? activeColor : inactiveColor;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 5),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
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
          // FIX FONT: sama seperti kartu countdown utama — fontFamily
          // eksplisit + fontWeight w600, biar konsisten.
          // UPDATE animasi: pakai flip card yang sama kayak card utama, biar
          // konsisten (dulu popup ini polos, sekarang ikut flip card juga).
          _buildFlipTimeRow(
            _format(_remaining),
            TextStyle(
              fontFamily: 'MontserratAlternates',
              fontSize: 52,
              fontWeight: FontWeight.w600,
              color: neutralAccent,
              letterSpacing: 0,
            ),
            cardColor: widget.isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF5F5F7),
            cardBorderColor: widget.isDark ? Colors.white24 : Colors.black12,
            seamColor: widget.isDark ? Colors.black45 : Colors.black.withValues(alpha: 0.12),
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