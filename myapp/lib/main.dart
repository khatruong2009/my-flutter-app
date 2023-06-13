import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 0;

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
            Center(child: Text('$count', style: const TextStyle(fontSize: 50))),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: (FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      count++;
                    });
                    print('Count going up');
                  },
                  child: const Icon(Icons.add),
                )),
              ),
            ),
            Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: (FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        count = 0;
                        print('Count reset');
                      });
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.refresh),
                  )),
                )),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: (FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        count = count * count;
                      });
                      print('Count squared');
                    },
                    backgroundColor: Colors.green[800],
                    child: const Icon(Icons.storm_outlined),
                  )),
                )),
            BottomNavigationBar(items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile')
            ])
          ])),
    );
  }
}
