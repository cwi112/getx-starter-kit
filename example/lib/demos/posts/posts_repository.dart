// =============================================================================
// 실전 예제 - Repository
//
// 실제 프로젝트에서는 화면마다 이 파일 하나에 그 화면이 쓰는 API 를 모은다.
// ParsingUtil.jsonToList 로 JSON 배열을 모델 목록으로 바꾼다.
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';

import 'post.dart';

class PostsRepository extends BaseRepository {
  Future<Either<Failure, List<Post>>> getPosts() => safeCall(
        () => client.get('/posts', query: {'_limit': 20}),
        parser: (data) => ParsingUtil.jsonToList(data as List, Post.fromJson),
      );

  Future<Either<Failure, Post>> createPost(String title) => safeCall(
        () => client.post('/posts', data: {'title': title, 'body': 'example', 'userId': 1}),
        parser: (data) => Post.fromJson(data as Map<String, dynamic>),
      );
}
