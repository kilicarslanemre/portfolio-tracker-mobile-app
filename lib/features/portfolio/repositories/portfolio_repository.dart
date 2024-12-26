import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

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
      final newAmount = asset['quantity'] - amount;

      if (newAmount <= 0) {
        // Miktar 0 veya daha az ise asset'i tamamen sil
        assets.removeAt(assetIndex);
      } else {
        // Miktarı güncelle
        assets[assetIndex] = {
          ...asset,
          'quantity': newAmount,
          'totalValue': newAmount * asset['currentPrice'],
        };
      }

      await docRef.update({'assets': assets});
    }
  }
}
