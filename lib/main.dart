import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ilya/login.dart';
import 'package:ilya/post.dart';
import 'package:ilya/post_card.dart';
import 'package:ilya/post_creation.dart';
import 'package:ilya/post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCkLiRlFXCCWx38uPC7-1dOi7_eY2Ur9tI",
      appId: "1:838495756774:web:97d4701dc6a0fa2d2f3627",
      messagingSenderId: "838495756774",
      projectId: "forum-f4b84",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blueGrey.shade300,
        ),
      ),
      title: 'Flutter Demo',
      initialRoute: '/home',
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/') {
          return null;
        }
        if (settings.name == '/createpost') {
          if (FirebaseAuth.instance.currentUser == null) {
            return null;
          } else {
            return MaterialPageRoute(
                builder: (context) {
                  return const PostCreator();
                },
                settings: settings);
          }
        }
        return MaterialPageRoute(
            builder: (context) {
              return PostPage(
                id: settings.name!.substring(
                  1,
                ),
              );
            },
            settings: settings);
      },
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) =>
            const MyLoginPage(title: 'Login page'),
        '/home': (BuildContext context) => const MyHomePage(title: 'Home page'),
        // '/post': (BuildContext context) => const PostPage(),
        // '/createpost': (BuildContext context) => const PostCreator(),
      },
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
  Future<List<Post>> postDownload() async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    QuerySnapshot<Object?> querySnapshot = await posts.get();
    List<Post> rtrn = [];
    for (QueryDocumentSnapshot<Object?> post in querySnapshot.docs) {
      Map<String, dynamic> postdata = post.data() as Map<String, dynamic>;
      rtrn.add(
        Post(
          creator: postdata['creator'],
          title: postdata['title'],
          text: postdata['text'],
          likeCounter: postdata['likeCounter'],
          likedBy: postdata['likedBy']?.cast<String>(),
          id: post.id,
        ),
      );
    }
    return rtrn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (FirebaseAuth.instance.currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User must be logged in!'),
              ),
            );
          } else {
            await FirebaseAuth.instance.currentUser!.reload();
            if (!FirebaseAuth.instance.currentUser!.emailVerified) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Email verification'),
                  content: const Text(
                      'You have to verify your email to access this page'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () {
                          FirebaseAuth.instance.currentUser!
                              .sendEmailVerification();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Send email'))
                  ],
                ),
              );
            } else {
              await Navigator.pushNamed(context, '/createpost').then(
                (_) {
                  setState(() {});
                },
              );
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('CREATE POST'),
        backgroundColor: Colors.blueGrey[600],
      ),
      appBar: AppBar(
        // centerTitle: true,
        title: const Text(
          'BetterThanStackOverflow',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              left: 0,
              right: 10,
              top: 5,
              bottom: 5,
            ),
            child: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text("LOGIN"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey[600],
                    ),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      setState(
                        () {
                          FirebaseAuth.instance.signOut();
                        },
                      );
                    },
                    child: const Text("SIGN OUT"),
                    style:
                        ElevatedButton.styleFrom(primary: Colors.blueGrey[600]),
                  );
                }
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(
          //     left: 10,
          //     right: 10,
          //     top: 5,
          //     bottom: 5,
          //   ),
          // child: ElevatedButton.icon(
          //   onPressed: () async {
          //     if (FirebaseAuth.instance.currentUser == null) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('User must be logged in!'),
          //         ),
          //       );
          //     } else {
          //       await FirebaseAuth.instance.currentUser!.reload();
          //       if (!FirebaseAuth.instance.currentUser!.emailVerified) {
          //         showDialog(
          //           context: context,
          //           builder: (_) => AlertDialog(
          //             title: const Text('Email verification'),
          //             content: const Text(
          //                 'You have to verify your email to access this page'),
          //             actions: [
          //               TextButton(
          //                 onPressed: () {
          //                   Navigator.of(context).pop();
          //                 },
          //                 child: const Text('Cancel'),
          //               ),
          //               TextButton(
          //                   onPressed: () {
          //                     FirebaseAuth.instance.currentUser!
          //                         .sendEmailVerification();
          //                     Navigator.of(context).pop();
          //                   },
          //                   child: const Text('Send email'))
          //             ],
          //           ),
          //         );
          //       } else {
          //         await Navigator.pushNamed(context, '/createpost').then(
          //           (_) {
          //             setState(() {});
          //           },
          //         );
          //       }
          //     }
          //   },
          //   icon: const Icon(Icons.add),
          //   label: const Text('Create post'),
          // ),
          // ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.house),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Center(
        child: FutureBuilder(
          // Initialize FlutterFire:
          future: postDownload(),
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
              List<Post> posts = snapshot.data as List<Post>;
              // List<Post> posts = [
              //   Post(
              //       likeCounter: 8,
              //       creator: "45",
              //       title: "Title",
              //       text: "- 1\n- 1\n- 2\n- 3"),
              //   Post(
              //       likeCounter: 943234,
              //       creator: "Ilya",
              //       title: "Title1",
              //       text: "# Very interesting text"),
              // ];
              return Padding(
                padding: const EdgeInsets.only(
                  left: 150,
                  right: 150,
                  top: 50,
                ),
                child: ListView(
                  children: posts
                      .map(
                        (Post post) => PostCard(post: post),
                      )
                      .toList(),
                ),
              );
            }

            // Otherwise, show something whilst waiting for initialization to complete
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
