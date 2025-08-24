import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/helpers.dart';
import '../../config/config.dart';
import '../../widgets/popups/native_popup.dart';
import '../constants/view_constants.dart';

class AdManager {
  AdManager() {
    _loadBannerAdWidget();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  Widget? _bannerAdWidget;

  final String _banner = 'banner';
  final String _interstitial = 'interstitial';
  final String _rewarded = 'rewarded';

  bool get isInterstitialAdAvailable => _interstitialAd != null;
  bool get isRewardedAdAvailable => _rewardedAd != null;

  late final Map<String, int> _retryCounts = {
    _banner: 0,
    _interstitial: 0,
    _rewarded: 0,
  };

  String get bannerAdUnitId {
    if (Config.debug) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/2435281174'
          : 'ca-app-pub-3940256099942544/9214589741';
    }
    // TODO: Add your own banner ad unit id
    return 'ca-app-pub-xxx/xxx';
  }

  String get interstitialAdUnitId {
    if (Config.debug) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    // TODO: Add your own interstitial ad unit id
    return 'ca-app-pub-xxx/xxx';
  }

  String get rewardedAdUnitId {
    if (Config.debug) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917';
    }
    // TODO: Add your own rewarded ad unit id
    return 'ca-app-pub-xxx/xxx';
  }

  void _loadBannerAd(ValueNotifier<BannerAd?> bannerAdNotifier) {
    final bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          printLog("✅ Banner Ad Loaded");
          _retryCounts[_banner] = 0;
          bannerAdNotifier.value = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          printLog("❌ Banner Ad failed: $error");
          ad.dispose();
          _retryLoadAd(_banner, () => _loadBannerAd(bannerAdNotifier));
        },
      ),
    );
    bannerAd.load();
  }

  void _retryLoadAd(String adType, VoidCallback loadAd) {
    int retryCount = _retryCounts[adType] ?? 0;
    int delay = 2 * (1 << retryCount);
    _retryCounts[adType] = (retryCount + 1).clamp(0, 5);

    printLog("🔄 Retrying $adType Ad in $delay seconds...");

    Future.delayed(Duration(seconds: delay), () {
      loadAd();
    });
  }

  Widget _loadBannerAdWidget() {
    final bannerAdNotifier = ValueNotifier<BannerAd?>(null);
    _loadBannerAd(bannerAdNotifier);
    _bannerAdWidget = ValueListenableBuilder(
      valueListenable: bannerAdNotifier,
      builder: (context, BannerAd? bannerAd, _) {
        if (bannerAd == null) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: bannerAd.size.height.toDouble(),
          width: bannerAd.size.width.toDouble(),
          child: AdWidget(ad: bannerAd),
        );
      },
    );
    return _bannerAdWidget!;
  }

  Widget getBannerAdWidget() {
    Future.delayed(
        const Duration(milliseconds: 200), () => _loadBannerAdWidget());
    if (_bannerAdWidget != null) return _bannerAdWidget!;
    return _loadBannerAdWidget();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _retryCounts[_interstitial] = 0;
        },
        onAdFailedToLoad: (error) {
          printLog("❌ Interstitial Ad failed: $error");
          _retryLoadAd(_interstitial, _loadInterstitialAd);
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _retryCounts[_rewarded] = 0;
        },
        onAdFailedToLoad: (error) {
          printLog("❌ Rewarded Ad failed: $error");
          _retryLoadAd(_rewarded, _loadRewardedAd);
        },
      ),
    );
  }

  void showRewardedAd({VoidCallback? onRewardEarned}) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onRewardEarned?.call();
        },
      );
      _rewardedAd = null;
      _loadRewardedAd();
    }
  }

  void showRewardedAdWithPopup(BuildContext context,
      {VoidCallback? onRewardEarned, String? title, String? description}) {
    if (!isRewardedAdAvailable) {
      onRewardEarned?.call();
      return;
    }

    // TODO: Add your own title and description or change rewarded ad display logic
    showNativePopup(
      context,
      title: title ?? ViewConstants.watchAd,
      description: description ?? ViewConstants.watchAdDescription,
      secondaryActionTitle: ViewConstants.cancel,
      primaryActionTitle: ViewConstants.continueButton.tr(),
      secondaryAction: () => {},
      primaryAction: () => showRewardedAd(onRewardEarned: onRewardEarned),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
