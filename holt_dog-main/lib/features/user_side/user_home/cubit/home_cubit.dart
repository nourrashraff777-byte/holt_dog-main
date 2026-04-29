import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/report_model.dart';

class HomeState {
  final List<Report> recentReports;
  final int totalReports;
  final int totalVets;
  final int totalShelters;
  final bool isLoading;
  final String? error;

  HomeState({
    this.recentReports = const [],
    this.totalReports = 0,
    this.totalVets = 0,
    this.totalShelters = 0,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<Report>? recentReports,
    int? totalReports,
    int? totalVets,
    int? totalShelters,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      recentReports: recentReports ?? this.recentReports,
      totalReports: totalReports ?? this.totalReports,
      totalVets: totalVets ?? this.totalVets,
      totalShelters: totalShelters ?? this.totalShelters,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  final FirestoreService _firestoreService;

  HomeCubit(this._firestoreService)
      : super(HomeState(
          recentReports: [],
          totalReports: 0,
          totalVets: 0,
          totalShelters: 0,
          isLoading: false,
        ));

  void init() {
    /// FIREBASE INTEGRATION READY
    /// 
    /// The logic below is prepared to connect the dashboard to Cloud Firestore.
    /// To enable real-time updates:
    /// 1. Ensure google-services.json/GoogleService-Info.plist are correctly placed.
    /// 2. Ensure Firestore collections ('reports', 'vets', 'shelters') exist.
    /// 3. Uncomment the blocks below.
    
    // try {
    //   _firestoreService.getReports().listen((reports) {
    //     if (reports.isNotEmpty) {
    //       emit(state.copyWith(
    //         recentReports: reports.take(5).toList(),
    //         totalReports: reports.length,
    //         isLoading: false,
    //       ));
    //     }
    //   });

    //   _firestoreService.getVets().listen((vets) {
    //     if (vets.isNotEmpty) {
    //       emit(state.copyWith(totalVets: vets.length));
    //     }
    //   });

    //   _firestoreService.getShelters().listen((shelters) {
    //     if (shelters.isNotEmpty) {
    //       emit(state.copyWith(totalShelters: shelters.length));
    //     }
    //   });
    // } catch (e) {
    //   // Keep mock data or handle error
    // }
  }
}
