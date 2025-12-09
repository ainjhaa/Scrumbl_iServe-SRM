import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;

  const EditEventPage({super.key, required this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();

  File? selectedImage;
  String? existingImageUrl;

  final List<String> eventcategory = [
    "Rakan Prihatin", "Rakan Demokrasi", "Rakan Muzik",
    "Rakan Aktif", "Rakan Ekspresi", "Rakan Niaga",
    "Rakan Bumi", "Rakan Digital", "Rakan Mahir", "Rakan Litar"
  ];
  String? value;

  final ImagePicker _picker = ImagePicker();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 00);

  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Event").doc(widget.eventId).get();

    if (doc.exists) {
      setState(() {
        namecontroller.text = doc["Name"];
        pricecontroller.text = doc["Price"];
        locationcontroller.text = doc["Location"];
        detailcontroller.text = doc["Detail"];
        value = doc["Category"];
        existingImageUrl = doc["Image"];

        selectedDate = DateTime.parse(doc["Date"]);
        selectedTime = _parseTime(doc["Time"]);
      });
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final format = DateFormat.jm();
    final dateTime = format.parse(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  Future<void> getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> saveUpdates() async {
    try {
      String finalImageUrl = existingImageUrl ?? "";
      
      // If admin selects new image, upload to Firebase Storage
      if (selectedImage != null) {
        Reference ref = FirebaseStorage.instance
        .ref()
        .child("eventImages")
        .child(widget.eventId); // overwrite old image
        
        await ref.putFile(selectedImage!);
        
        finalImageUrl = await ref.getDownloadURL();
      }

      String firstletter = namecontroller.text.substring(0, 1).toUpperCase();

      Map<String, dynamic> updatedEvent = {
        "Image": finalImageUrl,
        "Name": namecontroller.text,
        "Price": pricecontroller.text,
        "Category": value,
        "SearchKey": firstletter,
        "Location": locationcontroller.text,
        "Detail": detailcontroller.text,
        "UpdatedName": namecontroller.text.toUpperCase(),
        "Date": DateFormat('yyyy-MM-dd').format(selectedDate),
        "Time": formatTimeOfDay(selectedTime),
      };

      await FirebaseFirestore.instance
          .collection("Event")
          .doc(widget.eventId)
          .update(updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Event updated successfully!"),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error updating: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Event")),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// IMAGE SECTION
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
                  : existingImageUrl != null
                      ? Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              existingImageUrl!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Center(
                          child: GestureDetector(
                            onTap: getImage,
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black45, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.camera_alt_outlined),
                            ),
                          ),
                        ),

              const SizedBox(height: 30),

              // ---------- EVENT NAME ----------
              buildLabel("Event Name"),
              buildTextField(namecontroller, "Enter Event Name"),

              const SizedBox(height: 30),

              // ---------- PRICE ----------
              buildLabel("Ticket Price"),
              buildTextField(pricecontroller, "Enter Price"),

              const SizedBox(height: 20),

              // ---------- LOCATION ----------
              buildLabel("Event Location"),
              buildTextField(locationcontroller, "Enter Location"),

              const SizedBox(height: 20),

              // ---------- CATEGORY ----------
              buildLabel("Select Category"),
              buildDropdown(),

              const SizedBox(height: 20),

              // ---------- DATE + TIME ----------
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: const Icon(Icons.calendar_month, color: Colors.blue, size: 30),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) setState(() => selectedTime = picked);
                    },
                    child: const Icon(Icons.alarm, color: Colors.blue, size: 30),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatTimeOfDay(selectedTime),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ---------- DETAILS ----------
              buildLabel("Event Detail"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: const Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: detailcontroller,
                  maxLines: 6,
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "Event details..."),
                ),
              ),

              const SizedBox(height: 30),

              // ---------- SAVE BUTTON ----------
              Center(
                child: GestureDetector(
                  onTap: saveUpdates,
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xff6351ec),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Save Changes",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xffececf8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xffececf8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          items: eventcategory
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 18)),
                  ))
              .toList(),
          onChanged: (val) => setState(() => value = val),
          value: value,
          hint: const Text("Select Category"),
        ),
      ),
    );
  }
}
