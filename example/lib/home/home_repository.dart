import 'package:app_base_getx/app_base_getx.dart';

import 'post.dart';

class HomeRepository extends BaseRepository {
  Future<Either<Failure, List<Post>>> getPosts() => safeCall(
        () => client.get('/posts', query: {'_limit': 20}),
        parser: (data) => ParsingUtil.jsonToList(data as List, Post.fromJson),
      );

  Future<Either<Failure, Post>> createPost(String title) => safeCall(
        () => client.post('/posts', data: {'title': title, 'body': 'example', 'userId': 1}),
        parser: (data) => Post.fromJson(data as Map<String, dynamic>),
      );
}
