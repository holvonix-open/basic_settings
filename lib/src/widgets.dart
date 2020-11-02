import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'model.dart';

class BoolSetting extends StatelessWidget {
  const BoolSetting(
    this.setting,
    this.name, {
    this.description,
    Key key,
  }) : super(key: key);

  final String name, description;
  final Setting<bool, dynamic> setting;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (ctx) => SwitchListTile.adaptive(
          title: Text(name),
          subtitle: description != null ? Text(description) : null,
          value: setting.value,
          onChanged: (val) {
            setting.value = val;
          }),
    );
  }
}

class CheckboxSetting extends StatelessWidget {
  const CheckboxSetting(
    this.setting,
    this.name, {
    Key key,
  }) : super(key: key);

  final String name;
  final Setting<bool, dynamic> setting;

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (ctx) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: setting.value,
                  onChanged: (val) {
                    setting.value = val;
                  },
                ),
                Text(name)
              ],
            ));
  }
}

class RangeSetting extends StatelessWidget {
  const RangeSetting(
    this.setting,
    this.name, {
    Key key,
    @required this.min,
    @required this.max,
  }) : super(key: key);

  final Setting<double, dynamic> setting;
  final String name;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (ctx) => Column(
        children: [
          ListTile(
            title: Text(name),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Slider(
              label: '${setting.value}',
              value: setting.value,
              min: min,
              max: max,
              onChanged: (val) {
                setting.value = val;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EnumSetting<T> extends StatelessWidget {
  const EnumSetting(
    this.setting,
    this.name, {
    Key key,
    this.description,
    @required this.values,
    @required this.names,
  })  : assert(values.length == names.length),
        super(key: key);

  final Setting<T, dynamic> setting;
  final String name, description;
  final List<T> values;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (ctx) => Column(
        children: [
          ListTile(
            title: Text(name),
            subtitle: description != null ? Text(description) : null,
          ),
          ...(List.generate(
            values.length,
            (index) => RadioListTile(
              title: Text(names[index]),
              groupValue: setting.value,
              value: values[index],
              onChanged: (v) {
                setting.value = v;
              },
            ),
          )),
        ],
      ),
    );
  }
}
