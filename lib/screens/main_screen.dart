import 'package:flutter/material.dart';
import 'input_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _totalAlcoholGrams = 0.0;

  void _handleRecordSaved(double alcoholGrams) {
    setState(() {
      _totalAlcoholGrams += alcoholGrams;
    });
  }

  String _formatAlcoholAmount(double grams) {
    // 日本の1単位は純アルコール10gとして計算
    final units = (grams / 10).toStringAsFixed(1);
    return '$units単位';
  }

  // リセット確認ダイアログを表示
  Future<void> _showResetConfirmDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('記録をリセット'),
          content: const Text('今日の飲酒記録をリセットしますか？\nこの操作は取り消せません。'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'リセット',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                setState(() {
                  _totalAlcoholGrams = 0.0;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アルコールカウンター'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '今日の飲酒量',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              _formatAlcoholAmount(_totalAlcoholGrams),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '純アルコール: ${_totalAlcoholGrams.toStringAsFixed(1)}g',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputScreen(
                      onRecordSaved: _handleRecordSaved,
                    ),
                  ),
                );
              },
              child: const Text('飲酒を記録する'),
            ),
            if (_totalAlcoholGrams > 0) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _showResetConfirmDialog,
                icon: const Icon(Icons.refresh, color: Colors.red),
                label: const Text(
                  '記録をリセット',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
