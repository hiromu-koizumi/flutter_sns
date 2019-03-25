//import 'dart:async';
//
//import 'package:flutter_cos/tag/word.dart';
//import 'package:flutter_cos/tag/word_item.dart';
//
//import 'package:rxdart/subjects.dart';
//
//class WordAddition {
//  final String name;
//  WordAddition(this.name);
//}
//
//class WordRemoval {
//  final String name;
//  WordRemoval(this.name);
//}
//
//class WordBloc {
//  final Word _word = Word();
//
//  //BehaviorSubjectはStreamControllerの一種。
//  final BehaviorSubject<List<WordItem>> _items =
//  BehaviorSubject<List<WordItem>>(seedValue: []);
//
//  final BehaviorSubject<int> _itemCount =
//  BehaviorSubject<int>(seedValue: 0);
//
////ハート押されたら
//  //1
//  Sink<WordAddition> get wordAddition => _wordAdditionController.sink;
//
//  Sink<WordRemoval> get wordRemoval => _wordRemovalController.sink;
//
//
//  //2
//  final StreamController<WordAddition> _wordAdditionController =
//  StreamController<WordAddition>();
//
//  final StreamController<WordRemoval> _wordRemovalController =
//  StreamController<WordRemoval>();
//
//  WordBloc() {
//
//    //3
//    _wordAdditionController.stream.listen((addition){
//      int currentCount = _word.itemCount;
//      _word.add(addition.name);
//      _items.add(_word.items);
//      int updateCount = _word.itemCount;
//      if (updateCount != currentCount) {
//        _itemCount.add(updateCount);
//      }
//    });
//
//    _wordRemovalController.stream.listen((removal){
//      int currentCount = _word.itemCount;
//      _word.remove(removal.name);
//      print(_word.items.toString());
//      _items.add(_word.items);
//      int updateCount = _word.itemCount;
//      if (updateCount != currentCount) {
//        _itemCount.add(updateCount);
//      }
//    });
//  }
//
//
//
//
//  Stream<int> get itemCount => _itemCount.stream;
//
//  Stream<List<WordItem>> get items => _items.stream;
//
//  void dispose() {
//    _items.close();
//    _itemCount.close();
//    _wordAdditionController.close();
//    _wordRemovalController.close();
//  }
//}