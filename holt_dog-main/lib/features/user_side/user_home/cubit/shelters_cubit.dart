import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/shelter_model.dart';

class SheltersState {
  final List<Shelter> shelters;
  final bool isLoading;
  final String? error;

  SheltersState({
    this.shelters = const [],
    this.isLoading = false,
    this.error,
  });

  SheltersState copyWith({
    List<Shelter>? shelters,
    bool? isLoading,
    String? error,
  }) {
    return SheltersState(
      shelters: shelters ?? this.shelters,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SheltersCubit extends Cubit<SheltersState> {
  final FirestoreService _firestoreService;

  SheltersCubit(this._firestoreService)
      : super(SheltersState(shelters: [], isLoading: false));

  void fetchShelters() {
    /// FIREBASE INTEGRATION READY
    /// 
    /// The logic below is prepared to connect the shelters list to Cloud Firestore.
    /// To enable: Uncomment the block below and ensure firestore is set up.

    // try {
    //   _firestoreService.getShelters().listen((sheltersList) {
    //     if (sheltersList.isNotEmpty) {
    //       emit(state.copyWith(shelters: sheltersList, isLoading: false));
    //     }
    //   }, onError: (e) {
    //     // Handle error
    //   });
    // } catch (e) {
    //   // Handle error
    // }
  }
}
