import 'package:flutter_cos/models/product.dart';
import 'package:flutter_cos/models/user.dart';
import 'package:scoped_model/scoped_model.dart';



mixin ConnectedProductsModel on Model {
  //投稿内容を代入する変数
  List<Product> _products = [];

  //ハートボタン押したときにその商品のindexを格納する変数
  int _selProductIndex;

  User _authenticatedUser;
  bool _isLoading = false;

//  Future<Null> addProduct(
//      String title, String description, String image, double price) {
//    _isLoading = true;
//    notifyListeners();
//    final Map<String, dynamic> productData = {
//      'title': title,
//      'description': description,
//      'image':
//      'https://media-01.creema.net/user/20510/exhibits/1386529/1_598dbffda8e27db61f23b68d347ba990fa4773a5_583x585.jpg',
//      'price': price,
//      'userEmail': _authenticatedUser.email,
//      'userId': _authenticatedUser.id
//    };
//
//    //データをfirebaseに保存している。jsonに変換して。
////    return http
////        .post(
////        'https://udemy-flutter-products-4936e.firebaseio.com/products.json',
////
////        //firebaseに保存してから下記の処理を行いたいからthenを使用
////        body: json.encode(productData))
////        .then((http.Response response) {
////      final Map<String, dynamic> responseData = json.decode(response.body);
////      final Product newProduct = Product(
////          id: responseData['name'],
////          title: title,
////          description: description,
////          image: image,
////          price: price,
////          userEmail: _authenticatedUser.email,
////          userId: _authenticatedUser.id);
////      _products.add(newProduct);
////      _isLoading = false;
////      notifyListeners();
////    });
//  }
}

//mixinでclassをマージさせる
mixin ProductsModel on ConnectedProductsModel {
  //ハートが押されるたかどうか判断するための変数
  bool _showFavorites = false;

  //タイムラインで投稿を表示する際に呼び出されている
  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selProductIndex;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) {
      return null;
    }
    return _products[selectedProductIndex];
  }

  //ハートを呼び出す際に使用。ハートが押されていることを保存されている
  bool get displayFavoritesOnly {
    return _showFavorites;
  }

//  void updateProduct(
//      String title, String description, String image, double price) {
//    _isLoading = true;
//    notifyListeners();
//    final Map<String, dynamic> updateData = {
//      'title': title,
//      'description': description,
//      'image': 'https://media-01.creema.net/user/20510/exhibits/1386529/1_598dbffda8e27db61f23b68d347ba990fa4773a5_583x585.jpg',
//      'price': price,
//      'userEmail': selectedProduct.userEmail,
//      'userId': selectedProduct.userId
//
//    };
//    http.put('https://udemy-flutter-products-4936e.firebaseio.com/products/${selectedProduct.id}.json',
//        body: json.encode(updateData))
//        .then((http.Response response) {
//      _isLoading = false;
//      final Product updatedProduct = Product(
//          id: selectedProduct.id,
//          title: title,
//          description: description,
//          image: image,
//          price: price,
//          userEmail: selectedProduct.userEmail,
//          userId: selectedProduct.userId);
//      _products[selectedProductIndex] = updatedProduct;
//      notifyListeners();
//    });
//
//  }

  void deleteProduct() {
    _products.removeAt(selectedProductIndex);
    notifyListeners();
  }

//  void fetchProducts() {
//    _isLoading = true;
//    notifyListeners();
//    http
//        .get(
//        'https://udemy-flutter-products-4936e.firebaseio.com/products.json')
//        .then((http.Response response) {
//      final List<Product> fetchedProductList = [];
//
//      final Map<String, dynamic> productListData =
//      json.decode(response.body);
//
//      if (productListData == null) {
//        _isLoading = false;
//        notifyListeners();
//        return;
//      }
//
//      productListData
//          .forEach((String productId, dynamic productData) {
//        final Product product = Product(
//            id: productId,
//            title: productData['description'],
//            image: productData['image'],
//            price: productData['price'],
//            userEmail: productData['userEmail'],
//            userId: productData['userId']);
//        fetchedProductList.add(product);
//      });
//
//      _products = fetchedProductList;
//      _isLoading = false;
//      notifyListeners();
//    });
//  }

  //ハートボタン押されたときに呼び出される
  void toggleProductFavoriteStatus() {
    //現在ハートが押されているかの情報を代入している
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;

    //現在のハートのbool値の逆を代入
    final bool newFavoriteStatus = !isCurrentlyFavorite;

    //投稿情報を更新
    final Product updatedProduct = Product(
//        title: selectedProduct.title,
//        description: selectedProduct.description,
//        price: selectedProduct.price,
//        image: selectedProduct.image,
//        userEmail: selectedProduct.userEmail,
//        userId: selectedProduct.userId,
        isFavorite: newFavoriteStatus);
    _products[selectedProductIndex] = updatedProduct;

    //更新するのに必要
    notifyListeners();
  }

  //ハートボタン押されたときに呼び出される。選択した商品のindexを変数に代入する処理
  void selectProduct(int index) {
    _selProductIndex = index;
    //if (index != null) {
    notifyListeners();
    //}
  }

  //appBarのハートが押されたときに呼び出される
  void toggleDisplayMode() {
    //入っている逆を代入しているんだと思う
    _showFavorites = !_showFavorites;

    //更新を伝える処理、setStateと同じ役割だと思う
    notifyListeners();
  }
}



mixin UserModel on ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser =
        User(id: 'fdalsdfasf', email: email, password: password);
  }
}



mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }

}
