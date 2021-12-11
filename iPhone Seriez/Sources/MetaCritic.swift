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

class MetaCritic {
    var chrono : TimeInterval = 0
    let dateFormMetaCritic = DateFormatter()

    init() {
        dateFormMetaCritic.dateFormat = "MMM dd, yyyy"
    }
    
    
    func getSerieGlobalInfos(serie : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: serie)
        let webPage : String = getPath(serie: serie).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if (webPage == "") {
            return uneSerie
        }
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            let extract : String = try doc.select("[class='metascore_w header_size tvshow positive']").text()
            
            uneSerie.ratingMetaCritic = Int(extract) ?? 0
        }
        catch let error as NSError { print("MetaCritic failed: \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return uneSerie
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono : Date = Date()
        let webPage : String = getPath(serie: uneSerie.serie).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
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
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
    }
    
    
    func getTrendingShows() -> (names : [String], ids : [String]) {
        return getShowList(url: "https://www.metacritic.com/browse/tv/score/metascore/90day/filtered?sort=desc&view=condensed")
    }
    
    
    func getPopularShows() -> (names : [String], ids : [String]) {
        return getShowList(url: "https://www.metacritic.com/browse/tv/score/metascore/all/filtered?view=condensed&sort=desc")
    }
    

    func getShowList(url : String) -> (names : [String], ids : [String]) {
        let startChrono : Date = Date()
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0

        do {
            let page : String = try String(contentsOf: URL(string : url)!)
            let doc : Document = try SwiftSoup.parse(page)

            let showList = try doc.select("[class='collapsed']")
            
            for oneShow in showList {
                let showName : String = try oneShow.select("img").attr("alt")
                
                if (showName.contains(": Season")) {
                    let serie : String = showName.components(separatedBy: ": Season")[0]
                    
                    if ((!showNames.contains(serie)) && (compteur < popularShowsPerSource)){
                        showNames.append(serie)
                        showIds.append("")
                        compteur = compteur + 1
                    }                   
                }
            }
        }
        catch let error as NSError { print("MetaCritic failed for getShowList : \(error.localizedDescription)") }
        
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return (showNames, showIds)
    }
    
    
    func getPath(serie : String) -> String {
        switch serie {
            
        case "12 Monkeys":                              return "https://www.metacritic.com/tv/12-monkeys-2015"
        case "Marco Polo":                              return "https://www.metacritic.com/tv/marco-polo-2014"
        case "Outlander":                               return "https://www.metacritic.com/tv/outlander-2014"
        case "Maniac":                                  return "https://www.metacritic.com/tv/maniac-2018"
        case "Catch-22":                                return "https://www.metacritic.com/tv/catch-22-2019"
        case "What We Do in the Shadows":               return "https://www.metacritic.com/tv/what-we-do-in-the-shadows-2019"
        case "War of the Worlds":                       return "https://www.metacritic.com/tv/war-of-the-worlds-2020"
        case "The Outsider":                            return "https://www.metacritic.com/tv/the-outsider-2020"

        case "Absolutely Fabulous":                     return "https://www.metacritic.com/tv/absolutely-fabulous-uk"
        case "The IT Crowd":                            return "https://www.metacritic.com/tv/the-it-crowd-uk"
        case "Shameless":                               return "https://www.metacritic.com/tv/shameless-us"

        case "Dirk Gently's Holistic Detective Agency": return "https://www.metacritic.com/tv/dirk-gentlys-holistic-detective-agency"
        case "Mr. Robot":                               return "https://www.metacritic.com/tv/mr-robot"
        case "The End of the F***ing World":            return "https://www.metacritic.com/tv/the-end-of-the-fing-world"
        case "The Handmaid's Tale":                     return "https://www.metacritic.com/tv/the-handmaids-tale"
        case "The Haunting":                            return "https://www.metacritic.com/tv/the-haunting-of-hill-house"
        case "The Marvelous Mrs. Maisel":               return "https://www.metacritic.com/tv/the-marvelous-mrs-maisel"
        case "Rick and Morty":                          return "https://www.metacritic.com/tv/rick-morty"
        case "Locke & Key":                             return "https://www.metacritic.com/tv/locke-key"
        case "The Queen's Gambit":                      return "https://www.metacritic.com/tv/the-queens-gambit"
        case "Love, Death & Robots":                    return "https://www.metacritic.com/tv/love-death-robots"

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
             "Marianne",
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
             "Caliphate",
             "The Crimson Rivers",
             "One-Punch Man",
             "How to Sell Drugs Online (Fast)",
             
             "En thérapie",
             "OVNI(s)",
             "Sky Rojo",
             "Curon",
             "Kuroko's Basketball",
             "Hunter x Hunter",
             "The Seven Deadly Sins":
            return ""
            
        default:
            return "https://www.metacritic.com/tv/\(serie.lowercased().replacingOccurrences(of: "%", with: "-").replacingOccurrences(of: "'", with: "-").replacingOccurrences(of: " ", with: "-"))"
        }
    }
    
    
    func getCritics(serie: String, saison: Int) -> [Critique] {
        let startChrono : Date = Date()
        var result : [Critique] = []
        var webPage : String = getPath(serie: serie)
        
        if (webPage == "") { return result }
        webPage = webPage + "/critic-reviews?sort-by=date&num_items=200"
        webPage = webPage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            
            let critics = try doc.select("div [class='review pad_top1 pad_btm1']")
            
            for oneCritic in critics {
                let uneCritique : Critique = Critique()
                
                uneCritique.source = srcMetaCritic
                uneCritique.note = try oneCritic.select("div [class='left fl']").text()
                uneCritique.journal = try oneCritic.select("div [class='title pad_btm_half']").select("img").attr("title")
                uneCritique.logo = try oneCritic.select("div [class='title pad_btm_half']").select("img").attr("src")
                uneCritique.auteur = try oneCritic.select("div [class='title pad_btm_half']").select("[class='author']").text()
                uneCritique.saison = Int(try oneCritic.select("[class='season-des']").text().replacingOccurrences(of: "Season ", with: "").replacingOccurrences(of: " Review:", with: "")) ?? 0

                let dateString : String = try oneCritic.select("div [class='title pad_btm_half']").select("[class='date']").text()
                let dateTmp : Date = dateFormMetaCritic.date(from: dateString) ?? ZeroDate
                uneCritique.date = dateFormLong.string(from: dateTmp)

                if (try oneCritic.select("div [class='summary']").select("a").count > 0) {
                    uneCritique.texte = try oneCritic.select("div [class='summary']").select("a")[0].text().replacingOccurrences(of: "Season " + String(uneCritique.saison) + " Review: ", with: "")
                    uneCritique.lien = try oneCritic.select("div [class='summary']").select("a")[0].attr("href")
                }
                else {
                    uneCritique.texte = try oneCritic.select("div [class='summary']").text().replacingOccurrences(of: "Season " + String(uneCritique.saison) + " Review: ", with: "")
                }

                if (uneCritique.saison == saison) {
                    result.append(uneCritique)
                }
            }
        }
        catch let error as NSError { print("MetaCritic getCritics failed for \(serie): \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
}
