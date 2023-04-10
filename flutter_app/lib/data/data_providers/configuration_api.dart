import 'package:http/http.dart' as http;
import 'dart:convert';
import '/data/models/configuration.dart';

class ConfigurationAPI {
  Future<Configuration> getConfiguration(int index) async {
    http.Response response =
        await http.get(Uri.parse('http://localhost:3000/getconfig'));
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      return Configuration.fromJson(list[index]);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> setConfiguration(Object data) async {
    http.Response response = await http.post(
      Uri.parse('http://localhost:3000/setconfig'),
      body: jsonEncode(data),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return 'Configuration successfully applied!';
    } else {
      return 'Failed to create configuration.';
    }
  }
}
