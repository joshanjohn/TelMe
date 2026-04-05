import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/models/user_model.dart';
import 'package:telme/services/shift_services/shift_service.dart';
import 'package:telme/services/user_services/user_service.dart';
import 'package:telme/utils/constants/Image_string.dart';
import 'package:telme/utils/helpers/helper_function.dart';

class ListOfShifts extends StatefulWidget {
  const ListOfShifts({
    super.key,
  });

  @override
  State<ListOfShifts> createState() => _ListOfShiftsState();
}

class _ListOfShiftsState extends State<ListOfShifts> {
  final ShiftService _shiftService = ShiftService();
  UserModel? user;

  @override
  void initState() {
    _initUser();
    super.initState();
  }

  // fetching user id from shared preference
  Future<void> _initUser() async {
    try {
      user = await UserService().getUserInfo();
      print("User fetched successfully: ${user?.name}");
    } catch (e) {
      print("Error fetching user info: $e");
      // Optionally handle error state
    } finally {
      setState(() {}); // Trigger a rebuild after fetching
    }
  }

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);

    // Check if user is null before building the StreamBuilder
    if (user == null) {
      return const Center(
        child:
            CircularProgressIndicator(), // Show a loading indicator while user is being fetched
      );
    }

    // Ensure userId is non-null before using it in the stream
    final userId = user?.userId ?? '';

    return StreamBuilder<List<ShiftModel>>(
      stream: userId.isNotEmpty
          ? _shiftService.fetchShiftsStream(userId: userId)
          : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.no_shift),
                Text(
                  'No upcoming Shifts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        } else {
          List<ShiftModel> shifts = snapshot.data!;
          return ListView.separated(
            itemBuilder: (context, index) {
              ShiftModel shift = shifts[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                textColor: const Color.fromARGB(255, 66, 8, 95),
                tileColor: const Color.fromARGB(83, 157, 114, 178),
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
                  AppHelper.extractShiftStamp(
                    dateTime: shift.startTime,
                    format: 'dd\nMMM',
                  ),
                  style: _themeData.textTheme.displayLarge!
                      .copyWith(color: const Color.fromARGB(236, 98, 31, 114)),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppHelper.extractShiftStamp(
                        dateTime: shift.startTime,
                        format: 'HH:mm',
                      )} \t-\t ${AppHelper.extractShiftStamp(
                        dateTime: shift.endTime,
                        format: 'HH:mm',
                      )}',
                      style: _themeData.textTheme.titleMedium!.copyWith(
                        color: const Color.fromARGB(255, 10, 109, 25),
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(CupertinoIcons.ellipsis_vertical),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 10,
              );
            },
            itemCount: shifts.length,
          );
        }
      },
    );
  }
}
