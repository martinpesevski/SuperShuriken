
//
//  AppDelegate.swift
//  ClassicPong
//
//  Created by Martin Peshevski on 9/26/17.
//  Copyright © 2017 MP. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Initialize the Google Mobile Ads SDK.
        // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3254751950638386~5582425980")
        _ = MonsterManager.shared
        _ = AdsManager.shared
        GameCenterManager.shared.authenticate(viewController: UIApplication.getTopViewController()) { completed in
            if !completed { GameCenterManager.shared.showAuthenticationDialog() }
        }
        StoreManager.shared.fetchAvailableProducts()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Global.sharedInstance.isFirstRun = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        Global.sharedInstance.isFirstRun = false
    }
}

extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
