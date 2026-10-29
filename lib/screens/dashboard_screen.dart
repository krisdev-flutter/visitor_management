import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:visitor_management_task/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/bloc/visitor_event.dart';
import 'package:visitor_management_task/bloc/visitor_state.dart';
import 'package:visitor_management_task/widgets/common.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VisitorBloc>().add(const VisitorsRequested());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: const SafeArea(child: _DashboardHome()),
    bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 0) context.go('/dashboard');
        if (index == 1) context.go('/visitors');
        if (index == 2) context.go('/scan');
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt_rounded),
          label: 'Visitors',
        ),
        NavigationDestination(
          icon: Icon(Icons.qr_code_scanner_rounded),
          label: 'Scan QR',
        ),
      ],
    ),
  );
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) => BlocBuilder<VisitorBloc, VisitorState>(
    builder: (context, state) {
      if (state.status == VisitorStatus.loading && state.visitors.isEmpty) {
        return const LoadingView();
      }
      final today = DateUtils.dateOnly(DateTime.now());
      final todayVisitors = state.visitors
          .where((v) => DateUtils.isSameDay(v.createdAt.toLocal(), today))
          .length;
      final checkedOutToday = state.visitors
          .where(
            (v) =>
                v.checkOutTime != null &&
                DateUtils.isSameDay(v.checkOutTime!.toLocal(), today),
          )
          .length;
      return RefreshIndicator(
        onRefresh: () async =>
            context.read<VisitorBloc>().add(const VisitorsRequested()),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM').format(DateTime.now()),
                        style: const TextStyle(
                          color: Color(0xFF75839A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .3,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Good day 👋',
                        style: TextStyle(
                          fontSize: 27,
                          height: 1.1,
                          color: Color(0xFF17243B),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Here is your visitor overview.',
                        style: TextStyle(
                          color: Color(0xFF75839A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EEFF),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: Color(0xFF245BDB),
                    size: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF245BDB), Color(0xFF173A91)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF245BDB).withValues(alpha: .20),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VISITOR OPERATIONS',
                          style: TextStyle(
                            color: Color(0xFFD5E0FF),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${state.visitors.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Total visitor records',
                          style: TextStyle(
                            color: Color(0xFFE1E8FF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.groups_2_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Registered today',
                    value: '$todayVisitors',
                    icon: Icons.person_add_alt_1_rounded,
                    tint: const Color(0xFF245BDB),
                    bg: const Color(0xFFEAF0FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Currently inside',
                    value: '${state.checkedIn}',
                    icon: Icons.login_rounded,
                    tint: const Color(0xFF13845B),
                    bg: const Color(0xFFE5F7EF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricCard(
              title: 'Checked out today',
              value: '$checkedOutToday',
              icon: Icons.task_alt_rounded,
              tint: const Color(0xFF7854C8),
              bg: const Color(0xFFF0EAFF),
              wide: true,
            ),
            const SizedBox(height: 27),
            const Text(
              'Quick actions',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF17243B),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Register visitor',
                    subtitle: 'Add a new record',
                    onTap: () => context.push('/visitor/new'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Scan QR code',
                    subtitle: 'Find and check in',
                    onTap: () => context.push('/scan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent visitors',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF17243B),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/visitors'),
                  child: const Text('View all  →'),
                ),
              ],
            ),
            if (state.status == VisitorStatus.failure && state.visitors.isEmpty)
              EmptyState(
                title: 'Could not load visitors',
                subtitle:
                    state.message ??
                    'Check the MockAPI URL and internet connection.',
              )
            else if (state.visitors.isEmpty)
              const EmptyState(
                title: 'No visitors yet',
                subtitle: 'Register your first visitor to see activity here.',
              )
            else
              ...state.visitors
                  .take(4)
                  .map(
                    (visitor) => VisitorCard(
                      visitor: visitor,
                      onTap: () => context.push(
                        '/visitor/${visitor.id}',
                        extra: visitor,
                      ),
                    ),
                  ),
            if (state.status == VisitorStatus.failure &&
                state.visitors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.message ?? 'Refresh failed',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
    required this.bg,
    this.wide = false,
  });
  final String title, value;
  final IconData icon;
  final Color tint, bg;
  final bool wide;

  @override
  Widget build(BuildContext context) => Container(
    width: wide ? double.infinity : null,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: const Color(0xFFE8EDF5)),
    ),
    child: Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: tint, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.15,
                  color: Color(0xFF17243B),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF75839A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(21),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFE8EDF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF245BDB)),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF17243B),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF75839A), fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}
