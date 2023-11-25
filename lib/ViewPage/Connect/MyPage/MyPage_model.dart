import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> getMyData() async {
  Map<String, dynamic> myData = {};
  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  final dataFromFirebase =
      await FirebaseFirestore.instance.collection('Users').doc(userUID).get();
  Map<String, dynamic>? myInfo = dataFromFirebase.data();
  //혹시 내 정보가 없을 경우에 업데이트
  if (myInfo == null || myInfo.isEmpty) {
    final String hashcode = userUID.substring(0, 4) +
        userUID.substring(13, 15) +
        userUID.substring(27, 28);
    await FirebaseFirestore.instance.collection('Users').doc(userUID).set({
      'Name': 'anonymous',
      'HashCode': '#$hashcode',
      'uid': userUID,
    });
    myInfo = {
      'Name': 'anonymous',
      'HashCode': '#$hashcode',
      'uid': userUID,
    };
  }
  myData = myInfo;
  return myData;
}

Future<List<Map<String, dynamic>>> getFriendList() async {
  List<Map<String, dynamic>> friendList = [];
  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  final dataFromFirebase = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Friend')
      .get();
  List<DocumentSnapshot> dataList = dataFromFirebase.docs.toList();
  if (dataList.isNotEmpty) {
    for (DocumentSnapshot index in dataList) {
      final firendInfo = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userUID)
          .collection('Friend')
          .doc(index.id)
          .get();
      Map<String, dynamic>? friendData = firendInfo.data();
      if (friendData != null) {
        friendList.add(friendData);
      }
    }
  }

  return friendList;
}

Future<void> modifyMyName(String name) async {
  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('Users').doc(userUID).update({
    'Name': name,
  });
}

Future<void> deleteFriend(String uid) async {
  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('Friend')
      .doc(userUID)
      .delete();
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Friend')
      .doc(uid)
      .delete();
}
