import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_list/posts/models/post.dart';
import 'package:infinite_list/services/api_services.dart';

part 'post_event.dart';
part 'post_state.dart';

  
  const throttleDuration = Duration(milliseconds: 100);

  EventTransformer<E> throttleDroppable<E>( Duration duration) {
    return (events, mapper) {
      return droppable<E>().call(events.throttle(duration), mapper);
    };
  }
class PostBloc extends Bloc<PostEvent, PostState> {
    PostBloc({required this.httpClient}) : super(const PostState()) {
         on<PostFetched>(
        _onPostFetched,
        transformer: throttleDroppable(throttleDuration),
      );
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(PostFetched event, Emitter<PostState> emit) async{
    try {
      if(state.status == PostStatus.initial){
        final posts = await ApiServices().fetchPosts();
        return emit(state.copyWith(
          status: PostStatus.success,
            posts: posts,
            hasReachedMax: false,
        ));
      }
      
      final posts = await ApiServices().fetchPosts(state.posts.length);
      
      emit(posts.isEmpty
        ? state.copyWith(hasReachedMax: true)
        : state.copyWith(
          status: PostStatus.success,
          posts:  List.of(state.posts)..addAll(posts),
          hasReachedMax: false,
        ));
    }  catch (_) {
      emit(state.copyWith(status: PostStatus.failure));      
    }
  }
}
