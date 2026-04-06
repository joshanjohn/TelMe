import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:telme/bloc/clock/clock_cubit.dart';
import 'package:telme/core/providers/providers.dart';

class ClockPage extends ConsumerStatefulWidget {
  const ClockPage({super.key});

  @override
  ConsumerState<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends ConsumerState<ClockPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSuccess() async {
    try {
      await _audioPlayer.play(
        UrlSource(
            'https://www.myinstants.com/media/sounds/ding-sound-effect_2.mp3'),
      );
    } catch (error) {
      debugPrint('Sound error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No authenticated user found.')),
      );
    }

    return BlocProvider(
      create: (_) => ClockCubit(
        shiftRepository: ref.read(shiftRepositoryProvider),
        userId: user.id,
      )..load(),
      child: BlocListener<ClockCubit, ClockState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
        listener: (context, state) async {
          if (state.message == null) {
            return;
          }

          if (state.status != ClockStatus.failure) {
            await _playSuccess();
          }

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.status == ClockStatus.failure
                  ? Colors.red
                  : Colors.green,
            ),
          );
          context.read<ClockCubit>().clearMessage();
        },
        child: const _ClockPageView(),
      ),
    );
  }
}

class _ClockPageView extends StatelessWidget {
  const _ClockPageView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ClockCubit, ClockState>(
      builder: (context, state) {
        if (state.status == ClockStatus.loading ||
            state.status == ClockStatus.initial) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (state.status == ClockStatus.empty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Clock In')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_rounded,
                        size: 80, color: theme.disabledColor),
                    const SizedBox(height: 24),
                    Text(
                      'No shift starting soon.',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: theme.disabledColor),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You can only clock in 10 minutes before your shift starts.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.status == ClockStatus.failure) {
          return Scaffold(
            appBar: AppBar(title: const Text('Clock In/Out')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 72, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message ?? 'Unable to load clock data.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ClockCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final shift = state.currentShift!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Clock In/Out'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                _ShiftSummary(
                    shiftTitle: shift.title,
                    location: shift.location,
                    timeLabel:
                        '${DateFormat.jm().format(shift.startTime)} - ${DateFormat.jm().format(shift.endTime)}'),
                const SizedBox(height: 48),
                if (!state.isClockedOut)
                  _ClockButton(
                    isClockedIn: state.isClockedIn,
                    isSubmitting: state.isSubmitting,
                  )
                else
                  _CompletedMessage(),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShiftSummary extends StatelessWidget {
  const _ShiftSummary({
    required this.shiftTitle,
    required this.location,
    required this.timeLabel,
  });

  final String shiftTitle;
  final String location;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          shiftTitle,
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          location,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(timeLabel,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _ClockButton extends StatelessWidget {
  const _ClockButton({
    required this.isClockedIn,
    required this.isSubmitting,
  });

  final bool isClockedIn;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isSubmitting
          ? null
          : () => context.read<ClockCubit>().submitClockAction(),
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: isClockedIn
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isClockedIn
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary)
                  .withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isClockedIn ? Icons.logout_rounded : Icons.login_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isClockedIn ? 'CLOCK OUT' : 'CLOCK IN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ).animate().scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1.seconds,
          ),
    );
  }
}

class _CompletedMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Shift Completed',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
