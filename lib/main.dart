import 'package:flutter/material.dart';

import 'package:csa_frontend/app/app.dart';
import 'package:csa_frontend/features/offline/services/offline_store.dart';
import 'package:csa_frontend/shared/services/connectivity_service.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await OfflineStore.instance.init();
    await DownloadManager.instance.cleanupExpired();
  } catch (e) {
    debugPrint('Offline storage init/cleanup failed, continuing: $e');
  }
  try {
    await ConnectivityService.instance.start();
  } catch (e) {
    debugPrint('Connectivity init failed, continuing online: $e');
  }
  runApp(const FairyTaleApp());
}
