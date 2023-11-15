import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedPage extends ConsumerStatefulWidget {
  const SharedPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SharedPageState();
}

class _SharedPageState extends ConsumerState<SharedPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(),
    );
  }
}
