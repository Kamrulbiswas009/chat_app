import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/network/api_client.dart';
import 'core/network/socket_service.dart';
import 'core/routes/app_pages.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize Core Services
  await Get.putAsync<StorageService>(() => StorageService().init());
  Get.put<ApiClient>(ApiClient());
  await Get.putAsync<SocketService>(() => SocketService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
