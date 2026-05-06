import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/user_side/user_home/cubit/home_cubit.dart';
import 'features/marketplace/data/data_sources/marketplace_remote_data_source.dart';
import 'features/marketplace/data/repo/marketplace_repository.dart';
import 'features/marketplace/presentation/manager/marketplace_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase Initialized Successfully ✅');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e ');
  }

  runApp(const HoltDogApp());
}

class HoltDogApp extends StatelessWidget {
  const HoltDogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => authService),
          RepositoryProvider(create: (context) => firestoreService),
          RepositoryProvider<MarketplaceRepository>(
            create: (context) => MarketplaceRepositoryImpl(
              MarketplaceRemoteDataSourceImpl(FirebaseFirestore.instance),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthCubit(authService)..checkAuthStatus(),
            ),
            BlocProvider(
              create: (context) =>
                  HomeCubit(context.read<FirestoreService>())..init(),
            ),
            BlocProvider(
              create: (context) =>
                  MarketplaceCubit(context.read<MarketplaceRepository>())
                    ..fetchProducts(),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                routerConfig: AppRouter.router,
              );
            },
          ),
        ));
  }
}
