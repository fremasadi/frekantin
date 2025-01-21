import 'package:equatable/equatable.dart';

abstract class SearchProductEvent extends Equatable {
  const SearchProductEvent();

  @override
  List<Object> get props => [];
}

class SearchProductByKeyword extends SearchProductEvent {
  final String keyword;

  const SearchProductByKeyword(this.keyword);

  @override
  List<Object> get props => [keyword];
}

class ClearSearchResults extends SearchProductEvent {}
