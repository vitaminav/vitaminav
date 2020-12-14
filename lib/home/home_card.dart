import 'package:flutter/material.dart';

/// A slightly customized card widget for the home screen
class HomeCard extends StatelessWidget {
  final Widget child;
  final Widget icon;

  /// Creates a slightly customized card widget for the home screen
  const HomeCard({Key key, this.child, this.icon}) : super(key: key);
  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          child: child,
        ),
      );
}
