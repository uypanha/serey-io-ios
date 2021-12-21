//
//  AppDelegate.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    var apnsHandler: APNSHandler?
    var appDelegateHelper: AppDelegateHelper?
    var discussionService: DiscussionService?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        prepareApplication()
        configureRootView()
        
        initAPNSHandler(withApplication: application)
        if !PreferenceStore.shared.userDisabledNotifs {
            turnOnPushNotification()
        }
        
        if Constants.shouldClearOutBadgeCountWhenFiredUp {
            application.applicationIconBadgeNumber = 0
        }
        
        appDelegateHelper = AppDelegateHelper()
        appDelegateHelper?.initMessageHandlers(window: window!, apnsHandler: apnsHandler!)
        self.discussionService = .init()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        apnsHandler?.applicationDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        apnsHandler?.applicationDidBecomeActive()
        self.discussionService?.refreshSereyCountries()
        CoinPriceManager.loadTicker()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - APNS
extension AppDelegate {
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        apnsHandler?.application(didReceiveRemoteNotification: userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        apnsHandler?.applicationDidFailToRegisterForRemoteNotifications(withError: error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        apnsHandler?.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
}

// MARK: - Preparations & Tools
extension AppDelegate {
    
    static var shared: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var rootViewController: RootViewController? {
        return window?.rootViewController as? RootViewController
    }
    
    func clearData() {
        Constants.clearStoreData()
    }
    
    func turnOnPushNotification() {
        apnsHandler?.registerAPNS()
    }
    
    func turnOffPushNotification() {
        apnsHandler?.unregisterAPNS()
    }
}

// MARK: - Configurations
fileprivate extension AppDelegate {
    
    func configureRootView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator?.start()
    }
    
    func prepareApplication() {
        initRealm()
        Appearance.configure()
        initSwiftyBeaver()
    }
    
    func initRealm() {
        // Start to configure realm
        Realm.configureRealm(schemaVersion: 1)
    }
    
    func initSwiftyBeaver() {
        #if DEBUG
        let console = ConsoleDestination()  // log to Xcode Console
        log.addDestination(console)
        log.info("SwiftyBeaver initialized")
        #endif
    }
    
    func initAPNSHandler(withApplication application: UIApplication) {
        apnsHandler = APNSHandler(with: application)
    }
}
