// import 'dart:ffi';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
// import 'package:gp/bottomnav.dart';
import 'package:gp/main.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:gp/loginPage.dart';
import 'package:gp/market.dart';
import 'package:gp/profile.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for jsonEncode
import 'package:gp/WaterIntake/waterPage.dart';

int GolobalGoal = 2000;



  // Defining WeeklySummary list
  List<double> WeeklySummary2 = List<double>.filled(7, 0); // Initialize with 0 values

class barChart extends StatefulWidget {
  final String email;
  const barChart({super.key ,  required this.email,});
   
  @override
  State<barChart> createState() => _barChartState();
}

class _barChartState extends State<barChart> {

Future<void> get7daysarray() async {
    try {
      var url = Uri.parse('${MyApp.baseUrl}/get7daysarray');
      var response = await http.post(
        url,
        body: jsonEncode({
          'email': widget.email,    
        }),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
  // Parsing the JSON response
  Map<String, dynamic> responseData = json.decode(response.body);

  // Extracting 'dateAmountArray' and 'goalintake' from the response
  List<dynamic> dateAmountArray = responseData['dateAmountArray'];
  double goalIntake = double.parse(responseData['goalintake']);

  // Setting globalint to goalintake
  

     setState(() {
        GolobalGoal = goalIntake.toInt();
         
      });

  // Mapping days of the week to indices
  Map<String, int> dayToIndex = {
    "Sunday": 0,
    "Monday": 1,
    "Tuesday": 2,
    "Wednesday": 3,
    "Thursday": 4,
    "Friday": 5,
    "Saturday": 6
  };

  // Iterating through dateAmountArray to set values in WeeklySummary
  for (var item in dateAmountArray) {
    String day = item['day'];
    double totalAmount = item['totalAmount'].toDouble();
     int index = dayToIndex[day] ?? 0;
    WeeklySummary2[index] = totalAmount;
  }

  // Outputting results
  print('Weekly Summary: $WeeklySummary2');
  print('Goal Intake: $goalIntake');
  print('Global Int: $GolobalGoal');

       


      } else {
        // Some other error happened
        print(widget.email + MyApp.baseUrl);
        print('Show logged 7days water failed: ${response.statusCode}');
        print('Response body: ${response.body}');


      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    get7daysarray();

  }

    // List<double> WeeklySummary = [
    //   4.40,
    //   50.58,
    //   42.42,
    //   10.50,
    //   100.28,
    //   88.99,
    //   90.10,
    // ];

    Widget build(BuildContext context) {
   return Container(
  height: 300,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15.0), 
    color: Colors.grey[300], 
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Text(
          'This Week Water Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      SizedBox(
        height: 200,
        child: myBarGraph(
          WeeklySummary: WeeklySummary2,
        ),
      ),
    ],
  ),
);
  }

}


class indvidualBar {
  final int x;
  final double y;

indvidualBar({
  required this.x , 
  required this.y
  });

}

class BarData {

    final double sunAmount;
    final double monAmount;
    final double tuesAmount;
    final double wedAmount;
    final double thursAmount;
    final double friAmount;
    final double satAmount;

BarData({
  required this.sunAmount , 
  required this.monAmount ,
  required this.tuesAmount , 
  required this.wedAmount ,
  required this.thursAmount , 
  required this.friAmount ,
  required this.satAmount , 
  
  });

  List<indvidualBar> barData = [];

  //initilizae bar data
  void initilizaeBarData (){
    barData = [
      //sun
      indvidualBar(x: 0, y: sunAmount),

      //mon
      indvidualBar(x: 1, y: monAmount),

      //tues
      indvidualBar(x: 2, y: tuesAmount),

      //wed
      indvidualBar(x: 3, y: wedAmount),

      //thurs
      indvidualBar(x: 4, y: thursAmount),

      //fri
      indvidualBar(x: 5, y: friAmount),

      //sat
      indvidualBar(x: 6, y: satAmount),


    ];
  }
}

class myBarGraph extends StatelessWidget {
  
   final List WeeklySummary; //[sunamount...]
  const myBarGraph({super.key,required this.WeeklySummary});


  @override
  Widget build(BuildContext context) {

    BarData myBarData = BarData(
      sunAmount: WeeklySummary[0], 
      monAmount: WeeklySummary[1], 
      tuesAmount: WeeklySummary[2], 
      wedAmount: WeeklySummary[3], 
      thursAmount: WeeklySummary[4],
       friAmount: WeeklySummary[5], 
       satAmount: WeeklySummary[6]
       );
       myBarData.initilizaeBarData();

       

    return BarChart(

      BarChartData(
        maxY: 100,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData:FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          //topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,getTitlesWidget: getTopTitles,)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,getTitlesWidget: getBottomTitles,)),
          ),
        barGroups: myBarData.barData
        .map((data) => BarChartGroupData(
          x: data.x,
          barRods: [
            BarChartRodData(
              //toY: data.y,
                toY: data.y > 100 ? 100 : 100, 
              color:data.y > GolobalGoal ?  Colors.green:Colors.redAccent,
              width: 20,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 100,
                color: Colors.grey[200],
              ),
              ),
            ]
          ),
          ) //map
          .toList(),
      ),
    );
  }


Widget getBottomTitles(double value ,TitleMeta  meta ) {
  const style = TextStyle(color: Colors.grey , fontWeight: FontWeight.bold, fontSize:14 );

  Widget text;
    switch (value.toInt()) {

      case 0:
        text = const Text ('S' , style: style);
        break;


      case 1:
      text = const Text ('M' , style: style);
      break;


      case 2:
        text = const Text ('T' , style: style);
      break;


         case 3:
        text = const Text ('W' , style: style);
        break;


          case 4:
      text = const Text ('T' , style: style);
      break;



      case 5:
        text = const Text ('F' , style: style);
      break;



         case 6:
        text = const Text ('S' , style: style);
        break;


      default:
       text = const Text ('' , style: style);
        break;
    }
 
 return SideTitleWidget(child: text, axisSide: meta.axisSide);
}

Widget getTopTitles(double value, TitleMeta meta) {
  const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);

  Widget titleWidget;

  String textValue = '';
  if (value.toInt() >= 0 && value.toInt() < WeeklySummary.length) {
    textValue = WeeklySummary[value.toInt()].toString();
   // print(textValue);
  }

  
  double parsedValue = double.tryParse(textValue) ?? 0.0; // Handle null case
    if (parsedValue >= GolobalGoal) {
   
    titleWidget = SideTitleWidget(
      // child: Icon(
      //   Icons.emoji_events,
      //   color: Colors.green,
      //   size: 20.0,
      // ),
      child: Text ('${TodayIntakeClass.todayIntake}' , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
      axisSide: meta.axisSide,
    );
  } else {
  
    titleWidget = SideTitleWidget(
      // child: Icon(
      //   Icons.emoji_events,
      //   color: Colors.red,
      //   size: 20.0,
      // ),
      child: Text ('${parsedValue.toInt()}' , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),

      axisSide: meta.axisSide,
    );
  }

  return titleWidget;
}


}