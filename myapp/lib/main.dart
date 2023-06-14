import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'dart:io' as io;
import 'package:aws_common/vm.dart';
import 'package:file_picker/file_picker.dart';

import 'amplifyconfiguration.dart';

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
  String email = '';
  String password = '';
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  // Amplify Configuration
  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      final storage = AmplifyStorageS3();
      await Amplify.addPlugins([auth, storage]);

      await Amplify.configure(amplifyconfig);
      setState(() => _isAmplifyConfigured = true);
    } catch (e) {
      print('Could not configure Amplify: $e');
    }
  }

  // Sign Up
  Future<void> _signUp() async {
    try {
      print("SIGNING USER UP");
      final userAttributes = {AuthUserAttributeKey.email: email};
      final res = await Amplify.Auth.signUp(
          username: email,
          password: password,
          options: SignUpOptions(userAttributes: userAttributes));
      print("SUCCESS");
      print(res);
      await _confirmSignUp(res);
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  // Confirm Sign Up
  Future<void> _confirmSignUp(SignUpResult result) async {
    switch (result.nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignUpStep.done:
        print('Sign up done');
        break;
    }
  }

  // confirm user
  Future<void> confirmUser(
    String email,
    String confirmationCode,
  ) async {
    try {
      final res = await Amplify.Auth.confirmSignUp(
          username: email, confirmationCode: confirmationCode);
      print(res);
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  // Handle Code Delivery
  void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) async {
    print('Code sent to ${codeDeliveryDetails.destination}');
  }

  // Sign In
  Future<bool> _signIn() async {
    try {
      final res = await Amplify.Auth.signIn(
          username: email, password: password, options: SignInOptions());
      print(res);
      return Future<bool>.value(true);
    } on AuthException catch (e) {
      print(e.message);
      return Future<bool>.value(false);
    }
  }

  // LOGIN PAGE

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //       home: Builder(
  //     builder: (context) => Scaffold(
  //         appBar: AppBar(
  //           backgroundColor: const Color.fromARGB(255, 42, 35, 235),
  //           title: const Text('Login'),
  //         ),
  //         body: Stack(children: [
  //           Container(
  //             color: Colors.white,
  //           ),
  //           Center(
  //               child: Column(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(20.0),
  //                 child: TextField(
  //                   onChanged: (text) {
  //                     email = text;
  //                   },
  //                   decoration: const InputDecoration(
  //                       border: OutlineInputBorder(),
  //                       labelText: 'Email',
  //                       hintText: 'Enter your email'),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(20.0),
  //                 child: TextField(
  //                   obscureText: true,
  //                   onChanged: (text) {
  //                     password = text;
  //                   },
  //                   decoration: const InputDecoration(
  //                       border: OutlineInputBorder(),
  //                       labelText: 'Password',
  //                       hintText: 'Enter your password'),
  //                 ),
  //               ),
  //               Center(
  //                 child: Row(
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.all(20.0),
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           if (email != null && password != null) {
  //                             // sign in
  //                             bool? loggedIn;
  //                             _signIn().then((value) => loggedIn = value);
  //                             print("DID LOGIN SUCCEED?");
  //                             print(loggedIn);

  //                             // make sure sign in worked
  //                             if (Amplify.Auth.getCurrentUser() != null) {
  //                               Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                       builder: (context) => const MyApp()));
  //                             } else {
  //                               showDialog(
  //                                   context: context,
  //                                   builder: (BuildContext context) {
  //                                     return AlertDialog(
  //                                       title: const Text('Error'),
  //                                       content: const Text(
  //                                           'Email or password is incorrect'),
  //                                       actions: [
  //                                         TextButton(
  //                                             onPressed: () {
  //                                               Navigator.of(context).pop();
  //                                             },
  //                                             child: const Text('Close'))
  //                                       ],
  //                                     );
  //                                   });
  //                             }
  //                             // Navigator.push(
  //                             //     context,
  //                             //     MaterialPageRoute(
  //                             //         builder: (context) => const MyApp()));
  //                           } else {
  //                             showDialog(
  //                                 context: context,
  //                                 builder: (BuildContext context) {
  //                                   return AlertDialog(
  //                                     title: const Text('Error'),
  //                                     content: const Text(
  //                                         'Email or password is incorrect'),
  //                                     actions: [
  //                                       TextButton(
  //                                           onPressed: () {
  //                                             Navigator.of(context).pop();
  //                                           },
  //                                           child: const Text('Close'))
  //                                     ],
  //                                   );
  //                                 });
  //                           }
  //                         },
  //                         child: const Text('Login'),
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.all(20.0),
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           // _configureAmplify();
  //                           _signUp();
  //                         },
  //                         child: const Text('Sign Up'),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               // add a sign up button
  //             ],
  //           ))
  //         ])),
  //   ));
  // }

  // use Authenticator widget
  @override
  Widget build(BuildContext context) {
    return Authenticator(
        child: MaterialApp(
            builder: Authenticator.builder(),
            home: MyApp(),
            theme: ThemeData(
              primarySwatch: Colors.blue,
            )));
  }
}
// }

// HOME PAGE
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 0;
  var list = [];

  @override
  void initState() {
    listAlbum();
    listAllWithGuestAccessLevel();
    super.initState();
  }

  // sign out function
  Future<void> _signOut() async {
    try {
      await Amplify.Auth.signOut();
      print('Signed out');
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  // upload file from device
  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
      withReadStream: true,
      withData: false,
    );

    if (result == null) {
      print('No file selected');
      return;
    }

    final platformFile = result.files.single;
    try {
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          platformFile.readStream!,
          size: platformFile.size,
        ),
        key: platformFile.name,
        onProgress: (p0) =>
            print('Progress: ${p0.transferredBytes} / ${p0.totalBytes} %)'),
      ).result;
    } on StorageException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  // list files
  Future<void> listAlbum() async {
    // print("CALLING LIST ITEMS");
    try {
      String? nextToken;
      bool hashNextPage;

      do {
        final result = await Amplify.Storage.list(
          path: 'public/',
          options: StorageListOptions(
            accessLevel: StorageAccessLevel.guest,
            pageSize: 50,
            nextToken: nextToken,
            pluginOptions: const S3ListPluginOptions(
              excludeSubPaths: true,
            ),
          ),
        ).result;
        // print('Items: ${result.items}');
        nextToken = result.nextToken;
        hashNextPage = result.hasNextPage;
      } while (hashNextPage);
    } on StorageException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  // list all files with guest access level
  Future<void> listAllWithGuestAccessLevel() async {
    try {
      final result = await Amplify.Storage.list(
        options: const StorageListOptions(
          accessLevel: StorageAccessLevel.guest,
          pluginOptions: S3ListPluginOptions.listAll(),
        ),
      ).result;
      setState(() {
        list = result.items;
      });
      // print('Items: ${result.items}');
    } on StorageException catch (e) {
      print(e.message);
      rethrow;
    }
  }

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
            // Center(child: Text('$count', style: const TextStyle(fontSize: 50))),
            Center(
              child: ListView(
                children: [
                  for (var item in list)
                    ListTile(
                      title: Text(item.key),
                      subtitle: Text(item.lastModified.toString()),
                    )
                ],
              ),
            ),
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
            // sign out button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    _signOut();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  // backgroundColor: Colors.red,
                  // change color of the button to red
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: const Text(
                    'Log Out',
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    uploadFile();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green[800]!),
                  ),
                  child: const Text(
                    'Upload',
                  ),
                ),
              ),
            )
            // BottomNavigationBar(items: const [
            //   BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            //   BottomNavigationBarItem(
            //       icon: Icon(Icons.search), label: 'Search'),
            //   BottomNavigationBarItem(
            //       icon: Icon(Icons.person), label: 'Profile')
            // ])
          ])),
    );
  }
}
