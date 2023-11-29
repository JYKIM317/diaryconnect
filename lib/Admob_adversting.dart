class InterstitialAdId {
  //Admob interstitial ad id
  String android = 'ca-app-pub-3581534207395265/9285977438';
  String ios = 'ca-app-pub-3581534207395265/8915276491';
}

/* 
InterstitialAd? _interstitialAd;

void interstitialAd() {
  InterstitialAd.load(
    adUnitId: Platform.isAndroid
        ? InterstitialAdId().android
        : InterstitialAdId().ios,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        debugPrint('$ad loaded');
        _interstitialAd = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        debugPrint('$error');
      },
    ),
  );
}

@override
initState (){
  interstitialAd();
  super.initState();
}

@override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  usage -
  if (_interstitialAd != null) _interstitialAd?.show();
*/