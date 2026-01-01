import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reports"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.event), text: "Events Report"),
              Tab(icon: Icon(Icons.people), text: "Users Report"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EventReport(),
            UserReport(),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
//                        EVENT REPORT PAGE
// ----------------------------------------------------------------------

class EventReport extends StatelessWidget {
  const EventReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("Event").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Events: Loading..."),
                        Text("Total Participants: Loading..."),
                      ],
                    );
                  }
                  
                  final events = snapshot.data!.docs;
                  int totalParticipants = 0;
                  
                  for (var event in events) {
                    final eventData = event.data() as Map<String, dynamic>? ?? {};
                    final participants = eventData["RegisteredUsers"] ?? [];
                    
                    // Check if participants is a List
                    if (participants is List) {
                      totalParticipants += participants.length;
                    } else {
                      // Try to convert to list if it's not
                      try {
                        if (participants is Iterable) {
                          totalParticipants += participants.length;
                        }
                      } catch (e) {
                        print("Error counting participants: $e");
                      }
                    }
                  }
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Events: ${events.length}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Total Participants: $totalParticipants",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: 10),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Event")
                  .orderBy("Date", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!.docs;

                if (events.isEmpty) {
                  return const Center(child: Text("No events found"));
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventData = event.data() as Map<String, dynamic>? ?? {};

                    final name = eventData["Name"] ?? "Unknown Event";
                    final date = eventData["Date"] ?? "-";
                    final location = eventData["Location"] ?? "-";
                    final price = eventData["Price"]?.toString() ?? "0";
                    final participants = eventData["RegisteredUsers"] ?? [];
                    final image = eventData["Image"]?.toString() ?? "";
                    
                    // Ensure participants is a List
                    List participantsList = [];
                    if (participants is List) {
                      participantsList = List.from(participants);
                    } else if (participants != null) {
                      participantsList = [participants];
                    }

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (image.isNotEmpty)
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: image.isNotEmpty ? 12 : 0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(date),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded( 
                                            child: Text(location, 
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                          ),),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text("Price: $price"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Participants Summary
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Participants: ${participantsList.length}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (participantsList.isNotEmpty)
                                    FutureBuilder<int>(
                                      future: _calculateRevenue(price, participantsList.length),
                                      builder: (context, snapshot) {
                                        final revenue = snapshot.hasData ? snapshot.data! : 0;
                                        return Text(
                                          "Revenue: RM $revenue",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 10),

                            // Participant List
                            if (participantsList.isNotEmpty)
                              ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: const Text(
                                  "View Participant Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                children: participantsList.map<Widget>((participant) {
                                  // Handle both string userId and map participant
                                  String userId;
                                  String? userName;
                                  dynamic registrationDate;
                                  
                                  if (participant is String) {
                                    userId = participant;
                                  } else if (participant is Map) {
                                    userId = participant["userId"]?.toString() ?? "";
                                    userName = participant["userName"]?.toString();
                                    registrationDate = participant["registrationDate"];
                                  } else {
                                    userId = participant.toString();
                                  }
                                  
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(userId)
                                        .get(),
                                    builder: (context, userSnap) {
                                      if (!userSnap.hasData) {
                                        return const ListTile(
                                          leading: CircularProgressIndicator(),
                                          title: Text("Loading..."),
                                        );
                                      }

                                      final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {};
                                      final userEmail = userData["email"] ?? userData["Email"] ?? "N/A";
                                      
                                      String displayName = userName ?? userData["name"]?.toString() ?? "Unknown User";
                                      
                                      // Format registration date
                                      String formattedDate = "N/A";
                                      if (registrationDate != null && registrationDate is Timestamp) {
                                        try {
                                          final dateTime = registrationDate.toDate();
                                          formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
                                        } catch (e) {
                                          formattedDate = "N/A";
                                        }
                                      }

                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue[100],
                                          child: Icon(Icons.person, color: Colors.blue),
                                        ),
                                        title: Text(displayName),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(userEmail),
                                            if (formattedDate != "N/A")
                                              Text(
                                                "Registered: $formattedDate",
                                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                              ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("User Details"),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Name: $displayName"),
                                                    Text("Email: $userEmail"),
                                                    Text("User ID: $userId"),
                                                    SizedBox(height: 10),
                                                    Text("Event: $name"),
                                                    Text("Registered: $formattedDate"),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text("Close"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "No participants registered yet.",
                                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _calculateRevenue(String priceStr, int participantCount) async {
    try {
      // Remove "RM" and any non-numeric characters except decimal point
      String cleanPrice = priceStr.replaceAll("RM", "").replaceAll(RegExp(r'[^\d.]'), '').trim();
      double price = double.tryParse(cleanPrice) ?? 0.0;
      return (price * participantCount).round();
    } catch (e) {
      return 0;
    }
  }
}

// ----------------------------------------------------------------------
//                        USER REPORT PAGE
// ----------------------------------------------------------------------

class UserReport extends StatelessWidget {
  const UserReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Users: Loading..."),
                        Text("Active Users: Loading..."),
                      ],
                    );
                  }
                  
                  final users = snapshot.data!.docs;
                  int totalUsers = users.length;
                  
                  // Count active users (those with registered events)
                  int activeUsers = 0;
                  
                  return FutureBuilder<int>(
                    future: _getActiveUsersCount(users),
                    builder: (context, activeUsersSnapshot) {
                      final activeCount = activeUsersSnapshot.data ?? 0;
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Users: $totalUsers",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Active Users: $activeCount",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          StreamBuilder<int>(
                            stream: _getTotalEventsStream(),
                            builder: (context, eventsSnapshot) {
                              final totalEvents = eventsSnapshot.data ?? 0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Total Events: $totalEvents",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Avg: ${totalUsers > 0 ? (totalEvents / totalUsers).toStringAsFixed(1) : '0'}/user",
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: 10),
          
          Expanded(
            child: _UsersList(),
          ),
        ],
      ),
    );
  }

  Future<int> _getActiveUsersCount(List<QueryDocumentSnapshot> users) async {
    int activeCount = 0;
    
    for (var user in users) {
      final userId = user.id;
      try {
        final eventsSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("RegisteredEvents")
            .get();
        
        if (eventsSnapshot.docs.isNotEmpty) {
          activeCount++;
        }
      } catch (e) {
        print("Error checking user events: $e");
      }
    }
    
    return activeCount;
  }

  Stream<int> _getTotalEventsStream() {
    return FirebaseFirestore.instance
        .collection("Event")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

// Users List Widget
class _UsersList extends StatelessWidget {
  const _UsersList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  "No Users Found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  "There are no users in the database",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userData = user.data() as Map<String, dynamic>? ?? {};
            final userId = user.id;
            final userName = userData["name"]?.toString() ?? "Unknown User";
            final userEmail = userData["email"]?.toString() ?? userData["Email"]?.toString() ?? "No Email";
            final userRole = userData["role"]?.toString() ?? "user";
            
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: switch(userRole){ 
                                    "Admin" => Colors.red[100],
                                    "Member"=> Colors.blue[100],
                                    _ => Colors.yellow[100],},
                  child: Icon(
                    userRole == "Admin" ? Icons.admin_panel_settings : Icons.person,
                    color: switch(userRole){ 
                            "Admin" => Colors.red,
                            "Member"=> Colors.blue,
                            _ => Colors.orange,}
                  ),
                ),
                title: Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: switch(userRole){ 
                                "Admin" => Colors.red[50],
                                "Member"=> Colors.blue[50],
                                _ => Colors.yellow[50],},
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            userRole != "Admin" ? userRole.toUpperCase() : "COMMITTEE",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: switch(userRole){ 
                                "Admin" => Colors.red[700],
                                "Member"=> Colors.blue[700],
                                _ => Colors.orange[700],}
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        FutureBuilder<int>(
                          future: _getUserEventCount(userId),
                          builder: (context, snapshot) {
                            final eventCount = snapshot.data ?? 0;
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: eventCount > 0 ? Colors.green[50] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${eventCount} ${eventCount == 1 ? 'event' : 'events'}",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: eventCount > 0 ? Colors.green[700] : Colors.grey[700],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[500],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsPage(userId: userId),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<int> _getUserEventCount(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("RegisteredEvents")
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting event count: $e");
      return 0;
    }
  }
}

// ----------------------------------------------------------------------
//                        USER DETAILS PAGE
// ----------------------------------------------------------------------

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    "User Not Found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Go Back"),
                  ),
                ],
              ),
            );
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final userName = userData["name"]?.toString() ?? "Unknown User";
          final userEmail = userData["email"]?.toString() ?? userData["Email"]?.toString() ?? "No Email";
          final userRole = userData["role"]?.toString() ?? "user";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: userRole == "Admin" 
                              ? Colors.red[100] 
                              : Colors.blue[100],
                          child: Icon(
                            userRole == "Admin" ? Icons.admin_panel_settings : Icons.person,
                            size: 40,
                            color: userRole == "Admin" ? Colors.red : Colors.blue,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          userName,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          userEmail,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              label: Text(userRole.toUpperCase()),
                              backgroundColor: userRole == "Admin" 
                                  ? Colors.red[100] 
                                  : Colors.blue[100],
                              labelStyle: TextStyle(
                                color: userRole == "Admin" ? Colors.red[700] : Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            FutureBuilder<int>(
                              future: _getUserEventCount(userId),
                              builder: (context, snapshot) {
                                final eventCount = snapshot.data ?? 0;
                                return Chip(
                                  label: Text("${eventCount} ${eventCount == 1 ? 'Event' : 'Events'}"),
                                  backgroundColor: eventCount > 0 
                                      ? Colors.green[100] 
                                      : Colors.grey[200],
                                  labelStyle: TextStyle(
                                    color: eventCount > 0 ? Colors.green[700] : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // User Information
                Text(
                  "User Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.email, "Email", userEmail),
                        Divider(),
                        _buildInfoRow(Icons.person, "Role", userRole),
                        Divider(),
                        _buildInfoRow(Icons.credit_card, "User ID", userId),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Registered Events
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Registered Events",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder<int>(
                      future: _getUserEventCount(userId),
                      builder: (context, snapshot) {
                        final eventCount = snapshot.data ?? 0;
                        return Chip(
                          label: Text("Total: $eventCount"),
                          backgroundColor: Colors.blue[100],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
                // Events List
                _buildUserEventsList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserEventsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("RegisteredEvents")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs;

        if (events.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "No Events Registered",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This user hasn't registered for any events yet",
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final eventDoc = events[index];
            final eventData = eventDoc.data() as Map<String, dynamic>? ?? {};
            
            final eventName = eventData["eventName"]?.toString() ?? "Unknown Event";
            final eventDate = eventData["eventDate"]?.toString() ?? "No Date";
            final eventLocation = eventData["eventLocation"]?.toString() ?? "No Location";
            final eventPrice = eventData["eventPrice"]?.toString() ?? "Free";
            final status = eventData["status"]?.toString() ?? "registered";
            final paymentStatus = eventData["paymentStatus"]?.toString() ?? "paid";
            
            final registrationDate = eventData["registrationDate"];
            String formattedDate = "N/A";
            if (registrationDate is Timestamp) {
              try {
                formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(registrationDate.toDate());
              } catch (e) {
                formattedDate = "N/A";
              }
            } else if (registrationDate is String) {
              formattedDate = registrationDate;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            eventName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == "registered" ? Colors.green[100] : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: status == "registered" ? Colors.green[800] : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    _buildEventDetailRow(Icons.calendar_today, eventDate),
                    SizedBox(height: 6),
                    _buildEventDetailRow(Icons.location_on, eventLocation),
                    SizedBox(height: 6),
                    _buildEventDetailRow(Icons.attach_money, eventPrice),
                    
                    SizedBox(height: 12),
                    
                    Divider(),
                    
                    SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Registration Date",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: paymentStatus == "paid" ? Colors.green[100] : Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Payment: ${paymentStatus.toUpperCase()}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: paymentStatus == "paid" ? Colors.green[800] : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<int> _getUserEventCount(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("RegisteredEvents")
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting event count: $e");
      return 0;
    }
  }
}
