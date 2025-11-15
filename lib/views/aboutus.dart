import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/custom_style.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutUs extends StatefulWidget {
  static const routeName = '/aboutus';
  final String? title;

  const AboutUs({super.key, this.title});

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  Future<void>? _launched;

  Future<void> _launchInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildAppTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? link,
    String? linkLabel,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
        if (link != null)
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.link, color: iconColor),
                onPressed: () {
                  setState(() {
                    _launched = _launchInBrowser(link);
                  });
                },
              ),
              if (linkLabel != null) Text(linkLabel, style: cBodyText),
            ],
          ),
      ],
    );
  }

  Widget _buildSocialIcon(String url, String svgIconUrl, {Color? color}) {
    return IconButton(
      icon: SvgPicture.network(svgIconUrl, color: color, width: 40, height: 40),
      onPressed: () {
        setState(() {
          _launched = _launchInBrowser(url);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_book),
          color: Colors.deepOrangeAccent,
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        title: const Text(cAboutUsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            child: Column(
              children: [
                _buildAppTile(
                  icon: Icons.healing_outlined,
                  iconColor: Colors.blue,
                  title: 'Complete Healthcare Records Management & Strategy App',
                  subtitle: 'This community healthcare management app (HMS hospital management app) built in Flutter Firebase App for iOS, Android, Web & Desktop. Complete Healthcare Hospital Management (Patient, OPD, IPD, Rx, Lab) in Flutter Firebase App for iOS, Android, Web & Desktop.\n\nThis project is a community version and is absolutely free for private use.',
                ),
                _buildAppTile(
                  icon: Icons.album,
                  iconColor: Colors.greenAccent,
                  title: 'Covid Vaccine Distribution Records Management & Strategy App',
                  subtitle: 'This community project is part of healthcare management app (HMS hospital management app)...',
                  link: 'https://getcovidvaccine.web.app/',
                  linkLabel: 'Vaccine Distribution App',
                ),
                _buildAppTile(
                  icon: Icons.wallet_giftcard,
                  iconColor: Colors.deepOrange,
                  title: 'Pandemic Contact Tracing, Visitor Management, Mobile Assets/Employee Attendance App',
                  subtitle: 'An Electronic Visitor register App for storing Host & Guest Records, Picture Attendance with GPS Locations using user\'s mobile phone.',
                  link: 'https://www.youtube.com/watch?v=MkV413X2Kmw&list=PLp0TENYyY8lHL-G7jGbhpJBhVb2UdTOhQ&index=1&t=698s',
                  linkLabel: 'Contact Tracing App',
                ),
                _buildAppTile(
                  icon: Icons.dashboard_customize,
                  iconColor: Colors.blueGrey,
                  title: 'Store millions of records with lightening fast data retrieval',
                  subtitle: 'Database storage is only restricted by usage/payment per use.',
                ),
                _buildAppTile(
                  icon: Icons.mic,
                  iconColor: Colors.red,
                  title: 'Hands free /voice activated typing',
                  subtitle: 'Uses autofills and phone voice activated typing features.',
                ),
                _buildAppTile(
                  icon: Icons.workspaces_filled,
                  iconColor: Colors.pink,
                  title: 'Dictionary based auto-completion/auto-sync (Pro)',
                  subtitle: 'Self learning (ML auto complete) data entry (Pro), automatic dictionary update for faster data typing...',
                ),
                _buildAppTile(
                  icon: Icons.data_usage,
                  iconColor: Colors.grey,
                  title: 'GBs of pictures, documents, Lab reports, Receipts',
                  subtitle: 'Database usage and size is subject to pay per use policy.',
                ),
                _buildAppTile(
                  icon: Icons.sms,
                  iconColor: Colors.greenAccent,
                  title: 'Social authentication, SMS, EMAIL, WhatsAPP API (Pro)',
                  subtitle: 'Send email to info@elishcosulting.com for Pro version enquiries.',
                ),
                _buildAppTile(
                  icon: Icons.lock_open,
                  iconColor: Colors.blueGrey,
                  title: 'Role based user access',
                  subtitle: 'Different role based app access, patient see only their records, Rx access pharmacy, Lab access Pathology records only...',
                ),
                _buildAppTile(
                  icon: Icons.star,
                  iconColor: Colors.yellow,
                  title: 'AI Research script',
                  subtitle: 'Premium section of app, use participant data for an AI research program...',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSocialIcon(
                      'https://www.youtube.com/amitshukla_ai',
                      'https://raw.githubusercontent.com/AmitXShukla/AmitXShukla.github.io/master/assets/icons/youtube.svg',
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    _buildSocialIcon(
                      'https://twitter.com/ashuklax',
                      'https://raw.githubusercontent.com/AmitXShukla/AmitXShukla.github.io/master/assets/icons/twitter_2.svg',
                    ),
                    const SizedBox(width: 8),
                    _buildSocialIcon(
                      'https://amitxshukla.github.io',
                      'https://raw.githubusercontent.com/AmitXShukla/AmitXShukla.github.io/master/assets/icons/github.svg',
                    ),
                    const SizedBox(width: 8),
                    _buildSocialIcon(
                      'https://medium.com/@Amit_Shukla',
                      'https://raw.githubusercontent.com/AmitXShukla/AmitXShukla.github.io/master/assets/icons/medium.svg',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
