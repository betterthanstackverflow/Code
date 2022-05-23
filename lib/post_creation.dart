import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class PostCreator extends StatefulWidget {
  const PostCreator({Key? key}) : super(key: key);

  @override
  State<PostCreator> createState() => _PostCreatorState();
}

class _PostCreatorState extends State<PostCreator> {
  String textsave = '';
  String titlesave = '';
  ScrollController scrollController = ScrollController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late LinkedScrollControllerGroup _controllers;
  late ScrollController _Text;
  late ScrollController _MarkDown;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _Text = _controllers.addAndGet();
    _MarkDown = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _Text.dispose();
    _MarkDown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'CREATE YOUR POST',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        leading: IconButton(
          icon: const Icon(Icons.house),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            CollectionReference posts =
                FirebaseFirestore.instance.collection('posts');
            await posts.add(
              {
                'likeCounter': 0,
                'likedBy': [],
                'title': titlesave,
                'text': textsave,
                'creator': FirebaseAuth.instance.currentUser!.displayName!
              },
            ).then(
              (_) {
                Navigator.pop(context);
              },
            );
          }
        },
        backgroundColor: Colors.blueGrey[600],
      ),
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // child: Text(
            //   'Create Your Post',
            //   style: TextStyle(fontSize: 30, color: Colors.blueGrey[600]),
            // ),

            Card(
              margin: const EdgeInsets.only(
                  left: 35, right: 35, bottom: 20, top: 23),
              elevation: 7,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 15,
                  bottom: 20,
                ),
                child: TextFormField(
                  validator: (String? a) {
                    if (a == null || a.isEmpty) {
                      return 'Title should not be empty!';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your title'),
                  onSaved: (String? ac) {
                    titlesave = ac as String;
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(
                    left: 47,
                  ),
                  child: Text(
                    'Your post with Markdown support',
                    style: TextStyle(fontSize: 25, color: Colors.blueGrey[700]),
                  ),
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 31,
                    ),
                    child: Text(
                      'Preview',
                      style:
                          TextStyle(fontSize: 25, color: Colors.blueGrey[700]),
                    ),
                  ),
                ),
              ],
            ),
            // IntrinsicHeight(
            // child:
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.only(left: 35, right: 10, top: 5),
                    elevation: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 20,
                      ),
                      child: TextFormField(
                        scrollController: _Text,
                        maxLines: 15,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your text'),
                        onChanged: (String textfield) {
                          setState(() {
                            textsave = textfield;
                          });
                        },
                        validator: (String? a) {
                          if (a == null || a.isEmpty) {
                            return 'Text should not be empty!';
                          }
                          return null;
                        },
                        onSaved: (String? ac) {
                          textsave = ac as String;
                        },
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.only(right: 35, left: 10, top: 5),
                    elevation: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 20,
                      ),
                      child: SizedBox(
                        height: 315,
                        //   widthFactor: 1,
                        //   heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Markdown(
                            controller: _MarkDown,
                            softLineBreak: true,
                            styleSheet: MarkdownStyleSheet(
                              textScaleFactor: 1.2,
                            ),
                            data: textsave,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // )
          ],
        ),
      ),
    );
  }
}
