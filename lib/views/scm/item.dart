import 'package:flutter/material.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';
import '../../blocs/validators.dart';
import 'package:url_launcher/url_launcher.dart';

class Item extends StatefulWidget {
  static const routeName = '/item';

  const Item({super.key});
  @override
  ItemState createState() => ItemState();
}

class ItemState extends State<Item> with Validators {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

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
            Icon(Icons.thermostat_outlined, color: Colors.deepOrange),
            SizedBox(width: 5),
            Text("Setup Item", style: cHeaderDarkText),
          ],
        ),
        const SizedBox(height: 25),
        _buildTextField('Item ID', Icons.badge, evalName),
        const SizedBox(height: 15),
        _buildDropdown('Item Type', [
          'Item',
          'Manufacturer',
          'Dealer',
          'Direct Purchase',
          'Factory'
        ]),
        const SizedBox(height: 15),
        _buildTextField('Item Description #', Icons.create_new_folder_rounded, evalName),
        const SizedBox(height: 15),
        _buildDropdown('Item Vendor', [
          'ABC Corp.',
          'XYZ Inc',
          'Delta Corp.',
          'Alpha LLC',
          'Gamma LLP'
        ]),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildTextField('Item Price', Icons.attach_money, evalName)),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField('UOM', Icons.straighten, evalName)),
          ],
        ),
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
}
