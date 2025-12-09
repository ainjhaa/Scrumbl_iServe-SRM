import 'dart:io';
import 'package:demo_app/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class UploadEvent extends StatefulWidget {
  const UploadEvent({super.key});

  @override
  State<UploadEvent> createState() => _UploadEventState();
}

class _UploadEventState extends State<UploadEvent> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController pricecontroller = new TextEditingController();

  TextEditingController detailcontroller = new TextEditingController();
  TextEditingController locationcontroller = new TextEditingController();
  final List<String> eventcategory = ["Rakan Prihatin", "Rakan Demokrasi", "Rakan Muzik", "Rakan Aktif", "Rakan Ekspresi",
                                      "Rakan Niaga","Rakan Bumi","Rakan Digital","Rakan Mahir","Rakan Litar"];
  String? value;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {});
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 00);

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    // Convert TimeOfDay to DateTime
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    // Format to desired format with leading zero
    return DateFormat('hh:mm a').format(dateTime);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Event"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              selectedImage != null
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          selectedImage!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Center(
                      child: GestureDetector(
                        onTap: () {
                          getImage();
                        },
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black45, width: 2.0),
                              borderRadius: BorderRadius.circular(20)),
                          child: Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                    ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Event Name",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Enter Event Name"),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Ticket Price",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: pricecontroller,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Enter Price"),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
             
              Text(
                "Event Location",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: locationcontroller,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Enter Location"),
                ),
              ),
                 SizedBox(
                height: 20.0,
              ),
              Text(
                "Select Category",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items: eventcategory
                        .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                            )))
                        .toList(),
                    onChanged: ((value) => setState(() {
                          this.value = value;
                        })),
                    dropdownColor: Colors.white,
                    hint: Text("Select Category"),
                    iconSize: 36,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    value: value,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        _pickDate();
                      },
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                        size: 30.0,
                      )),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate!),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  GestureDetector(
                      onTap: () {
                        _pickTime();
                      },
                      child: Icon(
                        Icons.alarm,
                        color: Colors.blue,
                        size: 30.0,
                      )),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    formatTimeOfDay(selectedTime!),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Event Detail",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: detailcontroller,
                  maxLines: 6,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "What will be on that event...."),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                onTap: () async {
                  if (selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select an image first")),
                    );
                    return;
                  }
                  
                  String id = randomNumeric(10);
                  
                  // 1️⃣ Upload image to Firebase Storage
                  Reference ref = FirebaseStorage.instance
                  .ref()
                  .child("eventImages")
                  .child(id);
                  
                  UploadTask uploadTask = ref.putFile(selectedImage!);
                  TaskSnapshot snapshot = await uploadTask;
                  String downloadUrl = await snapshot.ref.getDownloadURL();
                  
                  // 2️⃣ Prepare data
                  String firstletter = namecontroller.text.substring(0, 1).toUpperCase();
                  
                  Map<String, dynamic> uploadevent = {
                    "Image": downloadUrl,
                    "Name": namecontroller.text,
                    "Price": pricecontroller.text,
                    "Category": value,
                    "SearchKey": firstletter,
                    "Location": locationcontroller.text,
                    "Detail": detailcontroller.text,
                    "UpdatedName": namecontroller.text.toUpperCase(),
                    "Date": DateFormat('yyyy-MM-dd').format(selectedDate),
                    "Time": formatTimeOfDay(selectedTime),
                    "id": id,
                  };
                  
                  // 3️⃣ Store into Firestore
                  await DatabaseMethods().addEvent(uploadevent, id);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text("Event Uploaded Successfully!",
                      style: TextStyle(fontSize: 20)),
                    ),
                  );
                  
                  setState(() {
                    namecontroller.clear();
                    pricecontroller.clear();
                    detailcontroller.clear();
                    selectedImage = null;
                  });
                },

                child: Center(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Color(0xff6351ec),
                        borderRadius: BorderRadius.circular(10)),
                    width: 200,
                    child: Center(
                      child: Text(
                        "Upload",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
