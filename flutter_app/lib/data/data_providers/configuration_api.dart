import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../pages/elements/custom_alert_dialog.dart';
import '/data/models/configuration.dart';
import 'package:flutter/material.dart';

class ConfigurationAPI {
  Future<Configuration> getConfiguration(
      int index, String ip, String port, BuildContext context) async {
    try {
      http.Response response =
          await http.get(Uri.parse('http://$ip:$port/getconfig'));
      if (response.statusCode == 200) {
        List list = jsonDecode(response.body);
        return Configuration.fromJson(list[index]);
      } else {
        throw Exception('Failed to load data');
      }
    } on Exception {
      CustomAlertDialog.show("Exception loading data", context: context);
      return Configuration(heater: "error", targetTmp: 30, delta: 3);
    }
  }

  Future<String> setConfiguration(Object data, String ip, String port) async {
    try {
      http.Response response = await http.post(
        Uri.parse('http://$ip:$port/setconfig'),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        return 'Configuration successfully applied!';
      } else {
        throw Exception('Failed to load data');
      }
    } on Exception {
      return 'Failed to load data';
    }
  }
}
