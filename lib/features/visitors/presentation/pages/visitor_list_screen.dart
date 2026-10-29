import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_task/app/theme/app_theme.dart';
import 'package:visitor_management_task/core/widgets/common.dart';
import 'package:visitor_management_task/features/visitors/domain/entities/visitor.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_event.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_state.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<VisitorBloc>().add(const VisitorsRequested());
  }

  void _openDetails(Visitor visitor) {
    if (visitor.id.trim().isEmpty) {
      _showMessage('This visitor has no ID. Refresh the list and try again.');
      return;
    }
    context.pushNamed(
      'visitor-details',
      pathParameters: {'id': visitor.id},
      extra: visitor,
    );
  }

  void _openEdit(Visitor visitor) {
    if (visitor.id.trim().isEmpty) {
      _showMessage('This visitor has no ID and cannot be edited.');
      return;
    }
    context.pushNamed(
      'visitor-edit',
      pathParameters: {'id': visitor.id},
      extra: visitor,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _delete(Visitor visitor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFC43D4B),
          size: 30,
        ),
        title: const Text('Delete visitor?'),
        content: Text(
          'Remove ${visitor.name} from the visitor register? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC43D4B),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete visitor'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<VisitorBloc>().add(VisitorDeleted(visitor.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: NavigationBar(
      selectedIndex: 1,
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
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/visitor/new'),
      icon: const Icon(Icons.person_add_alt_1_rounded),
      label: const Text('Register visitor'),
    ),
    body: SafeArea(
      child: BlocConsumer<VisitorBloc, VisitorState>(
        listener: (context, state) {
          if (state.message != null) _showMessage(state.message!);
        },
        builder: (context, state) {
          if (state.status == VisitorStatus.loading && state.visitors.isEmpty) {
            return const LoadingView();
          }
          final queryResults = state.filteredVisitors;
          final visitors = _statusFilter == 'All'
              ? queryResults
              : queryResults
                    .where((visitor) => visitor.status == _statusFilter)
                    .toList();
          final inside = state.visitors
              .where((visitor) => visitor.status == 'Checked In')
              .length;

          return ResponsiveContent(
            maxWidth: 1120,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageHeading(
                        title: 'Visitors',
                        subtitle:
                            'Search, review and manage every visitor record.',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: lineColor),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.visitors.length}',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: inkColor,
                                ),
                              ),
                              Text(
                                '$inside inside',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        onChanged: (value) => context.read<VisitorBloc>().add(
                          VisitorSearchChanged(value),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name or mobile number',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: state.searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => context
                                      .read<VisitorBloc>()
                                      .add(const VisitorSearchChanged('')),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All visitors',
                              value: 'All',
                              selected: _statusFilter,
                              count: state.visitors.length,
                              onSelected: (value) =>
                                  setState(() => _statusFilter = value),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Registered',
                              value: 'Registered',
                              selected: _statusFilter,
                              count: state.visitors
                                  .where((v) => v.status == 'Registered')
                                  .length,
                              onSelected: (value) =>
                                  setState(() => _statusFilter = value),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Checked in',
                              value: 'Checked In',
                              selected: _statusFilter,
                              count: inside,
                              onSelected: (value) =>
                                  setState(() => _statusFilter = value),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Checked out',
                              value: 'Checked Out',
                              selected: _statusFilter,
                              count: state.visitors
                                  .where((v) => v.status == 'Checked Out')
                                  .length,
                              onSelected: (value) =>
                                  setState(() => _statusFilter = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.status == VisitorStatus.failure &&
                    state.visitors.isEmpty)
                  Expanded(
                    child: EmptyState(
                      title: 'Could not load visitors',
                      subtitle:
                          state.message ??
                          'Check your API settings and connection.',
                      action: FilledButton.icon(
                        onPressed: () => context.read<VisitorBloc>().add(
                          const VisitorsRequested(),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ),
                  )
                else if (visitors.isEmpty)
                  Expanded(
                    child: EmptyState(
                      title: state.searchQuery.isNotEmpty
                          ? 'No matching visitors'
                          : 'No visitors in this view',
                      subtitle: state.searchQuery.isNotEmpty
                          ? 'Try another name or mobile number.'
                          : 'Choose another status or register a new visitor.',
                      action:
                          state.searchQuery.isNotEmpty || _statusFilter != 'All'
                          ? OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _statusFilter = 'All');
                                context.read<VisitorBloc>().add(
                                  const VisitorSearchChanged(''),
                                );
                              },
                              icon: const Icon(Icons.filter_alt_off_rounded),
                              label: const Text('Clear filters'),
                            )
                          : null,
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => context.read<VisitorBloc>().add(
                        const VisitorsRequested(),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                        itemCount: visitors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final visitor = visitors[index];
                          return VisitorCard(
                            visitor: visitor,
                            onTap: () => _openDetails(visitor),
                            onEdit: () => _openEdit(visitor),
                            onDelete: () => _delete(visitor),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.count,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String selected;
  final int count;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return ChoiceChip(
      selected: active,
      onSelected: (_) => onSelected(value),
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFEAF0FF),
      side: BorderSide(color: active ? const Color(0xFFB8C9FF) : lineColor),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: active ? brandColor : const Color(0xFFF0F3F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: active ? Colors.white : mutedColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      labelStyle: TextStyle(
        color: active ? brandColor : mutedColor,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
    );
  }
}
