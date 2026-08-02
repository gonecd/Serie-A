//
//  AppDelegate.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import UserNotifications
import BackgroundTasks


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

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
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "Home.SerieA.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        self.scheduleAppRefresh()

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
        
        trakt.start()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        let source = components?.host
        let params = components?.queryItems

        print("<<<<< Dans le AppDelegate >>>>")
        print("Redirect URI from: \(String(describing: source))")
        print("Full URL: \(url.absoluteString)")
        print("Query params: \(String(describing: params))")

        switch source {
        case "Trakt":
            if let code = params?.first(where: { $0.name == "code" })?.value {
                print("Authorization code received: \(code)")
                trakt.downloadToken(key: code)
                return true
            } else {
                print("Error: No authorization code found in URL")
                return false
            }
        case "ASuivre1":
            let navigationController = window!.rootViewController! as! UINavigationController
            navigationController.viewControllers.first?.performSegue(withIdentifier: "Go1", sender: nil)
            return true

        case "ASuivre2":
            let navigationController = window!.rootViewController! as! UINavigationController
            navigationController.viewControllers.first?.performSegue(withIdentifier: "Go2", sender: nil)
            return true

        case "ASuivre3":
            let navigationController = window!.rootViewController! as! UINavigationController
            navigationController.viewControllers.first?.performSegue(withIdentifier: "Go3", sender: nil)
            return true

        default:
            print("Unknown URL scheme host: \(String(describing: source))")
            return false
        }
    }
    
    private func scheduleAppRefresh() {
        let identifier = "Home.SerieA.refresh"
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 7200) // 2 hours
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh planifié avec succès pour '\(identifier)'")
        } catch let error as NSError {
            print("Impossible de planifier le refresh for \(identifier). Error code : \(error.code)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh() // Schedule next refresh
        task.expirationHandler = {
            // Handle expiration if needed
        }
        DispatchQueue.global().async {
            var fileUpdates: DataUpdates = db.loadDataUpdates()
            // Dates from TV Maze (once per day)
            if !Calendar.current.isDateInToday(fileUpdates.TVMaze_Dates) {
                loadDates()
                fileUpdates.TVMaze_Dates = Date()
                checkComingUp()
                db.saveDataUpdates(dataUpdates: fileUpdates)
            }
            // Ratings from IMDB (once per day)
            if !Calendar.current.isDateInToday(fileUpdates.IMDB_Rates) {
                loadIMDB()
                fileUpdates.IMDB_Rates = Date()
                db.saveDataUpdates(dataUpdates: fileUpdates)
            }
            // Visualisation from Trakt
            db.quickRefresh()
            db.finaliseDB()
            fileUpdates.Trakt_Viewed = Date()
            db.saveDataUpdates(dataUpdates: fileUpdates)
            db.saveDB()
            task.setTaskCompleted(success: true)
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
        // Ca permet d'afficher l'alerte meme si l'application est en train de tourner (ou de la gérer depuis l'appli le cas échéant)
    }
}

