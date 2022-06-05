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
    let today : Date = Date()
    
    for uneSerie in db.shows {
        if ( (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) && (uneSerie.status != "Ended") ){
            var svgSerie : Serie = Serie(serie: "")
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: uneSerie, requiringSecureCoding: false)
                svgSerie = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Serie)!
            } catch {
                print("La copie physique de la serie a échoué")
            }
            
            db.downloadDates(serie : uneSerie)
            
            for uneSaison in uneSerie.saisons {
                if (uneSaison.starts == uneSaison.ends) {
                    if (Calendar.current.isDateInToday(uneSaison.starts)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) est diffusée aujourd'hui") }
                    if (Calendar.current.isDateInTomorrow(uneSaison.starts)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) sera diffusée demain") }
                    
                    // La saison n'existait pas
                    if (uneSaison.saison > svgSerie.saisons.count) {
                        if (uneSaison.starts.compare(today) == .orderedDescending) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) sera diffusée le \(dateFormLong.string(from: uneSaison.starts))") }
                    }
                    else {
                        // La saison existait et les dates ont changé
                        if (uneSaison.starts != svgSerie.saisons[uneSaison.saison-1].starts) {
                            if (uneSaison.starts.compare(today) == .orderedDescending) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) sera diffusée le \(dateFormLong.string(from: uneSaison.starts))") }
                        }
                        if (uneSaison.ends != svgSerie.saisons[uneSaison.saison-1].ends) {
                            if (uneSaison.ends.compare(today) == .orderedDescending) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) sera diffusée le \(dateFormLong.string(from: uneSaison.ends))") }
                        }
                    }
                }
                else {
                    if (Calendar.current.isDateInToday(uneSaison.starts)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) commence aujourd'hui") }
                    if (Calendar.current.isDateInToday(uneSaison.ends)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) finit aujourd'hui") }
                    
                    if (Calendar.current.isDateInTomorrow(uneSaison.starts)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) commencera demain") }
                    if (Calendar.current.isDateInTomorrow(uneSaison.ends)) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) finira demain") }
                    
                    // La saison n'existait pas
                    if (uneSaison.saison > svgSerie.saisons.count) {
                        if (uneSaison.starts.compare(today) == .orderedDescending) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) commencera le \(dateFormLong.string(from: uneSaison.starts))") }
                        if (uneSaison.ends.compare(today) == .orderedDescending) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) finira le \(dateFormLong.string(from: uneSaison.ends))") }
                    }
                    else {
                        // La saison existait et les dates ont changé
                        if (uneSaison.starts != svgSerie.saisons[uneSaison.saison-1].starts) {
                            if (uneSaison.starts.compare(today) == .orderedDescending) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) commencera le \(dateFormLong.string(from: uneSaison.starts))") }
                        }
                        if (uneSaison.ends != svgSerie.saisons[uneSaison.saison-1].ends) {
                            if (uneSaison.ends.compare(today) == .orderedDescending) { pushNotification(titre: uneSerie.serie, soustitre: "", message: "La saison \(uneSaison.saison) finira le \(dateFormLong.string(from: uneSaison.ends))") }
                        }
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

