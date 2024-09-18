import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

class MovieMasonry extends StatefulWidget {

  final List<Movie> movies;
  final VoidCallback? loadNextPage;

  const MovieMasonry({
    super.key,
    required this.movies,
    this.loadNextPage
  });

  @override
  State<MovieMasonry> createState() => _MovieMasonryState();
}

class _MovieMasonryState extends State<MovieMasonry> {

  final ScrollController scrollController = ScrollController();

  //todo initState
  @override
  void initState() {
    super.initState();
    scrollController.addListener((){
      // scrollController.position.pixels --> posicion actual
      // scrollController.position.maxScrollExtent --> lo maximo a lo que puede llegar el scroll
      
      if(widget.loadNextPage == null) return;
      
      if((scrollController.position.pixels + 200) >= scrollController.position.maxScrollExtent) { // 500 px aprox. para llegar al final del scroll
        widget.loadNextPage!();
        // setState(() {});
      } 
    });
  }

  // todo dipose
  @override
  void dispose() {
    scrollController.dispose(); // Limpiar el controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: MasonryGridView.count(
        crossAxisCount: 3, 
        mainAxisSpacing: 10,
        crossAxisSpacing: 5,
        controller: scrollController,
        itemCount: widget.movies.length,
        itemBuilder: (context, index){
          if(index == 1){
            return Column(
              children: [
                const SizedBox(height: 40),
                MoviePosterLink(movie: widget.movies[index])
              ],
            );
          }
          return MoviePosterLink( movie: widget.movies[index]);
        }
      ),
    );
  }
}

