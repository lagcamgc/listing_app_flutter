import 'package:firebase_auth/firebase_auth.dart';
import 'package:listing_app_flutter/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'main.dart';

//stf when empty asnd it suggests
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int selectedMenuIndex = 0;

  static List<String> menuItems = [
    'Extra Option 1',
    'Extra Option 1',
    'Extra Option 1',
    'Extra Option 1',
    'Extra Option 1',
  ];

  static List<IconData> icons = [
    FontAwesomeIcons.one,
    FontAwesomeIcons.two,
    FontAwesomeIcons.three,
    FontAwesomeIcons.four,
    FontAwesomeIcons.five,
  ];

  Widget buildMenuRow(int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedMenuIndex = index;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Row(
          children: <Widget>[
            Icon(icons[index],
                color: selectedMenuIndex == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5)),
            SizedBox(width: 16.0),
            Text(
              menuItems[index],
              style: TextStyle(
                  color: selectedMenuIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                        radius: 20.0,
                        child: FirebaseAuth.instance.currentUser != null
                            ? ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(FirebaseAuth.instance
                                .currentUser!.providerData[0].photoURL
                                .toString()))
                            : Icon(FontAwesomeIcons.user, color: Colors.white)),
                    SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(FirebaseAuth.instance.currentUser != null ?
                        FirebaseAuth.instance
                            .currentUser!.providerData[0].displayName.toString() : "Guest",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 22.0)),
                      ],
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: menuItems
                      .asMap()
                      .entries
                      .map((mapEntry) => buildMenuRow(mapEntry.key))
                      .toList(),
                ),
                Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.doorOpen,
                        color: Colors.white.withOpacity(0.5)),
                    SizedBox(width: 16.0),
                    TextButton(
                      child: Text(
                        'Log out',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        context.push('/');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [startingColor, mainColor])),
      ),
    );
  }
}
