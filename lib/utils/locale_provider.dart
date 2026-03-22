import 'package:flutter/material.dart';
import 'package:csa_frontend/features/home/models/fairytale.dart';

final localeNotifier = ValueNotifier<Locale>(const Locale('ko'));
final mainTabNotifier = ValueNotifier<int>(2);
final favoritesNotifier = ValueNotifier<List<FairytaleItem>>([]);
