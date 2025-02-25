import 'package:flutter/material.dart';

class RelationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding for proper spacing
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green, // Background color
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white), // White icon
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Relations",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
           TextField(
  style: TextStyle(color: Colors.black), // Ensures typed text is black
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.search, color: Colors.black), 
    hintText: "Search",
    hintStyle: TextStyle(color: Colors.black54), // Hint text slightly dimmed black
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    filled: true, // Ensures background is filled
    fillColor: Colors.white, // Ensures input field background is white
  ),
),
 
            SizedBox(height: 16),

            // Community Section
            Text(
              "Community",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),

            // Placeholder for Community List
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3, // Placeholder for 3 items
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "Community $index",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black), // Text black
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Tabs for Community & My Activity
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Community", style: TextStyle(color: Colors.white)), // Ensure text is white here
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black), // Black border
                    ),
                    child: Text("My Activity", style: TextStyle(color: Colors.black)), // Text black
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Placeholder for Activity Feed
            Expanded(
              child: ListView.builder(
                itemCount: 2, // Placeholder for 2 posts
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "User Name",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Text black
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          "This is a placeholder text for the post content.",
                          style: TextStyle(color: Colors.black), // Text black
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.favorite_border, color: Colors.black),
                            SizedBox(width: 4),
                            Text("10", style: TextStyle(color: Colors.black)), // Text black
                            SizedBox(width: 16),
                            Icon(Icons.comment, color: Colors.black),
                            SizedBox(width: 4),
                            Text("2", style: TextStyle(color: Colors.black)), // Text black
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black, // Make unselected icons black
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: Colors.black),
            label: "Relations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
