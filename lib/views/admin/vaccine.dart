import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../models/datamodel.dart';
import '../../blocs/validators.dart';

class Vaccine extends StatefulWidget {
  static const routeName = '/vaccine';

  const Vaccine({super.key});
  @override
  VaccineState createState() => VaccineState();
}

class VaccineState extends State<Vaccine> with Validators {
  bool spinnerVisible = false;
  bool messageVisible = false;
  String messageTxt = "";
  String messageType = "";
  final _formKey = GlobalKey<FormState>();
  VaccineDataModel formData = VaccineDataModel(
    patientId: '',
    appointmentDate: '',
    newAppointmentDate: '',
    author: '',
  );
  bool _btnEnabled = false;
  String displayPage = "DataEntry";
  late TextEditingController _appointmentDate;
  late TextEditingController _newAppointmentDate;

  @override
  void initState() {
    super.initState();
    _appointmentDate = TextEditingController();
    _newAppointmentDate = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _setPatientID());
  }

  @override
  void dispose() {
    _appointmentDate.dispose();
    _newAppointmentDate.dispose();
    super.dispose();
  }

  void toggleSpinner() => setState(() => spinnerVisible = !spinnerVisible);
  void togglePage(String page) => setState(() => displayPage = page);

  void showMessage(bool visible, String type, String msg) {
    setState(() {
      messageVisible = visible;
      messageType =
          type == "error" ? CMessageType.error.toString() : CMessageType.success.toString();
      messageTxt = msg;
    });
  }

  void _setPatientID() {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    formData.patientId = args.patientID;
  }

  Stream<QuerySnapshot> getData(String filter, String docId) {
    Query qry;
    final authBloc = AuthBloc();

    switch (filter) {
      case "Vaccine":
        qry = authBloc.person.doc(docId).collection("Vaccine");
        break;
      case "OPD":
        qry = authBloc.person.doc(docId).collection("OPD");
        break;
      case "Rx":
        qry = authBloc.person.doc(docId).collection("Rx");
        break;
      case "Lab":
        qry = authBloc.person.doc(docId).collection("Lab");
        break;
      case "Messages":
        qry = authBloc.person.doc(docId).collection("Messages");
        break;
      case "Person":
        qry = authBloc.person.where("author", isEqualTo: docId);
        break;
      default:
        throw Exception("Unknown filter $filter");
    }

    return qry.limit(10).snapshots();
  }

  Future<void> setData(AuthBloc authBloc) async {
    toggleSpinner();
    try {
      await authBloc.setVaccineData(
        formData: formData,
      );
      showMessage(true, "success",
          "Data is saved. DO NOT click on SAVE again. Patient is given a new Appointment Date after 30 days.");
    } catch (error) {
      showMessage(true, "error", error.toString());
    }
    toggleSpinner();
  }

  Future<void> _deleteDoc(String patientId, String collID, String docId) async {
    toggleSpinner();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Are you sure you want to delete record #: $docId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final authBloc = AuthBloc();
      try {
        await authBloc.person.doc(patientId).collection(collID).doc(docId).delete();
        showMessage(true, "success", "Record Deleted.");
      } catch (e) {
        showMessage(true, "error", e.toString());
      }
    }
    toggleSpinner();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    final authBloc = AuthBloc();

    return Scaffold(
      appBar: AppBar(title: const Text(cVaccineTitle)),
      drawer: const Drawer(child: CustomAdminDrawer()),
      body: ListView(
        children: [
          Center(
            child: Container(
              width: 600,
              margin: const EdgeInsets.all(20.0),
              child: authBloc.isSignedIn()
                  ? _buildPage(context, authBloc, args.patientID)
                  : loginPage(authBloc),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, AuthBloc authBloc, String patientID) {
    switch (displayPage) {
      case "DataEntry":
        return settings(context, authBloc, patientID);
      case "Vaccine":
        return showVaccineHistory(context, authBloc);
      case "OPD":
        return showOPDHistory(context, authBloc);
      case "Rx":
        return showRxHistory(context, authBloc);
      case "Lab":
        return showLabHistory(context, authBloc);
      case "Messages":
        return showMessagesHistory(context, authBloc);
      case "Person":
        return showPersonHistory(context, authBloc);
      default:
        return settings(context, authBloc, patientID);
    }
  }

  Widget loginPage(AuthBloc authBloc) {
    return Column(
      children: [
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Click here to go to Login page'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  Widget settings(BuildContext context, AuthBloc authBloc, String patientID) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () => setState(() => _btnEnabled = _formKey.currentState!.validate()),
      child: Column(
        children: [
          const SizedBox(height: 25),
          TextFormField(
            controller: _appointmentDate,
            decoration: const InputDecoration(
              labelText: "Vaccination Date",
            ),
            validator: evalName,
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              DateTime? date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                _appointmentDate.text = date.toIso8601String();
                formData.appointmentDate = date.toIso8601String();
              }
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _newAppointmentDate,
            decoration: const InputDecoration(
              labelText: "Next Appointment Date",
            ),
            validator: evalName,
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              DateTime? date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                _newAppointmentDate.text = date.toIso8601String();
                formData.newAppointmentDate = date.toIso8601String();
              }
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _btnEnabled ? () => setData(authBloc) : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Aquí implementamos las vistas de historial de forma moderna:
  Widget showVaccineHistory(BuildContext context, AuthBloc authBloc) {
    return _historyList(context, authBloc, "Vaccine");
  }

  Widget showOPDHistory(BuildContext context, AuthBloc authBloc) {
    return _historyList(context, authBloc, "OPD");
  }

  Widget showRxHistory(BuildContext context, AuthBloc authBloc) {
    return _historyList(context, authBloc, "Rx");
  }

  Widget showLabHistory(BuildContext context, AuthBloc authBloc) {
    return _historyList(context, authBloc, "Lab");
  }

  Widget showMessagesHistory(BuildContext context, AuthBloc authBloc) {
    return _historyList(context, authBloc, "Messages");
  }

  Widget showPersonHistory(BuildContext context, AuthBloc authBloc) {
    return _historyList(context, authBloc, "Person");
  }

  Widget _historyList(BuildContext context, AuthBloc authBloc, String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: getData(collectionName, formData.patientId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("An unknown error has occurred");
        }
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final document = docs[index];
            return ListTile(
              title: Row(
                children: [
                  Text("$collectionName Record"),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.green),
                    onPressed: () => togglePage("DataEntry"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDoc(formData.patientId, collectionName, document.id),
                  ),
                ],
              ),
              subtitle: Text(document.data().toString()),
            );
          },
        );
      },
    );
  }
}
