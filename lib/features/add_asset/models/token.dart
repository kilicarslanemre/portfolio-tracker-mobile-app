class Token {
  final String name;
  final String symbol;
  final double price;

  Token({
    required this.name,
    required this.symbol,
    required this.price,
  });

  factory Token.fromJson(Map<String, dynamic> json, String symbol) {
    try {
      final tokenData = json['data'][symbol];
      if (tokenData == null) {
        throw Exception('Token bulunamadı');
      }

      return Token(
        name: tokenData['name'],
        symbol: tokenData['symbol'],
        price: tokenData['quote']['USD']['price'].toDouble(),
      );
    } catch (e) {
      print('Token parse error: $e'); // Debug için
      rethrow;
    }
  }
}
