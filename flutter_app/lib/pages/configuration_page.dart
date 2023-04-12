import 'package:flutter/material.dart';
import 'package:iot_ui/pages/elements/circular_slider.dart';

import '../constants/global.dart';
import '../data/models/configuration.dart';
import '../data/data_providers/configuration_api.dart';
import '../data/models/extreme_values.dart';
import '../constants/text_styles.dart';
import 'elements/custom_alert_dialog.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  late final ConfigurationAPI api;
  late Future<Configuration> futureSaunaConfiguration;
  late Future<Configuration> futurePoolConfiguration;

  late Configuration saunaConfiguration;
  late Configuration poolConfiguration;

  late ExtremeValues saunaEV;
  late ExtremeValues poolEV;

  void onPressedApply() {
    setState(() {
      if (saunaConfiguration.targetTmp != -1 &&
          saunaConfiguration.delta != -1 &&
          poolConfiguration.targetTmp != -1 &&
          poolConfiguration.delta != -1 &&
          saunaConfiguration.heater != "error") {
        api
            .setConfiguration(saunaConfiguration.toJson(), ip, port)
            .then((response) {
          api.setConfiguration(poolConfiguration.toJson(), ip, port).then(
            (response) {
              CustomAlertDialog.show(response, context: context);
            },
          ).catchError((e) {
            CustomAlertDialog.show(e, context: context);
          });
        }).catchError((e) {
          CustomAlertDialog.show(e, context: context);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    poolEV = ExtremeValues(10, 40, 0, 5);
    saunaEV = ExtremeValues(20, 100, 0, 5);
    saunaConfiguration =
        Configuration(heater: "sauna", targetTmp: -1, delta: -1);
    poolConfiguration = Configuration(heater: "pool", targetTmp: -1, delta: -1);
    api = ConfigurationAPI();
    futureSaunaConfiguration = api.getConfiguration(0, ip, port, context);
    futurePoolConfiguration = api.getConfiguration(1, ip, port, context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTwoColumnsLayout(screenWidth),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: onPressedApply,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
              child: const Text('Apply'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnsLayout(double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: _buildPoolWidget(screenWidth, poolEV),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: _buildSaunaWidget(screenWidth, saunaEV),
        ),
      ],
    );
  }

  Widget _buildSaunaWidget(double screenWidth, ExtremeValues limits) {
    return FutureBuilder<Configuration>(
      future: futureSaunaConfiguration,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          saunaConfiguration = snapshot.data!;
          return _buildColumn(screenWidth, saunaConfiguration, limits);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPoolWidget(double screenWidth, ExtremeValues limits) {
    return FutureBuilder<Configuration>(
      future: futurePoolConfiguration,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          poolConfiguration = snapshot.data!;
          return _buildColumn(screenWidth, poolConfiguration, limits);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildColumn(
    double screenWidth,
    Configuration config,
    ExtremeValues limits,
  ) {
    return Column(
      children: [
        Text(
          config.heater == 'sauna' ? 'Sauna' : 'Pool',
          style: TextStyles.titleTextStyle,
        ),
        const SizedBox(height: 28.0),
        const Text(
          'Temperature',
          style: TextStyles.title2TextStyle,
        ),
        const SizedBox(height: 16.0),
        CircularSlider(
          screenWidth: screenWidth,
          config: config,
          limits: limits,
        ),
        const SizedBox(height: 8.0),
        const Text(
          'Δ (Accuracy)',
          style: TextStyles.title2TextStyle,
        ),
        buildSliderColumn(screenWidth, config, limits),
      ],
    );
  }

  Widget buildSliderColumn(
      double screenWidth, Configuration config, ExtremeValues limits) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: (screenWidth - 16.0) / 2,
          child: SizedBox(
            width: (screenWidth - 16.0) / 2,
            child: Slider(
              min: 0.0,
              max: 5.0,
              activeColor: Colors.teal,
              inactiveColor: Colors.teal.withAlpha(0x3d),
              value: config.delta,
              onChanged: (value) {
                setState(() {
                  config.delta = value;
                });
              },
            ),
          ),
        ),
        Text(
          '${config.delta.toStringAsFixed(0)}°C',
          style: TextStyles.commonTextStyle,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
