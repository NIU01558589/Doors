import 'dart:async';

import 'package:flutter/material.dart';
import 'tutorial_acs/tree.dart';
import 'requests.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl_utils/intl_utils.dart';
import 'Language.dart';
import 'package:provider/provider.dart';

import 'tutorial_acs/screen_partition.dart';



class ScreenSpace extends StatefulWidget {
  final String id;
  const ScreenSpace({super.key, required this.id});

  @override
  State<ScreenSpace> createState() => _ScreenSpaceState();
}

class _ScreenSpaceState extends State<ScreenSpace> {
  late Future<Tree> futureTree;
  late Language language;

  @override
  void initState() {
    super.initState();
    futureTree = getTree(widget.id);


  }




  // future with listview
// https://medium.com/nonstopio/flutter-future-builder-with-list-view-builder-d7212314e8c9
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text(snapshot.data!.root.id),
              actions: <Widget>[
                IconButton(icon: const Icon(Icons.home), onPressed: () {
                  while(Navigator.of(context).canPop()) {
                    print("pop");
                    Navigator.of(context).pop();
                  }
                }
                ),
                IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () {
                    _showLanguage(context);
                  },
                ),

                //TODO other actions
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.root.children.length,
              itemBuilder: (BuildContext context, int i) =>
                  _buildRow(snapshot.data!.root.children[i], i),
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  void _showLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            children: [
              _buildLanguageButton(context, 'English', 'en'),
              _buildLanguageButton(context, 'Español', 'es'),
              _buildLanguageButton(context, 'Català', 'ca'),
              // Agrega más botones para otros idiomas según sea necesario
            ],
          ),
        );
      },
    );
  }



  Widget _buildLanguageButton(BuildContext context, String language, String locale) {
    final languageProvider = Provider.of<Language>(context);

    return TextButton(
      onPressed: () {
        languageProvider.changeLanguage(Locale(locale));
        Navigator.of(context).pop(); // Cierra el diálogo
      },
      child: Text(language),
    );
  }

  Widget _buildRow(Door door, int index) {
    return ListTile(
      title: Row(
        children: [
          Icon(
            door.state == 'locked' ? Icons.lock : Icons.lock_open,
            color: door.state == 'locked' ? Colors.red : Colors.green,
          ),
          SizedBox(width: 8),
          Text('${door.id}'),
        ],
      ),
      subtitle: door.state == 'locked'
          ? null
          : Row(
        mainAxisAlignment: MainAxisAlignment.start, // Alinea al principio
        children: [
          SizedBox(width: 40), // Ajusta según sea necesario
          Icon(
            door.closed == false ? Icons.door_front_door_outlined : Icons.sensor_door_rounded,
            color: door.closed == false ? Colors.green : Colors.red,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: ()  async {
              await unlockDoor(door);
              futureTree = getTree(widget.id);
              setState(() {});

              print(futureTree);


            },
            child: Text(AppLocalizations.of(context)!.unlock),
          ),
          SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              await lockDoor(door);
              futureTree = getTree(widget.id);
              setState(() {});



            },
            child: Text(AppLocalizations.of(context)!.lock),
          ),
          if (door.state == 'unlocked') ...[
            SizedBox(width: 8),
            TextButton(
              onPressed: () {
                openDoor(door);

              },
              child: Row(
                children: [
                  Icon(Icons.door_front_door_outlined, color: Colors.green),
                  SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.open),
                ],
              ),
            ),
            SizedBox(width: 8),
            TextButton(
              onPressed: () {
                closeDoor(door);

              },
              child: Row(
                children: [
                  Icon(Icons.sensor_door_rounded, color: Colors.red),
                  SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.close),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

}




