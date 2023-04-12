import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';

import '../../constants/global.dart';
import '../../data/data_providers/monitoring_api.dart';
import '../../data/models/chart_data.dart';

class Chart extends StatefulWidget {
  final String measurement;
  final String chartTitle;
  final String yAxisTitle;

  const Chart({
    Key? key,
    required this.measurement,
    required this.yAxisTitle,
    required this.chartTitle,
  }) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late ChartSeriesController _chartSeriesController;
  late List<ChartData> chartData;
  late int count;

  @override
  void initState() {
    count = 1;
    connectSse();
    chartData = getChartData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        title: ChartTitle(text: widget.chartTitle),
        series: <LineSeries<ChartData, int>>[
          LineSeries<ChartData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            dataSource: chartData,
            color: Colors.teal,
            xValueMapper: (ChartData sales, _) => sales.time,
            yValueMapper: (ChartData sales, _) => sales.data,
          )
        ],
        primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 5,
            title: AxisTitle(text: 'Time (seconds)')),
        primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            title: AxisTitle(text: widget.yAxisTitle)));
  }

  void connectSse() {
    var myStream = Sse.connect(
      uri: Uri.parse('http://$ip:$port/monitoring'),
      closeOnError: true,
      withCredentials: false,
    ).stream;

    myStream.listen((event) {
      chartData.add(ChartData(count, json.decode(event)[widget.measurement]));
      _updateDataSource(chartData, _chartSeriesController);
      count = count + 1;
    });
  }

  void _updateDataSource(
      List<ChartData> chartData, ChartSeriesController chartSeriesController) {
    if (chartData.length == 30 || count == 1) {
      chartData.removeAt(0);
      chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[chartData.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[chartData.length - 1],
      );
    }
  }

  List<ChartData> getChartData() {
    return <ChartData>[ChartData(0, 27)];
  }
}
