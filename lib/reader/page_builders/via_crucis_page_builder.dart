import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vitaminav/navigation/via_crucis_screen.dart';

import '../../common/extensions.dart';

/// A [ReaderPageBuilder] function that displays a station of the via crucis
Widget viaCrucisPageBuilder({
  @required List<dynamic> items,
  @required int index,
  ScrollController scrollController,
  void Function() scrollNext,
  void Function() scrollPrev,
}) {
  final item = items[index] as ViaCrucisItem;
  assert(item != null);

  final image = item.image;
  final number = item.number;
  final title = item.title;
  final caption = item.caption;
  final comment = item.comment;
  final author = item.author;
  final copyright = item.copyright;

  return Builder(
    builder: (BuildContext context) {
      return CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width,
            stretch: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: <StretchMode>[
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              background: Hero(
                tag: item,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Image(
                      image: image,
                      fit: BoxFit.cover,
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Image(
                        image: image,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.grey))),
                    child: Text(
                      caption,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    number.roman,
                    style: TextStyle(
                      fontSize: DefaultTextStyle.of(context).style.fontSize * 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          DefaultTextStyle.of(context).style.fontSize * 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Text(
                    comment,
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 20),
                  Text(
                    author,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 20),
                  Text(
                    copyright,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
