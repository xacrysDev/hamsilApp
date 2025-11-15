import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../blocs/validators.dart';
import '../../models/datamodel.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';

class OPD extends StatefulWidget {
  static const routeName = '/opd';

  const OPD({super.key});
  @override
  OPDState createState() => OPDState();
}

class OPDState extends State<OPD> with Validators {
  final _formKey = GlobalKey<FormState>();
  late final AuthBloc authBloc;

  // Controles de campos
  late final TextEditingController _opdDate;
  late final TextEditingController _symptoms;
  late final TextEditingController _diagnosis;
  late final TextEditingController _rx;
  late final TextEditingController _lab;
  late final TextEditingController _comments;

  bool spinnerVisible = false;
  bool messageVisible = false;
  bool _btnEnabled = false;
  String displayPage = "DataEntry";
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  OPDDataModel formData = OPDDataModel(
    patientId: '',
    opdDate: '',
    symptoms: '',
    diagnosis: '',
    treatment: '',
    rx: '',
    lab: '',
    comments: '',
    author: '',
  );

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();

    _opdDate = TextEditingController();
    _symptoms = TextEditingController();
    _diagnosis = TextEditingController();
    _rx = TextEditingController();
    _lab = TextEditingController();
    _comments = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => setPatientID());
  }

  @override
  void dispose() {
    authBloc.dispose();
    _opdDate.dispose();
    _symptoms.dispose();
    _diagnosis.dispose();
    _rx.dispose();
    _lab.dispose();
    _comments.dispose();
    super.dispose();
  }

  void toggleSpinner() => setState(() => spinnerVisible = !spinnerVisible);
  void togglePage(String page) => setState(() => displayPage = page);

  void showMessage(bool visible, String type, String msg) {
    setState(() {
      messageVisible = visible;
      messageType = type == "error"
          ? CMessageType.error
          : CMessageType.success;
      messageTxt = msg;
    });
  }

  void setPatientID() {
    final args = ModalRoute.of(context)?.settings.arguments as ScreenArguments?;
    if (args != null) {
      formData.patientId = args.patientID;
    }
  }

  Stream<QuerySnapshot> getData(String filter, String docId) {
    final personDoc = authBloc.person.doc(docId);

    switch (filter) {
      case "Vaccine":
        return personDoc.collection("Vaccine").limit(10).snapshots();
      case "OPD":
        return personDoc.collection("OPD").limit(10).snapshots();
      case "Rx":
        return personDoc.collection("Rx").limit(10).snapshots();
      case "Lab":
        return personDoc.collection("Lab").limit(10).snapshots();
      case "Messages":
        return personDoc.collection("Messages").limit(10).snapshots();
      case "Person":
        return authBloc.person
            .where("author", isEqualTo: docId)
            .limit(10)
            .snapshots();
      default:
        throw Exception("Unknown filter: $filter");
    }
  }

  Future<void> setData() async {
    toggleSpinner();
    try {
      await authBloc.setOPDData(formData: formData);
      showMessage(true, "success",
          "Data is saved. DO NOT click SAVE again. OPD Record is added.");
    } catch (error) {
      showMessage(true, "error", error.toString());
    }
    toggleSpinner();
  }

  Future<void> _deleteDoc(String patientId, String collID, String docId) async {
    toggleSpinner();
    messageVisible = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(
            'Are you sure you want to delete this record? Record #: $docId'),
        actions: [
          TextButton(
            child: const Text('Confirm'),
            onPressed: () async {
              try {
                await authBloc.person
                    .doc(patientId)
                    .collection(collID)
                    .doc(docId)
                    .delete();
                showMessage(true, "success", "Record Deleted.");
              } catch (error) {
                showMessage(true, "error", error.toString());
              }
              Navigator.of(context).pop();
              toggleSpinner();
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
              toggleSpinner();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ScreenArguments?;
    if (args != null) formData.patientId = args.patientID;

    return Scaffold(
      appBar: AppBar(title: const Text(cOPDIPDTitle)),
      drawer: Drawer(child: CustomAdminDrawer()),
      body: Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.all(20),
          child: authBloc.isSignedIn()
              ? displayPage == "DataEntry"
                  ? settings()
                  : historyPage(displayPage)
              : loginPage(),
        ),
      ),
    );
  }

  Widget loginPage() => Column(
        children: [
          const SizedBox(height: 50),
          ElevatedButton(
            child: const Text('Click here to go to Login page'),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      );

  Widget settings() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () =>
          setState(() => _btnEnabled = _formKey.currentState!.validate()),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          buildTextField(
              "Symptoms *", _symptoms, (val) => formData.symptoms = val),
          buildTextField(
              "Diagnosis *", _diagnosis, (val) => formData.diagnosis = val),
          buildTextField("Pharmacy *", _rx, (val) => formData.rx = val),
          buildTextField("Lab Tests *", _lab, (val) => formData.lab = val),
          buildTextField(
              "Treatment *", _comments, (val) => formData.treatment = val),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: _btnEnabled ? setData : null,
                  child: const Text("Save")),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/appointments'),
                  child: const Text("Back")),
            ],
          ),
          CustomSpinner(toggleSpinner: spinnerVisible),
          CustomMessage(
              toggleMessage: messageVisible,
              toggleMessageType: messageType,
              toggleMessageTxt: messageTxt),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      Function(String) onChanged) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 25),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.blueAccent,
        maxLength: 50,
        onChanged: onChanged,
        validator: evalName,
        decoration: InputDecoration(
          icon: const Icon(Icons.dashboard),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          hintText: label,
          labelText: label,
        ),
      ),
    );
  }

  Widget historyPage(String filter) {
    return StreamBuilder<QuerySnapshot>(
      stream: getData(filter, formData.patientId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("An unknown error occurred.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return ListTile(
              title: Row(
                children: [
                  Text("$filter Record:", style: cNavRightText),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.green),
                      onPressed: () => togglePage("DataEntry")),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deleteDoc(formData.patientId, filter, doc.id)),
                ],
              ),
              subtitle: Column(
                children: [
                  ...data.entries.map((e) => Row(
                        children: [Text("${e.key}: "), Text("${e.value}")],
                      )),
                  const Divider(color: Colors.black, height: 5, thickness: 2),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
