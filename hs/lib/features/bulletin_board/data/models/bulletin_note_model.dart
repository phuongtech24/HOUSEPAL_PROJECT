import 'package:cloud_firestore/cloud_firestore.dart';

class BulletinNoteModel {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorId;
  final bool isPinned;
  final DateTime createdAt;

  BulletinNoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorId,
    this.isPinned = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorName': authorName,
      'authorId': authorId,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BulletinNoteModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BulletinNoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorName: data['authorName'] ?? 'Ẩn danh',
      authorId: data['authorId'] ?? '',
      isPinned: data['isPinned'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}




// [Refactor] Code optimization pass 10
