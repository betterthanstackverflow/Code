import 'package:flutter/material.dart';
import 'package:ilya/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(post.likeCounter.toString()),
              Icon(Icons.thumb_up, color: Colors.grey.shade500),
            ],
          ),
        ),
        title: Text(post.title),
        subtitle: Text(post.creator),
        onTap: () {
          Navigator.pushNamed(context, '/${post.id}');
        },
      ),
    );
  }
}
