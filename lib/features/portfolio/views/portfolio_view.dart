import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_tracker/features/portfolio/viewmodels/portfolio_viewmodel.dart';
import 'package:portfolio_tracker/features/portfolio/widgets/asset_card.dart';
import 'package:portfolio_tracker/app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PortfolioView extends StatefulWidget {
  const PortfolioView({super.key});

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  bool _isBalanceVisible = true;

  String _formatBalance(double balance) {
    if (!_isBalanceVisible) return '∗∗∗∗∗∗';

    String priceString = balance.toStringAsFixed(2);
    final parts = priceString.split('.');
    final wholePart = parts[0];
    final decimalPart = parts[1];

    // Binlik ayracı ekleme
    final chars = wholePart.split('').reversed.toList();
    String formatted = '';
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted = ',' + formatted;
      }
      formatted = chars[i] + formatted;
    }

    return '\$${formatted}.${decimalPart}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<PortfolioViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Text(
                viewModel.error!,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          final portfolio = viewModel.portfolio;
          if (portfolio == null || portfolio.assets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Portföyünüzde henüz bir varlık bulunmuyor',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          final totalBalance = portfolio.assets.fold<double>(
            0,
            (total, asset) => total + (asset.quantity * asset.currentPrice),
          );

          return RefreshIndicator(
            onRefresh: viewModel.refreshPortfolio,
            child: CustomScrollView(
              slivers: [
                // Total Balance Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _formatBalance(totalBalance),
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                _isBalanceVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isBalanceVisible = !_isBalanceVisible;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: AppTheme.surface,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                // Asset Cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final asset = portfolio.assets[index];
                        return AssetCard(
                          id: asset.id,
                          symbol: asset.symbol,
                          name: asset.name,
                          amount: asset.quantity,
                          buyPrice: asset.buyPrice,
                          onDelete: (assetId) {
                            viewModel.deleteAsset(assetId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Varlık silindi')),
                            );
                          },
                          onUpdateAmount: (assetId, amount) {
                            viewModel.updateAssetAmount(assetId, amount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Varlık miktarı güncellendi')),
                            );
                          },
                        );
                      },
                      childCount: portfolio.assets.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
