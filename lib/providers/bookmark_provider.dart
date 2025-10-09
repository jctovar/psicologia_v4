import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:suayed/models/post_model.dart';
import 'package:suayed/models/storage_post_model.dart';

class BookmarkProvider extends ChangeNotifier {
  final _db = Localstore.instance;
  List<StoragePost> _bookmarks = [];

  List<StoragePost> get bookmarks => _bookmarks;

  BookmarkProvider() {
    fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    final result = await _db.collection('bookmarks').get();
    if (result != null) {
      _bookmarks = result.entries
          .map((entry) => StoragePost.fromJson(entry.value))
          .toList();
      notifyListeners();
    }
  }

  Future<void> addBookmark(PostModel post) async {
    final id = post.id.toString();
    await _db.collection('bookmarks').doc(id).set(post.toJson());
    // After adding, we create a StoragePost to add to the local list
    // to avoid re-fetching from the database.
    final newBookmark = StoragePost(
      id: post.id,
      date: post.date,
      title: post.title,
      link: post.link,
      image: post.image,
      content: post.content,
    );
    // Avoid duplicates
    _bookmarks.removeWhere((b) => b.id == newBookmark.id);
    _bookmarks.insert(0, newBookmark);
    notifyListeners();
  }

  Future<void> deleteBookmark(int id) async {
    await _db.collection('bookmarks').doc(id.toString()).delete();
    _bookmarks.removeWhere((bookmark) => bookmark.id == id);
    notifyListeners();
  }
}
