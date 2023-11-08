import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntryWrite extends ConsumerStatefulWidget {
  const EntryWrite({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntryWriteState();
}

class _EntryWriteState extends ConsumerState<EntryWrite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 24.h, 10.w, 0),
        child: SingleChildScrollView(
          child: SizedBox(),
        ),
      ),
    );
  }
}
