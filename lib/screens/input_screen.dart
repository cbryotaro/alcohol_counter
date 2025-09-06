import 'package:flutter/material.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  double _alcoholUnits = 0.0;
  
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '飲酒量を入力',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _alcoholUnits,
              min: 0,
              max: 10,
              divisions: 20,
              label: _alcoholUnits.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _alcoholUnits = value;
                });
              },
            ),
            Text(
              '${_alcoholUnits.toStringAsFixed(1)} 単位',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
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
    );
  }
}
