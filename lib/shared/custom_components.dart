import 'package:flutter/material.dart';
import './custom_style.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomSpinner extends StatelessWidget {
  final bool toggleSpinner;
  const CustomSpinner({super.key, required this.toggleSpinner});

  @override
  Widget build(BuildContext context) {
    return Center(child: toggleSpinner ? const CircularProgressIndicator() : null);
  }
}

class CustomMessage extends StatelessWidget {
  final bool toggleMessage;
  final CMessageType toggleMessageType;
  final String toggleMessageTxt;

  const CustomMessage({
    super.key,
    required this.toggleMessage,
    required this.toggleMessageType,
    required this.toggleMessageTxt,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: toggleMessage
          ? Text(
              toggleMessageTxt,
              style: toggleMessageType == CMessageType.error ? cErrorText : cSuccessText,
            )
          : null,
    );
  }
}

class CustomAdminNav extends StatelessWidget {
  const CustomAdminNav({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _navItem(context, Icons.calendar_today_rounded, Colors.deepPurple, "Appointments", '/appointments'),
        const SizedBox(width: 8),
        _navItem(context, Icons.dashboard, Colors.deepOrange, "SupplyChain", '/purchase'),
        const SizedBox(width: 8),
        _navItem(context, Icons.receipt, Colors.grey, "Reports", '/reports'),
        const SizedBox(width: 40),
        _navItem(context, Icons.settings, Colors.blue, "Sign Out", '/login'),
      ],
    );
  }

  Widget _navItem(BuildContext context, IconData icon, Color color, String label, String route) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: () => Navigator.pushReplacementNamed(context, route),
        ),
        Text(label, style: cBodyText),
      ],
    );
  }
}

class CustomGuestNav extends StatelessWidget {
  const CustomGuestNav({super.key});

  Future<void> _launchInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _navItem(context, Icons.calendar_today_rounded, Colors.greenAccent, "Appointment", '/appointment'),
        const SizedBox(width: 8),
        _navItem(context, Icons.person, Colors.pink, "Personal Data", '/person'),
        const SizedBox(width: 8),
        _navItem(context, Icons.receipt, Colors.orange, "Records", '/records'),
        const SizedBox(width: 8),
        _navItemWithAction(
          context,
          Icons.wallet_travel,
          Colors.greenAccent,
          "ContactTracing",
          () => _launchInBrowser('https://www.youtube.com/watch?v=MkV413X2Kmw'),
        ),
        const SizedBox(width: 40),
        _navItem(context, Icons.settings, Colors.blue, "Sign Out", '/login'),
      ],
    );
  }

  Widget _navItem(BuildContext context, IconData icon, Color color, String label, String route) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: () => Navigator.pushReplacementNamed(context, route),
        ),
        Text(label, style: cBodyText),
      ],
    );
  }

  Widget _navItemWithAction(BuildContext context, IconData icon, Color color, String label, VoidCallback action) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon, color: color), onPressed: action),
        Text(label, style: cBodyText),
      ],
    );
  }
}

class CustomAdminDrawer extends StatelessWidget {
  const CustomAdminDrawer({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: cLabel,
      child: ListView(
        padding: const EdgeInsets.all(4),
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(cAppTitle),
            accountEmail: Text(cEmailID),
            currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(cSampleImage)),
          ),
          _drawerItem(context, Icons.calendar_today_rounded, Colors.deepPurple, "Appointments", '/appointments', 'visitor appointments'),
          _drawerItem(context, Icons.healing_rounded, Colors.green, "Vaccination", '/appointments', 'Patient Vaccination'),
          _drawerItem(context, Icons.view_headline, Colors.greenAccent, "OPD/IPD", '/appointments', 'OPD/IPD'),
          _drawerItem(context, Icons.hot_tub, Colors.red, "Pharmacy", '/appointments', 'Pharmacy transactions'),
          _drawerItem(context, Icons.sanitizer, Colors.orangeAccent, "Lab Results", '/appointments', 'Patient Pathology Lab records'),
          _drawerItem(context, Icons.sms, Colors.deepPurple, "Messages", '/appointments', 'patient messages'),
          _drawerItem(context, Icons.movie, Colors.green, "Video", '/loomdocs', 'Video messages'),
          _drawerItem(context, Icons.dashboard, Colors.deepOrange, "Supply Chain", '/purchase', 'Manage supply chain', trailing: const Icon(Icons.more_vert)),
          _drawerItem(context, Icons.receipt, Colors.lightBlue, "Reports", '/reports', 'Manage Reports', trailing: const Icon(Icons.more_vert), isThreeLine: true),
          _drawerItem(context, Icons.settings, Colors.grey, "Admin", '/admin', null),
          ElevatedButton(
            child: const Text('Logout'),
            onPressed: () => _navigate(context, '/'),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, Color color, String title, String route, String? subtitle,
      {Widget? trailing, bool isThreeLine = false}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: cNavText),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      isThreeLine: isThreeLine,
      onTap: () => Navigator.pushReplacementNamed(context, route),
    );
  }
}

class CustomGuestDrawer extends StatelessWidget {
  const CustomGuestDrawer({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: cLabel,
      child: ListView(
        padding: const EdgeInsets.all(4),
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(cAppTitle),
            accountEmail: Text(cEmailID),
            currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(cSampleImage)),
          ),
          _drawerItem(context, Icons.calendar_today_rounded, Colors.deepPurple, "Appointment", '/appointment', 'Upcoming appointments'),
          _drawerItem(context, Icons.person, Colors.pink, "Personal Data", '/person', 'Manage personal data & info.', trailing: const Icon(Icons.more_vert), isThreeLine: true),
          _drawerItem(context, Icons.receipt, Colors.orange, "Records", '/records', 'OPD, IPD, Rx, LAB, COVID Vaccine records.', trailing: const Icon(Icons.more_vert), isThreeLine: true),
          _drawerItem(context, Icons.sms, Colors.deepPurple, "Text", '/records', 'patient messages'),
          _drawerItem(context, Icons.movie, Colors.green, "Video", '/loomrecord', 'Video messages'),
          ElevatedButton(
            child: const Text('Logout'),
            onPressed: () => _navigate(context, '/'),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, Color color, String title, String route, String? subtitle,
      {Widget? trailing, bool isThreeLine = false}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: cNavText),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      isThreeLine: isThreeLine,
      onTap: () => Navigator.pushReplacementNamed(context, route),
    );
  }
}

class CustomSCMNav extends StatelessWidget {
  const CustomSCMNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _navItem(context, Icons.receipt, Colors.orange, 'PO', '/purchase'),
        _navItem(context, Icons.outlet_rounded, Colors.blueGrey, 'MSR', '/msr'),
        _navItem(context, Icons.shopping_bag_rounded, Colors.blueAccent, 'Vendor', '/vendor'),
        _navItem(context, Icons.wallet_travel, Colors.red, 'Warehouse', '/warehouse'),
        _navItem(context, Icons.cached, Colors.purple, 'Center', '/centre'),
        _navItem(context, Icons.thermostat_outlined, Colors.deepOrange, 'Items', '/item'),
      ],
    );
  }

  Widget _navItem(BuildContext context, IconData icon, Color color, String label, String route) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: () => Navigator.pushReplacementNamed(context, route),
        ),
        Text(label, style: cBodyText),
      ],
    );
  }
}
