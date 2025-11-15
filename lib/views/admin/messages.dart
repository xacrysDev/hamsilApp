import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../models/datamodel.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../blocs/validators.dart';

class Messages extends StatefulWidget {
  static const routeName = '/messages';

  const Messages({super.key});
  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> with Validators {
  final _formKey = GlobalKey<FormState>();

  late final AuthBloc authBloc;

  // Controladores de campos de texto
  late final TextEditingController _from;
  late final TextEditingController _status;
  late final TextEditingController _message;
  late final TextEditingController _readReceipt;

  bool spinnerVisible = false;
  bool messageVisible = false;
  bool _btnEnabled = false;
  String displayPage = "DataEntry";
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;

  // Datos del formulario
  MessagesDataModel formData = MessagesDataModel(
    patientId: "",
    messagesDate: DateTime.now().toIso8601String(),
    from: "",
    status: "",
    message: "",
    readReceipt: false,
    author: "",
  );

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();

    _from = TextEditingController();
    _status = TextEditingController();
    _message = TextEditingController();
    _readReceipt = TextEditingController();

    // Inicializa patientId al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) => setPatientID());
  }

  @override
  void dispose() {
    authBloc.dispose();
    _from.dispose();
    _status.dispose();
    _message.dispose();
    _readReceipt.dispose();
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
      formData.author = args.patientID; // Autor por defecto
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
        return authBloc.person.where("author", isEqualTo: docId).limit(10).snapshots();
      default:
        throw Exception("Unknown filter: $filter");
    }
  }

  Future<void> setData() async {
    toggleSpinner();
    try {
      await authBloc.setMessagesData(formData: formData);
      showMessage(true, "success",
          "Data is saved. DO NOT click on SAVE again. Message record is added.");
    } catch (error) {
      showMessage(true, "error", error.toString());
    }
    toggleSpinner();
  }

  Future<void> deleteDoc(String patientId, String collID, String docId) async {
    toggleSpinner();
    messageVisible = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Are you sure you want to delete this record? Record #: $docId'),
        actions: [
          TextButton(
            child: const Text('Confirm'),
            onPressed: () async {
              try {
                await authBloc.person.doc(patientId).collection(collID).doc(docId).delete();
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
    return Scaffold(
      appBar: AppBar(title: const Text(cMessagesTitle)),
      drawer: Drawer(child: CustomAdminDrawer()),
      body: Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.all(20),
          child: authBloc.isSignedIn()
              ? displayPage == "DataEntry"
                  ? settings()
                  : pageSwitcher()
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
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      );

  Widget settings() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () => setState(() => _btnEnabled = _formKey.currentState!.validate()),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          buildTextField("From *", _from, (val) => formData.from = val),
          buildTextField("Status *", _status, (val) => formData.status = val),
          buildTextField("Message *", _message, (val) => formData.message = val),
          buildTextField("Read Receipt *", _readReceipt, (val) => formData.readReceipt = false),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/appointments'),
                  child: const Text("Back to Appointment")),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: _btnEnabled ? setData : null, child: const Text("Save")),
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

  Widget buildTextField(String label, TextEditingController controller, Function(String) onChanged) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 25),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.blueAccent,
        maxLength: 50,
        obscureText: false,
        onChanged: onChanged,
        validator: notEmpty,
        decoration: InputDecoration(
          icon: const Icon(Icons.dashboard),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          hintText: label,
          labelText: label,
        ),
      ),
    );
  }

  Widget pageSwitcher() {
    switch (displayPage) {
      case "Vaccine":
        return buildHistoryPage("Vaccine");
      case "Person":
        return buildHistoryPage("Person");
      case "OPD":
        return buildHistoryPage("OPD");
      case "Rx":
        return buildHistoryPage("Rx");
      case "Lab":
        return buildHistoryPage("Lab");
      case "Messages":
        return buildHistoryPage("Messages");
      default:
        return settings();
    }
  }

  Widget buildHistoryPage(String filter) {
    return StreamBuilder<QuerySnapshot>(
      stream: getData(filter, formData.patientId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("An unknown error occurred.");
        if (snapshot.connectionState == ConnectionState.waiting) return const Text("Loading...");
        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final document = docs[index];
            final data = document.data() as Map<String, dynamic>;

            return ListTile(
              title: Row(
                children: [
                  Text("$filter Record:", style: cNavRightText),
                  IconButton(icon: const Icon(Icons.close, color: Colors.green),
                      onPressed: () => togglePage("DataEntry")),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteDoc(formData.patientId, filter, document.id)),
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

  String? notEmpty(String? value) => (value == null || value.isEmpty) ? "Required" : null;
}
