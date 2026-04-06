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
            previous.status != current.status &&
            current.status == ClockStatus.success,
        listener: (context, state) async {
          await _playSuccess();
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
                      'No upcoming shift is ready for clock-in.',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: theme.disabledColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This page only shows the next shift you can clock into.',
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
            appBar: AppBar(title: const Text('Clock In')),
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

        if (state.status == ClockStatus.success) {
          return _ClockSuccessScreen(
            title: state.successTitle ?? 'Clock Successful',
          );
        }

        final shift = state.currentShift!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Upcoming Shift'),
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
                  dateLabel: DateFormat('EEEE, MMM d').format(shift.startTime),
                  timeLabel:
                      '${DateFormat.jm().format(shift.startTime)} - ${DateFormat.jm().format(shift.endTime)}',
                ),
                const SizedBox(height: 48),
                if (!state.isClockedIn)
                  _ClockButton(isSubmitting: state.isSubmitting)
                else
                  const _ClockedInMessage(),
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
    required this.dateLabel,
    required this.timeLabel,
  });

  final String shiftTitle;
  final String location;
  final String dateLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          shiftTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          location,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(dateLabel, style: theme.textTheme.bodyLarge),
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
  const _ClockButton({required this.isSubmitting});

  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isSubmitting
          ? null
          : () => context.read<ClockCubit>().submitClockIn(),
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, size: 48, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'CLOCK IN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.06, 1.06),
            duration: 1400.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .shimmer(
            duration: 1800.ms,
            color: Colors.white.withValues(alpha: 0.2),
          ),
    );
  }
}

class _ClockSuccessScreen extends StatefulWidget {
  const _ClockSuccessScreen({required this.title});

  final String title;

  @override
  State<_ClockSuccessScreen> createState() => _ClockSuccessScreenState();
}

class _ClockSuccessScreenState extends State<_ClockSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (!mounted) {
        return;
      }
      context.read<ClockCubit>().clearSuccessState();
      context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    context.read<ClockCubit>().clearSuccessState();
                    context.go('/dashboard');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              const Spacer(),
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 88,
                  color: Colors.green,
                ),
              ).animate().scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your shift attendance was updated successfully.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Returning to your shift list in 5 seconds.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClockedInMessage extends StatelessWidget {
  const _ClockedInMessage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Already Clocked In',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
