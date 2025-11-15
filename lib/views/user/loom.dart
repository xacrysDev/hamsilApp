import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_style.dart';
import '../../shared/custom_components.dart';

class Loom extends StatefulWidget {
  static const routeName = '/loomrecord';

  const Loom({super.key});

  @override
  LoomState createState() => LoomState();
}

class LoomState extends State<Loom> {
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  late String _url;
  late AuthBloc authBloc;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();
    // 🔹 Aquí pon la URL real (no localhost, porque Android/iOS no pueden entrar a localhost del PC)
    _url = "https://www.loom.com/share/${authBloc.getUID()}";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_url));
  }

  @override
  void dispose() {
    authBloc.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Message")),
      drawer: Drawer(
        child: isAdmin ? CustomAdminDrawer() : CustomGuestDrawer(),
      ),
      body: Center(
        child: Container(
          width: 600,
          height: 700,
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
        )
      ],
    );
  }

  Widget _settingsView() {
    return ListView(
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 25),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.movie, color: Colors.pink),
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/aboutus'),
                  ),
                  const Text("Record Video Message", style: cHeaderDarkText),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 600,
                height: 700,
                child: WebViewWidget(controller: _controller), // ✅ WebView en móviles
              ),
            ],
          ),
        ),
      ],
    );
  }
}
