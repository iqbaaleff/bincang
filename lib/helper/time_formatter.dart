import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShortTimeMessagesId implements timeago.LookupMessages {
  @override String prefixAgo() => '';
  @override String prefixFromNow() => '';
  @override String suffixAgo() => '';
  @override String suffixFromNow() => '';
  @override String lessThanOneMinute(int seconds) => 'baru';
  @override String aboutAMinute(int minutes) => '1m';
  @override String minutes(int minutes) => '${minutes}m';
  @override String aboutAnHour(int minutes) => '1j';
  @override String hours(int hours) => '${hours}j';
  @override String aDay(int hours) => '1h';
  @override String days(int days) => '${days}h';
  @override String aboutAMonth(int days) => '1bln';
  @override String months(int months) => '${months}bln';
  @override String aboutAYear(int year) => '1thn';
  @override String years(int years) => '${years}thn';
  @override String wordSeparator() => ' ';
}

void registerCustomLocale() {
  timeago.setLocaleMessages('id_short', ShortTimeMessagesId());
}

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return timeago.format(dateTime, locale: 'id_short');
}
