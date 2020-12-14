import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vitaminav/Reader/reader_screen.dart';
import 'package:vitaminav/common/vitaminav_preferences.dart';

import '../common/entities.dart';
import '../common/extensions.dart';

/// A generic table of contents that displays a list of items that can be opened
/// in the reader, and optionally keeps track of the last read item
class TableOfContentsScreen extends StatefulWidget {
  final String title;
  final Future<List<ContentItem>> futureItems;
  final ReaderPageBuilder pageBuilder;
  final String savePrefix;

  /// Creates a table of contents, given a `title`, a future list `futureItems`
  /// of [ContentItem] items and a `pageBuilder` function that will be used
  /// by the reader screen to display the given content.
  ///
  /// A `savePrefix` can be provided to keep track in the sahred preferences
  /// of the last read item and scroll position for a given table of contents.
  /// An additional item will appear at the beginning of the list to allow
  /// the user to resume reading, if available.
  TableOfContentsScreen({
    Key key,
    @required this.title,
    @required this.futureItems,
    @required this.pageBuilder,
    this.savePrefix,
  }) : super(key: key);

  @override
  _TableOfContentsScreenState createState() => _TableOfContentsScreenState();
}

class _TableOfContentsScreenState extends State<TableOfContentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<ContentItem>>(
        future: widget.futureItems,
        initialData: [],
        builder: (context, snapshot) {
          final List<ContentItem> items = snapshot.hasData ? snapshot.data : [];
          return ListView(children: [
            ...(snapshot.hasData &&
                    snapshot.data.length > 0 &&
                    widget.savePrefix != null &&
                    VitaminaVPreferences.of(context)
                            .getSavedIndex(widget.savePrefix) !=
                        null
                ? [_buildKeepReadingTile(context, snapshot.data), Divider()]
                : []),
            ...items
                .asMap()
                .map<int, Widget>(
                  (int index, ContentItem item) => MapEntry(
                    index,
                    _buildTile(context, items, index),
                  ),
                )
                .values
                .toList(),
          ]);
        },
      ),
    );
  }

  Widget _buildKeepReadingTile(BuildContext context, List<ContentItem> items) {
    final safeSavedIndex = VitaminaVPreferences.of(context)
        .getSavedIndex(widget.savePrefix)
        .sat(lower: 0, upper: items.length - 1);
    final safeSavedScroll =
        VitaminaVPreferences.of(context).getSavedScroll(widget.savePrefix);
    return ListTile(
      trailing: Icon(
        Icons.bookmark,
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).primaryColor
            : Colors.grey[500],
      ),
      title: Text(
        'Continua a leggere…',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      subtitle: Text('Riprendi da ${items[safeSavedIndex].subtitle}'),
      onTap: () => _openReader(
        context,
        items,
        safeSavedIndex,
        scroll: safeSavedScroll,
      ),
    );
  }

  Widget _buildTile(BuildContext context, List<ContentItem> items, int index) {
    return ListTile(
      title: Text(items[index].title),
      subtitle:
          items[index].subtitle != null ? Text(items[index].subtitle) : null,
      onTap: () => _openReader(context, items, index),
    );
  }

  void _openReader(BuildContext context, List<ContentItem> items, int index,
      {double scroll}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          scrollOrIndexChanged: widget.savePrefix != null
              ? (int index, double scroll) => _saveState(context, index, scroll)
              : null,
          title: widget.title,
          dbIds: items.map((e) => e.dbId).toList(),
          pageBuilder: widget.pageBuilder,
          initialPage: index,
          initialScroll: scroll ?? 0,
        ),
      ),
    );
  }

  void _saveState(BuildContext context, int index, double scroll) {
    VitaminaVPreferences.of(context).setSavedIndex(widget.savePrefix, index);
    VitaminaVPreferences.of(context).setSavedScroll(widget.savePrefix, scroll);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ContentItem {
  final String title;
  final String subtitle;
  final int index;
  final Identifier dbId;

  ContentItem({
    @required this.dbId,
    @required this.title,
    this.subtitle,
    this.index,
  });
}
