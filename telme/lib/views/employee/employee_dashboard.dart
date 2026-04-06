import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:telme/bloc/employee_schedule/employee_schedule_cubit.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:telme/models/shift_model.dart';

class EmployeeDashboard extends ConsumerWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No authenticated user found.')),
      );
    }

    return BlocProvider(
      create: (_) => EmployeeScheduleCubit(
        shiftRepository: ref.read(shiftRepositoryProvider),
        userId: user.id,
      )..subscribe(),
      child: const _EmployeeDashboardView(),
    );
  }
}

class _EmployeeDashboardView extends StatelessWidget {
  const _EmployeeDashboardView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Weekly Shifts',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                icon: const Icon(Icons.logout_rounded),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clock'),
        icon: const Icon(Icons.alarm_on_rounded),
        label: const Text('Clock In'),
      ),
      body: BlocBuilder<EmployeeScheduleCubit, EmployeeScheduleState>(
        builder: (context, state) {
          return Column(
            children: [
              _WeekPicker(state: state),
              Expanded(child: _ScheduleBody(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _WeekPicker extends StatelessWidget {
  const _WeekPicker({required this.state});

  final EmployeeScheduleState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a week',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat('MMM d').format(state.weekStart)} - ${DateFormat('MMM d, y').format(state.weekEnd)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TableCalendar<void>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: state.selectedDate,
            calendarFormat: CalendarFormat.week,
            availableCalendarFormats: const {
              CalendarFormat.week: 'Week',
            },
            selectedDayPredicate: (day) => _isSameDay(day, state.selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              context.read<EmployeeScheduleCubit>().selectDate(selectedDay);
            },
            onPageChanged: (focusedDay) {
              context.read<EmployeeScheduleCubit>().selectDate(focusedDay);
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: false,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleBody extends StatelessWidget {
  const _ScheduleBody({required this.state});

  final EmployeeScheduleState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.status == EmployeeScheduleStatus.loading &&
        state.shifts.isEmpty &&
        state.logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == EmployeeScheduleStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Unable to load your weekly schedule.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<EmployeeScheduleCubit>().subscribe(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final weeklyShifts = state.weeklyShifts;
    if (weeklyShifts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note_rounded,
                  size: 64, color: theme.disabledColor),
              const SizedBox(height: 16),
              Text(
                'No shifts scheduled for this week.',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.disabledColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final groupedShifts = <DateTime, List<Shift>>{};
    for (final shift in weeklyShifts) {
      final dayKey = DateTime(
          shift.startTime.year, shift.startTime.month, shift.startTime.day);
      groupedShifts.putIfAbsent(dayKey, () => []).add(shift);
    }

    final weekDays = List.generate(
      7,
      (index) => state.weekStart.add(Duration(days: index)),
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: weekDays.length,
      itemBuilder: (context, dayIndex) {
        final day = weekDays[dayIndex];
        final dayKey = DateTime(day.year, day.month, day.day);
        final dayShifts = groupedShifts[dayKey] ?? const <Shift>[];

        return _DaySection(
          day: day,
          shifts: dayShifts,
          state: state,
          dayIndex: dayIndex,
        );
      },
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.shifts,
    required this.state,
    required this.dayIndex,
  });

  final DateTime day;
  final List<Shift> shifts;
  final EmployeeScheduleState state;
  final int dayIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(day),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (shifts.isEmpty)
            Text(
              'No shifts',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.disabledColor),
            )
          else
            ...shifts.asMap().entries.map(
                  (entry) => _ShiftCard(
                    shift: entry.value,
                    log: state.logForShift(entry.value.id),
                    index: (dayIndex * 10) + entry.key,
                  ),
                ),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.shift,
    required this.log,
    required this.index,
  });

  final Shift shift;
  final ShiftLog? log;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusForShift(shift, log);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    child: Icon(Icons.work_outline_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shift.title,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(shift.location, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TimeBadge(
                    icon: Icons.login_rounded,
                    time: DateFormat.jm().format(shift.startTime),
                  ),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  _TimeBadge(
                    icon: Icons.logout_rounded,
                    time: DateFormat.jm().format(shift.endTime),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.1, end: 0);
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.icon, required this.time});

  final IconData icon;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Text(time,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ShiftStatusView status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ShiftStatusView {
  const ShiftStatusView({required this.label, required this.color});

  final String label;
  final Color color;
}

ShiftStatusView _statusForShift(Shift shift, ShiftLog? log) {
  final now = DateTime.now();

  if (log?.clockOut != null || now.isAfter(shift.endTime)) {
    return const ShiftStatusView(label: 'Ended', color: Colors.green);
  }

  if (log?.clockIn != null && now.isBefore(shift.startTime)) {
    return const ShiftStatusView(label: 'Started', color: Colors.orange);
  }

  if ((log?.clockIn != null && now.isBefore(shift.endTime)) ||
      (now.isAfter(shift.startTime) && now.isBefore(shift.endTime))) {
    return const ShiftStatusView(label: 'In Progress', color: Colors.blue);
  }

  return const ShiftStatusView(label: 'Upcoming', color: Colors.grey);
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
