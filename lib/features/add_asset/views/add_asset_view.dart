import 'dart:async';
import 'package:flutter/material.dart';
import 'package:portfolio_tracker/app/theme/app_theme.dart';
import 'package:portfolio_tracker/features/add_asset/models/token.dart';
import 'package:portfolio_tracker/features/add_asset/services/token_service.dart';
import 'package:portfolio_tracker/data/models/asset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AddAssetView extends StatefulWidget {
  const AddAssetView({super.key});

  @override
  State<AddAssetView> createState() => _AddAssetViewState();
}

class _AddAssetViewState extends State<AddAssetView> {
  final _tokenService = TokenService();
  final _searchController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _amountController = TextEditingController();
  Token? _selectedToken;
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),

              child: SearchBar(
                controller: _searchController,
                hintText: 'Token ara (örn: ETH)',
                hintStyle: MaterialStateProperty.all(
                  TextStyle(color: AppTheme.textSecondary),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                leading: Icon(Icons.search, color: AppTheme.textSecondary),
                onChanged: _searchToken,
              ),

            ),

            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_selectedToken != null)
              Card(
                color: AppTheme.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primary,
                              child: Text(
                                _selectedToken!.symbol.substring(0, 2),
                                style: TextStyle(color: AppTheme.background),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedToken!.symbol,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _selectedToken!.name,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${_selectedToken!.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Buy Price',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _buyPriceController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.numbers,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addAsset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            foregroundColor: AppTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add Asset'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addAsset() async {
    if (_selectedToken == null) return;

    final buyPrice = double.tryParse(_buyPriceController.text);
    final amount = double.tryParse(_amountController.text);

    if (buyPrice == null || amount == null) {
      setState(() => _error = 'Geçerli değerler giriniz');
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('portfolios')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final assets = List<Map<String, dynamic>>.from(data['assets'] ?? []);

        // Aynı symbol'e sahip asset'i bul
        final existingAssetIndex = assets.indexWhere(
          (asset) => asset['symbol'] == _selectedToken!.symbol,
        );

        if (existingAssetIndex != -1) {
          // Varolan asset'i güncelle
          final existingAsset = assets[existingAssetIndex];
          final oldAmount = existingAsset['quantity'] as double;
          final oldBuyPrice = existingAsset['buyPrice'] as double;

          // Yeni ortalama alış fiyatı hesapla
          final totalOldCost = oldAmount * oldBuyPrice;
          final totalNewCost = amount * buyPrice;
          final totalAmount = oldAmount + amount;
          final averageBuyPrice = (totalOldCost + totalNewCost) / totalAmount;

          assets[existingAssetIndex] = {
            'id': existingAsset['id'],
            'symbol': _selectedToken!.symbol,
            'name': _selectedToken!.name,
            'quantity': totalAmount,
            'buyPrice': averageBuyPrice,
            'currentPrice': _selectedToken!.price,
            'totalValue': totalAmount * _selectedToken!.price,
          };

          await FirebaseFirestore.instance
              .collection('portfolios')
              .doc(userId)
              .update({'assets': assets});
        } else {
          // Yeni asset ekle
          final newAsset = {
            'id': const Uuid().v4(),
            'symbol': _selectedToken!.symbol,
            'name': _selectedToken!.name,
            'quantity': amount,
            'buyPrice': buyPrice,
            'currentPrice': _selectedToken!.price,
            'totalValue': amount * _selectedToken!.price,
          };

          await FirebaseFirestore.instance
              .collection('portfolios')
              .doc(userId)
              .set({
            'assets': FieldValue.arrayUnion([newAsset]),
          }, SetOptions(merge: true));
        }
      } else {
        // İlk asset'i ekle
        final newAsset = {
          'id': const Uuid().v4(),
          'symbol': _selectedToken!.symbol,
          'name': _selectedToken!.name,
          'quantity': amount,
          'buyPrice': buyPrice,
          'currentPrice': _selectedToken!.price,
          'totalValue': amount * _selectedToken!.price,
        };

        await FirebaseFirestore.instance
            .collection('portfolios')
            .doc(userId)
            .set({
          'assets': [newAsset],
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Varlık başarıyla eklendi')),
        );
        _clearForm();
      }
    } catch (e) {
      setState(() => _error = 'Varlık eklenirken bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _selectedToken = null;
    _buyPriceController.clear();
    _amountController.clear();
    _searchController.clear();
  }

  Future<void> _searchToken(String symbol) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (symbol.isEmpty) {
      setState(() {
        _selectedToken = null;
        _error = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final response = await _tokenService.searchToken(symbol);
        if (!mounted) return;

        setState(() {
          _selectedToken = Token.fromJson(response, symbol.toUpperCase());
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _error = 'Token bulunamadı';
          _selectedToken = null;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
