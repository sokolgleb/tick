// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Tick';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String dateFormat(String date) {
    return '$date';
  }

  @override
  String get noActivitiesYet => 'Henüz aktivite yok';

  @override
  String get newActivity => 'Yeni Aktivite';

  @override
  String get editActivity => 'Aktiviteyi Düzenle';

  @override
  String get edit => 'Düzenle';

  @override
  String get archive => 'Arşivle';

  @override
  String get delete => 'Sil';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get create => 'Oluştur';

  @override
  String get add => 'Ekle';

  @override
  String get logTime => 'Zaman Kaydet';

  @override
  String get logCount => 'Sayı Kaydet';

  @override
  String get history => 'Geçmiş';

  @override
  String get noEntriesYet => 'Henüz kayıt yok';

  @override
  String get settings => 'Ayarlar';

  @override
  String get account => 'Hesap';

  @override
  String get appearance => 'Görünüm';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get viewMode => 'Görünüm';

  @override
  String get viewList => 'Liste';

  @override
  String get viewGrid => 'Izgara';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get signOut => 'Çıkış';

  @override
  String get signInWithGoogle => 'Google ile giriş yap';

  @override
  String get signInAnyway => 'Yine de giriş yap';

  @override
  String get linkAccount => 'Hesap Bağla';

  @override
  String get anonymousAccount => 'Anonim hesap';

  @override
  String get linkAccountHint =>
      'Verilerinizi cihazlar arası korumak için hesap bağlayın';

  @override
  String get signedIn => 'Giriş yapıldı';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get or => 'veya';

  @override
  String get trackYourTime => 'Zamanınızı takip edin, basitçe.';

  @override
  String get allTime => 'Tüm zamanlar';

  @override
  String get thisWeek => 'Bu hafta';

  @override
  String get thisMonth => 'Bu ay';

  @override
  String get thisYear => 'Bu yıl';

  @override
  String get custom => 'Özel';

  @override
  String get sortByDate => 'Tarihe göre';

  @override
  String get sortByValueAsc => 'Değer (artan)';

  @override
  String get sortByValueDesc => 'Değer (azalan)';

  @override
  String get summary => 'Özet';

  @override
  String get subActivities => 'Alt aktiviteler';

  @override
  String get addSubActivity => 'Alt aktivite ekle';

  @override
  String get time => 'Zaman';

  @override
  String get count => 'Sayı';

  @override
  String hoursMinutes(int hours, int minutes) {
    return '${hours}s ${minutes}d';
  }

  @override
  String minutesOnly(int minutes) {
    return '${minutes}d';
  }

  @override
  String hoursOnly(int hours) {
    return '${hours}s';
  }

  @override
  String get zeroMinutes => '0d';

  @override
  String countFormat(String count) {
    return '${count}x';
  }

  @override
  String get customDuration => 'Özel Süre';

  @override
  String get customCount => 'Özel Sayı';

  @override
  String get minutes => 'dk';

  @override
  String get deleteActivity => 'Aktivite silinsin mi?';

  @override
  String get deleteActivityConfirm =>
      'Bu aktivitenin tüm kayıtları da silinecek.';

  @override
  String get signOutConfirm => 'Çıkış yapılsın mı?';

  @override
  String get accountConflictTitle => 'Hesap zaten mevcut';

  @override
  String accountConflictMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'aktivite',
      one: 'aktivite',
    );
    return 'Mevcut verileriniz ($count $_temp0) mevcut hesaba giriş yaptığınızda silinecek.';
  }

  @override
  String logged(String value) {
    return '$value kaydedildi';
  }

  @override
  String error(String message) {
    return 'Hata: $message';
  }

  @override
  String get color => 'Renk';

  @override
  String get trackingType => 'Takip türü';

  @override
  String parentActivity(String name) {
    return 'Üst: $name';
  }

  @override
  String get editEntry => 'Kaydı düzenle';

  @override
  String get archiveActivity => 'Aktiviteyi arşivle?';

  @override
  String get archiveActivityConfirm =>
      'Aktivite gizlenecek. Verileriniz korunacak.';

  @override
  String updated(String value) {
    return 'Güncellendi: $value';
  }

  @override
  String activityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktivite',
      one: '1 aktivite',
    );
    return '$_temp0';
  }

  @override
  String get coloredGrid => 'Renkli ızgara';

  @override
  String get seconds => 'sn';

  @override
  String get hours => 'sa';

  @override
  String get days => 'gün';
}
