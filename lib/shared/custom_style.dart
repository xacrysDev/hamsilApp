import 'package:flutter/material.dart';

// ------------------- App Titles -------------------
const String cAppTitle = "HMS App";
const String cAboutUsTitle = "About us";
const String cSignupTitle = "Create new account";
const String cSettingsTitle = "Settings";
const String cRxTitle = "Pharmacy";
const String cVaccineTitle = "Vaccine";
const String cOPDIPDTitle = "OPD/IPD";
const String cMessagesTitle = "Messages";
const String cPathologyTitle = "Pathology";
const String cAppointment = "Appointments";
const String cAdmin = "Admin";
const String cPerson = "Personal Data";
const String cPRecords = "Records";
const String cReports = "Reports";
const String cSCM = "Supply Chain";
const String cAddressBookTitle = "Address Book";
const String cAddressBookAddTitle = "Add Address Book";
const String cAddressBookEditTitle = "Edit Address Book";
const String cSignUpTitle = "Sign up";

// ------------------- Email & Sample -------------------
const String cEmailID = "info@elishconsulting.com";
const String cLabel = "Navigation Menu";
const String cSampleImage =
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJIzlrP5Fm5juFKR3saDL1rYDOV32y5IPF3UWC0CbIEhDgayJzrw";

// ------------------- Enum -------------------
enum CMessageType { error, success }

// ------------------- Text Styles -------------------
const TextStyle cNavText = TextStyle(
  color: Colors.blueAccent,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

const TextStyle cNavRightText = TextStyle(
  color: Colors.blueAccent,
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

const TextStyle cBodyText = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.blueGrey,
);

const TextStyle cErrorText = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.red,
);

const TextStyle cWarnText = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.orange,
);

const TextStyle cSuccessText = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.green,
);

const TextStyle cHeaderText = TextStyle(
  color: Colors.blueAccent,
  fontSize: 20,
  fontWeight: FontWeight.w500,
);

const TextStyle cHeaderWhiteText = TextStyle(
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.w500,
);

const TextStyle cHeaderDarkText = TextStyle(
  color: Colors.blueGrey,
  fontSize: 20,
  fontWeight: FontWeight.w500,
);

// ------------------- Theme -------------------
final ThemeData cThemeData = ThemeData(
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
  ).copyWith(
    secondary: Colors.blueAccent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blueAccent,
    ),
  ),
);
