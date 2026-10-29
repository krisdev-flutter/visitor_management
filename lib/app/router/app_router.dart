import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_task/features/visitors/domain/entities/visitor.dart';
import 'package:visitor_management_task/features/visitors/presentation/pages/dashboard_screen.dart';
import 'package:visitor_management_task/features/visitors/presentation/pages/qr_scanner_screen.dart';
import 'package:visitor_management_task/features/visitors/presentation/pages/visitor_details_screen.dart';
import 'package:visitor_management_task/features/visitors/presentation/pages/visitor_form_screen.dart';
import 'package:visitor_management_task/features/visitors/presentation/pages/visitor_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: <RouteBase>[
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (BuildContext context, GoRouterState state) =>
          const DashboardScreen(),
    ),
    GoRoute(
      path: '/visitors',
      name: 'visitors',
      builder: (BuildContext context, GoRouterState state) =>
          const VisitorListScreen(),
    ),
    GoRoute(
      path: '/visitor/new',
      name: 'visitor-create',
      builder: (BuildContext context, GoRouterState state) =>
          const VisitorFormScreen(),
    ),
    GoRoute(
      path: '/visitor/:id',
      name: 'visitor-details',
      builder: (BuildContext context, GoRouterState state) {
        final visitor = state.extra;
        if (visitor is! Visitor) {
          return const _RouteErrorScreen(
            message:
                'Visitor details are not available. Open the visitor from the list or scan the QR code again.',
          );
        }
        return VisitorDetailsScreen(visitor: visitor);
      },
    ),
    GoRoute(
      path: '/visitor/:id/edit',
      name: 'visitor-edit',
      builder: (BuildContext context, GoRouterState state) {
        final visitor = state.extra;
        if (visitor is! Visitor) {
          return const _RouteErrorScreen(
            message:
                'Visitor details are not available. Return to the visitor list and try again.',
          );
        }
        return VisitorFormScreen(visitor: visitor);
      },
    ),
    GoRoute(
      path: '/scan',
      name: 'scan',
      builder: (BuildContext context, GoRouterState state) =>
          const QRScannerScreen(),
    ),
  ],
);

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unable to open page')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
