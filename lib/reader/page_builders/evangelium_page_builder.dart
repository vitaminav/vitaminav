import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/database.dart';
import '../../common/entities.dart';
import '../reader_screen.dart';

/// A [ReaderPageBuilder] function that prints an evangelium passage page,
/// dynamically loading content from the database
ReaderPageBuilder evangeliumPageBuilder = ({
  @required List<Identifier> dbIds,
  @required int index,
  ScrollController scrollController,
  void Function() scrollNext,
  void Function() scrollPrev,
}) {
  assert(dbIds[index] != null);

  final future = dbFuture.then((db) => db.query('evangelium',
      where: 'id = ?', whereArgs: [dbIds[index].id]).then((value) => value[0]));

  return FutureBuilder<Map<String, dynamic>>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.data == null) {
        return Container();
      }

      final String title = snapshot.data['title'];
      final String quote = snapshot.data['quote'];
      final String book = snapshot.data['book'];
      final int chapter = snapshot.data['chapter'];
      final int verse0 = snapshot.data['verse0'];
      final int verse1 = snapshot.data['verse1'];
      final String comment = snapshot.data['comment'];

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
                  fontSize: DefaultTextStyle.of(context).style.fontSize * 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: scrollPrev,
                ),
                Expanded(
                  child: Text(
                    '$book $chapter, $verse0-$verse1',
                    style: TextStyle(
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 1.2,
                        color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: scrollNext,
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              child: Text(
                quote,
                style: TextStyle(
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.justify,
              ),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(width: 2, color: Colors.grey),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              comment,
              style: TextStyle(height: 1.5),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 100),
          ],
        ),
      );
    },
  );
};
