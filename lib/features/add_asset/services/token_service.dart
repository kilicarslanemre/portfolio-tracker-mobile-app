import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenService {
  final String _baseUrl = 'pro-api.coinmarketcap.com';
  final String _apiKey = '6f25280b-4cb9-4821-88ea-ea5b28796b43';

  Future<Map<String, dynamic>> searchToken(String symbol) async {
    try {
      print('Searching for token: $symbol');

      final uri = Uri.https(_baseUrl, '/v1/cryptocurrency/quotes/latest', {
        'symbol': symbol.toUpperCase(),
      });

      final response = await http.get(
        uri,
        headers: {
          'X-CMC_PRO_API_KEY': _apiKey,
          'Accept': 'application/json',
          // CORS sorununu çözmek için
          'Access-Control-Allow-Origin': '*',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status']['error_code'] != 0) {
          throw Exception(data['status']['error_message']);
        }

        print('Token Data for $symbol: ${data['data'][symbol.toUpperCase()]}');
        return data;
      } else {
        throw Exception('API isteği başarısız oldu: ${response.statusCode}');
      }
    } catch (e) {
      print('Service error: $e');
      rethrow;
    }
  }
}
