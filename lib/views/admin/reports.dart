import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/custom_components.dart';
import '../../shared/custom_style.dart';

class Reports extends StatefulWidget {
  static const routeName = '/reports';

  const Reports({super.key});

  @override
  ReportsState createState() => ReportsState();
}

class ReportsState extends State<Reports> {
  late Future<void> _launched;

  @override
  Future<void> _launchInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showInfoDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Information'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const [
                Text('This page is in active development.'),
                SizedBox(height: 5),
                Text(
                    'Features -> all custom reports must have active filters, material design, paginations, sorting and run time parameters. Reports should also have a downloadable option.'),
                SizedBox(height: 5),
                Text(
                    'If you would like to contribute, please clone GitHub repo, PRs are welcome.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(cReports)),
      drawer: Drawer(child: CustomAdminDrawer()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildSettings(),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Row(
          children: [
            const Icon(Icons.receipt, color: Colors.grey),
            const SizedBox(width: 10),
            Text("Admin Reports", style: cHeaderDarkText),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.info, color: Colors.blue),
              onPressed: _showInfoDialog,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection("Appointments", [
          "Appointments by date",
          "Doses by date",
        ]),
        _buildSection("Patient Reports", [
          "Patient Vaccine records",
          "OPD/IPD records",
          "Pharmacy records",
          "Pathology Lab records",
        ]),
        _buildLinksSection(),
        _buildSection("Supply chain reports", [
          "On Hand Inventory Qty by warehouse",
          "On Hand Inventory Qty by distribution center",
          "Vendor PO status by date",
          "MSR (Material Service Request) status by date",
          "Received inventory by date",
          "Returned inventory by date",
          "Discarded inventory by date",
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.black, thickness: 2),
        const SizedBox(height: 10),
        Text(title, style: cHeaderDarkText),
        const SizedBox(height: 10),
        for (final item in items) ...[
          Text(item, style: cBodyText),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.black, thickness: 2),
        const SizedBox(height: 10),
        InkWell(
          child: Text(
            "COVID Vaccine Distribution management app",
            style: cNavText,
          ),
          onTap: () => setState(() {
            _launched = _launchInBrowser(
                'https://www.youtube.com/watch?v=MkV413X2Kmw&list=PLp0TENYyY8lHL-G7jGbhpJBhVb2UdTOhQ&index=1&t=698s');
          }),
        ),
        const SizedBox(height: 10),
        InkWell(
          child: Text(
            "Patient Contacts Tracing app",
            style: cNavText,
          ),
          onTap: () => setState(() {
            _launched =
                _launchInBrowser('https://getcovidvaccine.web.app/');
          }),
        ),
        const SizedBox(height: 10),
        Text("Vaccine Inventory Orders", style: cBodyText),
        const SizedBox(height: 10),
        Text("Vaccine Qty on Hand", style: cBodyText),
        const SizedBox(height: 10),
      ],
    );
  }
}
