import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/shift_services/shift_service.dart';
import 'package:telme/views/sections/shift/shift.dart';

class ListOfShifts extends StatelessWidget {
  ListOfShifts({
    super.key,
    required this.widget,
  });

  final ShiftSection widget;
  final ShiftService _shiftService = ShiftService();

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);

    return StreamBuilder(
      stream: _shiftService.fetchShiftsStream(userId: widget.user.userId ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child:
                  Text('No shifts available for user ${widget.user.userId}'));
        } else {
          List<ShiftModel> shifts = snapshot.data!;
          return ListView.separated(
              itemBuilder: (context, index) {
                ShiftModel shift = shifts[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  textColor: Color.fromARGB(255, 66, 8, 95),
                  tileColor: Color.fromARGB(83, 157, 114, 178),
                  title: RichText(
                    text: TextSpan(
                      text: shift.name,
                      style: _themeData.textTheme.titleMedium,
                      children: [
                        TextSpan(
                            text: '\n${shift.location}',
                            style: _themeData.textTheme.displayLarge!
                                .copyWith(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                  leading: Text(
                    _shiftService.extractShiftStamp(
                      dateTime: shift.startTime,
                      format: 'dd\nMMM',
                    ),
                    style: _themeData.textTheme.displayLarge!
                        .copyWith(color: Color.fromARGB(236, 98, 31, 114)),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_shiftService.extractShiftStamp(
                          dateTime: shift.startTime,
                          format: 'HH:mm',
                        )} \t-\t ${_shiftService.extractShiftStamp(
                          dateTime: shift.endTime,
                          format: 'HH:mm',
                        )}',
                        style: _themeData.textTheme.titleMedium!.copyWith(
                          color: Color.fromARGB(255, 10, 109, 25),
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(CupertinoIcons.ellipsis_vertical),
                );
              },
              separatorBuilder: (context, Index) {
                return SizedBox(
                  height: 10,
                );
              },
              itemCount: shifts.length);
        }
      },
    );
  }
}
