//
//  RottenTomatoes.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup

class RottenTomatoes {
    var chrono : TimeInterval = 0
    let dateFormRottenTomatoes = DateFormatter()
    
    init() {
        dateFormRottenTomatoes.dateFormat = "MMM dd, yyyy"
    }
    
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()
        
        var request : URLRequest = URLRequest(url: URL(string: reqAPI)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("RottenTomatoes::error \(response.statusCode) received for req=\(reqAPI)"); ended = true; return }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("RottenTomatoes::failed \(error.localizedDescription) for req=\(reqAPI) - error \(response.statusCode)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    
    func getSerieGlobalInfos(serie : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: serie)
        let webPage : String = getPath(serie: serie).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if (webPage == "") { return uneSerie }
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            
            let audience : String = try doc.select("media-scorecard").select("[slot='audienceScore']").text()
            uneSerie.ratingRottenTomatoes = Int(audience.components(separatedBy: CharacterSet.decimalDigits.inverted).first!) ?? 0
        }
        catch let error as NSError { print("RottenTomatoes failed for \(serie) : \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        
        return uneSerie
    }
    
    
    func getSerieGlobalInfosAPI_old(serie : String) -> Serie {
        let uneSerie : Serie = Serie(serie: serie)
        let reqURL : String = "https://www.rottentomatoes.com/api/private/v2.0/search?q=\(serie.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")"
        
        let reqResult : NSDictionary = loadAPI(reqAPI: reqURL) as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return uneSerie }
        
