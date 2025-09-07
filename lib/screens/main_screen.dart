import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drink_record.dart';
import 'input_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// 三角形のマーカーを描画するカスタムペインター
class TriangleMarkerPainter extends CustomPainter {
  final Color color;

  TriangleMarkerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width / 2, size.height)  // 頂点を下に
      ..lineTo(0, 0)                         // 左上に線を引く
      ..lineTo(size.width, 0)                // 右上に線を引く
      ..close();

    // 影を描画
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, shadowPaint);

    // メインの三角形を描画
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TriangleMarkerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _MainScreenState extends State<MainScreen> {
  double _totalAlcoholGrams = 0.0;
  double? _dailyLimit;
  bool _isLoading = true;
  List<DrinkRecord> _drinkHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyLimit = prefs.getDouble('dailyLimit') ?? 3.0;
    
    final historyJson = prefs.getString('drinkHistory') ?? '[]';
    final historyList = jsonDecode(historyJson) as List;
    final history = historyList
        .map((item) => DrinkRecord.fromJson(item as Map<String, dynamic>))
        .toList();

    final totalGrams = prefs.getDouble('totalAlcoholGrams') ?? 0.0;
    
    setState(() {
      _dailyLimit = dailyLimit;
      _drinkHistory = history;
      _totalAlcoholGrams = totalGrams;
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_drinkHistory.map((r) => r.toJson()).toList());
    await prefs.setString('drinkHistory', historyJson);
    await prefs.setDouble('totalAlcoholGrams', _totalAlcoholGrams);
  }

  Future<void> _loadDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyLimit = prefs.getDouble('dailyLimit') ?? 3.0;
    setState(() {
      _dailyLimit = dailyLimit;
    });
  }

  void _handleRecordSaved(double alcoholGrams, {String type = '', String size = ''}) {
    setState(() {
      _totalAlcoholGrams += alcoholGrams;
      if (type.isNotEmpty && size.isNotEmpty) {
        _drinkHistory.add(DrinkRecord(
          type: type,
          size: size,
          alcoholGrams: alcoholGrams,
        ));
      }
    });
    _saveData();
  }

  void _handleRefill(DrinkRecord record) {
    _handleRecordSaved(
      record.alcoholGrams,
      type: record.type,
      size: record.size,
    );
  }

  double _calculateBeerEquivalent(double alcoholGrams) {
    // 中ジョッキ（500ml, 5%）のビールを基準に換算
    // 中ジョッキ1杯のアルコール量 = 500 * 0.05 * 0.8 = 20g
    const beerAlcoholGrams = 20.0;
    return alcoholGrams / beerAlcoholGrams;
  }

  int _calculateBeerCount(double alcoholGrams) {
    return _calculateBeerEquivalent(alcoholGrams).round();
  }

  // 目標値を超えた量に応じて警告レベルを返す
  int _getWarningLevel() {
    if (_dailyLimit == null || _dailyLimit! <= 0) return 400;
    
    final ratio = _totalAlcoholGrams / (_dailyLimit! * 20.0);
    if (ratio >= 2.0) return 900; // 目標の2倍以上
    if (ratio >= 1.5) return 700; // 目標の1.5倍以上
    if (ratio >= 1.2) return 500; // 目標の1.2倍以上
    return 400; // 目標を超えた程度
  }

  Widget _getIconForDrinkType(String type) {
    String imagePath;
    switch (type) {
      case '生ビール':
        imagePath = 'assets/images/beer.png';
        break;
      case '焼酎':
        imagePath = 'assets/images/shochu.png';
        break;
      case '日本酒':
        imagePath = 'assets/images/sake.png';
        break;
      case 'ワイン':
        imagePath = 'assets/images/wine.png';
        break;
      case 'ウイスキー':
        imagePath = 'assets/images/whiskey.png';
        break;
      default:
        imagePath = 'assets/images/beer.png';
    }
    
    return Image.asset(
      imagePath,
      width: 28,
      height: 28,
      color: Colors.grey[700],
    );
  }

  Widget _buildBeerIcons(int count) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8, // アイコン間の水平スペース
      runSpacing: 8, // 行間のスペース
      children: List.generate(
        count,
        (index) => Icon(
          Icons.sports_bar,
          color: Colors.amber[600],
          size: 32,
        ),
      ),
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
                  _drinkHistory.clear();
                });
                _saveData();
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
        title: const Text('飲酒カウンター'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              _loadData(); // Settings画面から戻ってきたら全データを再読み込み
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (_dailyLimit == null || _dailyLimit! <= 0) {
                              return const SizedBox.shrink();
                            }

                            final targetGrams = _dailyLimit! * 20.0;
                            final isOverLimit = _totalAlcoholGrams > targetGrams;
                            final maxValue = isOverLimit ? _totalAlcoholGrams : targetGrams;
                            
                            // 目標値のマーカーの相対位置を計算
                            final targetPosition = (targetGrams / maxValue).clamp(0.0, 1.0);
                            // 現在値の相対位置を計算
                            final currentPosition = (_totalAlcoholGrams / maxValue).clamp(0.0, 1.0);

                            return Container(
                              height: 24, // マーカーのスペースを確保
                              child: Stack(
                                children: [
                                  // プログレスバー（下部に配置）
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 12,
                                      child: Stack(
                                        children: [
                                          // 背景
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          // 進捗バー
                                          FractionallySizedBox(
                                            widthFactor: currentPosition,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isOverLimit ? Colors.red[_getWarningLevel()] : Colors.green,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 目標値のマーカー（三角形）
                                  if (targetPosition < 1.0) // 目標値が表示範囲内の場合のみ表示
                                    Positioned(
                                      left: constraints.maxWidth * targetPosition - 10,
                                      top: 0,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 12,
                                            child: CustomPaint(
                                              painter: TriangleMarkerPainter(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 2,
                                            height: 12,
                                            color: Colors.black87,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '現在: ${(_totalAlcoholGrams / 20.0).toStringAsFixed(1)}杯',
                              style: TextStyle(
                                color: _dailyLimit != null &&
                                        _totalAlcoholGrams >= (_dailyLimit! * 20.0)
                                    ? Colors.red[_getWarningLevel()]
                                    : Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_dailyLimit != null && _totalAlcoholGrams > (_dailyLimit! * 20.0))
                              Text(
                                '目標の${(_totalAlcoholGrams / (_dailyLimit! * 20.0)).toStringAsFixed(1)}倍を摂取',
                                style: TextStyle(
                                  color: Colors.red[_getWarningLevel()],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Text(
                                '目標: ${_dailyLimit?.toStringAsFixed(1) ?? '2.0'}杯',
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
              _buildBeerIcons(_calculateBeerCount(_totalAlcoholGrams)),
              Text(
                '中ジョッキ${_calculateBeerCount(_totalAlcoholGrams)}杯分',
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
            if (_drinkHistory.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '今日飲んだお酒',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...List.generate(
                _drinkHistory.length,
                (index) {
                  // リストを逆順にアクセス
                  final reverseIndex = _drinkHistory.length - 1 - index;
                  return ListTile(
                    leading: _getIconForDrinkType(_drinkHistory[reverseIndex].type),
                    title: Text('${_drinkHistory[reverseIndex].type} (${_drinkHistory[reverseIndex].size})'),
                    subtitle: Text('アルコール量: ${_drinkHistory[reverseIndex].alcoholGrams.toStringAsFixed(1)}g'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () => _handleRefill(_drinkHistory[reverseIndex]),
                      tooltip: 'おかわり',
                    ),
                  );
                },
              ),
            ],
            if (_totalAlcoholGrams > 0) ...[
              const SizedBox(height: 32),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: _showResetConfirmDialog,
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text(
                    '記録をリセット',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
