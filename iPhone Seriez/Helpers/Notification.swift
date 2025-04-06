//
//  Notification.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 10/03/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import UserNotifications

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
    for uneSerie in db.shows {
        if ( (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) && (uneSerie.status != "ended") && (uneSerie.status != "Ended") && (uneSerie.status != "canceled") ){
            let svgSerie : Serie = uneSerie.partialCopy()
            db.downloadDates(serie : uneSerie)
            let news : [String] = uneSerie.findUpdates(versus: svgSerie)
           
            for uneNews in news {
                journal.addInfo(serie: uneSerie.serie, source: srcTVMaze, methode: funcBackgroundFetch, texte: uneNews, type: newsDates)
                pushNotification(titre: uneSerie.serie, soustitre: "", message: uneNews)
            }
        }
    }
}


func checkComingUp() {
    for uneSerie in db.shows {
        if ( (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) && (uneSerie.status != "ended") && (uneSerie.status != "Ended") && (uneSerie.status != "canceled") ){
            
            for uneSaison in uneSerie.saisons {
                if (Calendar.current.isDateInToday(uneSaison.starts)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) commence aujourd'hui") }
                if (Calendar.current.isDateInToday(uneSaison.ends)) {
                    journal.addInfo(serie: uneSerie.serie, source: srcTVMaze, methode: funcBackgroundFetch, texte: "La saison \(uneSaison.saison) est entièrement diffusée", type: newsDiffusion)
                    pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) finit aujourd'hui")
                }
                
                if (Calendar.current.isDateInTomorrow(uneSaison.starts)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) commencera demain") }
                if (Calendar.current.isDateInTomorrow(uneSaison.ends)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) finira demain") }
            }
        }
    }
}
