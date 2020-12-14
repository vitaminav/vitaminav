import 'package:flutter/material.dart';

import '../common/database.dart';
import '../common/entities.dart';
import '../common/extensions.dart';
import '../common/widgets.dart';
import '../navigation/table_of_contents_screen.dart';
import '../navigation/tag_list_screen.dart';
import '../navigation/via_crucis_screen.dart';
import '../reader/page_builders/evangelium_page_builder.dart';
import '../reader/page_builders/pontifex_page_builder.dart';
import '../reader/page_builders/prayer_page_builder.dart';
import '../reader/page_builders/saint_page_builder.dart';
import 'home_card.dart';
import 'home_drawer.dart';
import 'submenu_tile.dart';

/// The home screen of VitaminaV, that displays all the available topics and,
/// when needed, submenus with categories
class HomeScreen extends StatelessWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : Colors.black,
      drawer: HomeDrawer(),
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'VitaminaV',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: ListView(
        padding: EdgeInsets.all(5),
        children: [
          HomeCard(
            child: _buildEvangeliumTile(context),
          ),
          HomeCard(
            child: _buildPontifexTile(context),
          ),
          HomeCard(
            child: ListTile(
              leading: IconAsset('assets/icons/saints.png'),
              title: Text('Vite di Santi', textAlign: TextAlign.center),
              trailing: Icon(null),
              onTap: () => openSaints(context),
            ),
          ),
          HomeCard(
            child: ListTile(
              leading: IconAsset('assets/icons/viacrucis.png'),
              title: Text('Via Crucis', textAlign: TextAlign.center),
              trailing: Icon(null),
              onTap: () => openViaCrucis(context),
            ),
          ),
          HomeCard(
            child: _buildPrayersTile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEvangeliumTile(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: Text(
            'Commenti al vangelo',
            textAlign: TextAlign.center,
          ),
          leading: IconAsset('assets/icons/evangelium.png'),
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ButtonTheme(
                colorScheme: ColorScheme.dark(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () =>
                                openEvangelium(context, EvangeliumBook.Mt),
                            child: Text('Matteo'),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: FlatButton(
                            onPressed: () =>
                                openEvangelium(context, EvangeliumBook.Mc),
                            child: Text('Marco'),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () =>
                                openEvangelium(context, EvangeliumBook.Lc),
                            child: Text('Luca'),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: FlatButton(
                            onPressed: () =>
                                openEvangelium(context, EvangeliumBook.Gv),
                            child: Text('Giovanni'),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    FlatButton(
                      onPressed: () => openTagList(context),
                      child: Text('# Temi'),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPontifexTile(BuildContext context) {
    final futureCateogories = dbFuture
        .then((db) => db.query('pontifex', columns: ['author'], distinct: true))
        .then((rows) => rows.map((e) => e['author'].toString()).toList());
    return SubmenuTile(
      icon: IconAsset('assets/icons/pontifex.png'),
      title: 'Testi del Santo Padre',
      futureCategories: futureCateogories,
      onOpen: (author) => openPontifex(context, author),
    );
  }

  Widget _buildPrayersTile(BuildContext context) {
    final futureCateogories = dbFuture
        .then(
            (db) => db.query('prayers', columns: ['category'], distinct: true))
        .then((rows) => rows.map((e) => e['category'].toString()).toList());
    return SubmenuTile(
        icon: IconAsset('assets/icons/prayers.png'),
        title: 'Preghiere',
        futureCategories: futureCateogories,
        onOpen: (category) => openPrayers(context, category));
  }

  void openEvangelium(BuildContext context, EvangeliumBook book) {
    final bookReferenceString = {
      EvangeliumBook.Gv: 'Gv',
      EvangeliumBook.Lc: 'Lc',
      EvangeliumBook.Mc: 'Mc',
      EvangeliumBook.Mt: 'Mt'
    }[book];

    final bookTitle = {
      EvangeliumBook.Gv: 'Giovanni',
      EvangeliumBook.Lc: 'Luca',
      EvangeliumBook.Mc: 'Marco',
      EvangeliumBook.Mt: 'Matteo'
    }[book];

    final itemsFuture = dbFuture
        .then(
          (db) => db.query('evangelium',
              where: 'book = ?',
              whereArgs: [bookReferenceString],
              orderBy: 'chapter ASC, verse0 ASC'),
        )
        .then(
          (rows) => rows
              .asMap()
              .map(
                (int index, row) => MapEntry(
                  index,
                  ContentItem(
                    dbId: Identifier(row['id']),
                    title: row['title'].toString(),
                    subtitle:
                        '${row['book']} ${row['chapter']}, ${row['verse0']}-${row['verse1']}',
                    index: index,
                  ),
                ),
              )
              .values
              .toList(),
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableOfContentsScreen(
          title: bookTitle,
          futureItems: itemsFuture,
          savePrefix: bookReferenceString,
          pageBuilder: evangeliumPageBuilder,
        ),
      ),
    );
  }

  void openPontifex(BuildContext context, String author) {
    final authors = dbFuture
        .then(
          (db) => db.query('pontifex',
              where: 'author = ?', whereArgs: [author], orderBy: 'id ASC'),
        )
        .then(
          (rows) => rows
              .asMap()
              .map(
                (int index, row) => MapEntry(
                  index,
                  ContentItem(
                    dbId: Identifier(row['id']),
                    title: row['title'].toString(),
                    subtitle: DateTime.fromMillisecondsSinceEpoch(row['date'])
                        .toItalianString(),
                    index: index,
                  ),
                ),
              )
              .values
              .toList(),
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableOfContentsScreen(
            title: author,
            savePrefix: author.hashCode.toRadixString(16),
            futureItems: authors,
            pageBuilder: pontifexPageBuilder),
      ),
    );
  }

  void openSaints(BuildContext context) {
    final prayersItems = dbFuture
        .then(
          (db) => db.query('saints', orderBy: 'id ASC'),
        )
        .then(
          (rows) => rows
              .asMap()
              .map(
                (int index, row) => MapEntry(
                  index,
                  ContentItem(
                    dbId: Identifier(row['id']),
                    title: row['title'].toString(),
                    subtitle: row['subtitle'].toString(),
                    index: index,
                  ),
                ),
              )
              .values
              .toList(),
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableOfContentsScreen(
          title: 'Vite di santi',
          futureItems: prayersItems,
          pageBuilder: saintPageBuilder,
        ),
      ),
    );
  }

  void openViaCrucis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViaCrucisScreen()),
    );
  }

  void openPrayers(BuildContext context, String category) {
    final prayersItems = dbFuture
        .then(
          (db) => db.query('prayers',
              where: 'category = ?', whereArgs: [category], orderBy: 'id ASC'),
        )
        .then(
          (rows) => rows
              .asMap()
              .map(
                (int index, row) => MapEntry(
                  index,
                  ContentItem(
                    dbId: Identifier(row['id']),
                    title: row['title'].toString(),
                    index: index,
                  ),
                ),
              )
              .values
              .toList(),
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableOfContentsScreen(
          title: category,
          futureItems: prayersItems,
          pageBuilder: prayerPageBuilder,
        ),
      ),
    );
  }

  void openTagList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TagListScreen()),
    );
  }
}