        for oneShow in (reqResult.object(forKey: "tvSeries") as! NSArray) {
            if (serie == (((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? "")) {
                uneSerie.ratingRottenTomatoes = ((oneShow as! NSDictionary).object(forKey: "meterScore")) as? Int ?? 0
                
                return uneSerie
            }
        }
        return uneSerie
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono : Date = Date()
        let webPage : String = getPath(serie: uneSerie.serie).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        if (webPage == "") { return }
        
        for uneSaison in uneSerie.saisons {
            do {
                let page : String = try String(contentsOf: URL(string : webPage+"/s0"+String(uneSaison.saison))!, encoding: .utf8)
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
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
    }
    
    
    func getEpisodeDetails(_ uneSerie: Serie, saison: Int, episode: Int) -> Int {
        let startChrono : Date = Date()
        let webPage : String = getPath(serie: uneSerie.serie).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if (webPage == "") { return 0 }
        
        let labelEps = String(format: "/s%02d/e%02d", saison, episode)
        var note : Int = 0
        var texte : String = ""
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage+labelEps)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            texte = try doc.select("media-scorecard [slot='criticsScore']").text()
        }
        catch let error as NSError { print("RottenTomatoes failed: \(error.localizedDescription)") }
        
        note = Int(texte.replacingOccurrences(of: "%", with: "")) ?? 0
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        
        return note
    }
    
    
    func getPath(serie : String) -> String {
        switch serie {
            
        case "The End of the F***ing World":        return "https://www.rottentomatoes.com/tv/the_end_of_the_f_ing_world"
        case "How to Sell Drugs Online (Fast)":     return "https://www.rottentomatoes.com/tv/how_to_sell_drugs_online_fast"
        case "Locke & Key":                         return "https://www.rottentomatoes.com/tv/locke_and_key"
        case "Call My Agent", "Call My Agent!":     return "https://www.rottentomatoes.com/tv/call_my_agent_"
        case "Nothing":                             return "https://www.rottentomatoes.com/tv/nada"
        case "Star Wars: Andor":                    return "https://www.rottentomatoes.com/tv/andor"
        case "Borgen - Power & Glory":              return "https://www.rottentomatoes.com/tv/borgen_power_and_glory"
        case "Love, Death & Robots":                return "https://www.rottentomatoes.com/tv/love_death_robots"
            
        case "The Boys":                            return "https://www.rottentomatoes.com/tv/the_boys_2019"
        case "Vikings":                             return "https://www.rottentomatoes.com/tv/vikings_2013"
        case "The IT Crowd":                        return "https://www.rottentomatoes.com/tv/the_it_crowd_2006"
        case "Shōgun":                              return "https://www.rottentomatoes.com/tv/shogun_2024"
        case "The Bridge":                          return "https://www.rottentomatoes.com/tv/the_bridge_2011"
        case "Vigil":                               return "https://www.rottentomatoes.com/tv/vigil_2021"
            
        case "Hero Corp",
            "All the Way Up",
            "Baron Noir",
            "Braquo",
            "Bref.",
            "Cheeky Business",
            "En thérapie",
            "Glue",
            "Guyane",
            "Hard",
            "HPI",
            "Infiniti",
            "Jordskott",
            "Kaamelott",
            "Kaboul Kitchen",
            "La Meilleure Version de moi-même",
            "Mafiosa",
            "Maison close",
            "Polar Park",
            "Shambles",
            "State of Happiness",
            "The Collapse",
            "UFOs",
            "Vernon Subutex",
            "WorkinGirls",
            "XIII":
            return ""
            
        default:
            return "https://www.rottentomatoes.com/tv/\(serie.lowercased().replacingOccurrences(of: "%", with: "_").replacingOccurrences(of: "'", with: "_").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: " ", with: "_"))"
        }
    }
    
    
    func getTrendingShows() -> (names : [String], ids : [String]) {
        return getShowList(url: "https://www.rottentomatoes.com/browse/tv_series_browse/sort:popular")
    }
    
    
    func getPopularShows() -> (names : [String], ids : [String]) {
        return getShowList(url: "https://www.rottentomatoes.com/browse/tv-list-3")
    }
    
    
    func getShowList(url : String) -> (names : [String], ids : [String]) {
        let startChrono : Date = Date()
        var showNames : [String] = []
        var showIds : [String] = []
        
        do {
            let page : String = try String(contentsOf: URL(string : url)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            
            let showList = try doc.select("div [class='flex-container']")

            for oneShow in showList {
                let showName : String = try oneShow.select("[class='p--small']").text()
                
                if (!showNames.contains(showName)) {
                    showNames.append(showName)
                    showIds.append("")
                }
            }
        }
        catch let error as NSError { print("RottenTomatoes failed for getShowList : \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return (showNames, showIds)
    }
    
    
    func getCritics(serie: String, saison: Int) -> [Critique] {
        let startChrono : Date = Date()
        var result : [Critique] = []
        var webPage : String = getPath(serie: serie)
        
        if (webPage == "") { return result }
        webPage = webPage + String(format: "/s%02d", saison) + "/reviews?type=top_critics"
        webPage = webPage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            
            let critics = try doc.select("div [class='review-row']")
            
            for oneCritic in critics {
                let uneCritique : Critique = Critique()
                
                uneCritique.source = srcRottenTom
                uneCritique.journal = try oneCritic.select("[class='publication']").text()
                uneCritique.auteur = try oneCritic.select("[class='display-name']").text()
                uneCritique.texte = try oneCritic.select("[class='review-text']").text()
                uneCritique.lien = try oneCritic.select("[class='original-score-and-url']").select("a").attr("href")
                uneCritique.note = try oneCritic.select("score-icon-critics").attr("sentiment")
                uneCritique.saison = saison
                
                let dateString : String = try oneCritic.select("[class='original-score-and-url'] span").text()
                let dateTmp : Date = dateFormRottenTomatoes.date(from: dateString) ?? ZeroDate
                uneCritique.date = dateFormLong.string(from: dateTmp)
                
                result.append(uneCritique)
            }
        }
        catch let error as NSError { print("RottenTomatoes getCritics failed for \(serie): \(error.localizedDescription)") }

        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func getComments(serie: String, saison: Int, episode: Int) -> [Critique] {
        let startChrono : Date = Date()
        var result : [Critique] = []
        var webPage : String = getPath(serie: serie)
        
        if (webPage == "") { return result }
        webPage = webPage + String(format: "/s%02d/e%02d", saison, episode) + "/reviews"
        webPage = webPage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            let criticList = try doc.select("div [class='review-row']")
            
            for oneCritic in criticList {
                let uneCritique : Critique = Critique()
                
                uneCritique.source = srcRottenTom
                uneCritique.journal = try oneCritic.select("div [class='publication']").text()
                uneCritique.auteur = try oneCritic.select("div [class='display-name']").text()
                uneCritique.texte = try oneCritic.select("div [class='review-text']").text()
                uneCritique.lien = try oneCritic.select("div [class='full-url']").attr("href")
                
                let dateString : String = try oneCritic.select("div [data-qa='review-date']").text()
                let dateTmp : Date = dateFormRottenTomatoes.date(from: dateString) ?? ZeroDate
                uneCritique.date = dateFormLong.string(from: dateTmp)
                
                result.append(uneCritique)
            }
            
        }
        catch let error as NSError { print("RottenTomatoes getCritics failed for \(serie): \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
}
