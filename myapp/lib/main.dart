import 'package:flutter/material.dart';

void main() {
  runApp(Login());
}

// LOGIN PAGE
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Builder(
      builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 42, 35, 235),
            title: const Text('Login'),
          ),
          body: Stack(children: [
            Container(
              color: Colors.white,
            ),
            Center(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    onChanged: (text) {
                      username = text;
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        hintText: 'Enter your username'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    onChanged: (text) {
                      password = text;
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        hintText: 'Enter your password'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (username == 'admin' && password == 'admin') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyApp()));
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text(
                                    'Username or password is incorrect'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'))
                                ],
                              );
                            });
                      }
                    },
                    child: const Text('Login'),
                  ),
                )
              ],
            ))
          ])),
    ));
  }
}

// HOME PAGE
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
            Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Logout'),
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
