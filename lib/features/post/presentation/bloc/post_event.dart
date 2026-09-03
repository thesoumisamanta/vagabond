import 'dart:io';

abstract class PostEvent {
  const PostEvent();
}

class CreatePostRequested extends PostEvent {
  final List<File> media;
  final String? caption;
  final String? location;
  final String? tags;

  const CreatePostRequested({required this.media, this.caption, this.location, this.tags});
}

class GetFeedPostsRequested extends PostEvent {
  final int page;
  final int limit;
  final bool isRefresh;

  const GetFeedPostsRequested({this.page = 1, this.limit = 10, this.isRefresh = false});
}

class GetPostDetailsRequested extends PostEvent {
  final String id;
  const GetPostDetailsRequested({required this.id});
}

class LikePostRequested extends PostEvent {
  final String id;
  const LikePostRequested({required this.id});
}

class DislikePostRequested extends PostEvent {
  final String id;
  const DislikePostRequested({required this.id});
}

class SharePostRequested extends PostEvent {
  final String id;
  const SharePostRequested({required this.id});
}
