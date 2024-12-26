class Asset {
  final String id;
  final String symbol;
  final String name;
  final double quantity;
  final double buyPrice;
  final double currentPrice;
  final double totalValue;

  Asset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.buyPrice,
    required this.currentPrice,
    required this.totalValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'currentPrice': currentPrice,
      'totalValue': totalValue,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'],
      symbol: map['symbol'],
      name: map['name'],
      quantity: map['quantity'].toDouble(),
      buyPrice: map['buyPrice'].toDouble(),
      currentPrice: map['currentPrice'].toDouble(),
      totalValue: map['totalValue'].toDouble(),
    );
  }
}
