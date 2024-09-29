import 'dart:io';  // Ajoutez ceci pour utiliser HttpOverrides
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_essai_flutter/helpers/database_helpers.dart';
import 'package:project_essai_flutter/mdels/user_model.dart';
import 'package:project_essai_flutter/screens/delete_element.dart';
 import 'package:project_essai_flutter/screens/element_details_bydate_screen.dart';
 import 'package:project_essai_flutter/screens/splaash_screen.dart';
import 'package:project_essai_flutter/screens/update_element.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/home_page.dart';
import 'screens/element_details_screen.dart';
import 'screens/elements_by_date_screen.dart';
import 'screens/add_element_page.dart';

// Cette classe va permettre de désactiver la vérification des certificats SSL
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  
   
  await DatabaseHelper.instance.database;

  // Désactive la validation SSL
  HttpOverrides.global = MyHttpOverrides();
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
                ChangeNotifierProvider(create: (_) => User()),

      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Essai',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),  
        '/home': (context) {
          final String token = ModalRoute.of(context)!.settings.arguments as String;
          return HomePage(token: token);
        },
        '/elementDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          final element = args['element'];
          final inspection = args['inspection'];
          return ElementDetailsScreen(
            token: token,
            element: element,
            inspection: inspection,
          );
        },
        '/elementDetailsByDate': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          final element = args['element'];
          final inspection = args['inspection'];
          final inspectionDate = args['inspectionDate'];  

          return ElementDetailsByDateScreen(
            token: token,
            element: element,
            inspection: inspection, 
            inspectionDate: inspectionDate, 
          );
        },
        '/elementsByDate': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          final DateTime date = args['date'] as DateTime;
          return ElementsByDatePage(
            token: token,
            date: date,
          );
        },
        '/addElement': (context) {
          final String token = ModalRoute.of(context)!.settings.arguments as String;
          return AddElementPage(token: token);
        },
        '/deleteElement': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          final String? id = args['id'];
          final String? code = args['code'];
          return DeleteEelementPage(
            token: token,
            id: id,
            code: code,
          );
        },'/updateElement': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String token = args['token'];
          final String? id = args['id'];
          final String? code = args['code'];
          return UpdateElementPage(
            token: token,
            id: id,
            code: code,
          );
        },
        
      },
    );
  }
}
