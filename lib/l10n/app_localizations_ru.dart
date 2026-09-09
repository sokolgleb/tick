// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Tick';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String dateFormat(String date) {
    return '$date';
  }

  @override
  String get noActivitiesYet => 'Пока нет активностей';

  @override
  String get newActivity => 'Новая активность';

  @override
  String get editActivity => 'Редактировать';

  @override
  String get edit => 'Редактировать';

  @override
  String get archive => 'Архивировать';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get create => 'Создать';

  @override
  String get add => 'Добавить';

  @override
  String get logTime => 'Записать время';

  @override
  String get logCount => 'Записать количество';

  @override
  String get history => 'История';

  @override
  String get noEntriesYet => 'Пока нет записей';

  @override
  String get settings => 'Настройки';

  @override
  String get account => 'Аккаунт';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get viewMode => 'Вид';

  @override
  String get viewList => 'Список';

  @override
  String get viewGrid => 'Сетка';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Регистрация';

  @override
  String get signOut => 'Выйти';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get signInAnyway => 'Всё равно войти';

  @override
  String get linkAccount => 'Привязать аккаунт';

  @override
  String get anonymousAccount => 'Анонимный аккаунт';

  @override
  String get linkAccountHint =>
      'Привяжите аккаунт, чтобы сохранить данные на всех устройствах';

  @override
  String get signedIn => 'Вы вошли';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get or => 'или';

  @override
  String get trackYourTime => 'Трекер времени. Просто.';

  @override
  String get allTime => 'Всё время';

  @override
  String get thisWeek => 'Эта неделя';

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get thisYear => 'Этот год';

  @override
  String get custom => 'Произвольный';

  @override
  String get sortByDate => 'По дате';

  @override
  String get sortByValueAsc => 'По значению (мин-макс)';

  @override
  String get sortByValueDesc => 'По значению (макс-мин)';

  @override
  String get summary => 'Итого';

  @override
  String get subActivities => 'Подактивности';

  @override
  String get addSubActivity => 'Добавить подактивность';

  @override
  String get time => 'Время';

  @override
  String get count => 'Счёт';

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutesм';
  }

  @override
  String hoursOnly(int hours) {
    return '$hoursч';
  }

  @override
  String get zeroMinutes => '0м';

  @override
  String countFormat(String count) {
    return '${count}x';
  }

  @override
  String get customDuration => 'Произвольное время';

  @override
  String get customCount => 'Произвольное количество';

  @override
  String get minutes => 'мин';

  @override
  String get deleteActivity => 'Удалить активность?';

  @override
  String get deleteActivityConfirm =>
      'Все записи этой активности тоже будут удалены.';

  @override
  String get signOutConfirm => 'Выйти?';

  @override
  String get accountConflictTitle => 'Аккаунт уже существует';

  @override
  String accountConflictMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'активностей',
      few: 'активности',
      one: 'активность',
    );
    return 'Ваши текущие данные ($count $_temp0) будут удалены при входе в существующий аккаунт.';
  }

  @override
  String logged(String value) {
    return 'Записано $value';
  }

  @override
  String error(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get color => 'Цвет';

  @override
  String get trackingType => 'Тип трекинга';

  @override
  String parentActivity(String name) {
    return 'Родитель: $name';
  }
}
