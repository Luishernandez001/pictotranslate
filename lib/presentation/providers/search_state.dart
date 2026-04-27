import '../../domain/models/pictogram_result.dart';

class HomeSearchState {
  const HomeSearchState({
    this.query = '',
    this.language = 'en',
    this.result,
    this.loading = false,
    this.errorMessage,
    this.suggestions = const [],
    this.speaking = false,
  });

  final String query;
  final String language;
  final PictogramResult? result;
  final bool loading;
  final String? errorMessage;
  final List<String> suggestions;
  final bool speaking;

  HomeSearchState copyWith({
    String? query,
    String? language,
    PictogramResult? result,
    bool clearResult = false,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    List<String>? suggestions,
    bool? speaking,
  }) {
    return HomeSearchState(
      query: query ?? this.query,
      language: language ?? this.language,
      result: clearResult ? null : (result ?? this.result),
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      suggestions: suggestions ?? this.suggestions,
      speaking: speaking ?? this.speaking,
    );
  }
}
