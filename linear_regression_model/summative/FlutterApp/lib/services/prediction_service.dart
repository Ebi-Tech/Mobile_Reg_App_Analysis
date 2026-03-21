import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_input.dart';

class PredictionService {
  static const String _baseUrl =
      'https://mobile-reg-app-analysis.onrender.com';

  /// Sends student data to the API and returns the predicted exam score.
  /// Throws an [Exception] if the request fails or the server returns an error.
  static Future<double> predict(StudentInput input) async {
    final uri = Uri.parse('$_baseUrl/predict');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(input.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['predicted_exam_score'] as num).toDouble();
    } else if (response.statusCode == 422) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception('Validation error: ${data['detail']}');
    } else {
      throw Exception(
        'Server error ${response.statusCode}: ${response.body}',
      );
    }
  }
}
