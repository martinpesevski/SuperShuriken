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

class AdsManager: NSObject, GADBannerViewDelegate, GADInterstitialDelegate{
    static let sharedInstance = AdsManager()

    var rootViewController : UIViewController!
    var bannerView : GADBannerView!
    var interstitialView : GADInterstitial!
    var interstitialDelegate : adMobInterstitialDelegate?
    
    func showBanner() {
        if !Global.sharedInstance.adsEnabled {
            return
        }
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = rootViewController
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        addBannerViewToView(bannerView)
    }
    
    func createAndLoadInterstitial() {
        interstitialView = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitialView.delegate = self
        interstitialView.load(GADRequest())
    }
    
    func showInterstitial() {
        if !Global.sharedInstance.adsEnabled {
            interstitialDelegate?.didHideInterstitial()
            return
        }
        
        if (interstitialView!.isReady) {
            interstitialView!.present(fromRootViewController: rootViewController)
        } else {
            interstitialDelegate?.didHideInterstitial()
        }
    }
    
    func removeAds() {
        Global.sharedInstance.adsEnabled = false
        bannerView.removeFromSuperview()
        bannerView = nil
    }
    
    func showAds() {
        Global.sharedInstance.adsEnabled = true
        self.showBanner()
    }
    
    private override init() {
        super.init()
        
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        rootViewController = appDelegate.window!.rootViewController as UIViewController!
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        rootViewController.view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = rootViewController.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        rootViewController.view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: rootViewController.view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        rootViewController.view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: rootViewController.view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        rootViewController.view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: rootViewController.bottomLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
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
}
