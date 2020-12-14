import 'dart:ui';

import 'package:flutter/material.dart';

import '../common/database.dart';
import '../common/entities.dart';
import '../common/extensions.dart';
import '../common/widgets.dart';
import '../reader/page_builders/via_crucis_page_builder.dart';
import '../reader/reader_screen.dart';
import 'viacrucis_strings.dart';

/// A screen that displays the via crucis stations' artistic representations
/// in a grid layout, along with a short overview and biography of the author
class ViaCrucisScreen extends StatefulWidget {
  /// Creates a screen that displays the stations of the via crucis
  ViaCrucisScreen({Key key}) : super(key: key);

  @override
  _ViaCrucisScreen createState() => _ViaCrucisScreen();
}

class _ViaCrucisScreen extends State<ViaCrucisScreen> {
  List<ViaCrucisItem> items = [];

  void initState() {
    super.initState();

    _loadContents();
  }

  void _loadContents() async {
    final viaCrucisItems =
        await (await dbFuture).query('viacrucis', orderBy: 'number ASC');

    setState(() {
      items = viaCrucisItems.asMap().map(_parseItem).values.toList();
    });
  }

  MapEntry<int, ViaCrucisItem> _parseItem(int index, Map<String, dynamic> row) {
    return MapEntry(
      index,
      ViaCrucisItem(
        dbId: Identifier(row['id']),
        image: AssetImage('assets/via_crucis/${row['image']}'),
        number: row['number'],
        title: row['title'],
        author: row['author'],
        caption: row['caption'],
        comment: row['comment'],
        copyright: row['copyright'],
        onSelect: () => openReader(index),
      ),
    );
  }

  Widget _buildCard(ViaCrucisItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: item,
            child: Image(
              fit: BoxFit.cover,
              image: item.image,
            ),
          ),
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0),
                    Colors.black.withOpacity(0.7)
                  ]),
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                item.number.roman,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'RobotoSlab',
                ),
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: item.onSelect,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Via Crucis'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: [
                ExpansionTile(
                  title: Text('Descrizione generale delle tavole'),
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                      child: EmbeddedHtml(
                        ViaCrucisStrings.viaCrucisOverview,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text('Biografia dell\'autrice'),
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                      child: EmbeddedHtml(
                        ViaCrucisStrings.viaCrucisBio,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              children: items.map(_buildCard).toList(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                ViaCrucisStrings.viaCrucisCopyright,
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          SliverPadding(
            padding: new EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }

  /// Open the reader at a given page index.
  ///
  /// Note that unlike what appens in a common [TableOfContentsScreen], in
  /// this case the page builder function is given all the contents of the
  /// page as a [ViaCrucisItem], so it doesn't need to load any additional
  /// content from the database. Indeed the number of items is limited by
  /// the nature of the contents (a via crucis only has 14 stations) so
  /// scalability is not needed, and the absence of asynchrnous loading allows
  /// to use Hero animations.
  void openReader(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          title: 'Via Crucis',
          dbIds: items.map((e) => e.dbId).toList(),
          pageBuilder: ({
            @required List<Identifier> dbIds,
            @required int index,
            ScrollController scrollController,
            void Function() scrollNext,
            void Function() scrollPrev,
          }) =>
              viaCrucisPageBuilder(
            items: items,
            index: index,
            scrollController: scrollController,
          ),
          initialPage: index,
          initialScroll: 0,
        ),
      ),
    );
  }
}

class ViaCrucisItem {
  final ImageProvider image;
  final int number;
  final void Function() onSelect;
  final Identifier dbId;
  final String title;
  final String caption;
  final String comment;
  final String author;
  final String copyright;

  ViaCrucisItem({
    @required this.caption,
    @required this.comment,
    @required this.author,
    @required this.copyright,
    @required this.image,
    @required this.dbId,
    @required this.number,
    @required this.title,
    this.onSelect,
  });
}
