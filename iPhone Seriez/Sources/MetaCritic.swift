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
                    if (response.statusCode != 200) { print("MetaCritic::error \(response.statusCode) received for req=\(reqAPI)"); ended = true; return }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("MetaCritic::failed \(error.localizedDescription) for req=\(reqAPI) - error \(response.statusCode)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func getSerieGlobalInfos(serie : String) -> Serie {
        let uneSerie : Serie = Serie(serie: serie)
        var reqURL : String = ""
        let slug : String = getSlug(serie: serie)
        if (slug == "") { return uneSerie }
        else { reqURL = "https://backend.metacritic.com/v1/xapi/finder/metacritic/search/\(slug)/web?mcoTypeId=1&limit=5" }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: reqURL) as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) {
            print("MetaCritic.getSerieGlobalInfos : \(serie) non trouvée")
            return uneSerie
        }
        
        let itemsFound = ((reqResult as AnyObject).object(forKey: "data")! as AnyObject).object(forKey: "items") as? NSArray ?? NSArray()
        if (itemsFound.count == 0) {
            print("MetaCritic.getSerieGlobalInfos : \(serie) non trouvée")
            return uneSerie
        }
        
        for oneShow in itemsFound {
            let serieTrouvee = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
            
            if (serie.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == serieTrouvee.replacingOccurrences(of: #"\s?\([\w\s]*\)"#, with: "", options: .regularExpression).lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) {
                uneSerie.ratingMetaCritic = ((oneShow as! NSDictionary).object(forKey: "criticScoreSummary") as! NSDictionary).object(forKey: "score") as? Int ?? 0
                uneSerie.certification = (oneShow as! NSDictionary).object(forKey: "rating") as? String ?? ""
                uneSerie.year = (oneShow as! NSDictionary).object(forKey: "premiereYear") as? Int ?? 0
                uneSerie.nbSaisons = (oneShow as! NSDictionary).object(forKey: "seasonCount") as? Int ?? 0
                uneSerie.resume = (oneShow as! NSDictionary).object(forKey: "description") as? String ?? ""
                uneSerie.runtime = (oneShow as! NSDictionary).object(forKey: "duration") as? Int ?? 0
                uneSerie.slugMetaCritic = (oneShow as! NSDictionary).object(forKey: "slug") as? String ?? ""
                
                return uneSerie
            }
        }
        
        print("MetaCritic.getSerieGlobalInfos : \(serie) non trouvée")
        
        return uneSerie
    }
    
    
    func getSerieGlobalInfosWeb(serie : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: serie)
        if (uneSerie.slugMetaCritic == "") { return uneSerie }
        let webPage : String = "https://www.metacritic.com/tv/"+uneSerie.slugMetaCritic

        do {
            let page : String = try String(contentsOf: URL(string : webPage)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            let extract : String = try doc.select("[class='c-productScoreInfo u-clearfix g-inner-spacing-bottom-medium']").select("[class='c-productScoreInfo_scoreNumber u-float-right']").text()
            
            uneSerie.ratingMetaCritic = Int(extract) ?? 0
        }
        catch let error as NSError { print("MetaCritic failed: \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return uneSerie
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono : Date = Date()
        if (uneSerie.slugMetaCritic == "") { return }
        let webPage : String = "https://www.metacritic.com/tv/"+uneSerie.slugMetaCritic

        for uneSaison in uneSerie.saisons {
            do {
                let page : String = try String(contentsOf: URL(string : webPage+"/season-"+String(uneSaison.saison))!, encoding: .utf8)
                let doc : Document = try SwiftSoup.parse(page)
                let allNotes = try doc.select("li [class^='ep_guide_item']")
                
                for oneNote in allNotes {
                    let rate : String = try oneNote.select("div").text()
                    let note = Int(10.0 * (Double(rate) ?? 0.0))
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
        return getShowList(url: "https://www.metacritic.com/browse/tv/all/all/current-year/metascore/?page=1")
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
            let page : String = try String(contentsOf: URL(string : url)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            
            let showList = try doc.select("[class='c-finderProductCard_title']")

            for oneShow in showList {
                let spans = try oneShow.select("span")
                
                if (spans.count > 0) {
                    let showName : String = try spans[1].text()
                    
                    if (compteur < popularShowsPerSource){
                        showNames.append(showName)
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
    
    
    func getSlug(serie: String) -> String {
        switch serie {
            
        case "3%",
            "A Very Secret Service",
            "All the Way Up",
            "Baron Noir",
            "Borgen - Power & Glory",
            "Borgia",
            "Bottom",
            "Braquo",
            "Bref.",
            "Cheeky Business",
            "En thérapie",
            "Family Business",
            "Fawlty Towers",
            "Glue",
            "Guyane",
            "HPI",
            "Hard",
            "Hero Corp",
            "How to Sell Drugs Online (Fast)",
            "Infiniti",
            "Jordskott",
            "Kaamelott",
            "Kaboul Kitchen",
            "La Meilleure Version de moi-même",
            "Mafiosa",
            "Maison close",
            "Marianne",
            "Monty Python's Flying Circus",
            "Of Money and Blood",
            "One-Punch Man",
            "Polar Park",
            "Real Humans",
            "Savages",
            "Shambles",
            "Spiral",
            "State of Happiness",
            "The Bureau",
            "The Collapse",
            "UFOs",
            "Vernon Subutex",
            "Wentworth",
            "Attack on Titan",
            "Miskina, Poor Thing",
            "Nothing",
            "Standing Up",
            "The Frog",
            "Trapped",
            "Trom",
            "WorkinGirls":
            return ""            // Not available on Metacritic

            
        case "Shōgun",
            "Rick and Morty",
            "SAS: Rogue Heroes",
            "Star Wars: Andor":
            return ""            // Available on Metacritic mais mal gérées par UneSerie

            
//        case "Shōgun":            return "shogun-2024"
//        case "Rick and Morty":    return "rick-morty"
//        case "SAS: Rogue Heroes": return "rogue-heroes"
//        case "Star Wars: Andor":  return "andor"

        default : return serie.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        }
    }

    
    func getCritics(slug: String, saison: Int) -> [Critique] {
        let startChrono : Date = Date()
        var result : [Critique] = []
        if (slug == "") { return result }

        var webPage : String = "https://www.metacritic.com/tv/"+slug
        webPage = webPage + "/critic-reviews/?sort-by=Recently%20Added&num_items=20&season=season-" + String(saison)
        webPage = webPage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!, encoding: .utf8)
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
        catch let error as NSError { print("MetaCritic.getCritics failed for \(slug): \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
}
