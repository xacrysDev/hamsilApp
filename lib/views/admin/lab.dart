import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../models/datamodel.dart';
import '../../blocs/validators.dart';

class LAB extends StatefulWidget {
  static const routeName = '/lab';

  const LAB({super.key});

  @override
  LABState createState() => LABState();
}

class LABState extends State<LAB> with Validators{
  bool spinnerVisible = false;
  bool messageVisible = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  bool _btnEnabled = false;
  String displayPage = "DataEntry";

  final _formKey = GlobalKey<FormState>();
  LabDataModel formData = LabDataModel(
    patientId: '',
    labDate: '',
    from: '',
    status: '',
    lab: '',
    results: '',
    descr: '',
    comments: '',
    author: '',
  );

  final TextEditingController _labDateController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _labController = TextEditingController();
  final TextEditingController _resultsController = TextEditingController();
  final TextEditingController _descrController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  late final AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setPatientID());
  }

  @override
  void dispose() {
    authBloc.dispose();
    _labDateController.dispose();
    _fromController.dispose();
    _statusController.dispose();
    _labController.dispose();
    _resultsController.dispose();
    _descrController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void toggleSpinner() {
    setState(() => spinnerVisible = !spinnerVisible);
  }

  void togglePage(String page) {
    setState(() => displayPage = page);
  }

  void showMessage(bool visible, String type, String message) {
    setState(() {
      messageVisible = visible;
      messageType = type == "error"
          ? CMessageType.error
          : CMessageType.success;
      messageTxt = message;
    });
  }

  void _setPatientID() {
    final args = ModalRoute.of(context)?.settings.arguments as ScreenArguments?;
    if (args != null) {
      formData.patientId = args.patientID;
    }
  }

  Stream<QuerySnapshot> getData(String filter, String docId) {
    Query qry;

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
        qry = authBloc.person.doc(docId).collection("Lab");
    }

    return qry.limit(10).snapshots();
  }

  Future<void> setData() async {
    toggleSpinner();
    try {
      await authBloc.setLABData(formData);
      showMessage(true, "success", "Data is saved. DO NOT click SAVE again.");
    } catch (e) {
      showMessage(true, "error", e.toString());
    } finally {
      toggleSpinner();
    }
  }

  Future<void> _deleteDoc(String patientId, String collID, String docId) async {
    toggleSpinner();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
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
                } catch (e) {
                  showMessage(true, "error", e.toString());
                } finally {
                  Navigator.of(context).pop();
                  toggleSpinner();
                }
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
        );
      },
    );
  }

  Widget buildFormField(TextEditingController controller, String label,
      Function(String) onChanged) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 25),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.blueAccent,
        keyboardType: TextInputType.text,
        maxLength: 50,
        obscureText: false,
        onChanged: onChanged,
        validator: evalName,
        decoration: InputDecoration(
          icon: const Icon(Icons.dashboard),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          labelText: '$label *',
          hintText: label,
        ),
      ),
    );
  }

  Widget buildHistoryStream(String filter) {
    return StreamBuilder<QuerySnapshot>(
      stream: getData(filter, formData.patientId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("An unknown error occurred."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text("No records found."));

        return ListView(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Row(
                children: [
                  Text("$filter Record:", style: cNavRightText),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.green),
                    onPressed: () => togglePage("DataEntry"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteDoc(formData.patientId, filter, doc.id),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.entries.map((entry) {
                  return Row(
                    children: [
                      Text("${entry.key}: "),
                      Text("${entry.value}"),
                    ],
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildSettings() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () => setState(
          () => _btnEnabled = _formKey.currentState?.validate() ?? false),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon:
                        const Icon(Icons.sanitizer, color: Colors.orangeAccent),
                    onPressed: null),
                const Text("Update Lab Data", style: cHeaderDarkText),
                IconButton(
                    icon:
                        const Icon(Icons.healing_rounded, color: Colors.green),
                    onPressed: () => togglePage("Vaccine")),
                IconButton(
                    icon: const Icon(Icons.person, color: Colors.blueGrey),
                    onPressed: () => togglePage("Person")),
                IconButton(
                    icon: const Icon(Icons.view_headline,
                        color: Colors.greenAccent),
                    onPressed: () => togglePage("OPD")),
                IconButton(
                    icon: const Icon(Icons.hot_tub, color: Colors.red),
                    onPressed: () => togglePage("Rx")),
                IconButton(
                    icon:
                        const Icon(Icons.sanitizer, color: Colors.orangeAccent),
                    onPressed: () => togglePage("Lab")),
                IconButton(
                    icon: const Icon(Icons.sms, color: Colors.deepPurple),
                    onPressed: () => togglePage("Messages")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _btnEnabled ? setData : null,
                    child: const Text('Save')),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/appointments'),
                    child: const Text('Back')),
              ],
            ),
            const SizedBox(height: 10),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
                toggleMessage: messageVisible,
                toggleMessageType: messageType,
                toggleMessageTxt: messageTxt),
            buildFormField(
                _fromController, "From", (val) => formData.from = val),
            buildFormField(
                _statusController, "Status", (val) => formData.status = val),
            buildFormField(
                _labController, "Pathology", (val) => formData.lab = val),
            buildFormField(
                _resultsController, "Results", (val) => formData.results = val),
            buildFormField(
                _descrController, "Description", (val) => formData.descr = val),
            buildFormField(_commentsController, "Comments",
                (val) => formData.comments = val),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cPathologyTitle)),
      drawer: const Drawer(child: CustomAdminDrawer()),
      body: Center(
        child: Container(
          width: 600,
          height: 800,
          margin: const EdgeInsets.all(20),
          child: authBloc.isSignedIn()
              ? (displayPage == "DataEntry"
                  ? buildSettings()
                  : buildHistoryStream(displayPage))
              : Column(
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Click here to go to Login page'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
