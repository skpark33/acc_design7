import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'studio/studio_main_screen.dart';
import 'model/users.dart';
import 'constants/styles.dart';

void main() {
  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        appBarTheme: AppBarTheme(
          color: MyColors.primaryColor,
          centerTitle: true,
          titleTextStyle: MyTextStyles.subtitle1,
          actionsIconTheme: const IconThemeData(color: MyColors.primaryColor),
        ),
        primaryColor: MyColors.primaryColor,
        scaffoldBackgroundColor: MyColors.bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: MyColors.primaryText),
        canvasColor: MyColors.secondaryColor,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: MyColors.mainColor),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: MyButtonStyle.b1,
        ),
        tabBarTheme: TabBarTheme(
          labelStyle: MyTextStyles.body2, // color for text
        ),
      ),
      home: StudioMainScreen(
          contentsBoookName: '나의 첫 콘텐츠북', user: UserModel(id: 'skpark')),
    );
  }
}
