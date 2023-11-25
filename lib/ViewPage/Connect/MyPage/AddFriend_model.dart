import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//해쉬코드로 유저 검색
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

//친구 요청 불러오기
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

//친구신청 로직
Future<bool> requestFriend(String uid) async {
  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
  bool exist = false;
  bool result = true;

  var requestFromFirebase = await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('Request')
      .get();
  List<DocumentSnapshot> requestList = requestFromFirebase.docs.toList();
  for (DocumentSnapshot requestUsers in requestList) {
    if (requestUsers.id == userUID) {
      exist = true;
      result = false;
    }
  }
  if (!exist) {
    result = true;
    final dataFromFirebase =
        await FirebaseFirestore.instance.collection('Users').doc(userUID).get();
    Map<String, dynamic>? myInfo = dataFromFirebase.data();
    myInfo?.remove('LastLogin');
    if (myInfo != null && myInfo.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Request')
          .doc(userUID)
          .set(myInfo);
    }
  }
  return result;
}

//친구요청 수락
Future<void> acceptRequest(String uid) async {
  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
  final requestUser = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Request')
      .doc(uid)
      .get();
  Map<String, dynamic>? requestUserInfo = requestUser.data();
  if (requestUserInfo != null && requestUserInfo.isNotEmpty) {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUID)
        .collection('Friend')
        .doc(uid)
        .set(requestUserInfo)
        .then((value) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userUID)
          .collection('Request')
          .doc(uid)
          .delete();
    });
  }
}

//친구요청 거절
Future<void> deniedRequest(String uid) async {
  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Request')
      .doc(uid)
      .delete();
}
