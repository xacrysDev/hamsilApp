import 'dart:async';
import 'package:flutter/material.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../models/datamodel.dart';
import '../../blocs/validators.dart';
import '../../views/aboutus.dart';

class SignUp extends StatefulWidget {
  static const routeName = '/signup';

  const SignUp({super.key});
  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> with Validators {
  bool spinnerVisible = false;
  bool messageVisible = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;

  final _formKey = GlobalKey<FormState>();
  final model =LoginDataModel(email: '', password: '');
  bool _btnEnabled = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();
  }

  @override
  void dispose() {
    authBloc.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> fetchData() async {
    if (!_formKey.currentState!.validate()) return;

    toggleSpinner();
    var userAuth = await authBloc.signUpWithEmail(formData: model);

    if (userAuth == "") {
      showMessage(true, CMessageType.success, "SignUp Successful");
    } else {
      String msg;
      switch (userAuth) {
        case 'email-already-in-use':
          msg = "This email is already registered. Please login instead.";
          break;
        case 'weak-password':
          msg =
              "Weak password. Please enter at least 8 characters with numbers and letters.";
          break;
        default:
          msg = "An unknown error has occurred.";
      }
      showMessage(true, CMessageType.error, msg);
    }

    toggleSpinner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_open),
          color: Colors.deepOrangeAccent,
          iconSize: 28.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutUs()),
            );
          },
        ),
        title: const Text(cSignupTitle),
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: authBloc.isSignedIn() ? settingsPage() : userForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget userForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () => setState(() {
        _btnEnabled = _formKey.currentState!.validate();
      }),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                maxLength: 50,
                onChanged: (value) => model.email = value,
                validator: (value) => evalEmail(value ?? ''),
                decoration: InputDecoration(
                  icon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                  hintText: 'username@domain.com',
                  labelText: 'EmailID *',
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                maxLength: 50,
                onChanged: (value) => model.password = value,
                validator: (value) => evalPassword(value ?? ''),
                decoration: InputDecoration(
                  icon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                  hintText: 'Enter password',
                  labelText: 'Password *',
                ),
              ),
            ),
            const SizedBox(height: 25),
            CustomSpinner(toggleSpinner: spinnerVisible),
            CustomMessage(
              toggleMessage: messageVisible,
              toggleMessageType: messageType,
              toggleMessageTxt: messageTxt,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _btnEnabled ? fetchData : null,
              child: const Text('Signup'),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Chip(
                avatar: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add),
                ),
                label: Text("Already have an Account", style: cNavText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsPage() {
    return Column(
      children: [
        Chip(
          avatar: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.add),
          ),
          label: Text("Welcome to HMS App", style: cNavText),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Logout'),
          onPressed: () {
            authBloc.logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Go to Settings'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/settings');
          },
        ),
      ],
    );
  }
}
