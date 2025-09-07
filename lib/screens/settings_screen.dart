import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _enableNotifications = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  double _dailyLimit = 2.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = _prefs.getBool('enableNotifications') ?? true;
      _reminderTime = TimeOfDay(
        hour: _prefs.getInt('reminderHour') ?? 21,
        minute: _prefs.getInt('reminderMinute') ?? 0,
      );
      _dailyLimit = _prefs.getDouble('dailyLimit') ?? 2.0;
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setBool('enableNotifications', _enableNotifications);
    await _prefs.setInt('reminderHour', _reminderTime.hour);
    await _prefs.setInt('reminderMinute', _reminderTime.minute);
    await _prefs.setDouble('dailyLimit', _dailyLimit);
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
          SwitchListTile(
            title: const Text('通知'),
            subtitle: const Text('毎日の記録リマインダー'),
            value: _enableNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableNotifications = value;
              });
              _saveSettings();
            },
          ),
          ListTile(
            title: const Text('リマインダー時刻'),
            subtitle: Text('${_reminderTime.format(context)}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final TimeOfDay? newTime = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (newTime != null) {
                setState(() {
                  _reminderTime = newTime;
                });
                _saveSettings();
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('1日の目標'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: _dailyLimit,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: '${_dailyLimit.toStringAsFixed(1)}杯',
                  onChanged: (value) {
                    setState(() {
                      _dailyLimit = value;
                    });
                    _saveSettings();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '中ジョッキ ${_dailyLimit.toStringAsFixed(1)}杯まで',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '(アルコール量: 約${(_dailyLimit * 20).toStringAsFixed(1)}g)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
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
