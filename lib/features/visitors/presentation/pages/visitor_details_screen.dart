import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management_task/app/theme/app_theme.dart';
import 'package:visitor_management_task/core/widgets/common.dart';
import 'package:visitor_management_task/features/visitors/domain/entities/visitor.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_event.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_state.dart';

class VisitorDetailsScreen extends StatelessWidget {
  const VisitorDetailsScreen({super.key, required this.visitor});
  final Visitor visitor;

  String _date(DateTime? value) => value == null
      ? 'Not recorded'
      : DateFormat('d MMM yyyy, h:mm a').format(value.toLocal());

  @override
  Widget build(BuildContext context) => BlocConsumer<VisitorBloc, VisitorState>(
    listener: (context, state) {
      if (state.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
      }
    },
    builder: (context, state) {
      final current =
          state.visitors.where((item) => item.id == visitor.id).firstOrNull ??
          visitor;
      final busy = state.status == VisitorStatus.submitting;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Visitor profile'),
          actions: [
            IconButton(
              tooltip: 'Refresh records',
              onPressed: () =>
                  context.read<VisitorBloc>().add(const VisitorsRequested()),
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: 'Edit visitor',
              onPressed: () => context.pushNamed(
                'visitor-edit',
                pathParameters: {'id': current.id},
                extra: current,
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: SafeArea(
          child: ResponsiveContent(
            maxWidth: 1120,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final profile = _ProfileCard(visitor: current, date: _date);
                final qr = _QrCard(visitor: current);
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  children: [
                    Text(
                      'Visitor details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Review visitor information and manage their visit status.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: profile),
                          const SizedBox(width: 16),
                          Expanded(flex: 4, child: qr),
                        ],
                      )
                    else ...[
                      profile,
                      const SizedBox(height: 14),
                      qr,
                    ],
                    const SizedBox(height: 16),
                    _VisitActionCard(visitor: current, busy: busy),
                    if (busy)
                      const Padding(
                        padding: EdgeInsets.only(top: 18),
                        child: LinearProgressIndicator(minHeight: 3),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.visitor, required this.date});
  final Visitor visitor;
  final String Function(DateTime?) date;

  @override
  Widget build(BuildContext context) {
    final name = visitor.name.trim();
    final initials = name.isEmpty
        ? '?'
        : name
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FF),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: brandColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Unnamed visitor' : name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Visitor ID  ${visitor.id.isEmpty ? 'Pending' : visitor.id}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(child: StatusChip(status: visitor.status)),
              ],
            ),
            const SizedBox(height: 22),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.phone_iphone_rounded,
              label: 'Mobile number',
              value: visitor.mobile,
            ),
            _InfoRow(
              icon: Icons.mail_outline_rounded,
              label: 'Email address',
              value: visitor.email?.isNotEmpty == true
                  ? visitor.email!
                  : 'Not provided',
            ),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Visitor type',
              value: visitor.visitorType,
            ),
            _InfoRow(
              icon: Icons.apartment_rounded,
              label: 'Project',
              value: visitor.project,
            ),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'Purpose',
              value: visitor.purpose,
            ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Registered',
              value: date(visitor.createdAt),
            ),
            _InfoRow(
              icon: Icons.login_rounded,
              label: 'Check-in time',
              value: date(visitor.checkInTime),
            ),
            _InfoRow(
              icon: Icons.logout_rounded,
              label: 'Check-out time',
              value: date(visitor.checkOutTime),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.visitor});
  final Visitor visitor;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: brandColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visitor QR code',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Use this code to look up the record.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lineColor),
            ),
            child: visitor.id.isEmpty
                ? const SizedBox(
                    width: 190,
                    height: 190,
                    child: Center(
                      child: Text(
                        'QR code is available after the API returns a visitor ID.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : QrImageView(
                    data: visitor.id,
                    version: QrVersions.auto,
                    size: 190,
                    backgroundColor: Colors.white,
                  ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tag_rounded, size: 15, color: mutedColor),
                const SizedBox(width: 6),
                Text(
                  visitor.id.isEmpty ? 'ID pending' : visitor.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: inkColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Keep the QR code ready at the reception desk for a faster check-in.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}

class _VisitActionCard extends StatelessWidget {
  const _VisitActionCard({required this.visitor, required this.busy});
  final Visitor visitor;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final registered = visitor.status == VisitorStatusValue.registered;
    final checkedIn = visitor.status == VisitorStatusValue.checkedIn;
    final complete = visitor.status == VisitorStatusValue.checkedOut;
    final title = registered
        ? 'Ready for arrival'
        : checkedIn
        ? 'Visitor is on site'
        : 'Visit completed';
    final description = registered
        ? 'Confirm the visitor has arrived to record their check-in time.'
        : checkedIn
        ? 'Record the visitor’s departure to complete this visit.'
        : 'This visitor has checked out. The visit record is complete.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final action = registered
                ? FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () => context.read<VisitorBloc>().add(
                            VisitorCheckInRequested(visitor.id),
                          ),
                    icon: const Icon(Icons.login_rounded, size: 17),
                    label: const Text('Check in'),
                  )
                : checkedIn
                ? FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () => context.read<VisitorBloc>().add(
                            VisitorCheckOutRequested(visitor.id),
                          ),
                    icon: const Icon(Icons.logout_rounded, size: 17),
                    label: const Text('Check out'),
                  )
                : const StatusChip(status: VisitorStatusValue.checkedOut);
            final summary = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: complete
                        ? const Color(0xFFE5F7EF)
                        : const Color(0xFFEAF0FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    complete
                        ? Icons.check_circle_outline_rounded
                        : checkedIn
                        ? Icons.logout_rounded
                        : Icons.login_rounded,
                    color: complete ? const Color(0xFF16845B) : brandColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            );
            if (constraints.maxWidth < 540) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  summary,
                  const SizedBox(height: 16),
                  if (!complete)
                    SizedBox(width: double.infinity, child: action)
                  else
                    action,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: summary),
                const SizedBox(width: 14),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: mutedColor),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}
