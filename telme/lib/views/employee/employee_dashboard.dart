import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/models/shift_log_model.dart';

class EmployeeDashboard extends ConsumerWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.read(authRepositoryProvider).currentUser;
    final shiftsStream = user != null ? ref.watch(shiftRepositoryProvider).myShiftsStream(user.id) : null;
    final logsStream = user != null ? ref.watch(shiftRepositoryProvider).userLogsStream(user.id) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Shifts', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => ref.read(authRepositoryProvider).signOut(), icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: StreamBuilder<List<Shift>>(
        stream: shiftsStream,
        builder: (context, shiftsSnapshot) {
          if (shiftsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!shiftsSnapshot.hasData || shiftsSnapshot.data!.isEmpty) {
            return const Center(child: Text('No shifts assigned to you yet.'));
          }

          final shifts = shiftsSnapshot.data!;

          return StreamBuilder<List<ShiftLog>>(
            stream: logsStream,
            builder: (context, logsSnapshot) {
              final logs = logsSnapshot.data ?? [];
              
              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final shift = shifts[index];
                  final log = logs.firstWhere((l) => l.shiftId == shift.id, orElse: () => ShiftLog(id: '', shiftId: '', userId: '', createdAt: DateTime.now()));
                  
                  return _buildShiftCard(context, ref, shift, log);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, WidgetRef ref, Shift shift, ShiftLog log) {
    final theme = Theme.of(context);
    final isClockedIn = log.clockIn != null;
    final isClockedOut = log.clockOut != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(shift.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                _buildStatusChip(isClockedIn, isClockedOut),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.location_on_outlined, size: 18), const SizedBox(width: 8), Text(shift.location)]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.access_time, size: 18), const SizedBox(width: 8), Text('${DateFormat('MMM dd, yyyy').format(shift.startTime)} • ${DateFormat.jm().format(shift.startTime)} - ${DateFormat.jm().format(shift.endTime)}')]),
            const SizedBox(height: 24),
            
            if (!isClockedOut)
              ElevatedButton(
                onPressed: () => _handleClock(context, ref, shift, isClockedIn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isClockedIn ? theme.colorScheme.secondary : theme.colorScheme.primary,
                ),
                child: Text(isClockedIn ? 'Clock Out' : 'Clock In'),
              ),
            
            if (isClockedIn) ...[
              const SizedBox(height: 12),
              Text('Clocked In: ${DateFormat.jm().format(log.clockIn!)}', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            ],
            if (isClockedOut) ...[
              const SizedBox(height: 4),
              Text('Clocked Out: ${DateFormat.jm().format(log.clockOut!)}', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatusChip(bool isClockedIn, bool isClockedOut) {
    String text = 'Incoming';
    Color color = Colors.grey;
    if (isClockedOut) {
      text = 'Completed';
      color = Colors.green;
    } else if (isClockedIn) {
      text = 'Active';
      color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _handleClock(BuildContext context, WidgetRef ref, Shift shift, bool isClockedIn) async {
    try {
      final repo = ref.read(shiftRepositoryProvider);
      final userId = ref.read(authRepositoryProvider).currentUser!.id;
      
      if (!isClockedIn) {
        await repo.clockIn(shift.id, userId);
      } else {
        await repo.clockOut(shift.id, userId);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }
}
