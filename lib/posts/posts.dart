import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_list/posts/bloc/post_bloc.dart';
import 'package:http/http.dart' as http;

import 'models/post.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts'),),
      body: BlocProvider(
        create: (_) => PostBloc(httpClient: http.Client())..add(PostFetched()),
        child: const PostsList(),
      ),
    );
  }
}

class PostsList extends StatefulWidget {
  const PostsList({ Key? key }) : super(key: key);

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state){
        switch (state.status) {
          case PostStatus.failure:
            return const Center(child: Text("failed to fetch posts"),);
          case PostStatus.success:
            if(state.posts.isEmpty){
              return const Center(child: const Text("no posts"),);
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index){
              return index >= state.posts.length
                  ? const BottomLoader()
                  : PostListItem(post: state.posts[index]);
            },
            itemCount: state.hasReachedMax
                        ? state.posts.length
                        : state.posts.length + 1,
            controller: _scrollController,);
          default:
            return const Center(child: CircularProgressIndicator());

        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
    ..removeListener(_onScroll)
    ..dispose();
    super.dispose();
  }

  void _onScroll(){
    if(_isBottom) context.read<PostBloc>().add(PostFetched());
  }

  bool get _isBottom {
    if( !_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}

class BottomLoader extends StatelessWidget {
  const BottomLoader({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
      
    );
  }
}

class PostListItem extends StatelessWidget {
  const PostListItem({Key? key, required this.post}) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text('${post.id}', style: textTheme.caption),
        title: Text(post.title),
        isThreeLine: true,
        subtitle: Text(post.body),
        dense: true,
      ),
    );
  }
}