class ShiftLog {
  final String id;
  final String shiftId;
  final String userId;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final DateTime createdAt;

  ShiftLog({
    required this.id,
    required this.shiftId,
    required this.userId,
    this.clockIn,
    this.clockOut,
    required this.createdAt,
  });

  factory ShiftLog.fromJson(Map<String, dynamic> json) {
    return ShiftLog(
      id: json['id'],
      shiftId: json['shift_id'],
      userId: json['user_id'],
      clockIn: json['clock_in'] != null ? DateTime.parse(json['clock_in']) : null,
      clockOut: json['clock_out'] != null ? DateTime.parse(json['clock_out']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift_id': shiftId,
      'user_id': userId,
      'clock_in': clockIn?.toIso8601String(),
      'clock_out': clockOut?.toIso8601String(),
    };
  }
}
