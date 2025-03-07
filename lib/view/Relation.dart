import 'package:flutter/material.dart';
import '../services/comumnity_service.dart';
import '../models/community.dart';
import '../widgets/community_card.dart';

class RelationsPage extends StatefulWidget {
  @override
  _RelationsPageState createState() => _RelationsPageState();
}

class _RelationsPageState extends State<RelationsPage> {
  late Future<List<Community>> communities;

  @override
  void initState() {
    super.initState();
    communities = ApiService.fetchCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text("Relations", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black),
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue, width: 2)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            // Title "Community"
            Text("Community", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 8),

            // Fetch data & show in ListView
            FutureBuilder<List<Community>>(
              future: communities,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No communities found", style: TextStyle(color: Colors.black));
                } else {
                  return SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return CommunityCard(community: snapshot.data![index]);
                      },
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 16),

            // Tabs: Community & My Activity
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Community", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.black)),
                    child: Text("My Activity", style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Placeholder Activity Feed
            Expanded(
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 8), Text("User Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))]),
                        SizedBox(height: 8),
                        Text("This is a placeholder text for the post content.", style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
