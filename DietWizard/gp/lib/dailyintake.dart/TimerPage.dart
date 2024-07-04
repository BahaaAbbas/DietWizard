import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/BottomNav.dart';
import 'package:gp/dailyintake.dart/dailySummary.dart';
import 'package:gp/main.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/market.dart';
import 'package:gp/profile.dart';
import 'dart:math';
// import 'dart:ffi';
import 'package:fl_chart/fl_chart.dart';
import 'package:gp/WaterIntake/BarchartThing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for jsonEncode
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart'; // Add this line to import the intl package
import 'dart:async';
import 'package:gp/welcome.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
//-------------------------------------------------------------------------

//import 'package:audioplayers/audioplayers.dart';

// body: SingleChildScrollView(

//           child: TimerPage(),
//         )
class TimerPageShown extends StatefulWidget {
  final String baseUrl;
  final String name;
  final String email;

  const TimerPageShown({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<TimerPageShown> createState() => _TimerPageShownState();
}

class _TimerPageShownState extends State<TimerPageShown> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromARGB(255, 79, 180, 238),
      backgroundColor: const Color.fromRGBO(0, 39, 62, 1),
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Row(
          children: [
            SizedBox(width: 5),
            Image.asset(
              'images/img6.png',
              height: 87,
              width: 75,
            ),
            SizedBox(width: 55),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Timer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 6, 248),
                ),
              ),
            )
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8, top: 2.0),
            child: IconButton(
              onPressed: () {
            
                   Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => WelcomePage(
                              baseUrl: widget.baseUrl,
                              name: widget.name,
                              email: widget.email,
                             
                            ),
                          ),
                        );
              },
              icon: Icon(
                Icons.home,
                color: Color.fromARGB(255, 104, 159, 221),
                size: 35,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: TimerPage(
          baseUrl: widget.baseUrl,
          email: widget.email,
          name: widget.name,
        ),
      ),
    );
  }
}

class TimerPage extends StatelessWidget {
  //TimerPage({super.key});
  final String baseUrl;
  final String name;
  final String email;

  TimerPage({
    Key? key,
    required this.baseUrl,
    required this.name,
    required this.email,
  }) : super(key: key);

