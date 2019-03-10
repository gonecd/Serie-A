//
//  Notification.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 10/03/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import UserNotifications
import SeriesCommon

func pushNotification(titre :String, soustitre :String, message :String) {
    let now : Date = Date()
    
    //Notification Content
    let content = UNMutableNotificationContent()
    content.title = titre
    content.subtitle = soustitre
    content.body = message
    content.categoryIdentifier = "SCHED"
    content.sound = UNNotificationSound.default
    
    //Notification Trigger - when the notification should be fired
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    //Notification Request
    let request = UNNotificationRequest(identifier: "Serie \(now)", content: content, trigger: trigger)
    
    //Scheduling the Notification
    let center = UNUserNotificationCenter.current()
    center.add(request) { (error) in
        if let error = error {
            print(error.localizedDescription)
        }
    }
}

func loadIMDB() -> Int {
    
    let start : Date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "HH:mm:ss"
    
    let avant : Int = imdb.IMDBrates.count
    imdb.downloadData()
    imdb.loadDataFile()
    
    var tmpSerie : Serie
    for uneSerie in db.shows {
        tmpSerie = imdb.getSerieGlobalInfos(idIMDB: uneSerie.idIMdb)
        uneSerie.ratersIMDB = tmpSerie.ratersIMDB
        uneSerie.ratingIMDB = tmpSerie.ratingIMDB
    }
    db.saveDB()
    
    pushNotification(titre: "IMDB notes", soustitre: "\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: Date()))", message: "Notes IMDB récupérées")
    
    return 0
}


func loadDates() -> Int {
    let start : Date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "HH:mm:ss"
    
    for uneSerie in db.shows {
        if ( (uneSerie.watchlist == false) &&
            (uneSerie.unfollowed == false) &&
            (uneSerie.status != "Ended") ){
            db.downloadDates(serie : uneSerie)
        }
    }
    db.saveDB()

    pushNotification(titre: "TVmaze dates", soustitre: "\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: Date()))", message: "Dates mises à jour")
    
    return 0
}


func loadStatuses() -> Int {
    let start : Date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "HH:mm:ss"
    
    db.quickRefresh()
    db.finaliseDB()
    db.shareWithWidget()
    db.saveDB()

    pushNotification(titre: "Trakt statuses", soustitre: "\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: Date()))", message: "Status de visionnage mis à jour")
    
    return 0
    
}

