import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/map/presentation/civilization_map_screen.dart';
import '../features/quiz/presentation/quiz_screen.dart';
import '../features/scene/presentation/scene_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (BuildContext context, GoRouterState state) =>
          const CivilizationMapScreen(),
    ),
    GoRoute(
      path: '/scene/:nodeId',
      name: 'scene',
      builder: (BuildContext context, GoRouterState state) {
        final String nodeId = state.pathParameters['nodeId']!;
        return SceneScreen(nodeId: nodeId);
      },
    ),
    GoRoute(
      path: '/quiz/:nodeId',
      name: 'quiz',
      builder: (BuildContext context, GoRouterState state) {
        final String nodeId = state.pathParameters['nodeId']!;
        return QuizScreen(nodeId: nodeId);
      },
    ),
  ],
);
