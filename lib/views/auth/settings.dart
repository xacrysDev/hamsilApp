import 'dart:async';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../models/datamodel.dart';
import '../../blocs/validators.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  static const routeName = '/settings';

  const Settings({super.key});
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> with Validators {
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success; // enum directamente
  final _formKey = GlobalKey<FormState>();
  final SettingsDataModel formData = SettingsDataModel(
    name: '',
    email: '',
    phone: '',
    role: '',
    author: '',
  );
  bool _btnEnabled = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late final AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();
    getData();
  }

  @override
  void dispose() {
    authBloc.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void toggleSpinner() {
    setState(() => spinnerVisible = !spinnerVisible);
  }

  void showMessage(bool visible, CMessageType type, String message) {
    setState(() {
      messageVisible = visible;
      messageType = type;
      messageTxt = message;
    });
  }

  Future<void> getData() async {
    toggleSpinner();
    if (authBloc.isSignedIn()) {
      try {
        final res = await authBloc.getUserData();
        updateFormData(SettingsDataModel.fromJson(res!.data()!));
      } catch (e) {
        showMessage(
            true, CMessageType.error, "User information is not available.");
      }
    } else {
      showMessage(true, CMessageType.error, "An unknown error has occurred.");
    }
    toggleSpinner();
  }

  void updateFormData(SettingsDataModel data) {
    formData.name = data.name;
    formData.email = data.email;
    formData.phone = data.phone;
    formData.role = data.role;

    _nameController.text = formData.name;
    _emailController.text = formData.email;
    _phoneController.text = formData.phone;

    if (formData.role == "admin") {
      setState(() => isAdmin = true);
    }
  }

  Future<void> setData() async {
    toggleSpinner();
    try {
      await authBloc.setUserData(formData:formData);
      showMessage(true, CMessageType.success, "Data is saved.");
    } catch (e) {
      showMessage(true, CMessageType.error, e.toString());
    }
    toggleSpinner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cSettingsTitle)),
      drawer: Drawer(
        child: isAdmin ? CustomAdminDrawer() : CustomGuestDrawer(),
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: authBloc.isSignedIn() ? settingsForm() : loginPrompt(),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginPrompt() {
    return Column(
      children: [
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Go to Login page'),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ],
    );
  }

  Widget settingsForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () => setState(
          () => _btnEnabled = _formKey.currentState?.validate() ?? false),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            buildTextField(
                controller: _nameController,
                label: 'Name *',
                hint: 'your name',
                icon: Icons.person,
                onChanged: (val) => formData.name = val,
                validator: evalName),
            const SizedBox(height: 5),
            buildTextField(
                controller: _emailController,
                label: 'EmailID *',
                hint: 'name@domain.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => formData.email = val,
                validator: evalEmail),
            const SizedBox(height: 5),
            buildTextField(
                controller: _phoneController,
                label: 'Phone *',
                hint: '123-000-0000',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                onChanged: (val) => formData.phone = val,
                validator: evalPhone),
            const SizedBox(height: 25),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
                toggleMessage: messageVisible,
                toggleMessageType: messageType,
                toggleMessageTxt: messageTxt),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _btnEnabled ? setData : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 25),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.blueAccent,
        keyboardType: keyboardType,
        maxLength: 50,
        obscureText: false,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          hintText: hint,
          labelText: label,
        ),
      ),
    );
  }
}
