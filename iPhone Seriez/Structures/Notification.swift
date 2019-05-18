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
    //Notification Content
    let content = UNMutableNotificationContent()
    content.title = titre
    content.subtitle = soustitre
    content.body = message
    content.categoryIdentifier = "SCHED"
    content.sound = UNNotificationSound.default
    
    //Notification Trigger - when the notification should be fired
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    //Notification Request
    let request = UNNotificationRequest(identifier: "Serie \(Date().timeIntervalSince1970)", content: content, trigger: trigger)
    
    //Scheduling the Notification
    let center = UNUserNotificationCenter.current()
    center.add(request) { (error) in
        if let error = error {
            print(error.localizedDescription)
        }
    }
}

func loadIMDB() {
    imdb.downloadData()
    imdb.loadDataFile()
    
    var tmpSerie : Serie
    for uneSerie in db.shows {
        tmpSerie = imdb.getSerieGlobalInfos(idIMDB: uneSerie.idIMdb)
        uneSerie.ratersIMDB = tmpSerie.ratersIMDB
        uneSerie.ratingIMDB = tmpSerie.ratingIMDB
    }
}


func loadDates() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM yyyy"
    let today : Date = dateFormatter.date(from: dateFormatter.string(from: Date()))!
    
    for uneSerie in db.shows {
        if ( (uneSerie.watchlist == false) &&
            (uneSerie.unfollowed == false) &&
            (uneSerie.status != "Ended") ){
            let svgSerie : Serie = uneSerie
            db.downloadDates(serie : uneSerie)
            
            for uneSaison in uneSerie.saisons {
                if (uneSaison.starts == today) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) commence aujourd'hui") }
                if (uneSaison.ends == today) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) finit aujourd'hui") }
                
                if (uneSaison.saison <= svgSerie.saisons.count) {
                    if ( (uneSaison.starts != svgSerie.saisons[uneSaison.saison-1].starts) && (uneSaison.starts != ZeroDate) ) {
                        pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) commencera le \(dateFormatter.string(from: uneSaison.starts))")
                    }
                    if ( (uneSaison.ends != svgSerie.saisons[uneSaison.saison-1].ends) && (uneSaison.starts != ZeroDate) ) {
                        pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) finira le \(dateFormatter.string(from: uneSaison.ends))")
                    }
                }
            }
        }
    }
}


func loadStatuses() {
    db.quickRefresh()
    db.finaliseDB()
    db.shareWithWidget()
    db.saveDB()
}

