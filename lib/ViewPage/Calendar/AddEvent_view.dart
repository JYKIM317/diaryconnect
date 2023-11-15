import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'AddEvent_model.dart';

class AddEventPage extends ConsumerStatefulWidget {
  final DateTime date;
  const AddEventPage({super.key, required this.date});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddEventPageState();
}

class _AddEventPageState extends ConsumerState<AddEventPage> {
  DateTime? selectedDate;
  @override
  void initState() {
    selectedDate = widget.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(''),
    );
  }
}
