import 'dart:async';
import 'package:flutter/material.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../models/datamodel.dart';
import '../../blocs/validators.dart';

class Appointment extends StatefulWidget {
  static const routeName = '/appointment';

  const Appointment({super.key});
  @override
  AppointmentState createState() => AppointmentState();
}

class AppointmentState extends State<Appointment> with Validators {
  late AuthBloc authBloc;
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;

  final _formKey = GlobalKey<FormState>();
  AppointmentDataModel formData = AppointmentDataModel(
    appointmentDate: '',
    name: '',
    phone: '',
    comments: '',
    author: '',
    status: '',
  );
  bool _btnEnabled = false;

  final TextEditingController _appointmentDateController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();
    _getData();
  }

  @override
  void dispose() {
    authBloc.dispose();
    _appointmentDateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _commentsController.dispose();
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

  Future<void> _getData() async {
    toggleSpinner();
    messageVisible = true;

    if (authBloc.isSignedIn()) {
      try {
        final res = await authBloc.getUserData();
        setState(
            () => _updateFormData(AppointmentDataModel.fromJson(res!.data()!)));
      } catch (e) {
        showMessage(
            true, CMessageType.error, "User information is not available.");
      }
    } else {
      showMessage(true, CMessageType.error, "An unknown error has occurred.");
    }

    toggleSpinner();
  }

  void _updateFormData(AppointmentDataModel data) {
    formData = data;
    _appointmentDateController.text = data.appointmentDate ?? '';
    _nameController.text = data.name ?? '';
    _phoneController.text = data.phone ?? '';
    _commentsController.text = data.comments ?? '';
  }

  Future<void> _setData() async {
    formData.status = "New";
    toggleSpinner();
    messageVisible = true;

    try {
      await authBloc.setAppointmentData(formData: formData);
      showMessage(true, CMessageType.success, "Data is saved.");
    } catch (e) {
      showMessage(true, CMessageType.error, e.toString());
    }

    toggleSpinner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cAppointment)),
      drawer: Drawer(
        child: isAdmin ? CustomAdminDrawer() : CustomGuestDrawer(),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: authBloc.isSignedIn() ? _settingsView() : _loginPage(),
        ),
      ),
    );
  }

  Widget _loginPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Go to Login page'),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ],
    );
  }

  Widget _settingsView() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () => setState(() {
        _btnEnabled = _formKey.currentState?.validate() ?? false;
      }),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Text("Update Appointment Date", style: cHeaderDarkText),
            const SizedBox(height: 10),
            _buildDateField(),
            const SizedBox(height: 25),
            _buildTextField(_nameController, "Name *", Icons.person,
                (value) => formData.name = value, evalName),
            const SizedBox(height: 25),
            _buildTextField(_phoneController, "Phone *", Icons.phone,
                (value) => formData.phone = value, evalPhone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 25),
            _buildTextField(_commentsController, "Comments *", Icons.sms,
                (value) => formData.comments = value, evalChar),
            const SizedBox(height: 10),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
                toggleMessage: messageVisible,
                toggleMessageType: messageType == "error"
                    ? CMessageType.error
                    : CMessageType.success,
                toggleMessageTxt: messageTxt),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _btnEnabled ? _setData : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: _appointmentDateController,
        decoration: const InputDecoration(
          labelText: "Appointment Date",
          hintText: "Ex. preferred appointment datetime",
        ),
        validator: evalName,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            _appointmentDateController.text = date.toIso8601String();
            formData.appointmentDate = date.toIso8601String();
          }
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      Function(String) onChanged,
      String? Function(String?) validator,
      {TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      width: 300,
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
          hintText: label,
          labelText: label,
        ),
      ),
    );
  }
}
