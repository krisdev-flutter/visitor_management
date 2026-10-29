import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management_task/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/bloc/visitor_event.dart';
import 'package:visitor_management_task/bloc/visitor_state.dart';
import 'package:visitor_management_task/models/visitor.dart';
import 'package:visitor_management_task/widgets/common.dart';

class VisitorDetailsScreen extends StatelessWidget {
  const VisitorDetailsScreen({super.key, required this.visitor});
  final Visitor visitor;
  String _date(DateTime? date) => date == null
      ? 'Not recorded'
      : DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
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
          state.visitors.where((v) => v.id == visitor.id).firstOrNull ??
          visitor;
      final busy = state.status == VisitorStatus.submitting;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Visitor details'),
          actions: [
            IconButton(
              onPressed: () =>
                  context.read<VisitorBloc>().add(const VisitorsRequested()),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      child: Text(
                        current.name.isEmpty
                            ? '?'
                            : current.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 25),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      current.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    StatusChip(status: current.status),
                    const SizedBox(height: 18),
                    _InfoRow(label: 'Visitor ID', value: current.id),
                    _InfoRow(label: 'Mobile', value: current.mobile),
                    _InfoRow(
                      label: 'Email',
                      value: current.email?.isNotEmpty == true
                          ? current.email!
                          : 'Not provided',
                    ),
                    _InfoRow(label: 'Visitor type', value: current.visitorType),
                    _InfoRow(label: 'Project', value: current.project),
                    _InfoRow(label: 'Purpose', value: current.purpose),
                    _InfoRow(
                      label: 'Registered',
                      value: _date(current.createdAt),
                    ),
                    _InfoRow(
                      label: 'Check-in time',
                      value: _date(current.checkInTime),
                    ),
                    _InfoRow(
                      label: 'Check-out time',
                      value: _date(current.checkOutTime),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Visitor QR code',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan this code to retrieve the visitor record.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (current.id.isNotEmpty)
                      QrImageView(
                        data: current.id,
                        version: QrVersions.auto,
                        size: 190,
                      )
                    else
                      const Text(
                        'QR will be available after the API returns a visitor ID.',
                      ),
                    const SizedBox(height: 8),
                    Text(
                      current.id,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (current.status == 'Registered')
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => context.read<VisitorBloc>().add(
                        VisitorCheckInRequested(current.id),
                      ),
                icon: const Icon(Icons.login),
                label: const Text('Check in'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
            else if (current.status == 'Checked In')
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => context.read<VisitorBloc>().add(
                        VisitorCheckOutRequested(current.id),
                      ),
                icon: const Icon(Icons.logout),
                label: const Text('Check out'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This visit is complete. A completed visit cannot be checked in again.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (busy)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}
