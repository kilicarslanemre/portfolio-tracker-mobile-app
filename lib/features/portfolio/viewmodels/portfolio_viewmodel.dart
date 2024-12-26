import 'package:flutter/foundation.dart';
import 'package:portfolio_tracker/data/models/portfolio.dart';
import 'package:portfolio_tracker/data/repositories/portfolio_repository.dart';

class PortfolioViewModel extends ChangeNotifier {
  final PortfolioRepository _repository;
  Portfolio? _portfolio;
  bool _isLoading = false;
  String? _error;

  PortfolioViewModel(this._repository) {
    _initPortfolio();
  }

  Portfolio? get portfolio => _portfolio;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _initPortfolio() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Stream'i dinlemeye başla
      _repository.getPortfolio().listen(
        (portfolio) {
          _portfolio = portfolio;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPortfolio() async {
    await _initPortfolio();
  }

  Future<void> deleteAsset(String assetId) async {
    try {
      await _repository.deleteAsset(assetId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateAssetAmount(String assetId, double amount) async {
    try {
      await _repository.updateAssetAmount(assetId, amount);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