  void _goToNextpage(
      BuildContext context, int hr, int min, int sec, String txtlabel) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Countdownpage(
        label: txtlabel,
        hours: hr,
        minutes: min,
        seconds: sec,
        baseUrl: baseUrl,
        email: email,
        name: name,
      ),
    ));
  }

  final timer = Settimer();

  final txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // const SafeArea(
          //   child: Text(
          //     "Timer",
          //     style: TextStyle(
          //
          //       fontSize: 40,
          //       color: Colors.white
          //     ),
          //   )
          // ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 13,
            ),
            alignment: Alignment.center,
            child: const Text(
              "Set the timer",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),

          Timercard(
            time: timer,
            baseUrl: baseUrl,
            email: email,
            name: name,
          ),

          Container(
            padding: const EdgeInsets.only(left: 13),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Set the label(Optional)",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),

          Container(
            padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 10,
                right: MediaQuery.of(context).size.width * 1 / 4),
            child: TextField(
              controller: txtController,
              cursorColor: Colors.white,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                // height: 0.7
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10),
                isDense: true,
                filled: true,
                fillColor: Color.fromARGB(255, 3, 76, 118),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 3, 76, 118), width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              keyboardType: TextInputType.name,
            ),
          ),

          Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Center(
                child: SizedBox(
                  height: 50,
                  width: 110,
                  child: ElevatedButton(
                    onPressed: () {
                      if (timer.isNull()) {
                        const snackbar = SnackBar(
                            content: Text("Ensure that you have set the time"));
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      } else {
                        _goToNextpage(
                            context,
                            timer.getHours(),
                            timer.getMinutes(),
                            timer.getSeconds(),
                            txtController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 3, 76, 118),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text(
                      'start',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              )),
          Container(
            padding: const EdgeInsets.only(left: 13),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Presets",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: const SizedBox(
                      height: 80,
                      child: Presets(seconds: 300),
                    ),
                    onTap: () {
                      _goToNextpage(context, 0, 5, 0, "Countdown");
                    },
                  ),
                  GestureDetector(
                    child: const SizedBox(
                      height: 80,
                      child: Presets(seconds: 600),
                    ),
                    onTap: () {
                      _goToNextpage(context, 0, 10, 0, "Countdown");
                    },
                  ),
                  GestureDetector(
                    child: const SizedBox(
                      height: 80,
                      child: Presets(seconds: 900),
                    ),
                    onTap: () {
                      _goToNextpage(context, 0, 15, 0, "Countdown");
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
} // HomePage.dart
//-------------------------------------------------------------------------

class Timercard extends StatefulWidget {
  final Settimer time;
  final String baseUrl;
  final String name;
  final String email;

  const Timercard({
    super.key,
    required this.time,
    required this.baseUrl,
    required this.name,
    required this.email,
  });

  @override
  State<Timercard> createState() => _TimercardState();
}

class _TimercardState extends State<Timercard> {
  static int _hr = 0;
  static int _min = 0;
  static int _sec = 0;
  static Color _hrColor = const Color.fromRGBO(0, 39, 62, 1);
  static Color _minColor = const Color.fromARGB(255, 3, 76, 118);
  static Color _secColor = const Color.fromARGB(255, 3, 76, 118);
  static String currentSelection = 'hr';

  @override
  Widget build(BuildContext context) {
    var hourColumn = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Center(
          child: Text(
            "H",
            style: TextStyle(
                fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Center(
          child: Text(
            _hr.toString().padLeft(2, "0"),
            style: const TextStyle(
                fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        )
      ],
    );

    var hourcard = Card(
      elevation: 0,
      color: _hrColor,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: hourColumn,
      ),
    );

    var minutesColumn = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Center(
          child: Text(
            "M",
            style: TextStyle(
                fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Center(
          child: Text(
            _min.toString().padLeft(2, "0"),
            style: const TextStyle(
                fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        )
      ],
    );

    var minscard = Card(
      elevation: 0,
      color: _minColor,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: minutesColumn,
      ),
    );

    var secondsColumn = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Center(
          child: Text(
            "S",
            style: TextStyle(
                fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Center(
          child: Text(
            _sec.toString().padLeft(2, "0"),
            style: const TextStyle(
                fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        )
      ],
    );

    var seccard = Card(
      elevation: 0,
      color: _secColor,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: secondsColumn,
      ),
    );

    Card setTime = Card(
      elevation: 5,
      color: const Color.fromARGB(255, 3, 76, 118),
      margin: const EdgeInsets.only(top: 5, bottom: 5, right: 13, left: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            child: hourcard,
            onTap: () => {
              setState(() {
                _hrColor = widget.time.update_color(1);
                _minColor = widget.time.update_color(0);
                _secColor = widget.time.update_color(0);
                currentSelection = 'hr';
              })
            },
          ),
          const Center(
            child: Text(
              ":",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          GestureDetector(
            child: minscard,
            onTap: () => {
              setState(() {
                _hrColor = widget.time.update_color(0);
                _minColor = widget.time.update_color(1);
                _secColor = widget.time.update_color(0);
                currentSelection = 'min';
              })
            },
          ),
          const Center(
            child: Text(
              ":",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          GestureDetector(
            child: seccard,
            onTap: () => {
              setState(() {
                _hrColor = widget.time.update_color(0);
                _minColor = widget.time.update_color(0);
                _secColor = widget.time.update_color(1);
                currentSelection = 'sec';
              })
            },
          ),
        ],
      ),
    );

    Row buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            padding: const EdgeInsets.all(5),
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (currentSelection == 'hr') {
                      _hr = widget.time.minus_time(_hr, currentSelection);
                    } else if (currentSelection == 'min') {
                      _min = widget.time.minus_time(_min, currentSelection);
                    } else if (currentSelection == 'sec') {
                      _sec = widget.time.minus_time(_sec, currentSelection);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 76, 118),
                    shape: const CircleBorder(),
                    elevation: 5),
                child: const SizedBox(
                  height: 20,
                  width: 20,
                  child: Image(image: AssetImage('Icons/minus.png')),
                ))),
        Container(
            padding: const EdgeInsets.all(5),
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (currentSelection == 'hr') {
                      _hr = widget.time.add_time(_hr, currentSelection);
                    } else if (currentSelection == 'min') {
                      _min = widget.time.add_time(_min, currentSelection);
                    } else if (currentSelection == 'sec') {
                      _sec = widget.time.add_time(_sec, currentSelection);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 76, 118),
                    shape: const CircleBorder(),
                    elevation: 5),
                child: const SizedBox(
                  height: 20,
                  width: 20,
                  child: Image(image: AssetImage('Icons/plus.png')),
                )))
      ],
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [setTime, buttonRow],
      ),
    );
  }
}

class Settimer {
  final hours = 12;
  final minutes = 60;
  final seconds = 60;

  int currenthours = 0;
  int currentminutes = 0;
  int currentseconds = 0;

  // int currentselection = 0;

  int add_time(int currentTime, String unit) {
    if (unit == 'hr' && currentTime == 11) {
      currenthours = 0;
      return 0;
    } else if (unit == 'min' && currentTime == 59) {
      currentminutes = 0;
      return 0;
    } else if (unit == 'sec' && currentTime == 59) {
      currentseconds = 0;
      return 0;
    }

    if (unit == 'hr') {
      currenthours = ++currentTime;
    } else if (unit == 'min') {
      currentminutes = ++currentTime;
    } else if (unit == 'sec') {
      currentseconds = ++currentTime;
    }

    return currentTime;
  }

  int minus_time(int currentTime, String unit) {
    if (unit == 'hr' && currentTime == 0) {
      currenthours = 11;
      return 11;
    } else if (unit == 'min' && currentTime == 0) {
      currentminutes = 59;
      return 59;
    } else if (unit == 'sec' && currentTime == 0) {
      currentseconds = 59;
      return 59;
    }

    if (unit == 'hr') {
      currenthours = --currentTime;
    } else if (unit == 'min') {
      currentminutes = --currentTime;
    } else if (unit == 'sec') {
      currentseconds = --currentTime;
    }

    return currentTime;
  }

  Color update_color(int value) {
    if (value == 1) {
      return const Color.fromRGBO(0, 39, 62, 1);
    } else {
      return const Color.fromARGB(255, 3, 76, 118);
    }
  }

  bool isNull() {
    if (currenthours == 0 && currentminutes == 0 && currentseconds == 0) {
      return true;
    } else {
      return false;
    }
  }

  int getHours() {
    return currenthours;
  }

  int getMinutes() {
    return currentminutes;
  }

  int getSeconds() {
    return currentseconds;
  }
} // timercard.dart
//-------------------------------------------------------------------------

class Progress extends StatelessWidget {
  final int totalTime;
  final int remTime;
  final String remTimeText;
  final double progressValue;
  const Progress(
      {super.key,
      required this.totalTime,
      required this.remTime,
      required this.remTimeText,
      required this.progressValue});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            padding: const EdgeInsets.all(15),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: FractionallySizedBox(
              heightFactor: 0.8,
              widthFactor: 0.8,
              child: CircularProgressIndicator(
                backgroundColor: const Color.fromARGB(255, 3, 76, 118),
                color: Colors.white,
                value: progressValue,
                strokeWidth: 30,
                strokeCap: StrokeCap.round,
              ),
            )),
        Container(
            padding: const EdgeInsets.all(15),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: FractionallySizedBox(
                heightFactor: 0.8,
                widthFactor: 0.8,
                child: Center(
                  child: Text(
                    remTimeText,
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                )))
      ],
    );
  }
} // ProgressIndicator.dart

//-------------------------------------------------------------------------

class Presets extends StatelessWidget {
  final int seconds;
  const Presets({super.key, required this.seconds});

  String formatTime(int seconds) {
    int hr = seconds ~/ 3600;
    int rem = seconds % 3600;
    int min = rem ~/ 60;
    rem = rem % 60;
    int sec = rem;
    String result;

    if (hr > 0) {
      result =
          "${hr.toString().padLeft(2, "0")}:${min.toString().padLeft(2, "0")}:${sec.toString().padLeft(2, "0")}";
    } else {
      result =
          "${min.toString().padLeft(2, "0")}:${sec.toString().padLeft(2, "0")}";
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: const Color.fromARGB(255, 3, 76, 118),
      elevation: 5,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: const ImageIcon(
                size: 35,
                color: Colors.white,
                AssetImage('Icons/stopwatch.png')),
          ),
          const SizedBox(width: 20),
          Text(
            formatTime(seconds),
            style: const TextStyle(fontSize: 25, color: Colors.white),
          ),
          const SizedBox(width: 20),
          const Text(
            "Mins",
            style: TextStyle(fontSize: 20, color: Colors.white30),
          ),
        ],
      ),
    );
  }
} //Presets.dart

