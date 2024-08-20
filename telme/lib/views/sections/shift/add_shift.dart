import 'package:flutter/material.dart';
import 'package:telme/views/widgets/common/custom_textfield.dart';
import 'package:telme/views/widgets/shift/custom_date_time_picker.dart';

class AddShift extends StatelessWidget {
  AddShift({super.key});

  final GlobalKey<FormState> _addShiftFormKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _startShiftDateTime;
  DateTime? _endShiftDateTime;

  @override
  Widget build(BuildContext context) {
    final ThemeData _themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 212, 223),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(72, 67, 31, 82),
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
                CustomDateTimePicker(
                  pickLabel: "Start Shift",
                  initialDateTime: _startShiftDateTime,
                  onDateTimeChanged: (dateTime) {
                    _startShiftDateTime = dateTime;
                  },
                ),
                const SizedBox(height: 20),
          
                // shift end date and time
                CustomDateTimePicker(
                  pickLabel: "End Shift",
                  initialDateTime: _endShiftDateTime,
                  onDateTimeChanged: (dateTime) {
                    _endShiftDateTime = dateTime;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      if (_addShiftFormKey.currentState!.validate()) {
                        // Form is valid, proceed with further actions
                        print("Start Shift: $_startShiftDateTime");
                        print("End Shift: $_endShiftDateTime");
                        // Further processing can be done here
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
