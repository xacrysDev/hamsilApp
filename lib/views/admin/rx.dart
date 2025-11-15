import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../models/datamodel.dart';
import '../../blocs/validators.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';

class Rx extends StatefulWidget {
  static const routeName = '/rx';

  const Rx({super.key});
  @override
  RxState createState() => RxState();
}

class RxState extends State<Rx> with Validators {
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool _btnEnabled = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  String displayPage = "DataEntry";

  final _formKey = GlobalKey<FormState>();
  RxDataModel formData = RxDataModel(
    patientId: '',
    rxDate: '',
    from: '',
    status: '',
    rx: '',
    results: '',
    descr: '',
    comments: '',
    author: '',
  );

  late TextEditingController _rxDate;
  late TextEditingController _from;
  late TextEditingController _status;
  late TextEditingController _rx;
  late TextEditingController _results;
  late TextEditingController _descr;
  late TextEditingController _comments;
  late TextEditingController _author;

  @override
  void initState() {
    super.initState();
    _rxDate = TextEditingController();
    _from = TextEditingController();
    _status = TextEditingController();
    _rx = TextEditingController();
    _results = TextEditingController();
    _descr = TextEditingController();
    _comments = TextEditingController();
    _author = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _setPatientID());
  }

  @override
  void dispose() {
    _rxDate.dispose();
    _from.dispose();
    _status.dispose();
    _rx.dispose();
    _results.dispose();
    _descr.dispose();
    _comments.dispose();
    _author.dispose();
    authBloc.dispose();
    super.dispose();
  }

  void toggleSpinner() => setState(() => spinnerVisible = !spinnerVisible);

  void togglePage(String page) => setState(() => displayPage = page);

  void showMessage(bool visible, String type, String msg) {
    setState(() {
      messageVisible = visible;
      messageType = type == "error" ? CMessageType.error : CMessageType.success;
      messageTxt = msg;
    });
  }

  void _setPatientID() {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    formData.patientId = args.patientID;
    _author.text = args.patientID; // por si quieres autocompletar author
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
        throw Exception("Unknown filter $filter");
    }

    return qry.limit(10).snapshots();
  }

  Future<void> setData(AuthBloc authBloc) async {
    toggleSpinner();
    try {
      formData.rxDate = _rxDate.text;
      formData.from = _from.text;
      formData.status = _status.text;
      formData.rx = _rx.text;
      formData.results = _results.text;
      formData.descr = _descr.text;
      formData.comments = _comments.text;
      formData.author = _author.text;

      await authBloc.setRxData(formData: formData);
      showMessage(true, "success",
          "Data is saved. DO NOT click SAVE again. Rx Record is added.");
    } catch (error) {
      showMessage(true, "error", error.toString());
    }
    toggleSpinner();
  }

  Future<void> _deleteDoc(String patientId, String collID, String docId) async {
    toggleSpinner();
    messageVisible = true;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Are you sure you want to delete record #: $docId?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await authBloc.person
            .doc(patientId)
            .collection(collID)
            .doc(docId)
            .delete();
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
      appBar: AppBar(title: const Text(cRxTitle)),
      drawer: const Drawer(child: CustomAdminDrawer()),
      body: ListView(
        children: [
          Center(
            child: Container(
              width: 600,
              height: 800,
              margin: const EdgeInsets.all(20.0),
              child: authBloc.isSignedIn()
                  ? _buildPage(authBloc, args.patientID)
                  : _loginPage(authBloc),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPage(AuthBloc authBloc, String patientID) {
    switch (displayPage) {
      case "DataEntry":
        return _settings(authBloc, patientID);
      case "Vaccine":
        return _historyList("Vaccine", patientID, authBloc);
      case "OPD":
        return _historyList("OPD", patientID, authBloc);
      case "Rx":
        return _historyList("Rx", patientID, authBloc);
      case "Lab":
        return _historyList("Lab", patientID, authBloc);
      case "Person":
        return _historyList("Person", patientID, authBloc);
      case "Messages":
        return _historyList("Messages", patientID, authBloc);
      default:
        return _settings(authBloc, patientID);
    }
  }

  Widget _loginPage(AuthBloc authBloc) {
    return Column(
      children: [
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Click here to go to Login page'),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ],
    );
  }

  // ====================================
  // Funciones nuevas: _settings y _historyList
  // ====================================
  Widget _settings(AuthBloc authBloc, String patientID) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () =>
          setState(() => _btnEnabled = _formKey.currentState!.validate()),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.hot_tub, color: Colors.red),
                    onPressed: null),
                const SizedBox(width: 5),
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _btnEnabled ? () => setData(authBloc) : null,
                  child: const Text('Save'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  child: const Text('Back'),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/appointments'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
              toggleMessage: messageVisible,
              toggleMessageType: messageType,
              toggleMessageTxt: messageTxt,
            ),
            ..._buildFormFields(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final fields = [
      {
        'controller': _rxDate,
        'label': 'Rx Date',
        'value': (String v) => formData.rxDate = v
      },
      {
        'controller': _from,
        'label': 'From',
        'value': (String v) => formData.from = v
      },
      {
        'controller': _status,
        'label': 'Status',
        'value': (String v) => formData.status = v
      },
      {
        'controller': _rx,
        'label': 'Pharmacy',
        'value': (String v) => formData.rx = v
      },
      {
        'controller': _results,
        'label': 'Results',
        'value': (String v) => formData.results = v
      },
      {
        'controller': _descr,
        'label': 'Description',
        'value': (String v) => formData.descr = v
      },
      {
        'controller': _comments,
        'label': 'Comments',
        'value': (String v) => formData.comments = v
      },
      {
        'controller': _author,
        'label': 'Author',
        'value': (String v) => formData.author = v
      },
    ];

    return fields.map((f) {
      return Container(
        width: 300,
        margin: const EdgeInsets.only(top: 25),
        child: TextFormField(
          controller: f['controller'] as TextEditingController,
          maxLength: 50,
          onChanged: f['value'] as void Function(String),
          validator: evalName,
          decoration: InputDecoration(
            labelText: '${f['label']} *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.dashboard),
          ),
        ),
      );
    }).toList();
  }

  Widget _historyList(String filter, String patientID, AuthBloc authBloc) {
    return StreamBuilder<QuerySnapshot>(
      stream: getData(filter, patientID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          showMessage(true, "error", "An unknown error has occurred.");
          return const SizedBox();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final document = docs[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Row(
                  children: [
                    Text("$filter Record:", style: cNavRightText),
                    IconButton(
                        icon: const Icon(Icons.close, color: Colors.green),
                        onPressed: () => togglePage("DataEntry")),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deleteDoc(patientID, filter, document.id)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (document.data() as Map<String, dynamic>)
                      .entries
                      .map<Widget>((e) {
                    return Row(
                      children: [
                        Text("${e.key}: "),
                        Text("${e.value}"),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
