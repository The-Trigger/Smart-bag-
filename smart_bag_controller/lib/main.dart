import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'screens/home_screen.dart';
import 'services/bluetooth_service.dart';
import 'services/auth_service.dart';
import 'services/bag_controller_service.dart';
import 'providers/bag_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request necessary permissions
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();
  await Permission.location.request();
  
  runApp(const SmartBagControllerApp());
}

class SmartBagControllerApp extends StatelessWidget {
  const SmartBagControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BagStateProvider()),
        Provider<BluetoothService>(create: (_) => BluetoothService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<BagControllerService>(create: (_) => BagControllerService()),
      ],
      child: MaterialApp(
        title: 'Smart Bag Controller',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}