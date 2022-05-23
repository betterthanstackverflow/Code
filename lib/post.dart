import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post({
    int? likeCounter,
    required this.creator,
    required this.title,
    required this.text,
    required this.id,
    List<String>? likedBy,
  })  : likeCounter = likeCounter ?? 0,
        likedBy = likedBy ?? [] {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(id)
        .snapshots()
        .listen(update);
  }
  void update(DocumentSnapshot doc) {
    likeCounter = doc['likeCounter'];
    creator = doc['creator'];
    title = doc['title'];
    text = doc['text'];
    likedBy = doc['likedBy']?.cast<String>();
  }

  int likeCounter;
  String creator;
  String title;
  String text;
  String id;
  List<String> likedBy;
}
