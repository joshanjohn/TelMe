import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/services/shift_services/shift_service.dart';
import 'package:telme/utils/common/widgets/custom_textfield.dart';
import 'package:telme/views/widgets/shift/custom_date_time_picker.dart';

class AddShift extends StatelessWidget {
  AddShift({super.key});

  final ShiftService _shift = ShiftService();

  final GlobalKey<FormState> _addShiftFormKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final ValueNotifier<DateTime?> _startDateTimeTimeNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> _endDateTimeNotifier =
      ValueNotifier<DateTime?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(71, 202, 199, 203),
        title: const Text(
          "Add Shift",
          style: TextStyle(color: Color.fromARGB(210, 75, 48, 80)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _addShiftFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // name of shift
                const SizedBox(height: 30),

                CustomTextField(
                  controller: _nameController,
                  label: "Name",
                ),
                const SizedBox(height: 20),

                // location name
                CustomTextField(
                  controller: _locationController,
                  label: "Location",
                ),
                const SizedBox(height: 20),

                // shift start date and time
                ValueListenableBuilder<DateTime?>(
                  valueListenable: _startDateTimeTimeNotifier,
                  builder: (context, startShiftDateTime, child) {
                    return CustomDateTimePicker(
                      pickLabel: "Start Shift",
                      onDateTimeChanged: (dateTime) {
                        _startDateTimeTimeNotifier.value = dateTime;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // shift end date and time
                ValueListenableBuilder<DateTime?>(
                  valueListenable: _endDateTimeNotifier,
                  builder: (context, endShiftDateTime, child) {
                    return CustomDateTimePicker(
                      pickLabel: "End Shift",
                      onDateTimeChanged: (dateTime) {
                        _endDateTimeNotifier.value = dateTime;
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      if (_addShiftFormKey.currentState!.validate() &&
                          _startDateTimeTimeNotifier.value != null &&
                          _endDateTimeNotifier != null) {
                        _shift.addShift(
                          ShiftModel(
                            name: _nameController.text,
                            location: _locationController.text,
                            startTime: _startDateTimeTimeNotifier.value!,
                            endTime: _endDateTimeNotifier.value!,
                          ),context
                        ).then((value){
                        context.pop();
                        });
                      }
                    },
                    child: const Text(
                      'Submit',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
