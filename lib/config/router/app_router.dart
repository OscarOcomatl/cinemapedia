import 'package:cinemapedia/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(), routes: [
        GoRoute( // Cuando hay hijos, el path ya no tiene por que ponerse ya que lo está asigando el padre
          path: 'movie/:id', // Argumentos, siempre van a ser String
          name: MovieScreen.name,
          builder: (context, state) { // El state tiene todo lo que nos puede servir en navegacion
            final movieId = state.pathParameters['id'] ?? 'no-id'; // Si no viene, el valor por defecto es 'no-id'
            return MovieScreen(movieId: movieId);
          },
        ),
      ]
    ),
  ]
);