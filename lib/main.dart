import 'package:flutter/material.dart';

import 'package:csa_frontend/app/app.dart';
import 'package:csa_frontend/features/offline/services/offline_store.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await OfflineStore.instance.init();
    await DownloadManager.instance.cleanupExpired();
  } catch (e) {
    debugPrint('Offline storage init/cleanup failed, continuing: $e');
  }
  runApp(const FairyTaleApp());
}
