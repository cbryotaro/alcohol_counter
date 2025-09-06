import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  String _selectedAlcoholType = '生ビール';
  String _selectedSize = '中ジョッキ';

  // お酒の種類の定義
  final List<Map<String, dynamic>> _alcoholTypes = [
    {
      'name': '生ビール',
      'image': 'assets/images/beer.png',
      'sizes': ['小ジョッキ', '中ジョッキ', '大ジョッキ'],
    },
    {
      'name': '焼酎',
      'image': 'assets/images/shochu.png',
      'sizes': ['0.5合', '1合', '2合'],
    },
    {
      'name': '日本酒',
      'image': 'assets/images/sake.png',
      'sizes': ['0.5合', '1合', '2合'],
    },
    {
      'name': 'ワイン',
      'image': 'assets/images/wine.png',
      'sizes': ['グラス(120ml)', 'ボトル(750ml)'],
    },
    {
      'name': 'ウイスキー',
      'image': 'assets/images/whiskey.png',
      'sizes': ['シングル(30ml)', 'ダブル(60ml)'],
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,  // 3列に変更
                childAspectRatio: 0.85,  // 縦長に調整
                crossAxisSpacing: 8,  // 間隔を縮小
                mainAxisSpacing: 8,  // 間隔を縮小
              ),
              itemCount: _alcoholTypes.length,
              itemBuilder: (context, index) {
                final type = _alcoholTypes[index];
                final isSelected = _selectedAlcoholType == type['name'];
                
                return Card(
                  elevation: isSelected ? 8 : 2,
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAlcoholType = type['name'];
                        _selectedSize = type['sizes'][0];
                      });
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
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'サイズを選択',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedSize,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: _alcoholTypes
                          .firstWhere((type) => type['name'] == _selectedAlcoholType)['sizes']
                          .map<DropdownMenuItem<String>>((String size) {
                        return DropdownMenuItem<String>(
                          value: size,
                          child: Text(size),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSize = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // TODO: 飲酒量を保存する処理を実装
                Navigator.pop(context);
              },
              child: const Text('記録する'),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
