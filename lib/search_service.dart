import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  searchByName(String searchField) {
    return Firestore.instance
        .collection('users')
        .where('searchKey', isEqualTo: searchField)
        .getDocuments();
  }

  searchByTag(String searchField) {
    return Firestore.instance
        .collection('posts')
        .where('tag', isEqualTo: searchField)
        .getDocuments();
  }



}
