import 'dart:math';

import 'package:eumi_erp_services/Dbhelper/linkhelper.dart';
import 'package:eumi_erp_services/VelaApartmentScreens/velaapartmentmobile.dart';
import 'package:eumi_erp_services/dashboard/mobilehomescreen.dart';
import 'package:eumi_erp_services/model/userlogin.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import 'package:http/http.dart' as http;

class OTPLayout extends StatefulWidget {
  const OTPLayout({Key? key}) : super(key: key);

  @override
  _OTPLayoutState createState() => _OTPLayoutState();
}

String otpnumber = "";

class _OTPLayoutState extends State<OTPLayout> {
  TextEditingController etone = new TextEditingController();
  TextEditingController ettwo = new TextEditingController();
  TextEditingController etthree = new TextEditingController();
  TextEditingController etfour = new TextEditingController();

  //late FocusNode pin1FN;
  late FocusNode pin2FN;
  late FocusNode pin3FN;
  late FocusNode pin4FN;

  void randomotp() {
    otpnumber = Random().nextInt(9999).toString().padLeft(4, '0');

    print("Random otp");
    print(otpnumber);

    getotp(otpnumber);
  }

  @override
  void initState() {
    super.initState();
    //pin1FN = FocusNode();

    randomotp();
    pin2FN = FocusNode();
    pin3FN = FocusNode();
    pin4FN = FocusNode();

    //pin1FN.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    /*  pin2FN?.dispose();
    pin2FN?.dispose();
    pin2FN?.dispose();*/
  }

  void nextfield(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Card(
                elevation: 0,
                surfaceTintColor: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //      _backButton(),
                      Center(
                        child: Image.asset(
                          "assets/images/otppp.png",
                          height: 130.0,
                          width: 130.0,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: Text(
                          "Enter OTP",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.green[900],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Text(
                          "",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.green[900],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Center(
                          child: Text(
                            "We have sent you access code",
                            // "Otp sending failed",

                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Center(
                          child: Text(
                            "via SMS for mobile number verification",
                            // "Please make the payment immediately",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              width: 50,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Container(
                                color: Colors.transparent,
                                child: TextFormField(
                                  controller: etone,
                                  autofocus: true,
                                  onChanged: (value) {
                                    nextfield(value, pin2FN);
                                  },
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.green[500]),
                                  textAlign: TextAlign.center,
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.number,
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: "1",
                                    hintStyle: TextStyle(color: Colors.black26),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              width: 50,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Container(
                                color: Colors.transparent,
                                child: TextFormField(
                                  controller: ettwo,
                                  focusNode: pin2FN,
                                  onChanged: (value) =>
                                      nextfield(value, pin3FN),
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.green[500]),
                                  textAlign: TextAlign.center,
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.number,
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: "2",
                                    hintStyle: TextStyle(color: Colors.black26),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              width: 50,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Container(
                                color: Colors.transparent,
                                child: TextFormField(
                                  controller: etthree,
                                  onChanged: (value) =>
                                      nextfield(value, pin4FN),
                                  focusNode: pin3FN,
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.green[500]),
                                  textAlign: TextAlign.center,
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.number,
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: "3",
                                    hintStyle: TextStyle(color: Colors.black26),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              width: 50,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Container(
                                color: Colors.transparent,
                                child: TextFormField(
                                  controller: etfour,
                                  focusNode: pin4FN,
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      pin4FN.unfocus();
                                    }
                                  },
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.green[500]),
                                  textAlign: TextAlign.center,
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: "4",
                                    hintStyle: TextStyle(color: Colors.black26),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.green[900],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward),
                            iconSize: 20,
                            color: Colors.white,
                            splashColor: Colors.green,
                            onPressed: () {
                              setState(() {
                                String otptext = etone.text +
                                    ettwo.text +
                                    etthree.text +
                                    etfour.text;

                                if (otpnumber == otptext) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            VilaApartmentMobile() //MobileHomeScreen(),
                                        ),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please Enter Correct OTP",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }

                                // randomotp();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 90,
                      ),
                      Column(
                        children: [
                          Center(
                            child: Text(
                              "Didn't Receive the OTP?",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black38,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              "Resend Code",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.green[500],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void getotp(String otpnumber) async {
    setState(() {});

    try {
      var phoneno = userlogin.phoneno.replaceAll("[\\s\\-()]", "");

      print("Mobile no");
      print(phoneno);

      var url = Uri.parse(Linkhelper.smsapi);
      var response = await http.post(url, body: {
        'Phone': "971" + userlogin.phoneno.toString(),
        'OTP': otpnumber +
            " is the OTP to login at ATAG Home Services App\n -Emirates National Facilities Management (ATAG),For  any clarification please call 800 3200.",
      });

      if (response.statusCode == 200) {
        //final data = jsonDecode(response.body);
        Fluttertoast.showToast(
            msg: "OTP Sent to your number please verify your number",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 12.0);

        ///  print(listmobservices.length);
      } else {}
    } catch (e) {
      print(e);
    }
  }
}
