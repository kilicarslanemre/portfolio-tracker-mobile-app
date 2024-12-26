import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portfolio_tracker/data/models/portfolio.dart';
import 'package:portfolio_tracker/data/models/asset.dart';

abstract class PortfolioRepository {
  Stream<Portfolio> getPortfolio();
  Future<void> addAsset(Asset asset);
  Future<void> deleteAsset(String assetId);
  Future<void> updateAssetAmount(String assetId, double amount);
}

class PortfolioRepositoryImpl implements PortfolioRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Stream<Portfolio> getPortfolio() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Kullanıcı oturum açmamış');

    return _firestore.collection('portfolios').doc(userId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) {
          return Portfolio(
            id: userId,
            name: 'My Portfolio',
            assets: [],
          );
        }

        final data = snapshot.data()!;
        final assets = (data['assets'] as List? ?? [])
            .map((asset) => Asset.fromMap(asset))
            .toList();

        final totalValue = assets.fold<double>(
          0,
          (total, asset) => total + (asset.quantity * asset.currentPrice),
        );

        return Portfolio(
          id: userId,
          name: 'My Portfolio',
          assets: assets,
          totalValue: totalValue,
        );
      },
    );
  }

  @override
  Future<void> addAsset(Asset asset) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Kullanıcı oturum açmamış');

    await _firestore.collection('portfolios').doc(userId).set({
      'assets': FieldValue.arrayUnion([asset.toMap()]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteAsset(String assetId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Kullanıcı oturum açmamış');

    final docRef = _firestore.collection('portfolios').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final assets = List<Map<String, dynamic>>.from(data['assets'] ?? []);
      assets.removeWhere((asset) => asset['id'] == assetId);

      await docRef.update({'assets': assets});
    }
  }

  @override
  Future<void> updateAssetAmount(String assetId, double amount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Kullanıcı oturum açmamış');

    final docRef = _firestore.collection('portfolios').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final assets = List<Map<String, dynamic>>.from(data['assets'] ?? []);
      final assetIndex = assets.indexWhere((asset) => asset['id'] == assetId);

      if (assetIndex != -1) {
        final asset = assets[assetIndex];
        final currentQuantity = (asset['quantity'] as num).toDouble();
        final newAmount = currentQuantity - amount;

        if (newAmount <= 0) {
          // Miktar 0 veya daha az ise asset'i tamamen sil
          assets.removeAt(assetIndex);
        } else {
          // Miktarı güncelle
          assets[assetIndex] = {
            ...asset,
            'quantity': newAmount,
            'totalValue': newAmount * (asset['currentPrice'] as num).toDouble(),
          };
        }

        await docRef.update({'assets': assets});
      }
    }
  }
}
