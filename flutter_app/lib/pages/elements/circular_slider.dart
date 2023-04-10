import 'package:flutter/material.dart';
import 'package:iot_ui/data/models/configuration.dart';
import 'package:iot_ui/data/models/extreme_values.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../constants/text_styles.dart';

class CircularSlider extends StatefulWidget {
  final double screenWidth;
  final Configuration config;
  final ExtremeValues limits;

  const CircularSlider({
    Key? key,
    required this.screenWidth,
    required this.config,
    required this.limits,
  }) : super(key: key);

  @override
  State<CircularSlider> createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  late CustomSliderWidths customWidth;

  @override
  void initState() {
    customWidth = CustomSliderWidths(
      trackWidth: 5,
      progressBarWidth: 15,
      shadowWidth: 2,
    );
    super.initState();
  }

  late final customAppearance = CircularSliderAppearance(
    customWidths: customWidth,
    customColors: CustomSliderColors(
      dotColor: Colors.white.withOpacity(0.8),
      trackColor: Colors.teal.withAlpha(0x3d),
      progressBarColor: Colors.teal,
      shadowColor: Colors.teal,
      shadowStep: 0.1,
      shadowMaxOpacity: 0.3,
    ),
    animationEnabled: false,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SleekCircularSlider(
          appearance: customAppearance,
          min: widget.limits.minTemperature,
          max: widget.limits.maxTemperature,
          initialValue: widget.config.targetTmp,
          onChange: (double value) {
            setState(() {
              widget.config.targetTmp = value;
            });
          },
          innerWidget: (double value) {
            return _customInnerWidget(value);
          },
        ),
      ],
    );
  }

  Widget _customInnerWidget(double value) {
    return Center(
        child: Text(
      '${value.toStringAsFixed(0)}°C',
      style: commonTextStyle,
    ));
  }
}
