import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_biometric_auth/pages/biometric_login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    ContentPage(title: "Primary"),
    ContentPage(title: "Social"),
    ContentPage(title: "Promotions"),
    ContentPage(title: "Updates"),
    ContentPage(title: "Starred"),
    ContentPage(title: "Snoozed"),
    ContentPage(title: "Settings"),
    ContentPage(title: "Help & feedback"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEF8F6),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Hello Flutter",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF4B352A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // Handle logout action
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BiometricLogin()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      },
      drawerEnableOpenDragGesture: false,
      drawer: NavigationDrawerTheme(
        data: NavigationDrawerThemeData(
          indicatorSize: const Size(336.0, 80.0),
        ),
        child: NavigationDrawer(
          // backgroundColor: Color(0xFFFEF8F6),
          // indicatorColor: Color(0xFFFBDBCF),
          elevation: 30,
          shadowColor: Colors.black,
          onDestinationSelected: (value) {
            setState(() {
              _currentIndex = value;
            });
            _scaffoldKey.currentState?.closeDrawer();
          },

          selectedIndex: _currentIndex,
          header: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                Icon(
                  Icons.email,
                  size: 40,
                ),
                Text(
                  "My Mail App",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
          footer: Text('Version: 1.0.1'),
          children: [
            NavigationDrawerDestination(
              icon: Icon(Icons.tv_outlined),
              label: Text("Primary"),
              selectedIcon: Icon(Icons.tv),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.people_outline),
              label: Text("Social"),
              selectedIcon: Icon(Icons.people),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.discount_outlined),
              label: Text("Promotions"),
              selectedIcon: Icon(Icons.discount),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.info_outline),
              label: Text("Updates"),
              selectedIcon: Icon(Icons.info),
            ),
            Divider(),
            NavigationDrawerDestination(
              icon: Icon(Icons.star_outline),
              label: Text("Starred"),
              selectedIcon: Icon(Icons.star),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.snooze_outlined),
              label: Text("Snoozed"),
              selectedIcon: Icon(Icons.snooze_outlined),
            ),
            Divider(),
            NavigationDrawerDestination(
              icon: Icon(Icons.settings_outlined),
              label: Text("Settings"),
              selectedIcon: Icon(Icons.settings),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.help_outlined),
              label: Text("Help & feedback"),
              selectedIcon: Icon(Icons.help),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentPage extends StatelessWidget {
  final String title;

  const ContentPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}


