import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ilya/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
// class PostPage extends StatelessWidget {
//   PostPage({Key? key}) : super(key: key);
//   Post? post;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          FirebaseFirestore.instance.collection('posts').doc(widget.id).get(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Center(
            child: Text('ERROR 404'),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          DocumentSnapshot<Map<String, dynamic>> postdata = snapshot.data!;
          Post post = Post(
            creator: postdata['creator'],
            title: postdata['title'],
            text: postdata['text'],
            likeCounter: postdata['likeCounter'],
            likedBy: postdata['likedBy']?.cast<String>(),
            id: postdata.id,
          );
          return Scaffold(
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
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blueGrey[600],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
              leading: IconButton(
                icon: const Icon(Icons.house),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              label: Text(
                post.likeCounter.toString(),
              ),
              icon: FirebaseAuth.instance.currentUser != null &&
                      post.likedBy
                          .contains(FirebaseAuth.instance.currentUser!.uid)
                  ? const Icon(Icons.thumb_up)
                  : const Icon(Icons.thumb_up_outlined),
              backgroundColor: Colors.blueGrey[600],
              onPressed: () async {
                if (FirebaseAuth.instance.currentUser == null) {
                  Navigator.pushNamed(context, '/login');
                } else if (post.likedBy
                    .contains(FirebaseAuth.instance.currentUser!.uid)) {
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(post.id)
                      .update(
                    {
                      'likedBy': FieldValue.arrayRemove(
                          [FirebaseAuth.instance.currentUser!.uid]),
                      'likeCounter': FieldValue.increment(-1),
                    },
                  );
                  setState(
                    () {
                      post.likedBy
                          .remove(FirebaseAuth.instance.currentUser!.uid);
                    },
                  );
                } else {
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(post.id)
                      .update(
                    {
                      'likeCounter': FieldValue.increment(1),
                      'likedBy': FieldValue.arrayUnion(
                          [FirebaseAuth.instance.currentUser!.uid]),
                    },
                  );
                  setState(
                    () {
                      post.likedBy.add(FirebaseAuth.instance.currentUser!.uid);
                    },
                  );
                }
              },
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    post.title,
                    style: const TextStyle(
                        color: Color.fromRGBO(84, 110, 122, 1),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'written by ',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 25,
                            color: Colors.blueGrey[400],
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        post.creator,
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.blueGrey[600],
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Divider(
                  indent: 60,
                  endIndent: 60,
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 7,
                      margin: const EdgeInsets.only(
                          top: 15, bottom: 30, left: 35, right: 35),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: 20,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Markdown(
                            softLineBreak: true,
                            styleSheet: MarkdownStyleSheet(
                              textScaleFactor: 1.2,
                            ),
                            data: post.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
