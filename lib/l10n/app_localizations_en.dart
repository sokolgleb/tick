// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tick';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String dateFormat(String date) {
    return '$date';
  }

  @override
  String get noActivitiesYet => 'No activities yet';

  @override
  String get newActivity => 'New Activity';

  @override
  String get editActivity => 'Edit Activity';

  @override
  String get edit => 'Edit';

  @override
  String get archive => 'Archive';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get add => 'Add';

  @override
  String get logTime => 'Log Time';

  @override
  String get logCount => 'Log Count';

  @override
  String get history => 'History';

  @override
  String get noEntriesYet => 'No entries yet';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get viewMode => 'View Mode';

  @override
  String get viewList => 'List';

  @override
  String get viewGrid => 'Grid';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get signOut => 'Sign out';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInAnyway => 'Sign in anyway';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get anonymousAccount => 'Anonymous account';

  @override
  String get linkAccountHint =>
      'Link an account to keep your data across devices';

  @override
  String get signedIn => 'Signed in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get or => 'or';

  @override
  String get trackYourTime => 'Track your time, simply.';

  @override
  String get allTime => 'All time';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get custom => 'Custom';

  @override
  String get sortByDate => 'By date';

  @override
  String get sortByValueAsc => 'Value (low to high)';

  @override
  String get sortByValueDesc => 'Value (high to low)';

  @override
  String get summary => 'Summary';

  @override
  String get subActivities => 'Sub-activities';

  @override
  String get addSubActivity => 'Add sub-activity';

  @override
  String get time => 'Time';

  @override
  String get count => 'Count';

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
  String get customDuration => 'Custom Duration';

  @override
  String get customCount => 'Custom Count';

  @override
  String get minutes => 'min';

  @override
  String get deleteActivity => 'Delete activity?';

  @override
  String get deleteActivityConfirm =>
      'This will also delete all entries for this activity.';

  @override
  String get signOutConfirm => 'Sign out?';

  @override
  String get accountConflictTitle => 'Account already exists';

  @override
  String accountConflictMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'activities',
      one: 'activity',
    );
    return 'Your current data ($count $_temp0) will be deleted when you sign in to the existing account.';
  }

  @override
  String logged(String value) {
    return 'Logged $value';
  }

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get color => 'Color';

  @override
  String get trackingType => 'Tracking type';

  @override
  String parentActivity(String name) {
    return 'Parent: $name';
  }
}
