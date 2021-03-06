import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/database.dart';
import '../../common/entities.dart';
import '../../common/widgets.dart';
import '../reader_screen.dart';

/// A [ReaderPageBuilder] function that prints a page for a prayer,
/// dynamically loading content from the database
ReaderPageBuilder prayerPageBuilder = ({
  @required List<Identifier> dbIds,
  @required int index,
  ScrollController scrollController,
  void Function() scrollNext,
  void Function() scrollPrev,
}) {
  assert(dbIds[index] != null);

  final future = dbFuture.then((db) => db.query('prayers',
      where: 'id = ?', whereArgs: [dbIds[index].id]).then((value) => value[0]));

  return FutureBuilder<Map<String, dynamic>>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.data == null) {
        return Container();
      }

      final String title = snapshot.data['title'];
      final String text = snapshot.data['text'];

      return SingleChildScrollView(
        padding: EdgeInsets.all(15),
        controller: scrollController,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: DefaultTextStyle.of(context).style.fontSize * 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 40,
            ),
            EmbeddedHtml(
              text,
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 100),
          ],
        ),
      );
    },
  );
};
