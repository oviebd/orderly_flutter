import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/business_setup_page.dart';
import 'features/home/presentation/pages/main_screen.dart';
import 'core/navigation/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await di.init();

  runApp(const OrderlyApp());
}

class OrderlyApp extends StatelessWidget {
  const OrderlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Orderly',
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is Authenticated) {
              return const MainScreen();
            }
            if (state is NeedsBusiness) {
              return const BusinessSetupPage();
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
