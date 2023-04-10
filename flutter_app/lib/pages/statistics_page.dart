import 'package:flutter/material.dart';
import 'elements/chart.dart';

class LiveData {
  LiveData(this.time, this.data);
  final String time;
  final num data;
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: const [
          Chart(
            measurement: 'poolTmp',
            yAxisTitle: 'Temperature (°C)',
            chartTitle: 'Pool Temperature',
          ),
          Chart(
            measurement: 'saunaHum',
            yAxisTitle: 'Humidity (RH)',
            chartTitle: 'Sauna Humidity',
          ),
          Chart(
            measurement: 'saunaTmp',
            yAxisTitle: 'Temperature (°C)',
            chartTitle: 'Sauna Temperature',
          ),
        ],
      ),
    ));
  }
}
