import 'package:basic_settings/basic_settings.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Settings {
  static Future<Settings> load(HiveInterface hive, String name) async {
    return Settings._(await hive.openBox('ex1'));
  }

  final Box _box;

  Settings._(this._box)
      : dingSetting = Setting.simple(_box, 'ding', defaultValue: false),
        dinosaursSetting =
            Setting.simple(_box, 'dinosaursRawr', defaultValue: true),
        themeSetting = Setting.enumValue(_box, 'themeSetting',
            values: ThemeSetting.values, defaultValue: ThemeSetting.system),
        cacheSetting =
            Setting.simple(_box, 'cacheSetting', defaultValue: 250.0);

  void clear() async {
    await _box.clear();
  }

  final Setting<bool, bool> dingSetting;
  final Setting<bool, bool> dinosaursSetting;
  final Setting<ThemeSetting, int> themeSetting;
  final Setting<double, double> cacheSetting;
}

class SettingsPage extends StatelessWidget {
  final Settings settings;

  const SettingsPage({Key? key, required this.settings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = [
      BoolSetting(settings.dingSetting, 'Notifications',
          description: 'Play a ding sound!'),
      EnumSetting(settings.themeSetting, 'Theme',
          values: [ThemeSetting.system, ThemeSetting.light, ThemeSetting.dark],
          names: ['System', 'Light', 'Dark']),
      RangeSetting(settings.cacheSetting, 'Cache size (MB)', min: 0, max: 1000),
      BoolSetting(settings.dinosaursSetting, 'Enable Dinosaurs'),
      SizedBox(
        height: 64,
      ),
    ];
    return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
            child: ListView(
                shrinkWrap: true,
                children: ListTile.divideTiles(
                  tiles: children,
                  context: context,
                ).toList())));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(MyApp(settings: await Settings.load(Hive, 'settings')));
}

class MyApp extends StatelessWidget {
  final Settings settings;

  const MyApp({Key? key, required this.settings}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SettingsPage(settings: settings),
    );
  }
}
