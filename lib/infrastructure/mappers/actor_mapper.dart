

import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';

class ActorMapper {
  static Actor castToEntity( Cast cast ) => Actor(
    id: cast.id, 
    name: cast.name, 
    profilePath: cast.profilePath != null 
    ? 'https://image.tmdb.org/t/p/w500${ cast.profilePath }'
    : 'https://cdn.vectorstock.com/i/500p/21/23/avatar-photo-default-user-icon-person-image-vector-47852123.jpg', 
    character: cast.character
  );
}

