import 'package:flutter/material.dart';

import '../common/widgets.dart';

/// The credits screen
class CreditsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crediti'),
      ),
      body: Container(
        child: ListView(
          children: [
            ListTile(
              title: Text('Autore', textAlign: TextAlign.center),
              subtitle: Text('App author', textAlign: TextAlign.center),
            ),
            ListTile(
              leading: IconAsset('assets/icons/pontifex.png'),
              title: Text('Testi del Santo Padre'),
              subtitle: Text('© Copyright …'),
            ),
            ListTile(
              leading: IconAsset('assets/icons/viacrucis.png'),
              title: Text('Tavole della Via Crucis'),
              subtitle: Text('© Copyright …'),
            ),
            ListTile(
              leading: IconAsset('assets/icons/evangelium.png'),
              title: Text('Commenti al Vangelo'),
              subtitle: Text('© Copyright …'),
            ),
            ListTile(
              leading: IconAsset('assets/icons/saints.png'),
              title: Text('Vite di Santi'),
              subtitle: Text('© Copyright …'),
            ),
            ListTile(
              leading: IconAsset('assets/icons/prayers.png'),
              title: Text('Preghiere'),
              subtitle: Text('© Copyright …'),
            ),
            ListTile(
              leading: IconAsset('assets/logo.png'),
              title: Text('Logo'),
              subtitle: Text('© Copyright …'),
            ),
            ListTile(
              leading: Icon(Icons.code, size: 40),
              title: Text('Programmazione'),
              subtitle: Text('Questo è un progetto open source.'),
            ),
          ],
        ),
      ),
    );
  }
}
