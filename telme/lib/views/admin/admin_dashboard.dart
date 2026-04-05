import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/models/shift_model.dart';
import 'package:telme/models/profile_model.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Stats'),
            Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Calendar'),
            Tab(icon: Icon(Icons.people_outline_rounded), text: 'Staff'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showShiftForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Shift'),
      ).animate().scale(delay: 400.ms),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildCalendarTab(),
          _buildStaffTab(),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final theme = Theme.of(context);
    final shiftsStream = ref.watch(shiftRepositoryProvider).shiftsStream;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Stats', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                StreamBuilder<List<Shift>>(
                  stream: shiftsStream,
                  builder: (context, snapshot) {
                    final totalShifts = snapshot.data?.length ?? 0;
                    return FutureBuilder<List<Profile>>(
                      future: ref.read(authRepositoryProvider).getAllProfiles(),
                      builder: (context, profileSnapshot) {
                        final totalStaff = profileSnapshot.data?.where((p) => p.role == UserRole.employee).length ?? 0;
                        return Row(
                          children: [
                            _buildStatCard('Total Shifts', totalShifts.toString(), Icons.calendar_today_rounded),
                            const SizedBox(width: 16),
                            _buildStatCard('Total Staff', totalStaff.toString(), Icons.people_rounded),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Text('Upcoming Shifts', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        StreamBuilder<List<Shift>>(
          stream: shiftsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text('Database Error: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  ),
                ),
              );
            }
            if (!snapshot.hasData) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            final shifts = snapshot.data!;
            if (shifts.isEmpty) return const SliverFillRemaining(child: Center(child: Text('No upcoming shifts found.')));
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildShiftCard(shifts[index], index),
                childCount: shifts.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarTab() {
    final theme = Theme.of(context);
    final shiftsStream = ref.watch(shiftRepositoryProvider).shiftsStream;

    return StreamBuilder<List<Shift>>(
      stream: shiftsStream,
      builder: (context, snapshot) {
        final shifts = snapshot.data ?? [];
        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              eventLoader: (day) {
                return shifts.where((s) => isSameDay(s.startTime, day)).toList();
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: theme.colorScheme.secondary, shape: BoxShape.circle),
              ),
            ).animate().fadeIn(),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: shifts
                    .where((s) => isSameDay(s.startTime, _selectedDay))
                    .map((s) => _buildShiftCard(s, 0, minimal: true))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStaffTab() {
    return FutureBuilder<List<Profile>>(
      future: ref.read(authRepositoryProvider).getAllProfiles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final staff = snapshot.data!.where((p) => p.role == UserRole.employee).toList();
        
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final person = staff[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(person.fullName[0].toUpperCase()),
                ),
                title: Text(person.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(person.email),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // View individual performance, etc.
                },
              ),
            ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
          },
        );
      },
    );
  }

  Widget _buildShiftCard(Shift shift, int index, {bool minimal = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Card(
        child: ListTile(
          onTap: () => _showShiftForm(context, shift: shift),
          title: Text(shift.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [const Icon(Icons.access_time, size: 14), const SizedBox(width: 4), Text(DateFormat('MMM d, HH:mm').format(shift.startTime))]),
              if (!minimal) Text('${shift.assignedEmployees.length} assigned employees', style: TextStyle(color: theme.colorScheme.primary)),
            ],
          ),
          trailing: const Icon(Icons.edit_outlined, size: 20),
        ),
      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _showShiftForm(BuildContext context, {Shift? shift}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShiftFormSheet(shift: shift),
    );
  }
}

class _ShiftFormSheet extends ConsumerStatefulWidget {
  final Shift? shift;
  const _ShiftFormSheet({this.shift});

  @override
  ConsumerState<_ShiftFormSheet> createState() => _ShiftFormSheetState();
}

class _ShiftFormSheetState extends ConsumerState<_ShiftFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late DateTime _startTime;
  late DateTime _endTime;
  List<Profile> _assigned = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.shift?.title);
    _locationController = TextEditingController(text: widget.shift?.location);
    _startTime = widget.shift?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    _endTime = widget.shift?.endTime ?? _startTime.add(const Duration(hours: 8));
    _assigned = widget.shift?.assignedEmployees ?? [];
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _endTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
    );
    if (time == null) return;

    setState(() {
      final newDt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _startTime = newDt;
        if (_endTime.isBefore(_startTime)) _endTime = _startTime.add(const Duration(hours: 8));
      } else {
        _endTime = newDt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.shift == null ? 'Create Shift' : 'Edit Shift', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (widget.shift != null)
                  IconButton(
                    onPressed: () async {
                      await ref.read(shiftRepositoryProvider).deleteShift(widget.shift!.id);
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Job Title', prefixIcon: Icon(Icons.work_outline))),
            const SizedBox(height: 16),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start'),
                    subtitle: Text(DateFormat('MMM d, HH:mm').format(_startTime)),
                    onTap: () => _pickDateTime(true),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded),
                Expanded(
                  child: ListTile(
                    title: const Text('End'),
                    subtitle: Text(DateFormat('MMM d, HH:mm').format(_endTime)),
                    onTap: () => _pickDateTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ref.watch(allEmployeesProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (profiles) {
                final staff = profiles
                    .where((p) => p.role == UserRole.employee)
                    .toList();
                    
                return MultiSelectBottomSheetField<Profile?>(
                  initialValue: _assigned,
                  initialChildSize: 0.4,
                  listType: MultiSelectListType.CHIP,
                  searchable: true,
                  buttonText: const Text("Assign Employees"),
                  title: const Text("Staff"),
                  items: staff.map((p) => MultiSelectItem<Profile?>(p, p.fullName)).toList(),
                  onConfirm: (List<Profile?> values) => setState(() => _assigned = values.whereType<Profile>().toList()),
                  chipDisplay: MultiSelectChipDisplay(
                    items: _assigned.map((p) => MultiSelectItem<Profile?>(p, p.fullName)).toList(),
                    onTap: (item) => setState(() => _assigned.removeWhere((p) => p.id == (item as Profile?)?.id)),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                setState(() => _isSaving = true);
                try {
                  final shift = Shift(
                    id: widget.shift?.id ?? '',
                    title: _titleController.text,
                    location: _locationController.text,
                    startTime: _startTime,
                    endTime: _endTime,
                    createdBy: ref.read(authRepositoryProvider).currentUser?.id,
                    createdAt: widget.shift?.createdAt ?? DateTime.now(),
                  );
                  
                  // Use ToSet() to avoid DUPLICATE KEY violations
                  final ids = _assigned.map((p) => p.id).toSet().toList();
                  
                  if (widget.shift == null) {
                    await ref.read(shiftRepositoryProvider).createShift(shift, ids);
                  } else {
                    await ref.read(shiftRepositoryProvider).updateShift(shift, ids);
                  }
                  if (mounted) Navigator.pop(context);
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
              },
              child: _isSaving ? const CircularProgressIndicator() : Text(widget.shift == null ? 'Create' : 'Save Changes'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
