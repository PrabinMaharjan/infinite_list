import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:infinite_list/posts/models/post.dart';

class ApiServices {
  late final http.Client httpClient;
  static const _postLimit = 20;

  Future<List<Post>> fetchPosts([int startIndex =0]) async {
    final response = await httpClient.get(
      Uri.https('jsonplaceholder.typicode.com', '/posts',
      <String, String> {'_start': '$startIndex', '_limit': '$_postLimit'})
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((dynamic json) {
        return Post(
          id: json['id'] as int,
          title: json['title'] as String,
          body: json['body'] as String,
        );
      }).toList();
    }
    throw Exception('error fetching posts');
  }
}