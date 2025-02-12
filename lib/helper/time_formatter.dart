import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestap) {
  DateTime dateTime = timestap.toDate();
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
