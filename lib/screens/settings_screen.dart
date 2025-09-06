import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);

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
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('データを削除'),
            textColor: Colors.red,
            onTap: () {
              // TODO: データ削除の確認ダイアログと処理を実装
            },
          ),
        ],
      ),
    );
  }
}
