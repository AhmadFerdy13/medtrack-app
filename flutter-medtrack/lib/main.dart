import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// BLoCs
import 'features/auth/bloc/auth_bloc.dart';
import 'features/medicine/bloc/medicine_bloc.dart';
import 'features/schedule/bloc/schedule_bloc.dart';
import 'features/schedule/bloc/today_dose_bloc.dart';

// Pages
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/auth/presentation/profile_page.dart';
import 'features/dashboard/presentation/dashboard_page.dart';
import 'features/medicine/presentation/medicine_form_page.dart';
import 'features/medicine/data/models/medicine_model.dart';
import 'features/schedule/presentation/schedule_detail_page.dart';
import 'features/schedule/presentation/schedule_form_page.dart';
import 'features/schedule/data/models/schedule_model.dart';

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MedTrackApp());
}

/// Root aplikasi MedTrack.
class MedTrackApp extends StatelessWidget {
  const MedTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => MedicineBloc()),
        BlocProvider(create: (_) => ScheduleBloc()),
        BlocProvider(create: (_) => TodayDoseBloc()),
      ],
      child: MaterialApp(
        title: 'MedTrack',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Tema aplikasi — warna kesehatan (teal/cyan).
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF0D9488),
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xFFF8FAFB),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF0D9488),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D9488),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Routing aplikasi.
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case '/medicine/form':
        final medicine = settings.arguments as MedicineModel?;
        return MaterialPageRoute(
          builder: (_) => MedicineFormPage(medicine: medicine),
        );

      case '/schedule/detail':
        final schedule = settings.arguments as ScheduleModel;
        return MaterialPageRoute(
          builder: (_) => ScheduleDetailPage(schedule: schedule),
        );

      case '/schedule/form':
        final schedule = settings.arguments as ScheduleModel?;
        return MaterialPageRoute(
          builder: (_) => ScheduleFormPage(schedule: schedule),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  }
}
