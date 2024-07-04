import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/ScreenChat/testfortest.dart';
import 'package:gp/WaterIntake/waterPage.dart';
import 'package:gp/dailyintake.dart/cohachesRating.dart';
import 'package:gp/welcome.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/market.dart';
import 'package:gp/home.dart';
import 'package:gp/profile.dart';
import 'package:gp/WaterIntake/BarchartThing.dart';
// import 'dart:ffi';
import 'package:fl_chart/fl_chart.dart';

class BottomNav extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;
  final String? password;
  final String indexbottom;

BottomNav({
  Key? key,
  required this.indexbottom,
  required this.baseUrl,
  required this.name,
  required this.email,
  String? password,
}) : this.password = password ?? 'default_passwordNAV',
     super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  @override
  void initState() {
   super.initState();
    if (widget.indexbottom != null) {
      _selectedIndex = int.parse(widget.indexbottom!);
    }

    //print("Password is = ${widget.password}");
 

  }

  

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(17),
      ),
      child: Container(
        height: 100,
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(7),
              child: GNav(
                backgroundColor: Colors.transparent,
                color: Colors.white,
                activeColor: Colors.white,
                tabBackgroundColor: Colors.grey.shade700,
                gap: 10,
                padding: EdgeInsets.all(15),
                selectedIndex: _selectedIndex,
                onTabChange: (indexOfItem) {
                  setState(() {
                    _selectedIndex = indexOfItem;
                  });
                },
                tabs: [
                  GButton( // 0
                    icon: Icons.home,
                    text: 'Home',
                
                    onPressed: () {
                      try {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => WelcomePage(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              email: widget.email,
                              password: widget.password,
                            ),
                          ),
                        );
                      } catch (e, stackTrace) {
                        print('Error: $e');
                        print('Stack Trace: $stackTrace');
                      }
                    },
                  ),
                  GButton( // 1
                    icon: Icons.contact_page,
                    text: 'Coaches',
                    onPressed: () {
                      // Navigator.pushReplacement(
                      //   context,
                      //   CupertinoPageRoute(
                      //     builder: (context) => waterpage(
                      //       baseUrl: widget.baseUrl,
                      //       name: widget.name,
                      //       email: widget.email,
                         
                      //     ),
                      //   ),
                      // );

                          Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => coachesRating(
                            baseUrl: widget.baseUrl,
                            name: widget.name,
                            email: widget.email,
                         
                          ),
                        ),
                      );

                    },
                  ),
                  GButton( // 2
                    icon: Icons.add_to_photos_outlined,
                    text: 'Community',
                    onPressed: () {
                      // Add your onPressed functionality here

                        Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => HomePage(
                            baseUrl: widget.baseUrl,
                            name: widget.name,
                            email: widget.email,
                           password: widget.password ?? 'default_password',
                         
                          ),
                        ),
                      );

                    },
                  ),
                  GButton( // 3
                    icon: Icons.shopping_cart_outlined,
                    text: 'Markets',
                    onPressed: () {
                      // Add your onPressed functionality here
                          Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => Market(
                                baseUrl: widget.baseUrl,
                                nameuser: widget.name,
                                email: widget.email,
                                
                              )
                                ),
                              );
                    },
                  ),
                  GButton(// 4
                    icon: Icons.menu,
                    text: 'More',
                    onPressed: () {
                      // Add your onPressed functionality here
                            Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => menuProfile(
                                baseUrl: widget.baseUrl,
                                name: widget.name,
                                email: widget.email,
                              )
                                ),
                              );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
