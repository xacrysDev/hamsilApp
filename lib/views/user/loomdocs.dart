import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../blocs/auth/auth.bloc.dart';
import '../../shared/custom_style.dart';
import '../../shared/custom_components.dart';

class LoomDocs extends StatefulWidget {
  static const routeName = '/loomdocs';

  const LoomDocs({super.key});
  @override
  LoomDocsState createState() => LoomDocsState();
}

class LoomDocsState extends State<LoomDocs> {
  bool spinnerVisible = false;
  bool messageVisible = false;
  bool isAdmin = false;
  String messageTxt = "";
  CMessageType messageType = CMessageType.success;
  String _url = "";

  late final AuthBloc authBloc;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();

    // 🚨 IMPORTANTE: cambia localhost por una URL accesible desde móviles
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

  void showMessage(bool visible, String type, String message) {
    setState(() {
      messageVisible = visible;
      messageType = type == "error" ? CMessageType.error : CMessageType.success;
      messageTxt = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Message")),
      drawer: Drawer(
        child: isAdmin ? CustomAdminDrawer() : CustomAdminDrawer(),
      ),
      body: Center(
        child: Container(
          width: 600,
          height: 700,
          margin: const EdgeInsets.all(20.0),
          child: authBloc.isSignedIn() ? _settings() : _loginPage(),
        ),
      ),
    );
  }

  Widget _loginPage() {
    return Column(
      children: [
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text('Go to Login Page'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  Widget _settings() {
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
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/aboutus');
                    },
                  ),
                  const Text("Show Patient Message", style: cHeaderDarkText),
                  const SizedBox(width: 10),
                  const Text("Patient Name: Amit Shukla", style: cNavRightText),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: const Text('Reply - Record Video'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/loomrecord');
                    },
                  ),
                ],
              ),
              SizedBox(
                width: 600,
                height: 700,
                child: WebViewWidget(controller: _controller), // ✅ WebView en Android/iOS
              ),
              if (spinnerVisible) CustomSpinner(toggleSpinner: spinnerVisible),
              if (messageVisible)
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
}
