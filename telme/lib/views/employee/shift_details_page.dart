import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/models/shift_model.dart';
import 'package:go_router/go_router.dart';

class ShiftDetailsPage extends ConsumerWidget {
  final String shiftId;
  const ShiftDetailsPage({super.key, required this.shiftId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shiftFuture =
        ref.watch(shiftRepositoryProvider).getShiftById(shiftId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<Shift>(
        future: shiftFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final shift = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme, shift),
                const SizedBox(height: 32),
                _buildInfoSection(
                    theme,
                    'Date & Time',
                    [
                      DateFormat('EEEE, MMM dd').format(shift.startTime),
                      '${DateFormat.jm().format(shift.startTime)} - ${DateFormat.jm().format(shift.endTime)}',
                    ],
                    Icons.calendar_today_rounded),
                const SizedBox(height: 24),
                _buildInfoSection(
                    theme,
                    'Location',
                    [
                      shift.location,
                    ],
                    Icons.location_on_rounded, action: () {
                  // Map launch logic could go here
                }),
                const SizedBox(height: 24),
                _buildColleaguesSection(theme, shift),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => context.push('/clock'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Go to Clock-In',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Shift shift) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.work_outline_rounded,
              size: 48, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Text(shift.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoSection(
      ThemeData theme, String title, List<String> items, IconData icon,
      {VoidCallback? action}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...items.map(
                    (text) => Text(text, style: theme.textTheme.bodyLarge)),
              ],
            ),
          ),
          if (action != null)
            IconButton(
                onPressed: action,
                icon: const Icon(Icons.open_in_new_rounded, size: 20)),
        ],
      ),
    );
  }

  Widget _buildColleaguesSection(ThemeData theme, Shift shift) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Colleagues',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        if (shift.assignedEmployees.isEmpty)
          const Text('No colleagues assigned for this shift.')
        else
          ...shift.assignedEmployees.map((profile) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.secondary.withValues(alpha: 0.2),
                  child: Text(profile.fullName[0].toUpperCase(),
                      style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold)),
                ),
                title: Text(profile.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(profile.email, style: theme.textTheme.bodySmall),
              )),
      ],
    );
  }
}
