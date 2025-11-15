import 'package:flutter/material.dart';
import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../models/datamodel.dart';
import '../../blocs/validators.dart';

class LogIn extends StatefulWidget {
  static const routeName = '/login';

  const LogIn({super.key});
  @override
  LogInState createState() => LogInState();
}

class LogInState extends State<LogIn> with Validators {
  final _formKey = GlobalKey<FormState>();
  final model =LoginDataModel(email: '', password: '');
  bool spinnerVisible = false;
  bool messageVisible = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  bool _btnEnabled = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> fetchData(AuthBloc authBloc, String loginType) async {
    toggleSpinner();
    Object? userAuth;
    if (loginType == "Google") {
      userAuth = await authBloc.signInWithGoogle();
    } else {
      userAuth = await authBloc.signInWithEmail(formData: model);
    }

    if (userAuth == "") {
      showMessage(true, "success", "Login Successful");
    } else {
      showMessage(
        true,
        "error",
        (userAuth == 'user-not-found')
            ? "No user found for that email."
            : ((userAuth == 'wrong-password')
                ? "Wrong password provided for that user."
                : "An unknown error has occurred."),
      );
    }
    toggleSpinner();
  }

  Future<void> logout(AuthBloc authBloc) async {
    setState(() {
      model.password = "";
      _passwordController.clear();
      _btnEnabled = false;
    });
    toggleSpinner();
    try {
      await authBloc.logout();
      showMessage(true, "success", "Successfully logged out.");
    } catch (e) {
      showMessage(true, "error", e.toString());
    }
    toggleSpinner();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBloc();
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        child: authBloc.isSignedIn() ? _settingsPage(authBloc) : _loginForm(authBloc),
      ),
    );
  }

  Widget _loginForm(AuthBloc authBloc) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () =>
          setState(() => _btnEnabled = _formKey.currentState?.validate() ?? false),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Text(
              "This is a DEMO app.\nUse your email and non-secret password to login as patient.\nFor Admin panel: info@elishconsulting.com / password1",
              style: cBodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text("Sign In", style: cHeaderDarkText),
            const SizedBox(height: 25),
            _buildTextField(
              controller: _emailController,
              label: 'EmailID *',
              hint: 'username@domain.com',
              icon: Icons.email,
              validator: evalEmail,
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) => model.email = val,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _passwordController,
              label: 'Password *',
              hint: 'enter password',
              icon: Icons.lock_outline,
              validator: evalPassword,
              obscureText: true,
              onChanged: (val) => model.password = val,
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
              onPressed: _btnEnabled ? () => fetchData(authBloc, "email") : null,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 15),
            _googleSignInChip(authBloc),
            const SizedBox(height: 15),
            _createAccountChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.blueAccent,
        keyboardType: keyboardType,
        maxLength: 50,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          hintText: hint,
          labelText: label,
        ),
      ),
    );
  }

  Widget _googleSignInChip(AuthBloc authBloc) {
    return Chip(
      label: const Text("Login with Google", style: cErrorText),
      avatar: CircleAvatar(
        backgroundColor: Colors.red,
        child: ElevatedButton(
          child: const Text('G'),
          onPressed: () => fetchData(authBloc, "Google"),
        ),
      ),
    );
  }

  Widget _createAccountChip() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/signup'),
      child: Chip(
        avatar: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.add),
        ),
        label: const Text("Create new Account", style: cNavText),
      ),
    );
  }

  Widget _settingsPage(AuthBloc authBloc) {
    return Column(
      children: [
        Chip(
          avatar: CircleAvatar(
            backgroundColor: Colors.grey,
            child: const Icon(Icons.add),
          ),
          label: const Text("Welcome to HMS App", style: cNavText),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Logout'),
          onPressed: () => logout(authBloc),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Go to Settings'),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/settings'),
        ),
      ],
    );
  }
}
