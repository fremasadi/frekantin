import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repository/content_repository.dart';

class ImageContentBloc extends Bloc<ImageContentEvent, ImageContentState> {
  final ContentRepository repository;

  ImageContentBloc({required this.repository})
      : super(const ImageContentState()) {
    on<FetchActiveImagesEvent>(_onFetchActiveImages);
  }

  Future<void> _onFetchActiveImages(
      FetchActiveImagesEvent event, Emitter<ImageContentState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final images = await repository.getActiveImages();
      emit(state.copyWith(images: images, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }
}

extension ImageContentStateExtension on ImageContentState {
  ImageContentState copyWith({
    List<dynamic>? images,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ImageContentState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

abstract class ImageContentEvent extends Equatable {
  const ImageContentEvent();

  @override
  List<Object> get props => [];
}

class FetchActiveImagesEvent extends ImageContentEvent {}

class ImageContentState extends Equatable {
  final List<dynamic> images;
  final bool isLoading;
  final String errorMessage;

  const ImageContentState({
    this.images = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  @override
  List<Object> get props => [images, isLoading, errorMessage];
}
