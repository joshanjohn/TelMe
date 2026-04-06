import 'package:flutter_test/flutter_test.dart';
import 'package:telme/models/profile_model.dart';
import 'package:telme/models/shift_model.dart';

void main() {
  test('Shift.fromJson maps assigned employees correctly', () {
    final shift = Shift.fromJson({
      'id': 'shift-1',
      'title': 'Morning Shift',
      'location': 'Dublin',
      'start_time': '2026-04-06T08:00:00.000Z',
      'end_time': '2026-04-06T16:00:00.000Z',
      'created_at': '2026-04-05T12:00:00.000Z',
      'assigned_employees': [
        {
          'id': 'user-1',
          'full_name': 'Alex Doe',
          'email': 'alex@example.com',
          'role': 'employee',
          'created_at': '2026-04-01T09:00:00.000Z',
        },
      ],
    });

    expect(shift.id, 'shift-1');
    expect(shift.assignedEmployees, hasLength(1));
    expect(shift.assignedEmployees.first.fullName, 'Alex Doe');
    expect(shift.assignedEmployees.first.role, UserRole.employee);
  });

  test('Profile.toJson preserves the user role name', () {
    final profile = Profile(
      id: 'admin-1',
      fullName: 'Taylor Admin',
      email: 'taylor@example.com',
      role: UserRole.admin,
      createdAt: DateTime.utc(2026, 4, 6),
    );

    expect(profile.toJson()['role'], 'admin');
  });
}
