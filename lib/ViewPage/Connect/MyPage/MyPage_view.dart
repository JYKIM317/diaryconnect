import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'MyPage_model.dart';
import 'AddFriend_view.dart';
import 'package:diaryconnect/main.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  final TextEditingController nameController = TextEditingController();
  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 28.sp,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFriendPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.person_add_alt_1,
                size: 28.sp,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.primaryContainer,
        padding: EdgeInsets.fromLTRB(20.w, 47.h, 20.w, 34.h),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 120.h,
                padding: EdgeInsets.fromLTRB(10.w, 19.h, 10.w, 19.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  color: Theme.of(context).colorScheme.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12.sp,
                      offset: Offset(8.w, 10.h),
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    FutureBuilder(
                        future: getMyData(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) return const SizedBox();
                          Map<String, dynamic> myInfo = snapshot.data;
                          final String myName = myInfo['Name'] ?? 'anonymous';
                          final String myHashCode = myInfo['HashCode'] ??
                              userUID!.substring(0, 4) +
                                  userUID!.substring(13, 15) +
                                  userUID!.substring(27, 28);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                      text: myName,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [
                                        const TextSpan(text: ' '),
                                        TextSpan(
                                          text: myHashCode,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: myHashCode));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Center(
                                            child: Text(
                                              lang.copySucess,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary,
                                              ),
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.content_copy,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: 28.sp,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      //알러트 보여주고 이름 받은 후 수정하는 로직
                                      String modifyName = myName;
                                      if (userUID != null) {
                                        nameController.text = myName;
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: TextField(
                                                controller: nameController,
                                                maxLines: 1,
                                                onChanged: (value) =>
                                                    modifyName = value,
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text(lang.cancel,
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14.sp,
                                                      )),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(lang.save,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontSize: 14.sp,
                                                      )),
                                                  onPressed: () async {
                                                    //수정된 내용 없을 시 팝
                                                    if (modifyName == myName) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    } else {
                                                      //firebase에 저장하는 로직
                                                      await modifyMyName(
                                                          modifyName);
                                                      Future.microtask(() {
                                                        Navigator.pop(context);
                                                        setState(() {});
                                                      });
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      Icons.border_color,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: 28.sp,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        }),
                    Transform.translate(
                      offset: Offset(4.w, -12.h),
                      child: Text(
                        lang.me,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10.w, 0, 0, 14.h),
                child: Text(
                  lang.friend,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 24.sp,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              FutureBuilder(
                  future: getFriendList(),
                  initialData: const [],
                  builder: (BuildContext contex, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    List<dynamic> friendList = snapshot.data.toList();
                    if (friendList.isEmpty) {
                      return SizedBox(
                        height: 300.h,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            lang.empty,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.6),
                              fontSize: 78.sp,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: friendList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> firendInfo = friendList[index];
                        String friendName = firendInfo['Name'] ?? 'anonymous';
                        String friendHashCode =
                            firendInfo['HashCode'] ?? '#error';
                        String? friendUID = firendInfo['uid'];
                        return Container(
                          width: double.infinity,
                          height: 120.h,
                          padding: EdgeInsets.fromLTRB(10.w, 19.h, 10.w, 19.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.sp),
                            color: Theme.of(context).colorScheme.background,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12.sp,
                                offset: Offset(8.w, 10.h),
                              ),
                            ],
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                      text: friendName,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [
                                        const TextSpan(text: ' '),
                                        TextSpan(
                                          text: friendHashCode,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    if (friendUID != null) {
                                      //친구삭제
                                      await deleteFriend(friendUID);
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 28.sp,
                                  ))
                            ],
                          ),
                        );
                      },
                      separatorBuilder: ((context, index) {
                        return SizedBox(height: 20.h);
                      }),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
