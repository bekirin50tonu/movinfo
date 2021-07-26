import 'package:json_annotation/json_annotation.dart';
import 'package:movinfo/core/base/base_model.dart';

part 'movie_model.g.dart';

@JsonSerializable()
class MovieModel extends BaseModel {
  Dates? dates;
  int? page;
  List<Results>? results;
  @JsonKey(name: 'total_pages')
  int? totalPages;
  @JsonKey(name: 'total_results')
  int? totalResults;

  MovieModel(
      {this.dates,
      this.page,
      this.results,
      this.totalPages,
      this.totalResults});

  Map<String, dynamic> toJson() {
    return _$MovieModelToJson(this);
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return _$MovieModelFromJson(json);
  }
}

@JsonSerializable()
class Dates {
  String? maximum;
  String? minimum;

  Dates({this.maximum, this.minimum});

  factory Dates.fromJson(Map<String, dynamic> json) {
    return _$DatesFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$DatesToJson(this);
  }
}

@JsonSerializable()
class Results {
  bool? adult;
  @JsonKey(name: 'backdrop_path')
  String? backdropPath;
  @JsonKey(name: 'genre_ids')
  List<int>? genreIds;
  int? id;
  @JsonKey(name: 'original_language')
  String? originalLanguage;
  @JsonKey(name: 'original_title')
  String? originalTitle;
  String? overview;
  double? popularity;
  @JsonKey(name: 'poster_path')
  String? posterPath;
  @JsonKey(name: 'release_date')
  String? releaseDate;
  String? title;
  bool? video;
  @JsonKey(name: 'vote_average')
  double? voteAverage;
  @JsonKey(name: 'vote_count')
  int? voteCount;

  Results(
      {this.adult,
      this.backdropPath,
      this.genreIds,
      this.id,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.popularity,
      this.posterPath,
      this.releaseDate,
      this.title,
      this.video,
      this.voteAverage,
      this.voteCount});

  factory Results.fromJson(Map<String, dynamic> json) {
    return _$ResultsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$ResultsToJson(this);
  }

  @override
  String toString() {
    return "$backdropPath $posterPath";
  }
}
