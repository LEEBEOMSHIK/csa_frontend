import 'package:flutter/material.dart';
import 'package:csa_frontend/shared/widgets/app_top_bar.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: Column(
        children: [
          const AppTopBar(title: '마이'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_rounded,
                      size: 72, color: Color(0xFFBBBBBB)),
                  SizedBox(height: 16),
                  Text(
                    '마이 페이지',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '준비 중입니다',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
