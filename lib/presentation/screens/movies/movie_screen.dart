
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MovieScreen extends ConsumerStatefulWidget {
  const MovieScreen({
    required this.movieId,
    super.key
  });

  static const name = 'movie-screen';

  final String movieId;

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch( movieInfoProvider )[widget.movieId];

    if( movie == null ){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar( movie: movie ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _MovieDetails(movie: movie),
              childCount: 1
            ),
          )
        ],
      ),
    );
  }
}

class _MovieDetails extends StatelessWidget {
  const _MovieDetails({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                ),
              ),
              const SizedBox( width: 10 ),
              // Descripcion
              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( movie.title, style: textStyle.titleLarge ),
                    Text( movie.overview, style: textStyle.bodyMedium ),
                  ],
                ),
              )
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                margin: const EdgeInsets.only( right: 10 ),
                child: Chip(
                  label: Text( gender ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ))
            ],
          )
        ),

        _ActorsByMovie(movieId: movie.id.toString() ),
        // const SizedBox(height: 10)
      ],
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {
const _ActorsByMovie({required this.movieId});

final String movieId;

  @override
  Widget build(BuildContext context, ref){

    final actorsByMovie = ref.watch( actorsByMovieProvider );

    if(actorsByMovie[movieId] == null ){
      return const CircularProgressIndicator(strokeWidth: 2);
    }

    final actors = actorsByMovie[movieId]!;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: ( context, index ) {
          final actor =  actors[index];
          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 135,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInRight(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      actor.profilePath,
                      height: 180,
                      width: 135,
                  
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(actor.name, maxLines: 2),
                Text(
                  actor.character ?? '',
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                )
              ],
            )
          );
        }
      ),
    );


    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    //   child: Container(
    //     width: double.infinity,
    //     height: 200,
    //     color: Colors.red,
    //     child: ListView.builder(
    //       scrollDirection: Axis.horizontal,
    //       itemCount: 10,
    //       itemBuilder: (context, index) {
    //         return Text('$movieId');
    //       }
    //     ),
    //   ),
    // );
  }
}

final isFavoriteProvider = FutureProvider.family.autoDispose((ref, int movieId){
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return localStorageRepository.isMovieFavorite(movieId);// si está en favoritos
});

class _CustomSliverAppBar extends ConsumerWidget {
  const _CustomSliverAppBar({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final AsyncValue isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));

    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async {
            // ref.watch(localStorageRepositoryProvider)
            //   .toggleFavorite(movie);
            await ref.read( favoriteMoviesProvider.notifier)
              .toggleFavorite(movie);

            ref.invalidate(isFavoriteProvider(movie.id)); // Invalida el estado del provider y lo regresa a su estado original
          },
          icon: isFavoriteFuture.when(
            loading: () => const CircularProgressIndicator(strokeWidth: 2),
            data: (isFavorite) => isFavorite
              ? const Icon(Icons.favorite_rounded, color: Colors.red)
              : const Icon(Icons.favorite_border), 
            error: (_,__) => throw UnimplementedError(), 
          )
          // const Icon(Icons.favorite_border)
          // icon: Icon(Icons.favorite_rounded, color: Colors.red),
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20, color: Colors.white),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingBuilder) {
                  if ( loadingBuilder != null ) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),
            const _CustomGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, stops: [0.0, 0.2],colors: [Colors.black54,Colors.transparent],),
            const _CustomGradient(begin: Alignment.topCenter,end: Alignment.bottomCenter, stops: [0.8, 1.0],colors: [Colors.transparent,Colors.black54],),
            const _CustomGradient(begin: Alignment.topLeft, stops: [0.0, 0.3],colors: [Colors.black87,Colors.transparent],)
          ]
        ),
      ),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  const _CustomGradient({
    required this.begin,
             this.end,
    required this.stops,
    required this.colors,
  });

  final AlignmentGeometry begin;
  final List<Color> colors;
  final AlignmentGeometry? end;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end ?? Alignment.center,
            stops: stops,
            colors: colors
          )
        )
      ),
    );
  }
}