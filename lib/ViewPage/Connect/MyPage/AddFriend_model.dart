import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> searchFriend(String searchText) async {
  List<Map<String, dynamic>> searchUserList = [];

  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
  final String hashcode = userUID.substring(0, 4) +
      userUID.substring(13, 15) +
      userUID.substring(27, 28);

  //Firestore Users에서 Hashcode로 비교해서 같은 유저 가져오기 (본인 제외)
  if ('#$hashcode' != searchText) {
    var searchFromFirebase = await FirebaseFirestore.instance
        .collection('Users')
        .where('HashCode', isEqualTo: searchText)
        .get();
    List<DocumentSnapshot> equalHashCodeList = searchFromFirebase.docs.toList();
    for (DocumentSnapshot equalUser in equalHashCodeList) {
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(equalUser.id)
          .get();
      Map<String, dynamic>? userInfo = userData.data();
      if (userInfo != null && userInfo.isNotEmpty) {
        searchUserList.add(userInfo);
      }
    }
  }

  return searchUserList;
}

Future<List<Map<String, dynamic>>> getRequestList() async {
  List<Map<String, dynamic>> requestUserList = [];

  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;

  //Firestore 에서 Request Users List 가져오기
  var requestFromFirebase = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Request')
      .get();
  List<DocumentSnapshot> requestList = requestFromFirebase.docs.toList();
  for (DocumentSnapshot requestUser in requestList) {
    final userData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUID)
        .collection('Request')
        .doc(requestUser.id)
        .get();
    Map<String, dynamic>? userInfo = userData.data();
    if (userInfo != null && userInfo.isNotEmpty) {
      requestUserList.add(userInfo);
    }
  }

  return requestUserList;
}
