import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'input_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _totalAlcoholGrams = 0.0;
  double? _dailyLimit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyLimit();
  }

  Future<void> _loadDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyLimit = prefs.getDouble('dailyLimit') ?? 3.0;
      _isLoading = false;
    });
  }

  void _handleRecordSaved(double alcoholGrams) {
    setState(() {
      _totalAlcoholGrams += alcoholGrams;
    });
  }

  int _calculateBeerEquivalent(double alcoholGrams) {
    // 中ジョッキ（500ml, 5%）のビールを基準に換算
    // 中ジョッキ1杯のアルコール量 = 500 * 0.05 * 0.8 = 20g
    const beerAlcoholGrams = 20.0;
    return (alcoholGrams / beerAlcoholGrams).round();
  }

  Widget _buildBeerIcons(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
          count > 10 ? 10 : count,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.sports_bar,
              color: Colors.amber[600],
              size: 32,
            ),
          ),
        ),
        if (count > 10)
          Text(
            '+${count - 10}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.amber[600],
            ),
          ),
      ],
    );
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
            Text(
              '今日の飲酒量',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_totalAlcoholGrams.toStringAsFixed(1)}g',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: _dailyLimit != null && _dailyLimit! > 0
                              ? (_totalAlcoholGrams / 20.0) / _dailyLimit!
                              : 0.0,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _dailyLimit != null &&
                                    (_totalAlcoholGrams / 20.0) >= _dailyLimit!
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(_totalAlcoholGrams / 20.0).toStringAsFixed(1)}単位',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '目標: ${_dailyLimit?.toStringAsFixed(1) ?? '2.0'}単位',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            if (_totalAlcoholGrams > 0) ...[
              const SizedBox(height: 8),
              _buildBeerIcons(_calculateBeerEquivalent(_totalAlcoholGrams)),
              Text(
                '中ジョッキ${_calculateBeerEquivalent(_totalAlcoholGrams)}杯分',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
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
