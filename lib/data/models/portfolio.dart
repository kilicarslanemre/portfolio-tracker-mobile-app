import 'package:portfolio_tracker/data/models/asset.dart';

class Portfolio {
  final String id;
  final String name;
  final List<Asset> assets;
  final double totalValue;

  Portfolio({
    required this.id,
    required this.name,
    required this.assets,
    double? totalValue,
  }) : totalValue = totalValue ??
            assets.fold(
              0,
              (total, asset) => total + (asset.quantity * asset.currentPrice),
            );
}
