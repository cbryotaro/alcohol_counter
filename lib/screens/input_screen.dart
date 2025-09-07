import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputScreen extends StatefulWidget {
  final Function(double, {String type, String size}) onRecordSaved;
  
  const InputScreen({
    super.key,
    required this.onRecordSaved,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  String _selectedAlcoholType = '生ビール';
  String _selectedSize = '中ジョッキ';

  void _showSizeSelectionModal(Map<String, dynamic> alcoholType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${alcoholType['name']}のサイズを選択',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...alcoholType['sizes'].map<Widget>((size) {
                return ListTile(
                  title: Text(size),
                  onTap: () {
                    setState(() {
                      _selectedSize = size;
                    });
                    Navigator.pop(context); // モーダルを閉じる
                    _saveRecord(); // 記録を保存
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // アルコール量を計算（純アルコールの量をグラムで返す）
  double _calculateAlcoholGrams(Map<String, dynamic> alcoholType, String size) {
    final double alcoholContent = alcoholType['alcoholContent'];
    final int volumeInMl = alcoholType['volumes'][size];
    // アルコールの比重を0.8として計算
    return volumeInMl * alcoholContent * 0.8;
  }

  void _saveRecord() {
    // 選択された種類のアルコール情報を取得
    final alcoholType = _alcoholTypes.firstWhere((type) => type['name'] == _selectedAlcoholType);
    // アルコール量を計算（グラム）
    final alcoholGrams = _calculateAlcoholGrams(alcoholType, _selectedSize);
    // コールバックで親に通知（種類とサイズの情報も含める）
    widget.onRecordSaved(
      alcoholGrams,
      type: _selectedAlcoholType,
      size: _selectedSize,
    );
    Navigator.pop(context);
  }

  // お酒の種類の定義
  final List<Map<String, dynamic>> _alcoholTypes = [
    {
      'name': '生ビール',
      'image': 'assets/images/beer.png',
      'sizes': ['小ジョッキ', '中ジョッキ', '大ジョッキ'],
      'alcoholContent': 0.05, // 5%
      'volumes': {
        '小ジョッキ': 340, // ml
        '中ジョッキ': 500, // ml
        '大ジョッキ': 700, // ml
      },
    },
    {
      'name': '焼酎',
      'image': 'assets/images/shochu.png',
      'sizes': ['0.5合', '1合', '2合'],
      'alcoholContent': 0.25, // 25%
      'volumes': {
        '0.5合': 90, // ml
        '1合': 180, // ml
        '2合': 360, // ml
      },
    },
    {
      'name': '日本酒',
      'image': 'assets/images/sake.png',
      'sizes': ['0.5合', '1合', '2合'],
      'alcoholContent': 0.15, // 15%
      'volumes': {
        '0.5合': 90, // ml
        '1合': 180, // ml
        '2合': 360, // ml
      },
    },
    {
      'name': 'ワイン',
      'image': 'assets/images/wine.png',
      'sizes': ['グラス(120ml)', 'ボトル(750ml)'],
      'alcoholContent': 0.12, // 12%
      'volumes': {
        'グラス(120ml)': 120, // ml
        'ボトル(750ml)': 750, // ml
      },
    },
    {
      'name': 'ウイスキー',
      'image': 'assets/images/whiskey.png',
      'sizes': ['シングル(30ml)', 'ダブル(60ml)'],
      'alcoholContent': 0.40, // 40%
      'volumes': {
        'シングル(30ml)': 30, // ml
        'ダブル(60ml)': 60, // ml
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('飲酒を記録'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'お酒の種類を選択',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // 画面幅が768px以上の場合は5列、それ以外は3列
                final crossAxisCount = constraints.maxWidth >= 768 ? 5 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _alcoholTypes.length,
                  itemBuilder: (BuildContext context, int index) {
                final type = _alcoholTypes[index];
                final isSelected = _selectedAlcoholType == type['name'];
                
                return Card(
                  elevation: isSelected ? 8 : 2,
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAlcoholType = type['name'];
                      });
                      _showSizeSelectionModal(type);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          type['image'],
                          width: 48,
                          height: 48,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          type['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                  },
                );
              },
            ),
          ],
          ),
        ),
      ),
    );
  }
}