//-------------------------------------------------------------------------

class Countdownpage extends StatefulWidget {
  final String label;
  final int hours;
  final int minutes;
  final int seconds;

  final String baseUrl;
  final String name;
  final String email;

  const Countdownpage({
    super.key,
    required this.label,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.baseUrl,
    required this.name,
    required this.email,
  });

  String formatTime(int seconds) {
    int hr = seconds ~/ 3600;
    int rem = seconds % 3600;
    int min = rem ~/ 60;
    rem = rem % 60;
    int sec = rem;

    return "${hr.toString().padLeft(2, "0")}:${min.toString().padLeft(2, "0")}:${sec.toString().padLeft(2, "0")}";
  }

  int getHours() {
    return hours;
  }

  int getMinutes() {
    return minutes;
  }

  int getSeconds() {
    return seconds;
  }

  int getTotalTimeInSeconds() {
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  @override
  State<Countdownpage> createState() => _Countdownpage();
}

class _Countdownpage extends State<Countdownpage> {
  late int totalSeconds;
  late int remSeconds;
  late int progressVal;
  late Timer timer;
  late StreamSubscription<int> stream;
  AssetImage icon = const AssetImage("Icons\\pause.png");
  bool isDone = false;

  @override
  void initState() {
    super.initState();
       AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Colors.blue,
            importance: NotificationImportance.High,
            enableVibration: true)
      ],
      debug: true,
    );
    totalSeconds = widget.getTotalTimeInSeconds();
    remSeconds = widget.getTotalTimeInSeconds();
    progressVal = 1;

    timer = Timer(timeInSeconds: widget.getTotalTimeInSeconds());
    stream = timer.tick().listen((value) {
      setState(() {
        remSeconds = value;
      });
    });

    stream.onDone(() { //here
      setState(() {
        isDone = true;
        icon = const AssetImage("Icons\\triangle.png");
              AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: 'Timer Ends',
          body: 'Your Timer Ends',
        ),
      );
      });
    });
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String topLabel;

    if (widget.label.length > 1) {
      topLabel = widget.label;
    } else {
      topLabel = "Countdown";
    }

    Row controls = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: const Color.fromARGB(255, 3, 76, 118),
                  shape: const CircleBorder()),
              onPressed: () {
                icon = const AssetImage("Icons\\pause.png");
                isDone = false;
                stream.cancel();
                stream = timer.tick().listen((value) {
                  setState(() {
                    remSeconds = value;
                  });
                });
                stream.onDone(() {
                  setState(() {
                    isDone = true;
                    icon = const AssetImage("Icons\\triangle.png");
                                  AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: 'Timer Ends',
          body: 'Your Timer Ends',
        ),
      );
                  });
                });
              },
              child: const Image(
                image: AssetImage("Icons\\square.png"),
                height: 15,
                width: 15,
              )),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: const Color.fromARGB(255, 3, 76, 118),
                  shape: const CircleBorder()),
              onPressed: () {
                setState(() {
                  if (stream.isPaused) {
                    icon = const AssetImage("Icons\\pause.png");
                    stream.resume();
                  } else if (stream.isPaused == false && isDone == false) {
                    icon = const AssetImage("Icons\\triangle.png");
                    stream.pause();
                  }
                });
              },
              child: Image(
                image: icon,
                height: 18,
                width: 18,
              )),
        )
      ],
    );

    return Scaffold(
        backgroundColor: const Color.fromRGBO(0, 39, 62, 1),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 5,
              ),
              SafeArea(
                  child: Text(
                topLabel,
                style: const TextStyle(fontSize: 40, color: Colors.white),
              )),
              Column(
                children: [
                  Progress(
                    totalTime: totalSeconds,
                    remTime: remSeconds,
                    remTimeText: widget.formatTime(remSeconds),
                    progressValue: remSeconds / totalSeconds,
                  ),
                  controls,
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 130,
                //child: bottomCard,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: const Color.fromARGB(255, 3, 76, 118),
                        shape: const CircleBorder()),
                    onPressed: () {
                      // icon = const AssetImage("Icons\\triangle.png");
                      // Navigator.pushReplacement(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (context) => TimerPageShown(
                      //                     baseUrl: widget.baseUrl,
                      //                     name: widget.name,
                      //                     email: widget.email,
                      //                   ),
                      //                 ),
                      //               );
                      setState(() {
                        _TimercardState._hr = 0;
                        _TimercardState._min = 0;
                        _TimercardState._sec = 0;
                      });

                      Navigator.pop(context);
                    },
                    child: Image(
                      image: AssetImage("Icons\\back.png"),
                      height: 60,
                      width: 60,
                    )),
              )
            ],
          ),
        ));
  }
} //CountDown.dart

//-------------------------------------------------------------------------
class Timer {
  final int timeInSeconds;
  const Timer({required this.timeInSeconds});

  Stream<int> tick() {
    Stream<int> values = Stream.periodic(
            const Duration(seconds: 1), (x) => timeInSeconds - x - 1)
        .take(timeInSeconds);
    return values;
  }
} // Timer.dart
//-------------------------------------------------------------------------
