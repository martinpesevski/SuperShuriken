//
//  AdsManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 1/17/18.
//  Copyright © 2018 MP. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol adMobInterstitialDelegate {
    func didHideInterstitial()
}

protocol adMobRewardedVideoDelegate {
    func didEarnReward(_ reward: GADAdReward)
    func didDismiss()
}

class AdsManager: NSObject, Application, GADBannerViewDelegate, GADInterstitialDelegate, GADRewardedAdDelegate {
    var app: App { return App.shared }
    
    static let shared = AdsManager()
    
    var interstitialView: GADInterstitial!
    var rewardedVideo: GADRewardedAd!
    
    func createAndLoadRewardedVideo() {
        rewardedVideo = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
        rewardedVideo.load(GADRequest())
    }
    
    func createAndLoadInterstitial() {
        interstitialView = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitialView.delegate = self
        interstitialView.load(GADRequest())
    }
    
    var rewardedVideoDelegate: adMobRewardedVideoDelegate?
    var interstitialDelegate : adMobInterstitialDelegate?
    
    func showInterstitial() {
        guard app.global.adsEnabled,
            interstitialView.isReady,
            let topViewController = UIApplication.getTopViewController() else {
                interstitialDelegate?.didHideInterstitial()
                return
        }
        
        interstitialView.present(fromRootViewController: topViewController)
    }

    
    func showRewardedVideo() {
        guard let topViewController = UIApplication.getTopViewController() else { return }
        guard rewardedVideo.isReady else {
            let alert = UIAlertController(title: "Could not load video, please try again later", message: nil, preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okButton)
            topViewController.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let alert = UIAlertController(title: "Would you like to watch a video to receive this reward?", message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Watch", style: .default, handler: { [unowned self] action in
            self.rewardedVideo.present(fromRootViewController: topViewController, delegate: self)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        topViewController.present(alert, animated: true, completion: nil)
    }
    
    func removeAds() {
        app.global.adsEnabled = false
    }
    
    func showAds() {
        app.global.adsEnabled = true
    }
    
    private override init() {
        super.init()
        
        createAndLoadInterstitial()
        createAndLoadRewardedVideo()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        guard let topViewController = UIApplication.getTopViewController() else { return }
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        topViewController.view.addSubview(bannerView)
        positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
    }
    
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        guard let guide = UIApplication.getTopViewController()?.view.safeAreaLayoutGuide else { return }
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    // MARK: - banner delegate
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    // MARK: - interstitial delegate
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        
        createAndLoadInterstitial()
        interstitialDelegate?.didHideInterstitial()
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    // MARK: - rewarded ad delegate

    /// Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("rewardedAd:userDidEarnReward:");
        rewardedVideoDelegate?.didEarnReward(reward)
    }
    
    /// Tells the delegate that the rewarded ad was presented.
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        print("rewardedAdDidPresent")
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        print("rewardedAd")
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        print("rewardedAdDidDismiss")
        rewardedVideoDelegate?.didDismiss()
        createAndLoadRewardedVideo()
    }
}
