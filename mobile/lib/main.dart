import 'package:flutter/material.dart';

void main() => runApp(const SmartTravelApp());

class SmartTravelApp extends StatelessWidget {
  const SmartTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartTravel',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartTravel')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Lên kế hoạch cho chuyến đi Đà Nẵng', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('Nhập sở thích, ngân sách và thời lượng để nhận lịch trình phù hợp.'),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.auto_awesome), label: const Text('Tạo lịch trình')),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.explore), label: const Text('Khám phá địa điểm')),
        ],
      ),
    );
  }
}

