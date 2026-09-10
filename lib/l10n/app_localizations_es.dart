// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tick';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String dateFormat(String date) {
    return '$date';
  }

  @override
  String get noActivitiesYet => 'Sin actividades aún';

  @override
  String get newActivity => 'Nueva actividad';

  @override
  String get editActivity => 'Editar actividad';

  @override
  String get edit => 'Editar';

  @override
  String get archive => 'Archivar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get add => 'Añadir';

  @override
  String get logTime => 'Registrar tiempo';

  @override
  String get logCount => 'Registrar cantidad';

  @override
  String get history => 'Historial';

  @override
  String get noEntriesYet => 'Sin registros aún';

  @override
  String get settings => 'Ajustes';

  @override
  String get account => 'Cuenta';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get viewMode => 'Vista';

  @override
  String get viewList => 'Lista';

  @override
  String get viewGrid => 'Cuadrícula';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signInAnyway => 'Iniciar sesión de todos modos';

  @override
  String get linkAccount => 'Vincular cuenta';

  @override
  String get anonymousAccount => 'Cuenta anónima';

  @override
  String get linkAccountHint =>
      'Vincula una cuenta para conservar tus datos en todos los dispositivos';

  @override
  String get signedIn => 'Sesión iniciada';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get or => 'o';

  @override
  String get trackYourTime => 'Registra tu tiempo, simplemente.';

  @override
  String get allTime => 'Todo';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get thisYear => 'Este año';

  @override
  String get custom => 'Personalizado';

  @override
  String get sortByDate => 'Por fecha';

  @override
  String get sortByValueAsc => 'Valor (ascendente)';

  @override
  String get sortByValueDesc => 'Valor (descendente)';

  @override
  String get summary => 'Resumen';

  @override
  String get subActivities => 'Sub-actividades';

  @override
  String get addSubActivity => 'Añadir sub-actividad';

  @override
  String get time => 'Tiempo';

  @override
  String get count => 'Conteo';

  @override
  String hoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String minutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String hoursOnly(int hours) {
    return '${hours}h';
  }

  @override
  String get zeroMinutes => '0m';

  @override
  String countFormat(String count) {
    return '${count}x';
  }

  @override
  String get customDuration => 'Duración personalizada';

  @override
  String get customCount => 'Cantidad personalizada';

  @override
  String get minutes => 'min';

  @override
  String get deleteActivity => '¿Eliminar actividad?';

  @override
  String get deleteActivityConfirm =>
      'También se eliminarán todos los registros de esta actividad.';

  @override
  String get signOutConfirm => '¿Cerrar sesión?';

  @override
  String get accountConflictTitle => 'La cuenta ya existe';

  @override
  String accountConflictMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'actividades',
      one: 'actividad',
    );
    return 'Tus datos actuales ($count $_temp0) se eliminarán al iniciar sesión en la cuenta existente.';
  }

  @override
  String logged(String value) {
    return 'Registrado $value';
  }

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get color => 'Color';

  @override
  String get trackingType => 'Tipo de seguimiento';

  @override
  String parentActivity(String name) {
    return 'Padre: $name';
  }

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get archiveActivity => '¿Archivar actividad?';

  @override
  String get archiveActivityConfirm =>
      'La actividad se ocultará. Tus datos se conservarán.';

  @override
  String updated(String value) {
    return 'Actualizado: $value';
  }

  @override
  String activityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actividades',
      one: '1 actividad',
    );
    return '$_temp0';
  }

  @override
  String get coloredGrid => 'Cuadrícula con color';

  @override
  String get seconds => 'seg';

  @override
  String get hours => 'hr';

  @override
  String get days => 'día';
}
