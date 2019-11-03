//
//  AppDelegate.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import UserNotifications
import SeriesCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Intervalle de réveil pour les jobs schédulés
        UIApplication.shared.setMinimumBackgroundFetchInterval(7200)
        
        
        // Demande d'uthorization de notifier
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            //granted = yes, if app is authorized for all of the requested interaction types
            //granted = no, if one or more interaction type is disallowed
        }
        
        // Notification categories registration
        let scheduledCategory = UNNotificationCategory(identifier: "SCHED", actions: [], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        let startCategory = UNNotificationCategory(identifier: "START", actions: [], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        let stopCategory = UNNotificationCategory(identifier: "STOP", actions: [], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        center.setNotificationCategories([scheduledCategory, startCategory, stopCategory])

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        var start : Date = Date()
        let defaults = UserDefaults.standard
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM HH:mm"

        var info : InfosRefresh = InfosRefresh(timestamp: dateFormatter.string(from: start),
                                               network: getNetWork(),
                                               wifi: "Undef",
                                               refreshDates: "No",
                                               refreshIMDB: "No",
                                               refreshViewed: "No")
        db.shareRefreshWithWidget(newInfo: info)
        
        // Dates TV Maze (une fois par jour)
        if (Calendar.current.isDateInToday(reloadDates) == false) {
            loadDates()
            let end : Date = Date()

            defaults.set(dateFormatter.string(from: start), forKey: "RefreshDates")
            //pushNotification(titre: "Dates des saisons rafraîchies", soustitre: "", message: "\(dateFormatter.string(from: start))")
            info.refreshDates = String(format : "%.2f s", end.timeIntervalSince(start))
            db.shareRefreshWithWidget(newInfo: info)
            
            reloadDates = start
            start = end
        }
        
        // Ratings IMDB (une fois par jpur)
        if ( (Calendar.current.isDateInToday(reloadIMDB) == false) && (info.network == "WiFi") ) {
            loadIMDB()
            let end : Date = Date()

            defaults.set(dateFormatter.string(from: start), forKey: "RefreshIMDB")
            //pushNotification(titre: "Notes IMDB mises à jour", soustitre: "", message: "\(dateFormatter.string(from: start))")
            info.refreshIMDB = String(format : "%.2f s", end.timeIntervalSince(start))
            db.shareRefreshWithWidget(newInfo: info)

            reloadIMDB = start
            start = end
        }
        
        // Statuses Trakt
        loadStatuses()
        let end : Date = Date()
        info.refreshViewed = String(format : "%.2f s", end.timeIntervalSince(start))
        db.shareRefreshWithWidget(newInfo: info)

        completionHandler(.newData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        // Ca permet d'afficher l'alerte meme si l'application est en train de tourner (ou de la gérer depuis l'appli le cas échéant)
    }
}
