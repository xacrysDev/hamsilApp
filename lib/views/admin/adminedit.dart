import 'package:flutter/material.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../models/datamodel.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../blocs/validators.dart';

class AdminEdit extends StatefulWidget {
  static const routeName = '/adminedit';

  const AdminEdit({super.key});
  @override
  AdminEditState createState() => AdminEditState();
}

class AdminEditState extends State<AdminEdit> with Validators{
  late final AuthBloc authBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  bool _btnEnabled = false;

  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  String dropDownRoleValue = 'none';

   SettingsDataModel formData = SettingsDataModel(
    name: '',
    email: '',
    phone: '',
    role: '',
    author: '',
  );

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as ScreenArguments?;
      if (args != null) getData(args);
    });
  }

  @override
  void dispose() {
    authBloc.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _authorController.dispose();
    _roleController.dispose();
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

  Future<void> getData(ScreenArguments args) async {
    toggleSpinner();
    try {
      if (authBloc.isSignedIn()) {
        final res = await authBloc.getDocData("users", args.patientID);
        setState(() => updateFormData(SettingsDataModel.fromJson(res!.data()!)));
      } else {
        showMessage(true, "error", "An unknown error has occurred.");
      }
    } catch (e) {
      showMessage(true, "error", "User information is not available.");
    } finally {
      toggleSpinner();
    }
  }

  void updateFormData(SettingsDataModel data) {
    formData = data;
    isAdmin = true;
    _nameController.text = formData.name ?? '';
    _emailController.text = formData.email ?? '';
    _phoneController.text = formData.phone ?? '';
    _authorController.text = formData.author ?? '';
    _roleController.text = formData.role ?? 'none';
    dropDownRoleValue = formData.role ?? 'none';
  }

  Future<void> setData() async {
    toggleSpinner();
    try {
      await authBloc.updData(formData);
      showMessage(true, "success", "Data is saved.");
    } catch (e) {
      showMessage(true, "error", e.toString());
    } finally {
      toggleSpinner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cAdmin)),
      drawer: Drawer(child: isAdmin ? CustomAdminDrawer() : CustomGuestDrawer()),
      body: ListView(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: authBloc.isSignedIn() ? settings() : loginPage(),
            ),
          ),
        ],
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
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () => setState(() => _btnEnabled = _formKey.currentState?.validate() ?? false),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings, color: Colors.grey),
                const SizedBox(width: 10),
                const Text("Edit User", style: cHeaderDarkText),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.backspace, color: Colors.blueAccent),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/admin'),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _buildTextField(_nameController, 'Name *', evalName, Icons.person, (val) => formData.name = val),
            const SizedBox(height: 5),
            _buildTextField(_emailController, 'emailID *', evalEmail, Icons.email, (val) => formData.email = val),
            const SizedBox(height: 5),
            _buildTextField(_phoneController, 'Phone *', evalPhone, Icons.phone, (val) => formData.phone = val),
            const SizedBox(height: 25),
            _buildDropdown(),
            const SizedBox(height: 25),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
              toggleMessage: messageVisible,
              toggleMessageType: messageType,
              toggleMessageTxt: messageTxt,
            ),
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

  Widget _buildTextField(TextEditingController controller, String label,
      String? Function(String?) validator, IconData icon, void Function(String) onChanged) {
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

  Widget _buildDropdown() {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(top: 25),
      child: DropdownButton<String>(
        value: dropDownRoleValue,
        icon: const Icon(Icons.settings),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: Container(height: 2, color: Colors.deepPurpleAccent),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              dropDownRoleValue = newValue;
              formData.role = newValue;
            });
          }
        },
        items: <String>['admin', 'employee', 'patient', 'none']
            .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
      ),
    );
  }
}
