import 'package:flutter/material.dart';
import 'package:football_news/models/news_entry.dart';
import 'package:football_news/widgets/left_drawer.dart';
import 'package:football_news/screens/news_detail.dart';
import 'package:football_news/widgets/news_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class NewsEntryListPage extends StatefulWidget {
  const NewsEntryListPage({super.key});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    // TODO: Replace the URL with your app's URL and don't forget to add a trailing slash (/)! 
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
    // If you using chrome,  use URL http://localhost:8000

    final response = await request.get('http://localhost:8000/json/');

    // Decode response to json format
    var data = response;

    // Convert json data to NewsEntry objects
    List<NewsEntry> listNews = [];
    for (var d in data) {
      if (d != null) {
        try {
          listNews.add(NewsEntry.fromJson(d));
        } catch (e) {
          // Prevent bad/null entries from breaking the UI
          debugPrint("Error parsing news entry: $e");
        }
      }
    }

    debugPrint("Fetched ${listNews.length} news entries");
    return listNews;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Entry List'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchNews(request),
        builder: (context, AsyncSnapshot snapshot) {
          // ✅ Still using same tutorial logic, but safer null handling
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'There are no news in football news yet.',
                  style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                ),
                SizedBox(height: 8),
              ],
            );
          } else {
            // ✅ Data exists, display list normally
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) => NewsEntryCard(
                news: snapshot.data![index],
                onTap: () {
                  // Navigate to news detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(
                        news: snapshot.data![index],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
