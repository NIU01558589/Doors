import 'dart:async';

import 'package:flutter/material.dart';
import '../screen_space.dart';
import 'tree.dart';
import 'package:fita3_frontend/requests.dart';
import 'package:provider/provider.dart';
import '../Language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';




class ScreenPartition extends StatefulWidget {
  final String id;

  const ScreenPartition({super.key, required this.id});

  @override
  State<ScreenPartition> createState() => _ScreenPartitionState();
}

class _ScreenPartitionState extends State<ScreenPartition> {
  late Future<Tree> futureTree;
  late Timer _timer;
  static const int refreshPeriod = 6;
  late Language language;
  List<String> recentAreas = [];


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
                  // TODO go home page = root
                ),
                IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () {
                    _showLanguage(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () {
                    _showRecentAreas(context);

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
  void _showRecentAreas(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Areas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select an area'),
                value: null, // Aquí puedes establecer el valor seleccionado si es necesario
                onChanged: (String? selectedArea) {
                  if (selectedArea != null) {
                    Navigator.of(context).pop();
                    //_navigateToRecentArea(selectedArea);
                  }
                },
                items: recentAreas.map<DropdownMenuItem<String>>((String areaId) {
                  return DropdownMenuItem<String>(
                    value: areaId,
                    child: Text(areaId),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToRecentArea(String areaId) {

    if (areaId is Partition) {
      _navigateDownPartition(areaId);
    } else {
      _navigateDownSpace(areaId);
    }
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
        Navigator.of(context).pop();
      },
      child: Text(language),
    );
  }

  @override
  void initState() {
    super.initState();
    futureTree = getTree(widget.id);
    _activateTimer();
  }

  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: refreshPeriod), (Timer t) {
      futureTree = getTree(widget.id);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildRow(Area area, int index) {
    assert (area is Partition || area is Space);
    if (area is Partition) {
      return ListTile(
        leading: Icon(Icons.home_work_outlined, color: Color(0xFFEDE7F6)),
        title: Text('${area.id}'),
        onTap: () => _navigateDownPartition(area.id),
        // TODO, navigate down to show children areas
      );
    } else {
      return ListTile(
        leading: Icon(Icons.add_home_outlined, color: Color(0xFFEDE7F6)),
        title:  Row(
          children: [
            Text('${area.id}'),
            Spacer(),
            Icon(Icons.door_front_door_outlined, color: Colors.green),
            FutureBuilder<List<Door>>(
              future: _getDoorsFromSpace(area.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildDoorStatusWidget(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text("Error loading doors: ${snapshot.error}");
                }
                return Container(); // or a loading indicator
              },
            ),
            ],
        ),
        onTap: () => _navigateDownSpace(area.id),
        // TODO, navigate down to show children doors
      );
    }
  }
  Future<List<Door>> _getDoorsFromSpace(String spaceId) async {
    return [];
  }
  Widget _buildDoorStatusWidget(List<Door> children) {
    String doorStatus = getDoorState(children.cast<Area>());
    Color statusColor = getStatusColor(doorStatus);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        doorStatus,
        style: TextStyle(color: statusColor),
      ),
    );
  }

  Color getStatusColor(String doorStatus) {
    switch (doorStatus) {
      case "Locked":
        return Colors.red;
      case "Unlocked":
        return Colors.green;
      case "Locked and unlocked":
        return Colors.orange;
      default:
        return Colors.black; // Ajusta según tus necesidades
    }
  }

  void _refresh() async {
    futureTree = getTree(widget.id);
    setState(() {});
  }

  void _navigateDownPartition(String childId) {
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
    // but doing _refresh(); without then() after push may also work
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => ScreenPartition(id: childId),
    ))
        .then((var value) {
          _activateTimer();
          _refresh();
          _updateRecentAreas(childId);
    });
  }

  void _navigateDownSpace(String childId) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => ScreenSpace(id: childId),
    ))
        .then((var value) {
          _activateTimer();
          _refresh();
    });
  }
  void _updateRecentAreas(String areaId) {
    setState(() {
      if (!recentAreas.contains(areaId)) {
        recentAreas.insert(0, areaId);

        if (recentAreas.length > 3) {
          recentAreas = recentAreas.sublist(0, 3);
        }
      }
    });
  }

  String getDoorState(List<Area> children) {
    int locked = 0;
    int unlocked = 0;

    for (Area area in children) {
      if (area is Space) {
        for (Door door in area.children) {
          if (door.state == 'locked') {
            locked++;
          } else if (door.state == 'unlocked') {
            unlocked++;
          }
        }
      }
    }

    if (locked > 0 && unlocked > 0) {
      return "Locked and unlocked";
    } else if (locked > 0) {
      return "Locked";
    } else if (unlocked > 0) {
      return "Unlocked";
    }

    return "Unlocked";
  }

}
