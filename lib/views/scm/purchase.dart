import 'package:flutter/material.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../blocs/validators.dart';
import 'package:url_launcher/url_launcher.dart';

class Purchase extends StatefulWidget {
  static const routeName = '/purchase';

  const Purchase({super.key});
  @override
  PurchaseState createState() => PurchaseState();
}

class PurchaseState extends State<Purchase> with Validators {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cSCM)),
      drawer: Drawer(child: CustomAdminDrawer()),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: _settingsView(),
        ),
      ),
    );
  }

  Widget _settingsView() {
    return ListView(
      children: [
        const SizedBox(height: 25),
        CustomSCMNav(),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.receipt, color: Colors.orange),
            SizedBox(width: 5),
            Text("Purchase Orders", style: cHeaderDarkText),
          ],
        ),
        const SizedBox(height: 25),
        _buildTextField('Purchase Order ID', Icons.person, evalName),
        const SizedBox(height: 15),
        _buildDropdown('Vendor Type', [
          'Warehouse',
          'Manufacturer',
          'Dealer',
          'Vendor',
          'Direct Purchase',
          'Factory'
        ]),
        const SizedBox(height: 15),
        _buildTextField('Vendor ID #', Icons.person_add_alt_1_sharp, evalName),
        const SizedBox(height: 15),
        _buildDropdown('Vendor Name', [
          'ABC Corp.',
          'XYZ Inc',
          'Delta Corp.',
          'Alpha LLC',
          'Gamma LLP'
        ]),
        const SizedBox(height: 15),
        _buildRowFields([
          ['Item ID', Icons.inventory, evalName],
          ['Amt', Icons.attach_money, evalName],
        ]),
        const SizedBox(height: 15),
        _buildRowFields([
          ['Order Date', Icons.calendar_today, evalName],
          ['Qty', Icons.format_list_numbered, evalName],
        ]),
        const SizedBox(height: 15),
        _buildRowFields([
          ['Recv Date', Icons.calendar_today, evalName],
          ['Qty', Icons.format_list_numbered, evalName],
        ]),
        const SizedBox(height: 15),
        _buildRowFields([
          ['Return Date', Icons.calendar_today, evalName],
          ['Qty', Icons.format_list_numbered, evalName],
        ]),
      ],
    );
  }

  Widget _buildTextField(
      String label, IconData icon, String? Function(String?) validator) {
    return TextFormField(
      cursorColor: Colors.blueAccent,
      maxLength: 50,
      obscureText: false,
      validator: validator,
      decoration: InputDecoration(
        icon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
        hintText: label,
        labelText: label,
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items) {
    String? selectedValue;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
        hintText: hint,
      ),
      onChanged: (String? newValue) {
        setState(() {
          selectedValue = newValue;
        });
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildRowFields(List<List<dynamic>> fields) {
    return Row(
      children: fields.map((f) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 10, top: 10),
            child: _buildTextField(f[0] as String, f[1] as IconData,
                f[2] as String? Function(String?)),
          ),
        );
      }).toList(),
    );
  }
}
