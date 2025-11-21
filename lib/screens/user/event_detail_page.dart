import 'dart:convert';

import 'package:demo_app/services/data.dart';
import 'package:demo_app/services/database.dart';
import 'package:demo_app/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class EDetailPage extends StatefulWidget {
  String image, name, location, date, detail, price;
  EDetailPage(
      {required this.date,
      required this.detail,
      required this.image,
      required this.location,
      required this.name,
      required this.price});
  @override
  State<EDetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<EDetailPage> {
  Map<String, dynamic>? paymentIntent;
  int ticket = 1;
  int total = 0;
  String? name, image, id;

  @override
  void initState() {
    total = int.parse(widget.price);
    ontheload();
    super.initState();
  }

  ontheload() async {
    name = await SharedpreferenceHelper().getUserName();
    image = await SharedpreferenceHelper().getUserImage();
    id = await SharedpreferenceHelper().getUserId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Image.asset(
                "images/event.jpg",
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(top: 40.0, left: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: Colors.black45),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                widget.date,
                                style: TextStyle(
                                  color: Color.fromARGB(211, 255, 255, 255),
                                  fontSize: 19.0,
                                ),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                widget.location,
                                style: TextStyle(
                                  color: Color.fromARGB(211, 255, 255, 255),
                                  fontSize: 19.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ]),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "About Event",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                widget.detail,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 30.0),
              child: Row(
                children: [
                  Text(
                    "Number of Tickets",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 40.0,
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 2.0),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            total = total + int.parse(widget.price);
                            ticket = ticket + 1;
                            setState(() {});
                          },
                          child: Text(
                            "+",
                            style:
                                TextStyle(color: Colors.black, fontSize: 25.0),
                          ),
                        ),
                        Text(
                          ticket.toString(),
                          style: TextStyle(
                              color: Color(0xff6351ec),
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (ticket > 1) {
                              total = total - int.parse(widget.price);
                              ticket = ticket - 1;
                              setState(() {});
                            }
                          },
                          child: Text(
                            "-",
                            style:
                                TextStyle(color: Colors.black, fontSize: 25.0),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: Row(
                children: [
                  Text(
                    "Amount : \$" + total.toString(),
                    style: TextStyle(
                        color: Color(0xff6351ec),
                        fontSize: 23.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      makePayment(total.toString());
                    },
                    child: Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Color(0xff6351ec),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          "Book Now",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent?['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Adnan'))
          .then((value) {});

      displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        Map<String, dynamic> bookingdetail = {
          "Number": ticket.toString(),
          "Total": total.toString(),
          "Event": widget.name,
          "Location": widget.location,
          "Date": widget.date,
          "Name": name,
          "Image": image,
          "EventImage": widget.image
        };
        await DatabaseMethods()
            .addUserBooking(bookingdetail, id!)
            .then((value) async {
          await DatabaseMethods().addAdminTickets(bookingdetail);
        });
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successfull")
                        ],
                      )
                    ],
                  ),
                ));
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print("Error is :---> $error $stackTrace");
      });
    } on StripeException catch (e) {
      print("Error is:---> $e");
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Cancelled"),
              ));
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretkey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount) * 100);

    return calculatedAmount.toString();
  }
}
