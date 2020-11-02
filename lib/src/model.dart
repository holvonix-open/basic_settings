import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

part 'model.g.dart';

// ignore: non_constant_identifier_names
final basic_settingsLogger = Logger('basic_settings');

@sealed
class Setting<T, U> extends _Setting<T, U> with _$Setting<T, U> {
  Setting(Box box, String key,
      {T defaultValue,
      @required U Function(T) store,
      @required T Function(U) load})
      : super(box, key, defaultValue: defaultValue, store: store, load: load);

  static Setting<T, T> simple<T>(Box box, String key, {T defaultValue}) =>
      Setting<T, T>(box, key,
          defaultValue: defaultValue, store: (t) => t, load: (u) => u);

  static Setting<bool, bool> boolValue(Box box, String key,
          {bool defaultValue}) =>
      simple<bool>(box, key, defaultValue: defaultValue);

  static Setting<String, String> stringValue(Box box, String key,
          {String defaultValue}) =>
      simple<String>(box, key, defaultValue: defaultValue);

  static Setting<int, int> intValue(Box box, String key, {int defaultValue}) =>
      simple<int>(box, key, defaultValue: defaultValue);

  static Setting<T, int> enumValue<T>(Box box, String key,
          {@required List<T> values, T defaultValue}) =>
      Setting<T, int>(box, key,
          defaultValue: defaultValue,
          store: (dynamic t) => t.index,
          load: (u) => values[u]);

  @override
  String toString() {
    return '$value';
  }
}

abstract class _Setting<T, U> with Store {
  final Box _box;
  final String key;
  final T Function(U) load;
  final U Function(T) store;
  _Setting(this._box, this.key,
      {T defaultValue, @required this.store, @required this.load})
      : stream = _box.watch(key: key).asObservable(
              initialValue: BoxEvent(
                key,
                _box.get(key, defaultValue: store(defaultValue)),
                false,
              ),
            ) {
    _cur = load(_box.get(key, defaultValue: store(defaultValue)));
    stream.listen((event) {
      basic_settingsLogger?.fine(() =>
          'Stream listen $key K: ${event.key} V: ${event.value} D: ${event.deleted}, prior: $_cur');
      _cur = load(event.value ?? store(defaultValue));
    });
  }

  final Stream<BoxEvent> stream;

  @observable
  T _cur;

  T get value {
    basic_settingsLogger?.finest(() => 'Loading $key => $_cur');
    return _cur;
  }

  set value(T newValue) {
    setValue(newValue);
  }

  Future<void> setValue(T newValue) async {
    basic_settingsLogger?.fine(() => 'Setting $key => $newValue');
    return _box.put(key, store(newValue));
  }
}

enum ThemeSetting { system, light, dark }

extension ThemeSettingMode on ThemeSetting {
  static const _map = {
    ThemeSetting.dark: ThemeMode.dark,
    ThemeSetting.light: ThemeMode.light,
    ThemeSetting.system: ThemeMode.system,
  };

  ThemeMode get themeMode {
    return _map[this];
  }
}
