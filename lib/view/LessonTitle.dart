import 'package:flutter/material.dart';

class Lessontitle extends StatelessWidget {
  final String categoryTitle; // Menerima data dari Lesson1Page

  Lessontitle({Key? key, required this.categoryTitle}) : super(key: key);

  // Data kursus dibuat secara native tanpa fetch dari API
  final List<Map<String, String>> lessonItems = [
    {
      'kata': 'Alphabet A',
      'link_yt': 'https://www.youtube.com/watch?v=A'
    },
    {
      'kata': 'Alphabet B',
      'link_yt': 'https://www.youtube.com/watch?v=B'
    },
    {
      'kata': 'Alphabet C',
      'link_yt': 'https://www.youtube.com/watch?v=C'
    },
  ];

  // Fungsi untuk membuka URL YouTube
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 95,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(2.0),
            child: Icon(Icons.arrow_back),
            decoration: BoxDecoration(
              color: Color(0xFFBAE1C4),
              shape: BoxShape.circle,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'List Course',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Kategori: $categoryTitle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: lessonItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        color: Color(0xFFDEF5E4),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ListTile(
                        title: Text(lessonItems[index]['kata']!), // Menampilkan 'kata'
                        trailing: Container(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/arrow-right.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        onTap: () {
                          
                        },
                      ),
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
