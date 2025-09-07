import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  double _dailyLimitGrams = 40.0; // デフォルト値を40g（ビール中ジョッキ2杯分）に設定

  // 各お酒1杯あたりのアルコール量（g）を計算するメソッド
  double _getAlcoholGramsPerDrink(String drinkType) {
    switch (drinkType) {
      case '生ビール': // 中ジョッキ（500ml, 5%）
        return 500 * 0.05 * 0.8; // = 20g
      case 'ワイン': // グラス（125ml, 12%）
        return 125 * 0.12 * 0.8; // = 12g
      case '日本酒': // 1合（180ml, 15%）
        return 180 * 0.15 * 0.8; // = 21.6g
      case '焼酎': // 1合（180ml, 25%）
        return 180 * 0.25 * 0.8; // = 36g
      case 'ウイスキー': // シングル（30ml, 40%）
        return 30 * 0.40 * 0.8; // = 9.6g
      default:
        return 20.0; // デフォルトはビール中ジョッキ基準
    }
  }

  String _getDrinkUnit(String drinkType) {
    switch (drinkType) {
      case '生ビール':
        return '中ジョッキ';
      case 'ワイン':
        return 'グラス';
      case '日本酒':
      case '焼酎':
        return '合';
      case 'ウイスキー':
        return 'シングル';
      default:
        return '杯';
    }
  }

  double _calculateDrinkCount(double totalAlcoholGrams, String drinkType) {
    return totalAlcoholGrams / _getAlcoholGramsPerDrink(drinkType);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // 既存のデータを変換（杯数からグラム数に）
      final oldValue = _prefs.getDouble('dailyLimit') ?? 2.0;
      _dailyLimitGrams = _prefs.getDouble('dailyLimitGrams') ?? (oldValue * 20.0);
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setDouble('dailyLimitGrams', _dailyLimitGrams);
    // ビール換算の杯数も保存（後方互換性のため）
    await _prefs.setDouble('dailyLimit', _dailyLimitGrams / 20.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text('設定'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('二日酔いにならない飲酒量'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: _dailyLimitGrams,
                  min: 0,
                  max: 200, // 最大200g
                  divisions: 40,
                  label: '${_dailyLimitGrams.toStringAsFixed(1)}g',
                  onChanged: (value) {
                    setState(() {
                      _dailyLimitGrams = value;
                    });
                    _saveSettings();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'アルコール量: ${_dailyLimitGrams.toStringAsFixed(1)}g',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '各お酒での換算：',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (var drinkType in ['生ビール', 'ワイン', '日本酒', '焼酎', 'ウイスキー'])
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                          child: Text(
                            drinkType == '日本酒' || drinkType == '焼酎'
                              ? '$drinkType ${_calculateDrinkCount(_dailyLimitGrams, drinkType).toStringAsFixed(1)}${_getDrinkUnit(drinkType)}'
                              : '$drinkType ${_getDrinkUnit(drinkType)} ${_calculateDrinkCount(_dailyLimitGrams, drinkType).toStringAsFixed(1)}杯分',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('データを削除'),
            textColor: Colors.red,
            onTap: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('確認'),
                  content: const Text('すべてのデータを削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('削除'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await _prefs.clear();
                await _loadSettings();
              }
            },
          ),
        ],
      ),
    );
  }
}
