import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatefulWidget {
  final String pickLabel;
  final DateTime? initialDateTime;
  final ValueChanged<DateTime?> onDateTimeChanged;

  CustomDateTimePicker({
    required this.pickLabel,
    required this.onDateTimeChanged,
    this.initialDateTime,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  // Display the selected date and time
  String _showSelectedTime() {
    return _selectedDateTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!)
        : 'PICK ${widget.pickLabel.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
        padding: EdgeInsets.all(0),
        splashFactory: NoSplash.splashFactory,
       overlayColor: Colors.transparent,

      ),
      onPressed: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(
            const Duration(days: 365 * 24),
          ),
        );
        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            
            context: context,
            initialTime:
                TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
          );

          if (pickedTime != null) {
            setState(() {
              _selectedDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              widget.onDateTimeChanged(_selectedDateTime);
            });
          }
        }
      },
      label: Text(_showSelectedTime()),
      icon: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          color: const Color.fromARGB(76, 167, 114, 231),
          child: const Icon(
            Icons.calendar_month,
            size: 40,
          ),
        ),
      ),
    );
  }
}
