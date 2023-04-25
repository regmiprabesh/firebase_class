import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_firebase_class/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  TextEditingController myController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    readNote();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: myController,
            ),
            ElevatedButton(
                onPressed: () {
                  createNote(title: myController.text);
                },
                child: Text('Add Data')),
            Expanded(
              child: StreamBuilder(
                stream: readNotes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final notes = snapshot.data!;
                    return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(notes[index]['title']),
                          );
                        });
                  } else {
                    return Text('No Data');
                  }
                },
              ),
            ),
            FutureBuilder(
              future: readNote(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!['title']);
                } else {
                  return Text('No Data');
                }
              },
            ),
            ElevatedButton(
                onPressed: () {
                  updateNote();
                },
                child: Text('Update Data')),
            ElevatedButton(
                onPressed: () {
                  deleteNote();
                },
                child: Text('Delete Data')),
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future createNote({required String title}) async {
    final docNote = FirebaseFirestore.instance.collection('notes').doc();
    final json = {
      'id': docNote.id,
      'title': title,
      'description': 'This is Description'
    };
    await docNote.set(json);
  }

  Stream<List> readNotes() => FirebaseFirestore.instance
      .collection('notes')
      .snapshots()
      .map((event) => event.docs.map((e) => e).toList());
  Future<Map<String, dynamic>?> readNote() async {
    var d = FirebaseFirestore.instance.collection('notes').doc('my-note');
    var data = await d.get();
    return data.data();
  }

  Future updateNote() async {
    final docNote =
        FirebaseFirestore.instance.collection('notes').doc('my-note');
    await docNote.update({
      'description.desc1': 'This is desc1',
      'description.desc2': 'This is desc 2'
    });
  }

  Future deleteNote() async {
    final docNote =
        FirebaseFirestore.instance.collection('notes').doc('my-note');
    await docNote.delete();
  }
}
