import 'package:flutter/material.dart';

import '../common/widgets.dart';

/// A widget used in the home screen to display an expandable submenu for topic
/// categories, given a [Future<List>] of the categories, as obtained
/// asynchronously from the SQLite database.
class SubmenuTile extends StatelessWidget {
  final Future<List<String>> futureCategories;
  final void Function(String category) onOpen;
  final IconAsset icon;
  final String title;

  /// Creates a [SubmenuTile] to display the categories of a topic in the home
  /// screen. The categories are provided as a a future list `futureCategories`.
  /// A tap on a category will fire the `onOpen` callback, passing the category
  /// name as argument.
  ///
  /// A `title` and an `icon` for the tile should also be provided.
  const SubmenuTile(
      {Key key,
      @required this.futureCategories,
      @required this.onOpen,
      @required this.icon,
      @required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: futureCategories,
      builder: (context, snapshot) {
        return ExpansionTile(
          leading: icon,
          title: Text(title, textAlign: TextAlign.center),
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ButtonTheme(
                colorScheme: ColorScheme.dark(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: !snapshot.hasData
                      ? []
                      : snapshot.data
                          .map(
                            (category) => FlatButton(
                              onPressed: () => onOpen(category),
                              child: Text(category),
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ],
        );
      },
      initialData: [],
    );
  }
}
