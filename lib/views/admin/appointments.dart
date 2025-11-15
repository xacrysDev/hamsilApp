import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../models/datamodel.dart';
import '../../blocs/validators.dart';

class Appointments extends StatefulWidget {
  static const routeName = '/appointments';

  const Appointments({super.key});
  @override
  AppointmentsState createState() => AppointmentsState();
}

class AppointmentsState extends State<Appointments> {
  final AuthBloc _authBloc = AuthBloc();
  final _formKey = GlobalKey<FormState>();

  bool spinnerVisible = false;
  bool messageVisible = false;
  bool searchVisible = false;

  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  String dropDownValue = 'New';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  AppointmentDataModel formData = AppointmentDataModel(
    appointmentDate: '',
    name: '',
    phone: '',
    comments: '',
    author: '',
    status: 'New', // valor por defecto
  );

  @override
  void dispose() {
    _authBloc.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void toggleSpinner() => setState(() => spinnerVisible = !spinnerVisible);

  void toggleSearch() {
    setState(() => searchVisible = !searchVisible);
  }

  void clearSearch() {
    _nameController.clear();
    _phoneController.clear();
    formData = AppointmentDataModel(
      appointmentDate: '',
      name: '',
      phone: '',
      comments: '',
      author: '',
      status: 'New', // valor por defecto
    ); // reset
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAppointmentsStream() {
    Query<Map<String, dynamic>> query = _authBloc.appointments;

    if (formData.name.isNotEmpty ?? false) {
      query = query.where('name', isEqualTo: formData.name);
    }
    if (formData.phone.isNotEmpty ?? false) {
      query = query.where('phone', isEqualTo: formData.phone);
    }

    query = query.where('status', isEqualTo: formData.status ?? 'New');

    return query.limit(10).snapshots();
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

  Future<void> markAppointmentComplete(String docId) async {
    toggleSpinner();
    try {
      await _authBloc.appointments.doc(docId).update({'status': 'Complete'});
      showMessage(true, "success", "Appointment marked as complete.");
    } catch (e) {
      showMessage(true, "error", e.toString());
    } finally {
      toggleSpinner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cAppointment)),
      drawer: const CustomAdminDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _authBloc.isSignedIn()
              ? buildContent()
              : buildLoginButton(context),
        ),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: const Text('Go to Login page'),
    );
  }

  Widget buildContent() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.deepPurple),
            const SizedBox(width: 10),
            const Text("Appointments", style: cHeaderDarkText),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.blueAccent),
              onPressed: toggleSearch,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: searchVisible ? buildSearchForm() : buildAppointmentsList(),
        ),
        CustomSpinner(toggleSpinner: spinnerVisible),
        CustomMessage(
          toggleMessage: messageVisible,
          toggleMessageType: messageType,
          toggleMessageTxt: messageTxt,
        ),
      ],
    );
  }

  Widget buildAppointmentsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: getAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          showMessage(true, "error", "An unknown error occurred.");
          return const Center(child: Text("Error loading appointments"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text("No appointments found"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date: ${data['appointmentDate']}"),
                    Text("Name: ${data['name']}"),
                    Text("Phone: ${data['phone']}"),
                    Text("Comments: ${data['comments']}"),
                    Text("Status: ${data['status'] ?? 'New'}"),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/vaccine',
                              arguments: ScreenArguments(data['author']),
                            );
                          },
                          child: const Text('Vaccine'),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/opd',
                              arguments: ScreenArguments(data['author']),
                            );
                          },
                          child: const Text('OPD/IPD'),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          icon: const Icon(Icons.check_box_rounded,
                              color: Colors.green),
                          onPressed: () =>
                              markAppointmentComplete(data['author']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSearchForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              labelText: 'Name',
              hintText: 'Enter name',
            ),
            onChanged: (value) => formData.name = value,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              icon: Icon(Icons.phone),
              labelText: 'Phone',
              hintText: '123-000-0000',
            ),
            onChanged: (value) => formData.phone = value,
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: dropDownValue,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  dropDownValue = newValue;
                  formData.status = newValue;
                });
              }
            },
            items: <String>['New', 'Complete']
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: toggleSearch, child: const Text('Search')),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: clearSearch, child: const Text('Clear')),
            ],
          ),
        ],
      ),
    );
  }
}
