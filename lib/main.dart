import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> filenames = [];
  List<String> choices = [];

  Future<List<String>> getAssetImagePaths() async {
    List<String> imagePaths = [];

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

      for (final path in manifestMap.keys) {
        if (path.startsWith('images/') &&
            (path.endsWith('.png') || path.endsWith('.JPG'))) {
          imagePaths.add(path);
          debugPrint(path);
        }
      }
    } catch (e) {
      print('Error loading asset manifest: $e');
    }

    return imagePaths;
  }

  void _setChoices() {
    debugPrint('setting choices ${filenames.length}');

    final random = Random();
    choices = [];
    while (choices.length < 4) {
      final randomIndex = random.nextInt(filenames.length);
      final randomString = filenames[randomIndex];

      if (!choices.contains(randomString)) {
        choices.add(randomString);
        debugPrint(randomString);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('in init function');
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _loadAssetImagePaths();
    _setChoices();
    debugPrint('in init ${filenames.length}');
  }

  Future<void> _loadAssetImagePaths() async {
    List<String> assetImagePaths = await getAssetImagePaths();
    setState(() {
      filenames = assetImagePaths;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('top'),
            Image(image: AssetImage('images/Sheppard_Matt.JPG')),
            Text('bottom'),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: _incrementCounter,
                    child: Text(filenames.isNotEmpty ? choices[0] : ''),
                  ),
                  TextButton(
                    onPressed: _incrementCounter,
                    child: Text(filenames.isNotEmpty ? choices[1] : ''),
                  ),
                ],
              ),
            ),
            Text('after row'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
