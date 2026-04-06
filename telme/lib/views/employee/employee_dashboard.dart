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
    final monthLabel = DateFormat('MMMM y').format(state.selectedDate);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextFormatter: (_, __) => monthLabel,
            ),
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) {
                return Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: state.selectedDate,
                        firstDate: DateTime.utc(2024, 1, 1),
                        lastDate: DateTime.utc(2030, 12, 31),
                      );
                      if (!context.mounted || selected == null) {
                        return;
                      }
                      context
                          .read<EmployeeScheduleCubit>()
                          .selectDate(selected);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            monthLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.expand_more_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: weeklyShifts.length,
      itemBuilder: (context, index) {
        final shift = weeklyShifts[index];
        return _ShiftCard(
          shift: shift,
          log: state.logForShift(shift.id),
          index: index,
        );
      },
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
