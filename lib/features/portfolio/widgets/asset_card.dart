import 'package:flutter/material.dart';
import 'package:portfolio_tracker/app/theme/app_theme.dart';
import 'package:portfolio_tracker/features/add_asset/services/token_service.dart';

class AssetCard extends StatefulWidget {
  final String id;
  final String symbol;
  final String name;
  final double amount;
  final double buyPrice;
  final Function(String) onDelete;
  final Function(String, double) onUpdateAmount;

  const AssetCard({
    super.key,
    required this.id,
    required this.symbol,
    required this.name,
    required this.amount,
    required this.buyPrice,
    required this.onDelete,
    required this.onUpdateAmount,
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  final _tokenService = TokenService();
  double? _currentPrice;
  bool _isLoading = true;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentPrice();
  }

  Future<void> _fetchCurrentPrice() async {
    try {
      final response = await _tokenService.searchToken(widget.symbol);
      if (!mounted) return;

      setState(() {
        _currentPrice = response['data'][widget.symbol.toUpperCase()]['quote']
                ['USD']['price']
            .toDouble();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showEditModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Token Miktarını Düzenle',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Çıkarmak istediğiniz miktar (Max: ${widget.amount})',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: '0.00',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Geçerli bir miktar giriniz')),
                    );
                    return;
                  }
                  if (amount > widget.amount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mevcut miktardan fazla çıkaramazsınız'),
                      ),
                    );
                    return;
                  }

                  if (amount == widget.amount) {
                    widget.onDelete(widget.id);
                  } else {
                    widget.onUpdateAmount(widget.id, amount);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Güncelle',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalValue =
        _currentPrice != null ? widget.amount * _currentPrice! : 0.0;
    final pnlAmount = _currentPrice != null
        ? ((_currentPrice! - widget.buyPrice) * widget.amount)
        : 0.0;
    final pnlPercentage = _currentPrice != null
        ? ((_currentPrice! - widget.buyPrice) / widget.buyPrice) * 100
        : 0.0;
    final isPnlPositive = pnlAmount >= 0;

    return Card(
      elevation: 0,
      color: AppTheme.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.delete_outline,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.cardBackground,
                    title: Text(
                      'Varlığı Sil',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    content: Text(
                      'Bu varlığı silmek istediğinizden emin misiniz?',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'İptal',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onDelete(widget.id);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sil',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst kısım - Token bilgileri ve miktar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sol taraf - Token bilgileri
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.surface,
                            radius: 16,
                            child: Text(
                              widget.symbol.substring(0, 2),
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.symbol,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      widget.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor:
                                                AppTheme.cardBackground,
                                            title: Text(
                                              'Varlığı Sil',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary),
                                            ),
                                            content: Text(
                                              'Bu varlığı silmek istediğinizden emin misiniz?',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.textSecondary),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'İptal',
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .textSecondary),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  widget.onDelete(widget.id);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Sil',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: _showEditModal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sağ taraf - Miktar ve değer
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.amount.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (_currentPrice != null)
                          Text(
                            '≈\$${totalValue.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Alt kısım - Fiyat bilgileri ve PNL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sol taraf - Başlıklar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ort. Alış Fiyatı',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        if (_currentPrice != null)
                          Text(
                            'Anlık Fiyat',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        Text(
                          'PNL',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Sağ taraf - Değerler
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.buyPrice.toStringAsFixed(3)}',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        if (_currentPrice != null)
                          Text(
                            '\$${_currentPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        if (_currentPrice != null)
                          Text(
                            '${isPnlPositive ? '+' : ''}\$${pnlAmount.toStringAsFixed(2)} (${isPnlPositive ? '+' : ''}${pnlPercentage.toStringAsFixed(2)}%)',
                            style: TextStyle(
                              color: isPnlPositive ? Colors.green : Colors.red,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
