import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_management_task/app/router/app_router.dart';
import 'package:visitor_management_task/app/theme/app_theme.dart';
import 'package:visitor_management_task/features/visitors/data/datasources/visitor_remote_data_source.dart';
import 'package:visitor_management_task/features/visitors/data/repositories/visitor_repository_impl.dart';
import 'package:visitor_management_task/features/visitors/domain/repositories/visitor_repository.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_bloc.dart';

class VisitorManagementApp extends StatelessWidget {
  const VisitorManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<VisitorRepository>(
      create: (_) => VisitorRepositoryImpl(VisitorRemoteDataSource()),
      child: BlocProvider<VisitorBloc>(
        create: (context) => VisitorBloc(context.read<VisitorRepository>()),
        child: MaterialApp.router(
          title: 'Visitor Management',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: buildAppTheme(),
        ),
      ),
    );
  }
}
