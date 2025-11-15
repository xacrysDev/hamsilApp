import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../models/datamodel.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../blocs/validators.dart';

class Admin extends StatefulWidget {
  static const routeName = '/admin';

  const Admin({super.key});
  @override
  AdminState createState() => AdminState();
}

class AdminState extends State<Admin> with Validators {
  final AuthBloc authBloc = AuthBloc();
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool spinnerVisible = false;
  bool messageVisible = false;
  bool srchVisible = false;
  bool _btnEnabled = false;

  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  SettingsDataModel formData = SettingsDataModel(
    name: '',
    email: '',
    phone: '',
    role: '',
    author: '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    authBloc.dispose();
    super.dispose();
  }

  void toggleSpinner() => setState(() => spinnerVisible = !spinnerVisible);

  void showMessage(bool visible, String type, String message) {
    setState(() {
      messageVisible = visible;
      messageType = type == "error"
          ? CMessageType.error
          : CMessageType.success;
      messageTxt = message;
    });
  }

  void clearSearch() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    formData = SettingsDataModel(
      name: '',
      email: '',
      phone: '',
      role: '',
      author: '',
    );
  }

  void toggleSearch() {
    setState(() => srchVisible = !srchVisible);
  }

  Stream<QuerySnapshot> getData(SettingsDataModel formData) {
    Query qry = users;

    if ((formData.name ?? '').isNotEmpty) {
      qry = qry.where('name', isEqualTo: formData.name);
    }
    if ((formData.email ?? '').isNotEmpty) {
      qry = qry.where('email', isEqualTo: formData.email);
    }
    if ((formData.phone ?? '').isNotEmpty) {
      qry = qry.where('phone', isEqualTo: formData.phone);
    }

    return qry.limit(10).snapshots();
  }

  Future<void> _deleteUser(String docId) async {
    toggleSpinner();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(
            'Are you sure you want to delete this record? Record #: $docId'),
        actions: [
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              try {
                await users.doc(docId).delete();
                showMessage(true, "success", "Record deleted.");
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cAdmin)),
      drawer: Drawer(child: CustomAdminDrawer()),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: authBloc.isSignedIn() ? settings() : loginPage(),
        ),
      ),
    );
  }

  Widget loginPage() {
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

  Widget settings() {
    return ListView(
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Text("Manage Users", style: cHeaderDarkText),
                  const SizedBox(width: 30),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.blueAccent),
                    onPressed: toggleSearch,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 400,
                height: 600,
                child: srchVisible ? showSearch() : showUsers(),
              ),
              const SizedBox(height: 10),
              CustomSpinner(toggleSpinner: spinnerVisible),
              CustomMessage(
                toggleMessage: messageVisible,
                toggleMessageType: messageType,
                toggleMessageTxt: messageTxt,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showUsers() {
    return StreamBuilder<QuerySnapshot>(
      stream: getData(formData),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        final docs = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'] ?? ""),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.black, height: 5, thickness: 2),
                  Text("Email: ${data['email'] ?? ""}"),
                  Text("Phone: ${data['phone'] ?? ""}"),
                  Text("Author: ${data['author'] ?? ""}"),
                  Text("Role: ${data['role'] ?? "None assigned"}"),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/adminedit',
                          arguments: ScreenArguments(data['author']),
                        ),
                      ),
                      const SizedBox(width: 3, height: 50),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(data['author']),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget showSearch() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () => setState(
          () => _btnEnabled = _formKey.currentState?.validate() ?? false),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            _buildTextField(_nameController, "Name *", evalName, Icons.person,
                (val) => formData.name = val),
            const SizedBox(height: 5),
            _buildTextField(_emailController, "emailID *", evalEmail,
                Icons.email, (val) => formData.email = val),
            const SizedBox(height: 5),
            _buildTextField(_phoneController, "Phone *", evalPhone, Icons.phone,
                (val) => formData.phone = val),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: toggleSearch, child: const Text("Search")),
                const SizedBox(width: 30),
                ElevatedButton(
                    onPressed: clearSearch, child: const Text("Clear")),
              ],
            ),
            const SizedBox(height: 15),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
              toggleMessage: messageVisible,
              toggleMessageType: messageType,
              toggleMessageTxt: messageTxt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String? Function(String?) validator,
      IconData icon,
      void Function(String) onChanged) {
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
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
          hintText: label,
          labelText: label,
        ),
      ),
    );
  }
}
