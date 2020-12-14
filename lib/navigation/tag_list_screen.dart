import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../common/database.dart';
import '../common/entities.dart';
import '../reader/page_builders/evangelium_page_builder.dart';
import 'table_of_contents_screen.dart';

/// A special list view screen used to display the available tags for evangelium
/// readings, obtained directly from the database
class TagListScreen extends StatefulWidget {
  /// Creates a screen that displays all the available tags for evangelium readings
  TagListScreen({Key key}) : super(key: key);

  @override
  _TagListScreen createState() => _TagListScreen();
}

class _TagListScreen extends State<TagListScreen> {
  List<TableOfContentsItem> tags = [];

  void initState() {
    super.initState();

    _loadContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temi'),
      ),
      body: ListView(
        children: tags.map(_buildTile).toList(),
      ),
    );
  }

  void _loadContents() async {
    final evangeliumTags = await (await dbFuture)
        .query('evangelium_tags', groupBy: 'tag', orderBy: 'tag ASC');

    setState(() {
      tags = evangeliumTags.map(_parseItem).toList();
    });
  }

  TableOfContentsItem _parseItem(Map<String, dynamic> row) {
    return TableOfContentsItem(
        title: '${row['tag']}',
        onSelect: () => {openTag(row['tag'].toString())});
  }

  Widget _buildTile(TableOfContentsItem item) {
    return ListTile(
      leading: Icon(FeatherIcons.hash),
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle) : null,
      onTap: item.onSelect,
    );
  }

  void openTag(String tag) {
    final itemsFuture = dbFuture
        .then(
          (db) => db.query(
              'evangelium INNER JOIN evangelium_tags ON evangelium.id=evangelium_tags.evangelium_id',
              columns: ['*', 'evangelium.id as id'],
              where: 'evangelium_tags.tag = ?',
              whereArgs: [tag],
              orderBy: 'verse0 ASC, chapter ASC, book ASC'),
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
          title: '#$tag',
          futureItems: itemsFuture,
          pageBuilder: evangeliumPageBuilder,
        ),
      ),
    );
  }
}

class TableOfContentsItem {
  final String title;
  final String subtitle;
  final void Function() onSelect;

  TableOfContentsItem({@required this.title, this.subtitle, this.onSelect});
}
