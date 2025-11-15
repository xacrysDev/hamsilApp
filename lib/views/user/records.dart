import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';

class Records extends StatefulWidget {
  static const routeName = '/records';

  const Records({super.key});

  @override
  RecordsState createState() => RecordsState();
}

class RecordsState extends State<Records> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  String messageType = "";
  String displayPage = "Vaccine";

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }

  void toggleSpinner() => setState(() => spinnerVisible = !spinnerVisible);

  void togglePage(String filter) => setState(() => displayPage = filter);

  void showMessage(bool msgVisible, String msgType, String message) {
    messageVisible = msgVisible;
    setState(() {
      messageType =
          msgType == "error" ? CMessageType.error.toString() : CMessageType.success.toString();
      messageTxt = message;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getData(String filter, String docId) {
    CollectionReference<Map<String, dynamic>>? collection;
    Query<Map<String, dynamic>>? query;

    switch (filter) {
      case "Vaccine":
      case "OPD":
      case "Rx":
      case "Lab":
      case "Messages":
        collection = authBloc.person.doc(docId).collection(filter);
        query = collection.limit(10);
        break;
      case "Person":
        query = authBloc.person.where("author", isEqualTo: docId).limit(10);
        break;
    }

    return query!.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cPRecords)),
      drawer: const Drawer(child: CustomGuestDrawer()),
      body: Center(
        child: Container(
          width: 600,
          height: 600,
          margin: const EdgeInsets.all(20),
          child: authBloc.isSignedIn() ? settings(authBloc) : loginPage(authBloc),
        ),
      ),
    );
  }

  Widget loginPage(AuthBloc authBloc) {
    return Column(
      children: [
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Click here to go to Login page'),
        ),
      ],
    );
  }

  Widget settings(AuthBloc authBloc) {
    return Column(
      children: [
        const SizedBox(height: 25),
        Wrap(
          spacing: 10,
          children: [
            IconButton(
                icon: const Icon(Icons.settings, color: Colors.blue),
                onPressed: null),
            IconButton(
                icon: const Icon(Icons.healing_rounded, color: Colors.green),
                onPressed: () => togglePage("Vaccine")),
            IconButton(
                icon: const Icon(Icons.person, color: Colors.blueGrey),
                onPressed: () => togglePage("Person")),
            IconButton(
                icon: const Icon(Icons.view_headline, color: Colors.greenAccent),
                onPressed: () => togglePage("OPD")),
            IconButton(
                icon: const Icon(Icons.hot_tub, color: Colors.red),
                onPressed: () => togglePage("Rx")),
            IconButton(
                icon: const Icon(Icons.sanitizer, color: Colors.orangeAccent),
                onPressed: () => togglePage("Lab")),
            IconButton(
                icon: const Icon(Icons.sms, color: Colors.deepPurple),
                onPressed: () => togglePage("Messages")),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SizedBox(
            width: 600,
            child: Builder(
              builder: (_) {
                switch (displayPage) {
                  case "Vaccine":
                    return recordList("Past Vaccine Record:", "Vaccine");
                  case "Person":
                    return recordList("Person Record:", "Person");
                  case "OPD":
                    return recordList("Past OPD Record:", "OPD");
                  case "Rx":
                    return recordList("Past Rx Record:", "Rx");
                  case "Lab":
                    return recordList("Past Lab Record:", "Lab");
                  case "Messages":
                    return recordList("Message Record:", "Messages");
                  default:
                    return const Text("No Records");
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget recordList(String titleLabel, String collectionName) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: getData(collectionName, _auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('No past records available.', style: cErrorText);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.black, thickness: 1),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(titleLabel, style: cNavRightText),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("${entry.key}: ${entry.value}"),
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
