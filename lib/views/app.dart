import 'package:flutter/material.dart';
import '../../shared/custom_style.dart';
import '../../views/aboutus.dart';
import '../../views/auth/settings.dart';
import '../../views/auth/signup.dart';
import '../../views/auth/login.dart';
import '../../views/admin/reports.dart';
import '../../views/admin/patient.dart';
import '../../views/admin/appointments.dart';
import '../../views/admin/vaccine.dart';
import '../../views/admin/opd.dart';
import '../../views/admin/messages.dart';
import '../../views/admin/rx.dart';
import '../../views/admin/lab.dart';
import '../../views/admin/admin.dart';
import '../../views/admin/adminedit.dart';
import '../../views/user/person.dart';
import '../../views/user/records.dart';
import '../../views/user/appointment.dart';
import '../../views/user/loom.dart';
import '../../views/user/loomdocs.dart';
import '../../views/scm/purchase.dart';
import '../../views/scm/msr.dart';
import '../../views/scm/center.dart';
import '../../views/scm/vendor.dart';
import '../../views/scm/warehouse.dart';
import '../../views/scm/item.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF666666, {
          50: Color.fromRGBO(4, 131, 184, .1),
          100: Color.fromRGBO(4, 131, 184, .2),
          200: Color.fromRGBO(4, 131, 184, .3),
          300: Color.fromRGBO(4, 131, 184, .4),
          400: Color.fromRGBO(4, 131, 184, .5),
          500: Color.fromRGBO(4, 131, 184, .6),
          600: Color.fromRGBO(4, 131, 184, .7),
          700: Color.fromRGBO(4, 131, 184, .8),
          800: Color.fromRGBO(4, 131, 184, .9),
          900: Color.fromRGBO(4, 131, 184, 1),
        }),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        AboutUs.routeName: (context) => const AboutUs(),
        LogIn.routeName: (context) => LogIn(),
        Settings.routeName: (context) => Settings(),
        SignUp.routeName: (context) => SignUp(),
        Reports.routeName: (context) => Reports(),
        Patient.routeName: (context) => Patient(),
        Person.routeName: (context) => Person(),
        Records.routeName: (context) => Records(),
        Appointment.routeName: (context) => Appointment(),
        Loom.routeName: (context) => Loom(),
        LoomDocs.routeName: (context) => LoomDocs(),
        Appointments.routeName: (context) => Appointments(),
        Vaccine.routeName: (context) => Vaccine(),
        OPD.routeName: (context) => OPD(),
        LAB.routeName: (context) => LAB(),
        Rx.routeName: (context) => Rx(),
        Messages.routeName: (context) => Messages(),
        Purchase.routeName: (context) => Purchase(),
        MSR.routeName: (context) => MSR(),
        Centre.routeName: (context) => Centre(),
        Vendor.routeName: (context) => Vendor(),
        Warehouse.routeName: (context) => Warehouse(),
        Item.routeName: (context) => Item(),
        Admin.routeName: (context) => Admin(),
        AdminEdit.routeName: (context) => AdminEdit(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.deepOrangeAccent,
          iconSize: 28.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUs()),
            );
          },
        ),
        title: const Text(cAppTitle),
      ),
      body: ListView(
        children: [
          Center(
            child: LogIn(), // no const porque LogIn probablemente no tiene constructor const
          )
        ],
      ),
    );
  }
}
