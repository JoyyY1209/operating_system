import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:operating_system/new.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer() async{       //ei funtion ta splash screen kotokkhn thakbe oitar jonno
    Timer(Duration(seconds: 5),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DiningPhilosophersApp()));

    });
  }

  @override
  void initState() {     //ininstate function hocche ,application open korle,shobar prothome eta call hobe,startimer er age eta call hove,etar vhitor starttimer call hobe
    // TODO: implement initState
    super.initState();
    startTimer();
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 10,),
            Container(
              height: 60,
              width:300,
              decoration: BoxDecoration(
                //color: Colors.indigo[400],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  "Dinning Philosophers",
                  style: GoogleFonts.bowlbyOne(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 120,),
            Lottie.asset(
              'assets/animations/dinning.json', // Path to your Lottie animation file
              width: 100, // Set the desired width for the animation
              height: 80, // Set the desired height for the animation
              repeat: true, // Loop the animation
              animate: true, // Start animation automatically
            ),
            // CircularProgressIndicator(
            //   color: Colors.green.shade200,
            // ),

            //Spacer(),
            SizedBox(height: 20,),
            Text("Our Operating System Project",style: GoogleFonts.acme(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.green.shade200,
            )),

          ],
        ),
      ),
    );
  }
}