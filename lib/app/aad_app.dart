// Openapi Generator last run: : 2024-02-12T04:31:17.746509
import 'package:admin/admin.dart';
import 'package:core_ui/core_ui.dart';
import 'package:dashboard/dashboard_screen.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

@Openapi(
  additionalProperties: DioProperties(
    pubName: 'api_client',
    pubAuthor: 'Aplinkos apsaugos departamentas',
  ),
  inputSpec: InputSpec(path: 'openapi.yaml'),
  generatorName: Generator.dio,
  outputDirectory: 'api_client',
)
class AadApp extends StatelessWidget {
  AadApp({
    Key? key,
  }) : super(key: key);

  final _router = GoRouter(
    initialLocation: '/',
    observers: [SentryNavigatorObserver()],
    errorBuilder: (context, state) => RouteErrorScreen(
      errorText: state.matchedLocation,
      onPressed: () {
        context.goNamed("home");
      },
    ),
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
          name: 'admin',
          path: '/admin',
          builder: (context, state) => const AdminScreen(),
          routes: [
            GoRoute(
                name: 'report_admin',
                path: "pranesimas",
                builder: (context, state) {
                  return TrashScreen(
                    refId: state.uri.queryParameters['id'] ?? '1',
                  );
                }),
            GoRoute(
                name: 'dump_admin',
                path: 'aikstele',
                builder: (context, state) {
                  return DumpScreen(
                    refId: state.uri.queryParameters['id'] ?? '1',
                  );
                }),
          ]),
      GoRoute(
        name: 'report',
        path: '/pranesimas',
        builder: (context, state) =>
            InformationScreen(reportId: state.uri.queryParameters['id'] ?? '1'),
      ),
      GoRoute(
          name: 'newReportTrash',
          path: '/pranesti-atliekos',
          builder: (context, state) => const AddingScreenTrash()),
      GoRoute(
          name: 'newReportForest',
          path: '/pranesti-miskai',
          builder: (context, state) => const AddingScreenForest()),
      GoRoute(
          name: 'report_category',
          path: '/pasirinkti-kategorija',
          builder: (context, state) => const ReportCategoryScreen()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      color: const Color.fromRGBO(57, 97, 84, 1),
      locale: const Locale('lt'),
      theme: ThemeData.light()
          .copyWith(primaryColor: const Color.fromRGBO(57, 97, 84, 1)),
    );
  }
}