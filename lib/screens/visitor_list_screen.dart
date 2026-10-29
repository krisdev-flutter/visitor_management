import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_task/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/bloc/visitor_event.dart';
import 'package:visitor_management_task/bloc/visitor_state.dart';
import 'package:visitor_management_task/models/visitor.dart';
import 'package:visitor_management_task/widgets/common.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});
  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VisitorBloc>().add(const VisitorsRequested());
  }

  void _openDetails(Visitor visitor) {
    final id = visitor.id.trim();
    if (id.isEmpty) {
      _showMessage('This visitor has no ID. Refresh the list and try again.');
      return;
    }

    context.pushNamed(
      'visitor-details',
      pathParameters: {'id': id},
      extra: visitor,
    );
  }

  void _openEdit(Visitor visitor) {
    final id = visitor.id.trim();
    if (id.isEmpty) {
      _showMessage('This visitor has no ID and cannot be edited.');
      return;
    }

    context.pushNamed(
      'visitor-edit',
      pathParameters: {'id': id},
      extra: visitor,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _delete(Visitor visitor) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete visitor?'),
        content: Text(
          'Delete ${visitor.name} from visitor records? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      context.read<VisitorBloc>().add(VisitorDeleted(visitor.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: NavigationBar(
      selectedIndex: 1,
      onDestinationSelected: (index) {
        if (index == 0) {
          context.go('/dashboard');
        }
        if (index == 1) {
          context.go('/visitors');
        }
        if (index == 2) {
          context.go('/scan');
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Visitors',
        ),
        NavigationDestination(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan QR',
        ),
      ],
    ),
    appBar: AppBar(
      title: const Text('Visitors'),
      actions: [
        IconButton(
          onPressed: () =>
              context.read<VisitorBloc>().add(const VisitorsRequested()),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/visitor/new'),
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Register'),
    ),
    body: BlocConsumer<VisitorBloc, VisitorState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        if (state.status == VisitorStatus.loading && state.visitors.isEmpty) {
          return const LoadingView();
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                onChanged: (value) => context.read<VisitorBloc>().add(
                  VisitorSearchChanged(value),
                ),
                decoration: InputDecoration(
                  hintText: 'Search name or mobile number',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: state.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            context.read<VisitorBloc>().add(
                              const VisitorSearchChanged(''),
                            );
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            if (state.status == VisitorStatus.failure && state.visitors.isEmpty)
              Expanded(
                child: EmptyState(
                  title: 'Could not load visitors',
                  subtitle:
                      state.message ??
                      'Check your API settings and connection.',
                ),
              )
            else if (state.filteredVisitors.isEmpty)
              const Expanded(child: EmptyState(title: 'No matching visitors'))
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => context.read<VisitorBloc>().add(
                    const VisitorsRequested(),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: state.filteredVisitors.length,
                    itemBuilder: (context, index) {
                      final visitor = state.filteredVisitors[index];
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
        );
      },
    ),
  );
}
