import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteConnectDiary(String diaryName) async {
  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Diary')
      .doc(diaryName)
      .delete();
}
