import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fluttertoast/fluttertoast.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int correct = 0;
  int incorrect = 0;
  List<String> filenames = [];
  List<String> choices = [];
  String correct_choice = '';
  String score = 'score';
  late BuildContext _context;

  Future<List<String>> getAssetImagePaths() async {
    List<String> imagePaths = [];

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

      for (final path in manifestMap.keys) {
        if (path.startsWith('images/') &&
            !path.contains('(1)') &&
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

    correct_choice = choices[random.nextInt(4)];
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

  Future<void> _showMyDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => _buildAlertDialog(context),
    );
  }

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Incorrect'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('The correct answer was ${parseImageName(correct_choice)}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Copy That'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _guess(String choice) async {
    if (choice == correct_choice) {
      correct += 1;
    } else {
      incorrect += 1;
      await _showMyDialog(_context);
    }
    score = "$correct out of $incorrect";

    setState(() {
      _setChoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(score),
            Image(
              image: AssetImage(correct_choice),
              height: 400,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GuessButton(onPressed: _guess, text: choices[0]),
                  GuessButton(onPressed: _guess, text: choices[1]),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GuessButton(onPressed: _guess, text: choices[2]),
                  GuessButton(onPressed: _guess, text: choices[3]),
                ],
              ),
            ),
            Text('after row'),
          ],
        ),
      ),
    );
  }
}

String parseImageName(String imageName) {
  final fileName = imageName.split('/').last;
  final nameParts = fileName.split('_');

  if (nameParts.length == 2) {
    final firstName = nameParts[1].replaceAll('.JPG', '');
    final lastName = nameParts[0].replaceAll('.JPG', '');
    return '$firstName $lastName';
  }

  return imageName;
}

class GuessButton extends StatelessWidget {
  final Function(String) onPressed;
  final String text;

  const GuessButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed(text),
      child: Text(parseImageName(text)),
    );
  }
}
