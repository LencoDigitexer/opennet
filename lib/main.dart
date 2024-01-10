import 'package:flutter/cupertino.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:enough_convert/enough_convert.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'OpenNet - Новости',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RssFeed? feed;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('https://www.opennet.ru/opennews/opennews_full.rss'),
      headers: {'Content-Type': 'application/rss+xml; charset=koi8-r'},
    );

    if (response.statusCode == 200) {
      final encodedBytes = response.bodyBytes;
      const codec = Koi8rCodec(allowInvalid: false);
      final encoded = codec.decode(encodedBytes);

      final document = xml.parse(encoded);
      final rssElement = document.findElements('rss').first;
      setState(() {
        feed = RssFeed.parse(rssElement.toXmlString());
      });
    } else {
      throw Exception('Failed to load RSS feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('OpenNet - Новости'),
      ),
      child: feed == null
          ? const Center(child: CupertinoActivityIndicator())
          : ListView.builder(
              itemCount: feed?.items?.length ?? 0,
              itemBuilder: (context, index) {
                final List<RssItem>? items = feed?.items;
                if (items != null && index < items.length) {
                  final item = items[index];
                  return CupertinoButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => NewsDetailScreen(item),
                        ),
                      );
                    },
                    child: CupertinoListTile(
                      title: Text(
                        item.title ?? '',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        softWrap: true,
                        maxLines:
                            2, // Set the maximum number of lines before wrapping
                        overflow: TextOverflow
                            .ellipsis, // Display ellipsis (...) when text overflows
                      ),
                      subtitle: Text(item.pubDate?.toString() ?? ''),
                      padding: EdgeInsets.zero,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final RssItem item;

  NewsDetailScreen(this.item);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(item.title ?? ''),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Text(
                item.title ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                item.pubDate?.toString() ?? '',
                style: const TextStyle(
                    fontSize: 14, color: CupertinoColors.systemGrey),
              ),
              const SizedBox(height: 16),
              HtmlWidget(item.description ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}
