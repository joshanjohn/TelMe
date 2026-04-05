import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/models/shift_log_model.dart';
import 'package:go_router/go_router.dart';

class ClockPage extends ConsumerStatefulWidget {
  const ClockPage({super.key});

  @override
  ConsumerState<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends ConsumerState<ClockPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSuccess = false;
  Shift? _currentShift;
  ShiftLog? _currentLog;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    
    final repo = ref.read(shiftRepositoryProvider);
    final shift = await repo.getImminentShift(user.id);
    
    if (shift != null) {
      final logs = await repo.userLogsStream(user.id).first;
      final log = logs.firstWhere((l) => l.shiftId == shift.id, orElse: () => ShiftLog(id: '', shiftId: '', userId: '', createdAt: DateTime.now()));
      if (mounted) {
        setState(() {
          _currentShift = shift;
          _currentLog = log;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _playSuccess() async {
    try {
      await _audioPlayer.play(UrlSource('https://www.myinstants.com/media/sounds/ding-sound-effect_2.mp3'));
    } catch (e) {
      debugPrint("Sound error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentShift == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clock In')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy_rounded, size: 80, color: theme.disabledColor),
                const SizedBox(height: 24),
                Text('No shift starting soon.', style: theme.textTheme.headlineSmall?.copyWith(color: theme.disabledColor)),
                const SizedBox(height: 12),
                const Text('You can only clock in 10 minutes before your shift starts.', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    final isClockedIn = _currentLog?.clockIn != null;
    final isClockedOut = _currentLog?.clockOut != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In/Out'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Spacer(),
            _buildShiftSummary(theme),
            const SizedBox(height: 48),
            if (!isClockedOut)
              _buildClockButton(theme, isClockedIn)
            else
              _buildCompletedMessage(theme),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftSummary(ThemeData theme) {
    return Column(
      children: [
        Text(_currentShift!.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_currentShift!.location, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${DateFormat.jm().format(_currentShift!.startTime)} - ${DateFormat.jm().format(_currentShift!.endTime)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildClockButton(ThemeData theme, bool isClockedIn) {
    return GestureDetector(
      onTap: () => _handleClock(isClockedIn),
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: isClockedIn ? theme.colorScheme.secondary : theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isClockedIn ? theme.colorScheme.secondary : theme.colorScheme.primary).withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isClockedIn ? Icons.logout_rounded : Icons.login_rounded, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(isClockedIn ? 'CLOCK OUT' : 'CLOCK IN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ],
          ),
        ),
      )
      .animate(target: _isSuccess ? 1 : 0)
      .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), curve: Curves.elasticOut)
      .then()
      .animate(onPlay: (controller) => controller.repeat(reverse: true))
      .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds),
    );
  }

  Widget _buildCompletedMessage(ThemeData theme) {
    return Column(
      children: [
        const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        Text('Shift Completed', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _handleClock(bool isClockedIn) async {
    try {
      final repo = ref.read(shiftRepositoryProvider);
      final userId = ref.read(authRepositoryProvider).currentUser!.id;
      
      if (!isClockedIn) {
        await repo.clockIn(_currentShift!.id, userId);
        _playSuccess();
        setState(() => _isSuccess = true);
        Future.delayed(1.seconds, () {
          if (mounted) setState(() => _isSuccess = false);
        });
      } else {
        await repo.clockOut(_currentShift!.id, userId);
        _playSuccess();
      }
      _loadData(); // Refresh info
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }
}
