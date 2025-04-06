//
//  AppDelegate.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import UserNotifications



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
        var dataUpdates : DataUpdatesEntry = db.loadDataUpdates()
        
        // Dates TV Maze (une fois par jour)
        if (Calendar.current.isDateInToday(dataUpdates.TVMaze_Dates) == false) {
            loadDates()
            dataUpdates.TVMaze_Dates = Date()
            checkComingUp()
            db.saveDataUpdates(dataUpdates: dataUpdates)
        }

        // Ratings IMDB (une fois par jpur)
        if ( Calendar.current.isDateInToday(dataUpdates.IMDB_Episodes) == false ) {
            loadIMDB()
            dataUpdates.IMDB_Rates = Date()
            db.saveDataUpdates(dataUpdates: dataUpdates)
        }

        // Statuses Trakt
        db.quickRefresh()
        db.finaliseDB()
        dataUpdates.Trakt_Viewed = Date()
        db.saveDataUpdates(dataUpdates: dataUpdates)

        db.saveDB()
        completionHandler(.newData)
    }
    
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        let source = components!.host
        let params = components!.queryItems

        switch source {
        case "Trakt":
            trakt.downloadToken(key: params?.first?.value ?? "")
            break
            
        case "ASuivre1":
            let navigationController = window!.rootViewController! as! UINavigationController
            navigationController.viewControllers.first?.performSegue(withIdentifier: "Go1", sender: nil)
            break
            
        case "ASuivre2":
            let navigationController = window!.rootViewController! as! UINavigationController
            navigationController.viewControllers.first?.performSegue(withIdentifier: "Go2", sender: nil)
            break
        
        case "ASuivre3":
            let navigationController = window!.rootViewController! as! UINavigationController
            navigationController.viewControllers.first?.performSegue(withIdentifier: "Go3", sender: nil)
            break
            
        default:
            break
        }
        
        return true
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
        // Ca permet d'afficher l'alerte meme si l'application est en train de tourner (ou de la gérer depuis l'appli le cas échéant)
    }
}
