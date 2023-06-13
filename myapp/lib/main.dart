import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 42, 35, 235),
            title: const Text('Kha\'s First App'),
          ),
          body: Stack(children: [
            Container(
              color: Colors.white,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: (FloatingActionButton(
                  onPressed: () {
                    print('You clicked me!');
                  },
                  child: const Icon(Icons.add),
                )),
              ),
            )
          ])),
    );
  }
}
