import 'package:flutter/material.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/validators.dart';

class Centre extends StatefulWidget {
  static const routeName = '/centre';

  const Centre({super.key});
  @override
  CentreState createState() => CentreState();
}

class CentreState extends State<Centre> with Validators {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _distIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String? _vendorType;
  String? _vendorName;

  @override
  void dispose() {
    _distIdController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cSCM)),
      drawer: const Drawer(child: CustomAdminDrawer()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 25),
              const CustomSCMNav(),
              const SizedBox(height: 25),
              _buildHeader(Icons.cached, "Setup Centre"),
              const SizedBox(height: 25),
              _buildTextField(_distIdController, "Dist ID *", "Distrib Centre ID"),
              const SizedBox(height: 15),
              _buildDropdown(
                "Vendor Type",
                _vendorType,
                ['Warehouse', 'Manufacturer', 'Dealer', 'Vendor', 'Direct Purchase', 'Factory'],
                (val) => setState(() => _vendorType = val),
              ),
              const SizedBox(height: 15),
              _buildTextField(_addressController, "Address *", "Address #"),
              const SizedBox(height: 15),
              _buildDropdown(
                "Vendor Name",
                _vendorName,
                ['ABC Corp.', 'XYZ Inc', 'Delta Corp.', 'Alpha LLC', 'Gamma LLP'],
                (val) => setState(() => _vendorName = val),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField(_phoneController, "Ph. *", "Ph#")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(_codeController, "Code *", "code")),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(IconData icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(width: 8),
        Text(title, style: cHeaderDarkText),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: evalName,
    );
  }

  Widget _buildDropdown(String hint, String? currentValue, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $hint' : null,
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Aquí puedes procesar los datos, enviarlos a tu bloc o Firebase
      print("Dist ID: ${_distIdController.text}");
      print("Vendor Type: $_vendorType");
      print("Address: ${_addressController.text}");
      print("Vendor Name: $_vendorName");
      print("Phone: ${_phoneController.text}");
      print("Code: ${_codeController.text}");
    }
  }
}
