import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart' as htmlStyle;

// This file contains miscellaneous widgets that are used across different screens

/// A widget shaped and sized like a common [Icon] but built form an asset image
class IconAsset extends StatelessWidget {
  final String asset;
  final num size;

  const IconAsset(this.asset, {this.size = 50, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
        height: size.toDouble(),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Image.asset(
          asset,
          fit: BoxFit.fitHeight,
        ),
      );
}

/// A widget that renders simple HTML, inheriting style and text alignment from
/// context, if not specifically provided
class EmbeddedHtml extends StatelessWidget {
  final TextStyle textStyle;
  final TextAlign textAlign;
  final String data;

  /// Creates a widget that renders simple HTML, from an `html` [String].
  /// Default `textStyle` and `textAlign` can be passed, or otherwise are taken
  /// from context. If `preserveLikeBreak` is `true` line breaks in the html
  /// code are automatically converted to `<br/>` tags.
  EmbeddedHtml(
    String html, {
    this.textStyle,
    this.textAlign,
    bool preserveLineBreak = true,
  }) : this.data = preserveLineBreak ? html.split('\n').join('<br/>') : html;

  Widget build(BuildContext context) {
    final textStyle = this.textStyle ?? DefaultTextStyle.of(context).style;
    final textAlign = this.textAlign ?? DefaultTextStyle.of(context).textAlign;

    final style = {
      'html': htmlStyle.Style(
        fontFamily: textStyle.fontFamily,
        fontSize: htmlStyle.FontSize(textStyle.fontSize),
        textAlign: textAlign,
      )
    };

    return Html(data: data, style: style);
  }
}
