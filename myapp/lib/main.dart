import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'dart:io' show Platform;
import 'package:amplify_api/amplify_api.dart';

import 'package:amplify_datastore/amplify_datastore.dart';
import 'models/ModelProvider.dart';

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

  StreamSubscription<DataStoreHubEvent>? stream;

  bool networkIsUp = false;

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
      final analytics = AmplifyAnalyticsPinpoint();
      final api = AmplifyAPI();
      final dataStorePlugin =
          AmplifyDataStore(modelProvider: ModelProvider.instance);
      await Amplify.addPlugins(
        [auth, storage, analytics, dataStorePlugin, api],
      );

      try {
        await Amplify.configure(amplifyconfig);
      } on AmplifyAlreadyConfiguredException {
        print(
            'Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
      }

      setState(() => _isAmplifyConfigured = true);
    } catch (e) {
      print('Could not configure Amplify: $e');
    }
  }

  // listen to amplify events
  void observeEvents() {
    stream = Amplify.Hub.listen(HubChannel.DataStore, (hubEvent) {
      if (hubEvent.eventName == 'networkStatus') {
        setState(() {
          final status = hubEvent.payload as NetworkStatusEvent?;
          networkIsUp = status?.active ?? false;
        });
      }
    });
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

  //                             // only go to next page if sign in worked
  //                             if (loggedIn == true) {
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
            debugShowCheckedModeBanner: false,
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
  var todos = [];

  @override
  void initState() {
    listAlbum();
    listAllWithGuestAccessLevel();
    readToDo();
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

  // download file on mobile
  Future<void> downloadToLocalFile(String key) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final filepath = documentsDir.path + '/' + key;
    try {
      final result = await Amplify.Storage.downloadFile(
        key: key,
        localFile: AWSFile.fromPath(filepath),
        onProgress: (p0) {
          print('Progress: ${p0.transferredBytes} / ${p0.totalBytes} %)');
        },
      ).result;
    } on StorageException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  // download file on web
  Future<void> downloadFile(String key) async {
    try {
      final result = await Amplify.Storage.downloadFile(
              key: key, localFile: AWSFile.fromPath(key))
          .result;
      print('File downloaded');
    } on StorageException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  // delete file
  Future<void> removeFile({
    required String key,
    required StorageAccessLevel,
  }) async {
    try {
      final result = await Amplify.Storage.remove(
        key: key,
        options: StorageRemoveOptions(
          accessLevel: StorageAccessLevel,
        ),
      ).result;
      print('File removed');
    } on StorageException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  // record upload event
  Future<void> recordUploadEvent() async {
    final event = AnalyticsEvent('upload');

    event.customProperties
      ..addStringProperty('username', 'file uploaded')
      ..addBoolProperty('Successful', true);

    Amplify.Analytics.recordEvent(event: event);
  }

  // record download event
  Future<void> recordDownloadEvent() async {
    final event = AnalyticsEvent('download');

    event.customProperties
      ..addStringProperty('username', 'file downloaded')
      ..addBoolProperty('Successful', true);

    Amplify.Analytics.recordEvent(event: event);
  }

  // DATASTORE FUNCTIONS

  Future<void> saveToDo() async {
    final item = Todo(
      name: 'My first todo',
      description: 'Learn how to use Amplify DataStore.',
    );

    try {
      await Amplify.DataStore.save(item);
      print('Saved item: $item');
    } on DataStoreException catch (e) {
      print(e.message);
    }
  }

  Future<void> readToDo() async {
    try {
      final items = await Amplify.DataStore.query(Todo.classType);
      print(items);
      setState(() {
        todos = items;
      });
    } on DataStoreException catch (e) {
      print(e.message);
    }
  }

  // write a function to delete todos based on id pressed on UI
  Future<void> deleteToDo() async {
    try {
      final items = await Amplify.DataStore.query(Todo.classType);
      await Amplify.DataStore.delete(items[0]);
      print('Deleted item: $items');
    } on DataStoreException catch (e) {
      print(e.message);
    }
  }

  // REST API FUNCTIONS

  Future<void> postToDo() async {
    try {
      final restOperation = Amplify.API.post(
        'todo',
        body: HttpPayload.json({
          'name': 'My first todo',
          'description': 'Learn how to use Amplify DataStore.'
        }),
      );
      final response = await restOperation.response;
      print("POST CALL SUCCESSFUL");
      print(response.decodeBody());
    } on ApiException catch (e) {
      print(e.message);
    }
  }

  Future<void> getToDo() async {
    try {
      final restOperation = Amplify.API.get(
        'todo',
      );
      final response = await restOperation.response;
      print("GET CALL SUCCESSFUL");
      print(response.decodeBody());
    } on ApiException catch (e) {
      print(e.message);
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // TAB CONTROLLER
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 42, 35, 235),
            title: const Text('Kha\'s First App'),
            // TOP TAB BAR
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                // Tab(icon: Icon(Icons.upload_file)),
                Tab(icon: Icon(Icons.airplane_ticket_outlined)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // HOME PAGE
              homePage(context),
              // UPLOAD PAGE
              // uploadPage(),
              // API PAGE
              Scaffold(
                body: Center(
                  child: dataStorePage(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Scaffold uploadPage() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                uploadFile();
                recordUploadEvent();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green[800]!),
              ),
              child: const Text(
                'Upload',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stack homePage(BuildContext context) {
    return Stack(children: [
      // Container(
      //   color: Colors.white,
      // ),
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: ListView(
            children: [
              for (var item in list)
                ListTile(
                  title: Text(item.key),
                  subtitle: Text(item.lastModified.toString()),
                  hoverColor: Colors.blue,
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      if (Platform.isAndroid || Platform.isIOS) {
                        downloadToLocalFile(item.key);
                      } else if (Platform.isWindows ||
                          Platform.isMacOS ||
                          Platform.isLinux) {
                        downloadFile(item.key);
                      }
                      recordDownloadEvent();
                    },
                    color: Colors.grey[700],
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removeFile(
                        key: item.key,
                        StorageAccessLevel: StorageAccessLevel.guest,
                      );
                      setState(() {
                        listAllWithGuestAccessLevel();
                      });
                    },
                    color: Colors.red,
                  ),
                )
            ],
          ),
        ),
      ),
      Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: (FloatingActionButton(
              onPressed: () {
                setState(() {
                  listAllWithGuestAccessLevel();
                  print('List Refreshed');
                });
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.refresh),
            )),
          )),
      // sign out button
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              _signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            },
            // change color of the button to red
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
            child: const Text(
              'Log Out',
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            onPressed: () {
              uploadFile();
              recordUploadEvent();
            },
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.publish_sharp,
            ),
          ),
        ),
      )
    ]);
  }

  Stack dataStorePage() {
    return Stack(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: ListView(
            children: [
              for (var item in todos)
                ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  hoverColor: Colors.blue,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteToDo();
                    },
                    color: Colors.red,
                  ),
                )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: ElevatedButton(
              onPressed: () {
                saveToDo();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green[400]!),
              ),
              child: const Text(
                'API',
              ),
            ),
          ),
        ),
        Align(
          // give some more padding to the bottom right button
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: ElevatedButton(
              onPressed: () {
                readToDo();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green[600]!),
              ),
              child: const Text(
                'Read',
              ),
            ),
          ),
        ),
        // ElevatedButton(
        //   onPressed: () {
        //     postToDo();
        //   },
        //   style: ButtonStyle(
        //     backgroundColor: MaterialStateProperty.all<Color>(
        //         Colors.green[800]!),
        //   ),
        //   child: const Text(
        //     'Post Rest API',
        //   ),
        // ),
        // ElevatedButton(
        //   onPressed: () {
        //     getToDo();
        //   },
        //   style: ButtonStyle(
        //     backgroundColor: MaterialStateProperty.all<Color>(
        //         Colors.green[900]!),
        //   ),
        //   child: const Text(
        //     'Get Rest API',
        //   ),
        // ),
      ],
    );
  }
}
