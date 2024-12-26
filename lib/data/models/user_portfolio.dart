import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_tracker/data/models/asset.dart';

class UserPortfolio {
  final String userId;
  final List<Asset> assets;

  UserPortfolio({
    required this.userId,
    required this.assets,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'assets': assets.map((asset) => asset.toMap()).toList(),
    };
  }

  factory UserPortfolio.fromMap(Map<String, dynamic> map) {
    return UserPortfolio(
      userId: map['userId'],
      assets: List<Asset>.from(
        (map['assets'] as List).map((asset) => Asset.fromMap(asset)),
      ),
    );
  }
}
