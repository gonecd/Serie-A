//
//  RottenTomatoes.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup
import SeriesCommon

class RottenTomatoes {
    var chronoGlobal : TimeInterval = 0
    var chronoRatings : TimeInterval = 0
    var chronoOther : TimeInterval = 0

    init() {
    }
    
    func getChrono() -> TimeInterval {
        return chronoGlobal+chronoRatings
    }
    
    func getSerieGlobalInfos(serie : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: serie)
        let webPage : String = getPath(serie: serie)
        
        if (webPage == "") { return uneSerie }
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            
            let audience : String = try doc.select("div [class='mop-ratings-wrap__half audience-score']").text()
            uneSerie.ratingRottenTomatoes = Int(audience.components(separatedBy: CharacterSet.decimalDigits.inverted).first!) ?? 0
        }
        catch let error as NSError { print("RottenTomatoes failed: \(error.localizedDescription)") }
        
        chronoGlobal = chronoGlobal + Date().timeIntervalSince(startChrono)
        return uneSerie
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono : Date = Date()
        let webPage : String = getPath(serie: uneSerie.serie)
        if (webPage == "") { return }
        
        for uneSaison in uneSerie.saisons {
            do {
                let page : String = try String(contentsOf: URL(string : webPage+"/s0"+String(uneSaison.saison))!)
                let doc : Document = try SwiftSoup.parse(page)
                let allNotes = try doc.select("div [class='media episodeItem']")
                
                for oneNote in allNotes {
                    let episode : Int = Int(try oneNote.select("div [class='pull-left episodeItem-num']").text()) ?? 0
                    let rate : String = try oneNote.select("div [class='pull-left tomatometer']").text()
                    let note = Int(rate.components(separatedBy: CharacterSet.decimalDigits.inverted).first!) ?? 0
                    
                    if ( (episode < uneSaison.episodes.count+1) && (note != 0) ) {
                        uneSaison.episodes[episode-1].ratingRottenTomatoes = note
                    }
                }
            }
            catch let error as NSError { print("RottenTomatoes failed for \(uneSerie.serie) saison \(uneSaison.saison): \(error.localizedDescription)") }
        }

        chronoRatings = chronoRatings + Date().timeIntervalSince(startChrono)
    }
    
    
    func getEpisodeDetails(_ uneSerie: Serie, saison: Int, episode: Int) -> Int {
        let startChrono : Date = Date()
        let webPage : String = getPath(serie: uneSerie.serie)
        if (webPage == "") { return 0 }
        
        let labelEps = String(format: "/s%02d/e%02d", saison, episode)
        var note : String = ""
        var critic : String = ""
        
        do {
            print("URL = \(webPage+labelEps)")
            let page : String = try String(contentsOf: URL(string : webPage+labelEps)!)
            let doc : Document = try SwiftSoup.parse(page)
            //note = try doc.select("div [id='scoreStats'] div").first()?.text() ?? ""
            note = try (doc.select("div [id='scoreStats'] div").first()?.text().components(separatedBy: " ")[2].components(separatedBy: "/")[0])!
            critic = try doc.select("div [class='col-sm-12 tomato-info hidden-xs pad-left']").text()
        }
        catch let error as NSError { print("RottenTomatoes failed: \(error.localizedDescription)") }
        
        print("Note = \(note)")
        print("Avis = \(critic)")
        
        
        chronoOther = chronoOther + Date().timeIntervalSince(startChrono)
        return 0
    }
    
    
    func getPath(serie : String) -> String {
        switch serie {
        case "The End of the F***ing World":
            return "https://www.rottentomatoes.com/tv/the_end_of_the_f_ing_world"
            
        case "Money Heist":
            return "https://www.rottentomatoes.com/tv/la_casa_de_papel"
            
        case "Mr. Robot":
            return "https://www.rottentomatoes.com/tv/mr_robot"
            
        case "The Marvelous Mrs. Maisel":
            return "https://www.rottentomatoes.com/tv/the_marvelous_mrs_maisel"
            
        case "Bref.":
            return "https://www.rottentomatoes.com/tv/bref"
            
        case "The Haunting":
            return "https://www.rottentomatoes.com/tv/the_haunting_of_hill_house"
            
        case "Brooklyn Nine-Nine":
            return "https://www.rottentomatoes.com/tv/brooklyn_nine_nine"
            
        case "How to Sell Drugs Online (Fast)":
            return "https://www.rottentomatoes.com/tv/how_to_sell_drugs_online_fast"
            
        case "Catch-22":
            return "https://www.rottentomatoes.com/tv/catch_22"
            
        case "Hero Corp",
             "Call My Agent",
             "Call My Agent!",
             "Baron Noir",
             "Republican Gangsters",
             "WorkinGirls",
             "Guyane",
             "Kaboul Kitchen",
             "Hard",
             "Glue",
             "Kaamelott",
             "Mafiosa",
             "Real Humans",
             "Braquo",
             "XIII",
             "Vernon Subutex",
             "The Collapse",
             "Maison close":
            return ""
            
        default:
            return "https://www.rottentomatoes.com/tv/\(serie.lowercased().replacingOccurrences(of: "%", with: "_").replacingOccurrences(of: "'", with: "_").replacingOccurrences(of: " ", with: "_"))"
        }
    }
}
