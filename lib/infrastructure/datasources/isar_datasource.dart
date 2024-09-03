import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatasource extends LocalStorageDatasource {
  
  late Future<Isar> db; // La apertura de la db no es asincrona, se debe abrir o iniciar antes de realizar cualquier peticion

  IsarDatasource(){
    db = openDB();
  }

  Future<Isar> openDB() async {
    
    final directory = await getApplicationDocumentsDirectory();

    if ( Isar.instanceNames.isEmpty ){
      return await Isar.open([ MovieSchema ], inspector: true, directory: directory.path);
    }
    return Future.value( Isar.getInstance());
  }

  @override
  Future<bool> isMovieFavorite(int id) async {
    final isar = await db;
    final Movie? isFavoriteMovie = await isar.movies
      .filter()
      .idEqualTo(id)
      .findFirst();
    return isFavoriteMovie != null;
  }

  @override
  Future<void> toggleFavorite(Movie movie) async {
    final isar = await db;
    final favoriteMovie = await isar.movies
      .filter()
      .idEqualTo(movie.id)
      .findFirst();
    if( favoriteMovie != null ){
      // Borrar
      isar.writeTxnSync(() => isar.movies.deleteSync( favoriteMovie.isarid! ));
      return;
    }
    //Insertar
    isar.writeTxnSync(() => isar.movies.putSync(movie));
  }

  @override
  Future<List<Movie>> loadMovies({int limit = 10, offset = 0}) async {
    final isar = await db;
    return isar.movies.where()
      .offset(offset)
      .limit(limit)
      .findAll();
  }
}