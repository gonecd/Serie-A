//
//  MetaCritic.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 01/06/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


import Foundation
import SwiftSoup
import SeriesCommon

class MetaCritic {
    var chronoGlobal : TimeInterval = 0
    var chronoRatings : TimeInterval = 0

    init() {
    }
    
    func getChrono() -> TimeInterval {
        return chronoGlobal+chronoRatings
    }

    func getSerieGlobalInfos(serie : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: serie)
        let webPage : String = getPath(serie: serie)
        
        if (webPage == "") {
            return uneSerie
        }
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            let extract : String = try doc.select("div [class='product_header']").text()
            let rating : String = extract.components(separatedBy: " ")[2]
            
            uneSerie.ratingMetaCritic = Int(rating) ?? 0
        }
        catch let error as NSError { print("MetaCritic failed: \(error.localizedDescription)") }
        
        chronoGlobal = chronoGlobal + Date().timeIntervalSince(startChrono)
        return uneSerie
    }

    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono : Date = Date()
        let webPage : String = getPath(serie: uneSerie.serie)
        if (webPage == "") { return }
        
        for uneSaison in uneSerie.saisons {
            do {
                let page : String = try String(contentsOf: URL(string : webPage+"/season-"+String(uneSaison.saison))!)
                let doc : Document = try SwiftSoup.parse(page)
                let allNotes = try doc.select("li [class^='ep_guide_item']")
                
                for oneNote in allNotes {
                    let rate : String = try oneNote.select("div").text()
                    let note = Int(10.0 * (Double(rate) ?? 0.0))
                    //let note = Int(10.0 * (Double(rate.components(separatedBy: CharacterSet.decimalDigits.inverted).first!) ?? 0.0))
                    let episodeString : String = try oneNote.select("a").text()
                    var episode : Int = 0
                    if (episodeString.components(separatedBy: ":E").count > 1) {
                        episode = Int(String(episodeString.components(separatedBy: ":E")[1].components(separatedBy: CharacterSet.decimalDigits.inverted).first!)) ?? 0
                    }
                    
                    if ( (episode < uneSaison.episodes.count+1) && (note != 0) && (episode != 0)) {
                        uneSaison.episodes[episode-1].ratingMetaCritic = note
                    }
                }
            }
            catch let error as NSError { print("MetaCritic failed for \(uneSerie.serie) saison \(uneSaison.saison) : \(error.localizedDescription)") }
        }

        chronoRatings = chronoRatings + Date().timeIntervalSince(startChrono)
    }

        
    func getPath(serie : String) -> String {
        switch serie {
            
        case "12 Monkeys":
            return "https://www.metacritic.com/tv/12-monkeys-2015"
            
        case "Absolutely Fabulous":
            return "https://www.metacritic.com/tv/absolutely-fabulous-uk"
            
        case "Dirk Gently's Holistic Detective Agency":
            return "https://www.metacritic.com/tv/dirk-gentlys-holistic-detective-agency"
            
        case "Maniac":
            return "https://www.metacritic.com/tv/maniac-2018"
            
        case "Marco Polo":
            return "https://www.metacritic.com/tv/marco-polo-2014"
            
        case "Mr. Robot":
            return "https://www.metacritic.com/tv/mr-robot"
            
        case "Outlander":
            return "https://www.metacritic.com/tv/outlander-2014"
            
        case "Shameless":
            return "https://www.metacritic.com/tv/shameless-us"
            
        case "The End of the F***ing World":
            return "https://www.metacritic.com/tv/the-end-of-the-fing-world"
            
        case "The Handmaid's Tale":
            return "https://www.metacritic.com/tv/the-handmaids-tale"
            
        case "The Haunting":
            return "https://www.metacritic.com/tv/the-haunting-of-hill-house"
            
        case "The Marvelous Mrs. Maisel":
            return "https://www.metacritic.com/tv/the-marvelous-mrs-maisel"
            
        case "What We Do in the Shadows":
            return "https://www.metacritic.com/tv/what-we-do-in-the-shadows-2019"
            
        case "Catch-22":
            return "https://www.metacritic.com/tv/catch-22-2019"
            
        case "Hero Corp",
             "Call My Agent",
             "Call My Agent!",
             "3%",
             "A Very Secret Service",
             "Baron Noir",
             "Republican Gangsters",
             "Borgia",
             "Braquo",
             "Bref.",
             "Fawlty Towers",
             "Glue",
             "Guyane",
             "Hard",
             "Kaamelott",
             "Kaboul Kitchen",
             "Mafiosa",
             "Maison close",
             "Money Heist",
             "Monty Python's Flying Circus",
             "Real Humans",
             "Spiral",
             "The Bureau",
             "Utopia",
             "Wentworth",
             "WorkinGirls",
             "Savages",
             "The Collapse",
             "Vernon Subutex",
             "How to Sell Drugs Online (Fast)":
            return ""
            
        default:
            return "https://www.metacritic.com/tv/\(serie.lowercased().replacingOccurrences(of: "%", with: "-").replacingOccurrences(of: "'", with: "-").replacingOccurrences(of: " ", with: "-"))"
        }
    }
}
