import 'package:diaryconnect/ViewPage/Connect/MyPage/AddFriend_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import 'package:diaryconnect/main.dart';
import 'package:diaryconnect/Admob_adversting.dart';
import 'package:diaryconnect/Function_callback_control.dart';

class AddFriendPage extends ConsumerStatefulWidget {
  const AddFriendPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends ConsumerState<AddFriendPage> {
  InterstitialAd? _interstitialAd;
  void interstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? InterstitialAdId().android
          : InterstitialAdId().ios,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('$error');
        },
      ),
    );
  }

  Throttle throttle = Throttle(delay: Duration(milliseconds: 300));
  final TextEditingController searchController = TextEditingController();
  String? searchValue;
  bool pageState = true;

  @override
  void initState() {
    interstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Column(
          children: [
            //pageState select
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 47.h),
              alignment: Alignment.bottomCenter,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!pageState) {
                          setState(() {
                            pageState = true;
                          });
                        }
                      },
                      child: Container(
                        height: 68.h,
                        alignment: Alignment.center,
                        color: pageState
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          lang.findFriend,
                          style: TextStyle(
                            color: pageState
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.secondary,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (pageState) {
                          setState(() {
                            pageState = false;
                          });
                        }
                      },
                      child: Container(
                        height: 68.h,
                        alignment: Alignment.center,
                        color: !pageState
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          lang.request,
                          style: TextStyle(
                            color: !pageState
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.secondary,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 34.h),
                child: pageState
                    //find friend page
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 40.h),
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Text(
                              lang.findFriend,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 24.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            height: 80.h,
                            width: double.infinity,
                            padding:
                                EdgeInsets.fromLTRB(20.w, 10.h, 10.w, 10.h),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12.sp),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 3.sp,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  //친구 찾기
                                  child: TextField(
                                    controller: searchController,
                                    maxLines: 1,
                                    decoration: const InputDecoration(
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchValue = value;
                                      });
                                    },
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Text(
                              'Ex) #Qw1E2r',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.6),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 40.h),
                          if (searchValue != null)
                            FutureBuilder(
                              future: searchFriend(searchValue!),
                              initialData: const [],
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox();
                                }
                                List<dynamic> searchList =
                                    snapshot.data.toList();
                                if (searchList.isEmpty) {
                                  return SizedBox(
                                    height: 300.h,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        lang.noUser,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.6),
                                          fontSize: 48.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: searchList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Map<String, dynamic> searchUserInfo =
                                        searchList[index];
                                    String searchUserName =
                                        searchUserInfo['Name'] ?? 'anonymous';
                                    String searchUserHashCode =
                                        searchUserInfo['HashCode'] ?? '#error';
                                    String? searchUserUID =
                                        searchUserInfo['uid'];
                                    return Container(
                                      width: double.infinity,
                                      height: 120.h,
                                      padding: EdgeInsets.fromLTRB(
                                          10.w, 19.h, 10.w, 19.h),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.sp),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                  text: searchUserName,
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
                                                      text: searchUserHashCode,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    )
                                                  ]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              if (searchUserUID != null) {
                                                //전면광고 게재
                                                if (_interstitialAd != null) {
                                                  _interstitialAd?.show();
                                                }
                                                bool? requestResult;
                                                //친구 요청
                                                throttle.run(() async {
                                                  requestResult =
                                                      await requestFriend(
                                                          searchUserUID);
                                                });
                                                Future.microtask(
                                                  () {
                                                    requestResult ?? false
                                                        //친구 요청이 정상적으로 수행 된 경우
                                                        ? ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                            SnackBar(
                                                              content: Center(
                                                                child: Text(
                                                                  lang.requestSucess,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSecondary,
                                                                  ),
                                                                ),
                                                              ),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                            ),
                                                          )
                                                        //상대 목록에 이미 이용자가 있는 경우
                                                        : ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                            SnackBar(
                                                              content: Center(
                                                                child: Text(
                                                                  lang.alreadyRequest,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSecondary,
                                                                  ),
                                                                ),
                                                              ),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                            ),
                                                          );
                                                  },
                                                );
                                              }
                                            },
                                            icon: Icon(
                                              Icons.add,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              size: 28.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(height: 20.h);
                                  },
                                );
                              },
                            ),
                        ],
                      )
                    //Request Page
                    : FutureBuilder(
                        future: getRequestList(),
                        initialData: const [],
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          List<dynamic> requestList = snapshot.data.toList();
                          if (requestList.isEmpty) {
                            return SizedBox(
                              height: 300.h,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  lang.noUser,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.6),
                                    fontSize: 48.sp,
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: requestList.length,
                            itemBuilder: (BuildContext context, int index) {
                              Map<String, dynamic> requestUserInfo =
                                  requestList[index];
                              String requestUserName =
                                  requestUserInfo['Name'] ?? 'anonymous';
                              String requestUserHashCode =
                                  requestUserInfo['HashCode'] ?? '#error';
                              String? requestUserUID = requestUserInfo['uid'];
                              return Container(
                                width: double.infinity,
                                height: 120.h,
                                padding:
                                    EdgeInsets.fromLTRB(10.w, 19.h, 10.w, 19.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.sp),
                                  color:
                                      Theme.of(context).colorScheme.background,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                            text: requestUserName,
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
                                                text: requestUserHashCode,
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
                                          onPressed: () async {
                                            if (requestUserUID != null) {
                                              //요청 수락
                                              throttle.run(() async {
                                                await acceptRequest(
                                                        requestUserUID)
                                                    .then((_) {
                                                  setState(() {});
                                                });
                                              });
                                            }
                                          },
                                          icon: Icon(
                                            Icons.done,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            size: 28.sp,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            if (requestUserUID != null) {
                                              //요청 거절
                                              throttle.run(() async {
                                                await deniedRequest(
                                                        requestUserUID)
                                                    .then((_) {
                                                  setState(() {});
                                                });
                                              });
                                            }
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            size: 28.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 20.h);
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
