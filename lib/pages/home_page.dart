import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:band_app/data/data.dart';
import 'package:band_app/models/band_model.dart';
import 'package:band_app/pages/noitem_page.dart';
import 'package:band_app/providers/socket_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', (data) => _handleActiveBands(data));
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  _handleActiveBands(data) {
    bands = (data as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Votaciones ',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serverStatus != ServerStatus.online
                ? BounceInDown(
                    duration: const Duration(milliseconds: 500),
                    from: 10,
                    child: const Icon(
                      Icons.offline_bolt,
                      color: Colors.red,
                    ),
                  )
                : BounceInDown(
                    duration: const Duration(milliseconds: 500),
                    from: 10,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green[200],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewBand(context),
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            (bands.isNotEmpty) ? _showGraph() : const NoItemWidget(),
            const SizedBox(height: 30),
            ...bands
                .map((e) => _BandsWisget(
                      band: e,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  addNewBand(BuildContext context) {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Agregar banda'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la banda',
            ),
            onChanged: (value) {},
          ),
          actions: [
            MaterialButton(
              color: Colors.indigo,
              child: const Text('Add'),
              onPressed: () {
                addBandNameToList(name: textController.text);
              },
              elevation: 5,
              textColor: Colors.white,
            ),
          ],
        ),
      );
    }
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Agregar banda'),
        content: CupertinoTextField(
          controller: textController,
          placeholder: 'Nombre de la banda',
          onChanged: (value) {},
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Add'),
            onPressed: () => addBandNameToList(name: textController.text),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Dismiss'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    // ignore: avoid_function_literals_in_foreach_calls
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartValuesOptions: const ChartValuesOptions(
          decimalPlaces: 0,
          showChartValuesInPercentage: true,
        ),
      ),
    );
  }

  void addBandNameToList({required String name}) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
      Navigator.pop(context);
    }
  }
}

class _BandsWisget extends StatefulWidget {
  final Band band;
  const _BandsWisget({
    Key? key,
    required this.band,
  }) : super(key: key);

  @override
  State<_BandsWisget> createState() => _BandsWisgetState();
}

class _BandsWisgetState extends State<_BandsWisget> {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: true);

    return Dismissible(
      onDismissed: (direction) =>
          socketService.socket.emit('delete-band', {'id': widget.band.id}),
      key: Key(widget.band.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.only(left: 10),
        color: Colors.red,
        child: const Center(
          child: Text(
            'Delete Band',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      child: ListTile(
        trailing: Text(
          widget.band.votes.toString(),
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit('vote-band', {
          'id': widget.band.id,
        }),
        title: Text(widget.band.name),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            widget.band.name.substring(0, 2),
          ),
        ),
      ),
    );
  }
}
