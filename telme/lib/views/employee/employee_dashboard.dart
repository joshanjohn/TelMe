import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
          'My Schedule',
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
        label: const Text('Clock In/Out'),
      ),
      body: BlocBuilder<EmployeeScheduleCubit, EmployeeScheduleState>(
        builder: (context, state) {
          return Column(
            children: [
              _WeeklyHeader(selectedDate: state.selectedDate),
              Expanded(child: _ScheduleBody(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _WeeklyHeader extends StatelessWidget {
  const _WeeklyHeader({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = firstDayOfWeek.add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, today);

          return GestureDetector(
            onTap: () => context.read<EmployeeScheduleCubit>().selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isToday
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent),
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
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.bodySmall?.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.titleMedium?.color,
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
                state.errorMessage ?? 'Unable to load your schedule.',
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

    final dailyShifts = state.dailyShifts;
    if (dailyShifts.isEmpty) {
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
                'No shifts for this day.',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.disabledColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: dailyShifts.length,
      itemBuilder: (context, index) {
        final shift = dailyShifts[index];
        final log = state.logForShift(shift.id);
        return _ShiftCard(shift: shift, log: log, index: index);
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
    final isClockedIn = log?.clockIn != null;
    final isClockedOut = log?.clockOut != null;

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
                  _StatusChip(
                      isClockedIn: isClockedIn, isClockedOut: isClockedOut),
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
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
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
  const _StatusChip({
    required this.isClockedIn,
    required this.isClockedOut,
  });

  final bool isClockedIn;
  final bool isClockedOut;

  @override
  Widget build(BuildContext context) {
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
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
