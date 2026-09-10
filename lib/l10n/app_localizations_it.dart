// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class SIt extends S {
  SIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Tick';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String dateFormat(String date) {
    return '$date';
  }

  @override
  String get noActivitiesYet => 'Nessuna attività';

  @override
  String get newActivity => 'Nuova attività';

  @override
  String get editActivity => 'Modifica attività';

  @override
  String get edit => 'Modifica';

  @override
  String get archive => 'Archivia';

  @override
  String get delete => 'Elimina';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get create => 'Crea';

  @override
  String get add => 'Aggiungi';

  @override
  String get logTime => 'Registra tempo';

  @override
  String get logCount => 'Registra conteggio';

  @override
  String get history => 'Cronologia';

  @override
  String get noEntriesYet => 'Nessuna voce';

  @override
  String get settings => 'Impostazioni';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Aspetto';

  @override
  String get language => 'Lingua';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get viewMode => 'Visualizzazione';

  @override
  String get viewList => 'Lista';

  @override
  String get viewGrid => 'Griglia';

  @override
  String get signIn => 'Accedi';

  @override
  String get signUp => 'Registrati';

  @override
  String get signOut => 'Esci';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get signInAnyway => 'Accedi comunque';

  @override
  String get linkAccount => 'Collega account';

  @override
  String get anonymousAccount => 'Account anonimo';

  @override
  String get linkAccountHint =>
      'Collega un account per mantenere i dati su tutti i dispositivi';

  @override
  String get signedIn => 'Accesso effettuato';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get or => 'o';

  @override
  String get trackYourTime => 'Traccia il tuo tempo, semplicemente.';

  @override
  String get allTime => 'Tutto';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get thisMonth => 'Questo mese';

  @override
  String get thisYear => 'Quest\'anno';

  @override
  String get custom => 'Personalizzato';

  @override
  String get sortByDate => 'Per data';

  @override
  String get sortByValueAsc => 'Valore (crescente)';

  @override
  String get sortByValueDesc => 'Valore (decrescente)';

  @override
  String get summary => 'Riepilogo';

  @override
  String get subActivities => 'Sotto-attività';

  @override
  String get addSubActivity => 'Aggiungi sotto-attività';

  @override
  String get time => 'Tempo';

  @override
  String get count => 'Conteggio';

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
  String get customDuration => 'Durata personalizzata';

  @override
  String get customCount => 'Conteggio personalizzato';

  @override
  String get minutes => 'min';

  @override
  String get deleteActivity => 'Eliminare attività?';

  @override
  String get deleteActivityConfirm =>
      'Verranno eliminate anche tutte le voci di questa attività.';

  @override
  String get signOutConfirm => 'Uscire?';

  @override
  String get accountConflictTitle => 'Account già esistente';

  @override
  String accountConflictMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'attività',
      one: 'attività',
    );
    return 'I tuoi dati attuali ($count $_temp0) verranno eliminati quando accedi all\'account esistente.';
  }

  @override
  String logged(String value) {
    return 'Registrato $value';
  }

  @override
  String error(String message) {
    return 'Errore: $message';
  }

  @override
  String get color => 'Colore';

  @override
  String get trackingType => 'Tipo di tracciamento';

  @override
  String parentActivity(String name) {
    return 'Genitore: $name';
  }

  @override
  String get editEntry => 'Modifica voce';

  @override
  String get archiveActivity => 'Archiviare attività?';

  @override
  String get archiveActivityConfirm =>
      'L\'attività sarà nascosta. I dati saranno conservati.';

  @override
  String updated(String value) {
    return 'Aggiornato: $value';
  }

  @override
  String activityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attività',
      one: '1 attività',
    );
    return '$_temp0';
  }

  @override
  String get coloredGrid => 'Griglia colorata';

  @override
  String get seconds => 'sec';

  @override
  String get hours => 'ore';

  @override
  String get days => 'gg';
}
