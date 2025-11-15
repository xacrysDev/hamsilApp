import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../models/datamodel.dart';

class Patient extends StatefulWidget {
  static const routeName = '/patient';

  const Patient({super.key});

  @override
  PatientState createState() => PatientState();
}

class PatientState extends State<Patient> {
  bool spinnerVisible = false;
  bool messageVisible = false;
  String messageTxt = "";
  String messageType = "";

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }

  void showMessage(bool visible, String type, String message) {
    setState(() {
      messageVisible = visible;
      messageType = type == "error"
          ? CMessageType.error.toString()
          : CMessageType.success.toString();
      messageTxt = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as ScreenPatientArguments?;
    final authBloc = AuthBloc();

    return Scaffold(
      appBar: AppBar(title: const Text(cPRecords)),
      drawer: Drawer(child: CustomAdminDrawer()),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: authBloc.isSignedIn()
              ? _buildSettings(authBloc, args)
              : _buildLoginPage(authBloc),
        ),
      ),
    );
  }

  Widget _buildLoginPage(AuthBloc authBloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text('Click here to go to Login page'),
        ),
      ],
    );
  }

  Widget _buildSettings(AuthBloc authBloc, ScreenPatientArguments? args) {
    if (args == null) return const Text("No patient data provided.");

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          const SizedBox(height: 50),
          Text(args.reportType, style: cHeaderDarkText),
          const SizedBox(height: 50),
          SizedBox(
            width: 500,
            height: 500,
            child: _showRecords(args.patientID),
          ),
        ],
      ),
    );
  }

  Widget _showRecords(String patientID) {
    final stream = FirebaseFirestore.instance
        .collection('vaccine')
        .where('author', isEqualTo: patientID)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "An unknown error has occurred.",
            style: cErrorText,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text('Patient has no history records.', style: cErrorText);
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(doc['appointmentDate'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.black, thickness: 2),
                    Text("Name: ${doc['name'] ?? ''}  DOB: ${doc['dob'] ?? ''}"),
                    Text("ID Type: ${doc['idType'] ?? ''}  ID: ${doc['id'] ?? ''}"),
                    Text("Next Appt. Dt: ${doc['newAppointmentDate'] ?? ''}"),
                    Text("Occupation: ${doc['occupation'] ?? ''}"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
