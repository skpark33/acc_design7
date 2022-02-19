//import 'dart:io';
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../constants/constants.dart';

enum UserType {
  superAdmin,
  customerAdmin,
  siteAdimin,
}

UserModel currentUser = UserModel(id: 'b49');

class UserModel {
  List<Color> bgColorList1 = [
    Color(0x00000000),
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFED4D4D),
    Color(0xFFFFC224),
    Color(0xFF83D076),
    Color(0xFF5CA9F0),
    Color(0xFF5F5CF0),
    Color(0xFFAF5CF0),
    Color(0xFFE04D0D),
    Color(0xFF0FC024),
    Color(0xFF830076),
    Color(0xFF0CA9F0),
    Color(0xFF505C00),
    Color(0xFFAF0CF0),
  ];

  final int maxBgColor = 9;

  final String id;
  String pwd = 'Creta';
  String name = 'Creta B49';
  String tel = '02-2284-3323';
  String email = 'b49@sqisoft.com';
  String siteId = defaultSiteId;
  UserType userType = UserType.siteAdimin;
  String imageFile = '';

  UserModel({required this.id});
}
