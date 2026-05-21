import 'package:flutter/material.dart';
import 'user_session.dart';

class Tr {
  static String t(BuildContext context, String ar, String en) =>
      UserSession().language == 'ar' ? ar : en;

  static bool isAr(BuildContext context) => UserSession().language == 'ar';

  static String font(BuildContext context) =>
      UserSession().language == 'ar' ? 'Almarai' : 'Inter';
}
