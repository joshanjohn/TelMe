import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:go_router/go_router.dart';

class EmployeeDashboard extends ConsumerStatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  ConsumerState<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends ConsumerState<EmployeeDashboard> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.read(authRepositoryProvider).currentUser;
    final shiftsStream = user != null ? ref.watch(shiftRepositoryProvider).myShiftsStream(user.id) : null;
    final logsStream = user != null ? ref.watch(shiftRepositoryProvider).userLogsStream(user.id) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Schedule', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => ref.read(authRepositoryProvider).signOut(), icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clock'),
        icon: const Icon(Icons.alarm_on_rounded),
        label: const Text('Clock In/Out'),
      ),
      body: Column(
        children: [
          _buildWeeklyHeader(theme),
          Expanded(
            child: StreamBuilder<List<Shift>>(
              stream: shiftsStream,
              builder: (context, shiftsSnapshot) {
                if (shiftsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final allShifts = shiftsSnapshot.data ?? [];
                final dailyShifts = allShifts.where((s) => 
                  s.startTime.year == _selectedDate.year &&
                  s.startTime.month == _selectedDate.month &&
                  s.startTime.day == _selectedDate.day
                ).toList();

                if (dailyShifts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note_rounded, size: 64, color: theme.disabledColor),
                          const SizedBox(height: 16),
                          Text('No shifts for this day.', style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor)),
                        ],
                      ),
                    ),
                  );
                }

                return StreamBuilder<List<ShiftLog>>(
                  stream: logsStream,
                  builder: (context, logsSnapshot) {
                    final logs = logsSnapshot.data ?? [];
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: dailyShifts.length,
                      itemBuilder: (context, index) {
                        final shift = dailyShifts[index];
                        final log = logs.firstWhere((l) => l.shiftId == shift.id, orElse: () => ShiftLog(id: '', shiftId: '', userId: '', createdAt: DateTime.now()));
                        
                        return _buildShiftCard(shift, log);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHeader(ThemeData theme) {
    final today = DateTime.now();
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = firstDayOfWeek.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
          final isToday = date.day == today.day && date.month == today.month;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : (isToday ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent),
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected 
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.titleMedium?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShiftCard(Shift shift, ShiftLog log) {
    final theme = Theme.of(context);
    final isClockedIn = log.clockIn != null;
    final isClockedOut = log.clockOut != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => context.push('/shift/${shift.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.work_outline_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shift.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(shift.location, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  _buildStatusChip(isClockedIn, isClockedOut),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeBadge(theme, Icons.login_rounded, DateFormat.jm().format(shift.startTime)),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  _buildTimeBadge(theme, Icons.logout_rounded, DateFormat.jm().format(shift.endTime)),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildTimeBadge(ThemeData theme, IconData icon, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isClockedIn, bool isClockedOut) {
    String text = 'Incoming';
    Color color = Colors.grey;
    if (isClockedOut) {
      text = 'Done';
      color = Colors.green;
    } else if (isClockedIn) {
      text = 'Active';
      color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
