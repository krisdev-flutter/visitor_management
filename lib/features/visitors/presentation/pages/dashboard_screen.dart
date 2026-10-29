import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:visitor_management_task/app/theme/app_theme.dart';
import 'package:visitor_management_task/core/widgets/common.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_event.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_state.dart';

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
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard_rounded),
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
      final registeredToday = state.visitors
          .where(
            (visitor) =>
                DateUtils.isSameDay(visitor.createdAt.toLocal(), today),
          )
          .length;
      final checkedOutToday = state.visitors
          .where(
            (visitor) =>
                visitor.checkOutTime != null &&
                DateUtils.isSameDay(visitor.checkOutTime!.toLocal(), today),
          )
          .length;
      final waiting = state.visitors
          .where((visitor) => visitor.status == 'Registered')
          .length;
      final checkedIn = state.visitors
          .where((visitor) => visitor.status == 'Checked In')
          .length;

      return ResponsiveContent(
        maxWidth: 1180,
        child: RefreshIndicator(
          onRefresh: () async =>
              context.read<VisitorBloc>().add(const VisitorsRequested()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, d MMMM yyyy',
                          ).format(DateTime.now()),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Visitor overview',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'A clear view of today’s front-desk activity.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: lineColor),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: brandColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _WelcomePanel(
                total: state.visitors.length,
                onRegister: () => context.push('/visitor/new'),
                onScan: () => context.push('/scan'),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 850
                      ? 4
                      : constraints.maxWidth >= 540
                      ? 2
                      : 2;
                  const gap = 12.0;
                  final cardWidth =
                      (constraints.maxWidth - (gap * (columns - 1))) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _MetricCard(
                          label: 'Registered today',
                          value: '$registeredToday',
                          icon: Icons.person_add_alt_1_rounded,
                          accent: brandColor,
                          background: const Color(0xFFEAF0FF),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _MetricCard(
                          label: 'Awaiting check-in',
                          value: '$waiting',
                          icon: Icons.schedule_rounded,
                          accent: const Color(0xFFB7791F),
                          background: const Color(0xFFFFF4DE),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _MetricCard(
                          label: 'Currently inside',
                          value: '$checkedIn',
                          icon: Icons.login_rounded,
                          accent: const Color(0xFF16845B),
                          background: const Color(0xFFE5F7EF),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _MetricCard(
                          label: 'Checked out today',
                          value: '$checkedOutToday',
                          icon: Icons.task_alt_rounded,
                          accent: const Color(0xFF7755C8),
                          background: const Color(0xFFF0EAFF),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              const SectionHeading(
                title: 'Recent visitors',
                subtitle: 'The latest records in your visitor register.',
              ),
              const SizedBox(height: 14),
              if (state.status == VisitorStatus.failure &&
                  state.visitors.isEmpty)
                EmptyState(
                  title: 'Visitors could not be loaded',
                  subtitle:
                      state.message ??
                      'Check your internet connection and API configuration.',
                  action: OutlinedButton.icon(
                    onPressed: () => context.read<VisitorBloc>().add(
                      const VisitorsRequested(),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                )
              else if (state.visitors.isEmpty)
                EmptyState(
                  title: 'No visitors registered',
                  subtitle: 'New visitor registrations will appear here.',
                  action: FilledButton.icon(
                    onPressed: () => context.push('/visitor/new'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Register visitor'),
                  ),
                )
              else ...[
                ...state.visitors
                    .take(4)
                    .map(
                      (visitor) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: VisitorCard(
                          visitor: visitor,
                          onTap: () => context.push(
                            '/visitor/${visitor.id}',
                            extra: visitor,
                          ),
                        ),
                      ),
                    ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.push('/visitors'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: const Text('View all visitors'),
                  ),
                ),
              ],
              if (state.status == VisitorStatus.failure &&
                  state.visitors.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.message ?? 'Unable to refresh visitor records.',
                    style: const TextStyle(color: Color(0xFFC43D4B)),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.total,
    required this.onRegister,
    required this.onScan,
  });

  final int total;
  final VoidCallback onRegister;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2449C8), Color(0xFF172D78)],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2449C8).withValues(alpha: .15),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'FRONT DESK • LIVE REGISTER',
                style: TextStyle(
                  color: Color(0xFFDDE6FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '$total visitor ${total == 1 ? 'record' : 'records'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -.6,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Manage arrivals, verify visitor details and keep the check-in process moving.',
              style: TextStyle(
                color: Color(0xFFDDE6FF),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 19),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onRegister,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2449C8),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Register visitor'),
                ),
                OutlinedButton.icon(
                  onPressed: onScan,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: .45),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: const Text('Scan QR'),
                ),
              ],
            ),
          ],
        );
        if (constraints.maxWidth > 660) {
          return Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 28),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 58,
                ),
              ),
            ],
          );
        }
        return content;
      },
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: lineColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 19),
            ),
            const Spacer(),
            Icon(
              Icons.trending_flat_rounded,
              color: accent.withValues(alpha: .7),
              size: 19,
            ),
          ],
        ),
        const SizedBox(height: 17),
        Text(
          value,
          style: const TextStyle(
            color: inkColor,
            fontSize: 27,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
