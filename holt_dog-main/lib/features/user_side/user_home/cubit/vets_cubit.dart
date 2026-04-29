import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/vet_model.dart';

class VetsState {
  final List<Vet> vets;
  final bool isLoading;
  final String? error;

  VetsState({
    this.vets = const [],
    this.isLoading = false,
    this.error,
  });

  VetsState copyWith({
    List<Vet>? vets,
    bool? isLoading,
    String? error,
  }) {
    return VetsState(
      vets: vets ?? this.vets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class VetsCubit extends Cubit<VetsState> {
  final FirestoreService _firestoreService;

  VetsCubit(this._firestoreService) : super(VetsState(vets: [], isLoading: false));

  void fetchVets() {
    /// FIREBASE INTEGRATION READY
    /// 
    /// The logic below is prepared to connect the veterinarians list to Cloud Firestore.
    /// To enable: Uncomment the block below and ensure firestore is set up.

    // try {
    //   _firestoreService.getVets().listen((vetsList) {
    //     if (vetsList.isNotEmpty) {
    //       emit(state.copyWith(vets: vetsList, isLoading: false));
    //     }
    //   }, onError: (e) {
    //     // Handle error
    //   });
    // } catch (e) {
    //   // Handle error
    // }
  }
}
