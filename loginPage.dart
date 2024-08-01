import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:eumi_erp_services/Dbhelper/linkhelper.dart';
import 'package:eumi_erp_services/VelaApartmentScreens/velaapartmentmobile.dart';
import 'package:eumi_erp_services/dashboard/policywebviews.dart';
import 'package:eumi_erp_services/dashboard/termandcondition.dart';
import 'package:eumi_erp_services/loginlayouts/mobilelayout/otplayout.dart';
import 'package:eumi_erp_services/model/userlogin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/mobilesettings.dart';
import 'Widget/bezierContainer.dart';
import 'signup.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:store_redirect/store_redirect.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

String _currentAddress = "";
String latitude = "";
String longitd = "";

class _LoginPageState extends State<LoginPage> {
  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 7.0), border: OutlineInputBorder(), fillColor: Color(0xfff3f3f4), filled: true))
        ],
      ),
    );
  }

//Location Getting Code

  static const String _kLocationServicesDisabledMessage = 'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage = 'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();

    print("Position List here");
    print(position);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    latitude = position.latitude.toString();
    longitd = position.longitude.toString();

    Placemark place = placemarks[0];
    setState(() {
      _currentAddress = "${place.locality}, ${place.name},${place.subLocality},${place.postalCode}, ${place.country}";

      userlogin.userlocation = _currentAddress;
    });

    _updatePositionList(
      _PositionItemType.position,
      position.toString(),
    );
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _updatePositionList(
        _PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _updatePositionList(
          _PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        _PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(
      _PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));

    print("display Value");
    print(displayValue);

    setState(() {});
  }

  bool _isListening() => !(_positionStreamSubscription == null || _positionStreamSubscription!.isPaused);

  Color _determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }

  var otptext = "Request OTP";

  void checkphone(String phonetext) async {
    try {
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(max: 1, msg: "Please wait..");

      var url = Uri.parse(Linkhelper.user_signup);
      var response = await http.post(url, body: {
        'UserName': "admin",
        'Password': "123",
        'Name': "Enter First Name",
        'FatherName': "Enter Last Name",
        'OTP': "",
        'Phone': phonetext,
        'Address': "",
        'Email': "admin@.com",
        'Gender': "Male",
        'Longitude': longitd,
        'Latitude': latitude,
        'Location': _currentAddress,
        'Active': "1",
        'Delflag': "1",
        'Image': "",
      });

      if (response.statusCode == 200) {
        //final data = jsonDecode(response.body);
        pd.close();
        print("User sign Up data");
        //   print(data);
        print(response.body.toString());

        userlogin.phoneno = phonetext;

        setState(() {
          if (response.body.toString().trim() == "Already Exist") {
            otptext = "Login";

            Navigator.push(context, MaterialPageRoute(builder: (context) => VilaApartmentMobile()));
          } else if (response.body.toString().trim() == "Data Inserted") {
            otptext = "Request OTP";

            Navigator.push(context, MaterialPageRoute(builder: (context) => OTPLayout()));
          }
        });

        ///  print(listmobservices.length);
      } else {
        pd.close();
      }
    } catch (e) {
      print(e);
    }
  }

  String phoneno = "";

  void checkphonestatuschange(String phonetext, BuildContext context, String value) async {
    try {
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(max: 1, msg: "Please wait..");
      phoneno = phonetext;
      var url = Uri.parse(Linkhelper.user_signup);
      var response = await http.post(url, body: {
        'UserName': "admin",
        'Password': "123",
        'Name': "check",
        'FatherName': "Pending",
        'OTP': "0000",
        'Phone': phonetext,
        'Address': "",
        'Email': "admin@.com",
        'Gender': "Male",
        'Longitude': longitd,
        'Latitude': latitude,
        'Location': _currentAddress,
        'Active': "1",
        'Delflag': "1",
        'Image': "",
      });

      if (response.statusCode == 200) {
        //final data = jsonDecode(response.body);
        pd.close();

        print("User sign Up data");
        //   print(data);

        print(response.body.toString());

        userlogin.phoneno = phonetext;

        setState(() {
          if (response.body.toString().trim() == "Already Exist") {
            otptext = "Login";
            etphoneno.text = phoneno;
          } else {
            otptext = "Request OTP";
            etphoneno.text = phoneno;
          }
        });

        ///  print(listmobservices.length);
      }
    } catch (e) {
      print(e);
    }
  }

  late Future<void> _launched;

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  openwhatsapp() async {
    var whatsapp = "+9718003200";
    var whatsappURl_android = "whatsapp://send?phone=" + whatsapp + "&text=Hi How may i help you";
    var whatappURL_ios = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunch(whatappURL_ios)) {
        await launch(whatappURL_ios, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // android , web
      if (await canLaunch(whatsappURl_android)) {
        await launch(whatsappURl_android);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  //Get Mobile Settings

  String mobs_pascashflag = "";
  String mobs_versioncontrol = "";
  String mobs_versinner = "1.0.6";
  bool mobs_versioncontroll = false;

  void getmobilesettings() async {
    print("mobile settings method running");

    var url = Uri.parse(Linkhelper.getmobilesettings);
    var response = await http.post(url);

    if (response.statusCode == 200) {
      print("mobile settings");
      print(response.body.toString());
      final data = jsonDecode(response.body);

      setState(() {
        for (Map i in data) {
          mobs_pascashflag = MobileSettings.fromJson(i).PayCashFlag;
          mobs_versioncontrol = MobileSettings.fromJson(i).VersionControl;

          print("Mobile version control " + mobs_pascashflag.toString() + " " + mobs_versinner.toString());
        }

        if (mobs_versioncontrol == mobs_versinner) {
          mobs_versioncontroll = true;
        } else {
          mobs_versioncontroll = false;
        }
      });
    }

    // Fluttertoast.showToast(
    //  msg: mobs_versioncontroll.toString(),
    //  toastLength: Toast.LENGTH_SHORT,
    //  gravity: ToastGravity.CENTER,
    //  timeInSecForIosWeb: 1,
    //  backgroundColor: Colors.red,
    //  textColor: Colors.white,
    //  fontSize: 12.0);
  }

  TextEditingController etphoneno = new TextEditingController();

  @protected
  @mustCallSuper
  void initState() {
    _getCurrentPosition();
    getmobilesettings();
  }

  @override
  Widget build(BuildContext context) {
    String dropdownvalue = "+971";
    var items = ["+971"];
    bool checkedValue = true;

    void showtermandcondition() {
      setState(() {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TermsAndCondition(),
              ));
        });
      });
    }

    _launchURL(String url, String pagename) async {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebviewPolicy(url.toString(), pagename),
          ));
    }

    showdialog() {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Please Update App"),
          content: Text("This version is expired please update your app!!"),
          actions: [
            CupertinoDialogAction(
              child: Text("Open Store"),
              onPressed: () {
                StoreRedirect.redirect(
                  androidAppId: "com.rna.eumi_erp_services",
                  iOSAppId: "1619976412",
                );
              },
            )
          ],
        ),
      );
    }

    //final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
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
                color: Colors.white,
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
                      /*   Center(
                        child: Image.asset(
                          "assets/images/emfmlogin.png",
                          height: 180.0,
                          width: 180.0,
                        ),
                      ),*/

                      Center(
                        child: Text(
                          "ATAG HOME SERVICES",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25, color: Colors.green[900], fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Center(
                          child: Text(
                            //  "We will keep your home clean always"
                            "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 0),
                        child: Center(
                          child: Text(
                            //"you can relax"
                            "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                      /* SizedBox(
                        height: 20,
                      ),*/
                      Center(
                        child: Image.asset(
                          "assets/images/enfm.png",
                          height: 80.0,
                          width: 80.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black38,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Row(
                          children: [
                            DropdownButton(
                              value: dropdownvalue,
                              underline: Container(color: Colors.transparent),
                              icon: Icon(Icons.keyboard_arrow_down),
                              items: items.map((String items) {
                                return DropdownMenuItem(value: items, child: Text(items));
                              }).toList(),
                              onChanged: (String? value) {},
                            ),
                            Container(height: 50, child: VerticalDivider(color: Colors.black26)),
                            Expanded(
                              flex: 3, // 40% of space
                              child: Container(
                                color: Colors.transparent,
                                child: TextFormField(
                                  controller: etphoneno,
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.number,
                                  autocorrect: false,
                                  inputFormatters: [MaskedInputFormatter('###-00-####')],
                                  onChanged: (value) {
                                    if (mobs_versioncontroll == true) {
                                      if (etphoneno.text.length == 11) {
                                        /*   Fluttertoast.showToast(
                                            msg: "Please Enter Correct Phone Number",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 12.0);*/

                                        setState(() {
                                          checkphonestatuschange(etphoneno.text, context, value);
                                        });

                                        //      pd.close();
                                      } else {
                                        //send data to server

                                        //   checkphone(etphoneno.text);

                                        /*             Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OTPLayout()));*/
                                      }
                                    } else {
                                      showdialog();
                                    }
                                  },
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
                                    hintText: "521778352",
                                    hintStyle: TextStyle(color: Colors.black26),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (mobs_versioncontroll == true) {
                                if (etphoneno.text.length < 11) {
                                  Fluttertoast.showToast(
                                      msg: "Please Enter Correct Phone Number",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 12.0);
                                } else {
                                  //send data to server

                                  checkphone(etphoneno.text);

                                  /*             Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OTPLayout()));*/
                                }
                              } else {
                                showdialog();
                              }
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Center(
                              child: Text(
                                "$otptext",
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "By proceeding, you agree to our ",
                            style: TextStyle(fontSize: 8),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _launchURL(Linkhelper.maindomain + "/TermsandCondition.php", "Terms and Condition");
                                /*    AwesomeDialog(
                                  context: context,
                                  animType: AnimType.SCALE,
                                  dialogType: DialogType.INFO,
                                  body: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "TERMS OF USE",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Text(
                                        'These terms of use (the “Agreement”) govern the use and access of EnFM Website/Application (as defined below) including any content, functionality and services offered on or through www.enfm.aeEmirates National Facilities Management is an integrated facility management company incorporated in Abu Dhabi with its Head Office address at Etisalat Academy Exit 60 - E311 - Muhaisnah - Muhaisanah 2 – Dubai.This Agreement is entered into between you as the customer (“You” or “Customer”) and EnFM (referred to individually as a “Party” or collectively as the “Parties”), where You wish to use the Website to engage service professionals or an entity through which EnFM independent service professionals (collectively orindividually referred to as “Professional/s”) who wish to provide Professional Services (as defined hereinafter) to You using the EnFM Platform. If you do not agree to accept and be bound by this Agreement, you must immediately stop using the EnFM Platform.',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontStyle: FontStyle.normal),
                                      ),
                                      Text(
                                        "PLEASE READ THIS AGREEMENT THOROUGHLY AND CAREFULLY. CAPITALISED TERMS IN THIS \nAGREEMENT HAVE THE MEANING GIVEN TO THEM IN EXHIBIT A.\n\nTHE PARTIES AGREE TO THE FOLLOWING:\nPART 1: GENERAL",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Text(
                                          "This Agreement and the Private Policy constitutes a legally binding agreement between EnFM and the Customer. This Agreement sets out provisions that define the Customer’s legal rights and obligations with respect to its use of and participation in"
                                          "\nthe EnFM Platform as a whole, including the classified advertisements, forums, various email functions and internet links, and all content and EnFM services available through the domain and sub-domains of EnFM located at www.enfm.ae (collectively referred to herein as the 0Website), and"
                                          "\nthe online transactions between Customers and those Professionals who are providing services via the EnFM Platform (collectively “Services”). This Agreement incorporates by reference, the Privacy Policy through the link here as well as through the link titled “Privacy” on the Website and applies to all users of the EnFM Platform, including users who are also contributors of video content, information, private and public messages, advertisements, and other materials on the EnFM Platform."
                                          "\nYou acknowledge that the EnFM Platform serves as a venue for the online distribution and publication of information submitted and exchanged between Customers and Professionals, bookings for Professional Services and by using, visiting, registering for, and/or otherwise participating in this Website, including the availing of any services presented, promoted, and displayed on the EnFM Platform, and by clicking on I have readand agree to the terms of use, You hereby certify that:"
                                          "\n(1) You are a Customer,"
                                          "\n(2) You have the authority to enter into this Agreement,"
                                          "\n(3) upon confirmation of a booking by You, you authorize the transfer of payment for Professional Services requested from the Website or the ENFM App, and"
                                          "\n(4) You agree to be bound by all terms and conditions of this Agreement and any other documents incorporated by reference."
                                          "\n(5) By using the ENFM Platform, you confirm that You are at least 18 years of age or the age of majority in the relevant jurisdiction whichever")
                                    ],
                                  ),
                                  btnOkOnPress: () {},
                                )..show();*/
                              });
                            },
                            child: Text(
                              "T&C,",
                              style: TextStyle(decoration: TextDecoration.underline, color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            " ",
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {});
                              _launchURL(Linkhelper.maindomain + "/PrivacyPolicy.Php", "Privacy Policy");
                              /*  AwesomeDialog(
                                context: context,
                                animType: AnimType.SCALE,
                                dialogType: DialogType.INFO,
                                body: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Privacy Policy",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      'Emirates National Facilities Management values our client’s privacy. In this Privacy Policy ("Policy"), we describe the information that we collect about you when you visit our website, www.enfm.ae (the "Website") and use the services available on the Website ("Services"), and how we use and disclose that information.If you have any questions, comments or queries about the Privacy Policy, please contact us at; sales@enfm.ae.This Policy is incorporated into and is subject to Emirates National Facilities Management Terms of Use, which can be accessed at www.enfm.ae. Your use of the Website and/or Services and any personal information you provide on the Website remains subject to the terms of the Policy and EnFM Terms of Use.',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontStyle: FontStyle.normal),
                                    ),
                                    Text(
                                      "1. COLLECTION OF PERSONAL INFORMATION",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "Personal information",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                        "This is information or an opinion forming part of a database, whether true or not, and whether recorded in a material form or not, about an individual whose identity is apparent, or can reasonably be ascertained, from the information or opinion. The information may be used to readily identify or contact you EnFM as: name, address, email address, phone number etc.We collect personal information from our interested clients offering our services. This information is partially or completely accessible to our internal stakeholders using EnFM website or mobile CAFM System, either directly or by submitting a request for a service.Clients are required to create an account to be able to access specific pages of our Website, EnFM as to submit a comment/ query, write a review, request a quote, and/or request information. When clients create an account with EnFM, they will be required to disclose their personal information including personal contact details, bank details, personal identification details etc. The information gathered will be utilized to ensure greater customer satisfaction and help a customer satiate their needs. The type of personal information that we collect from our clients varies based on our particular interaction in the Website or mobile application."),
                                    Text(
                                      "Consumers",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                        "Consumers are people who use our services to meet their requirements. During the account registration process in the website or application, we will collect information such as client name, postal code, telephone no, email address and other personal information. Clients may provide us with their, mailing address, and demographic information (e.g., gender, age, and other information relevant to user surveys and/or offers). "),
                                    Text(
                                      "Service Professionals",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                        "If you are a Service Professional and would like to post any information about yourself, we will require you to register for an Account. During the Account registration process, we will collect your business name, telephone number, address, zip code, travel preferences, a description of your services, a headline for your profile, first and last name, and email address. Other information may also be required to be provided to EnFM. In addition, you may, but are not required to, provide other content or information about your business"),
                                    Text(
                                      "How do we protect your information?",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                        "Emirates National Facilities Management implements a variety of security measures to maintain the safety of our client’s personal information when they place an order or enter, submit, or access your personal information.We offer the use of a secure server. All supplied sensitive/credit information is transmitted via Secure Socket Layer (SSL) technology and then encrypted into our payment gateway providers database, which is only accessible by those authorized with special access rights to EnFM systems, and who are required to keep the information confidential.After a transaction, your private information (credit cards, social security numbers, financials, etc.) will not be stored on our servers."),
                                    Text(
                                      "Do we use cookies?",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                        "Yes. Cookies are small files that a site or its service provider transfers to your computer's hard drive through your web browser (if you allow) that enable the sites or service providers' systems to recognize your browser and capture and remember certain informationWe use cookies to help us remember and process the items in your shopping cart and understand and save your preferences for future visits.If you prefer, you can choose to have your computer warn you each time a cookie is being sent, or you can choose to turn off all cookies via your browser settings. Like most websites, if you turn your cookies off, some of our services may not function properly. However, you can still place orders over the telephone or by contacting EnFM Customer Service representative."),
                                    Text(
                                      "Do we disclose any information to outside parties?",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                        "Emirates National Facilities Management does not sell, trade or otherwise transfer to outside parties our client’s personal identifiable information. This does not include trusted third parties who assist us in operating our website, associating our business or servicing you, so long as those parties agree to keep this information confidential. EnFM may only release the information subjected to a UAE court warrant when we believe release is appropriate to comply with the law, enforce our site policies, or protect ours or others' rights, property or safety. However, non-personally identifiable visitor information may be used internally to reach out to you for marketing, advertising or other uses."),
                                    Text(
                                      "Children’s Online Privacy Protection Act Compliance",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                        "EnFM is compliant with the requirements of COPPA (Children’s Online Privacy Protection Act), as we do not collect/store any information from anyone under 18 years of age. Our website, products and services are all directed to people who are at least 18 years old or older."),
                                  ],
                                ),
                                btnOkOnPress: () {},
                              )..show();*/
                            },
                            child: Text(
                              "Privacy",
                              style: TextStyle(fontSize: 8, decoration: TextDecoration.underline, color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            " and ",
                            style: TextStyle(fontSize: 8),
                          ),
                          InkWell(
                            onTap: () {
                              _launchURL(Linkhelper.maindomain + "/CancellationPolicy.Php", "Cancellation Policy");
                              /*  AwesomeDialog(
                                context: context,
                                animType: AnimType.SCALE,
                                dialogType: DialogType.INFO,
                                body: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Cancellation Policy",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "Emirates National Facilities Management has a comprehensive cancellation policy. Our customer service representative receive request from clients, they then assign the task to a supervisor who then proceeds to block time for a technician to execute the job. In the event of a cancellation, charges will only be applicable when a technician has been assigned a task and his work schedule blocked for that period. (since they no longer receive other tasks for that time).Depending on the service, customers will be granted a buffer period after placing the request to cancel the job without incurring a fee.Pest Control requests placed in Dubai will be subjected to a fee of AED 25 if the order is canceled/rescheduled after 4hours when booking was made.",
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                                btnOkOnPress: () {},
                              )..show();*/
                            },
                            child: Text(
                              "Cancellation policy,",
                              style: TextStyle(decoration: TextDecoration.underline, color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      /*                     CheckboxListTile(
                        title: Text(
                          "Cancellation Policy",
                          style: TextStyle(
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ),
                        value: checkedValue,
                        onChanged: (newValue) {
                          showtermandcondition();
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Privacy Policy",
                          style: TextStyle(
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ),
                        value: checkedValue,
                        onChanged: (newValue) {
                          showtermandcondition();
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Terms and Condition",
                          style: TextStyle(
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ),
                        value: checkedValue,
                        onChanged: (newValue) {
                          showtermandcondition();
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),*/

                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Divider(
                              thickness: 1,
                              color: Colors.black26,
                            ),
                          ),
                          Text(
                            //"or Sign in with Google or Facebook"
                            "Connect with us via",
                            style: TextStyle(fontSize: 10),
                          ),
                          Expanded(
                            flex: 1,
                            child: Divider(
                              thickness: 1,
                              color: Colors.black26,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 0,
                      ),
                      /* Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: Container(
                                  width: 130,
                                  height: 40,
                                  child: Card(
                                      elevation: 5,
                                      color: Colors.white,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 0.0, vertical: 0.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Image.asset(
                                                "assets/images/google.png",
                                                height: 20.0,
                                                width: 20.0,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Google"),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Center(
                                child: Container(
                                  width: 130,
                                  height: 40,
                                  child: Card(
                                      elevation: 5,
                                      color: Colors.white,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 0.0, vertical: 0.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Image.asset(
                                                "assets/images/fb.png",
                                                height: 20.0,
                                                width: 20.0,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Facebook"),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              ))
                        ],
                      ),*/
                      SizedBox(height: 0),
                      /*        Row(
                        children: [
                          Text(
                            "Not registered yet?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                          Text(
                            "Create an Account",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[400],
                            ),
                          ),
                        ],
                      ),*/
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                openwhatsapp();
                              },
                              child: Image.asset(
                                "assets/images/whatsapp.png",
                                height: 40.0,
                                width: 40.0,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _launched = _makePhoneCall('mailto:sales@atag.ae');
                                });
                              },
                              child: Image.asset(
                                "assets/images/email_icon.png",
                                height: 40.0,
                                width: 40.0,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _makePhoneCall('tel:8003200');
                                });
                              },
                              child: Image.asset(
                                "assets/images/call.png",
                                height: 40.0,
                                width: 40.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Powered by ",
                            style: TextStyle(color: Colors.grey[400], fontFamily: 'SpaceAge'),
                          ),
                          Text(
                            "ATAG",
                            style: TextStyle(color: Colors.orange, fontFamily: 'SpaceAge'),
                          ),
                        ],
                      )
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
}
