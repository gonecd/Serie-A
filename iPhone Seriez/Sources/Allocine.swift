//
//  Allocine.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup

class AlloCine : NSObject {
    var chrono : TimeInterval = 0
    
    let indexWebPage: Dictionary = [
        "A Very Secret Service" : 10224,
        "All the Way Up" : 24293,
        "Bref." : 10520,
        "Borgen - Power & Glory" : 31831,
        "Call My Agent!" : 5019,
        "Cheeky Business" : 24639,
        "Crashing" : 20473,
        "Dirk Gently's Holistic Detective Agency" : 20395,
        "Elite" : 22373,
        "Fargo" : 11042,
        "House of the Dragon" : 25633,
        "Jordskott" : 19051,
        "Lioness" : 27407,
        "Maniac" : 20388,
        "Marianne" : 24219,
        "Marco Polo" : 10841,
        "Money Heist" : 21504,
        "Of Money and Blood" : 25647,
        "One-Punch Man" : 20669,
        "Parasyte: The Grey" : 32655,
        "Real Humans" : 10946,
        "Revolution" : 10591,
        "Savages" : 24290,
        "Shambles" : 31886,
        "Star Wars: Andor" : 24440,
        "State of Happiness" : 23413,
        "The 4400" : 251,
        "The Bureau" : 17907,
        "The Collapse" : 25687,
        "The Queen's Gambit" : 24971,
        "UFOs" : 25457,
        "Attack on Titan" : 17425,
        "Boss" : 9488,
        "Miskina, Poor Thing" : 28813,
        "Nothing" : 31587,
        "Standing Up" : 26113,
        "The Bridge" : 11138,
        "The Frog" : 35982,
        "The Seven Deadly Sins" : 19946
    ]
    
    override init() {
    }
    
    
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()
        
        var request : URLRequest = URLRequest(url: URL(string: reqAPI)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("RottenTomatoes::error \(response.statusCode) received for req=\(reqAPI)"); ended = true; return }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("RottenTomatoes::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
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
        
        if ( (uneSerie.idAlloCine == "") || (uneSerie.idAlloCine == "0") ){
            uneSerie.idAlloCine = String(indexWebPage[serie] ?? 0)
            if (uneSerie.idAlloCine == "0") { uneSerie.idAlloCine = getID(serie: serie) }
            if (uneSerie.idAlloCine == "0") {
                print("AlloCine::getSerieGlobalInfos no ID for \(serie)")
                return uneSerie
            }
        }

        let webPage : String = "http://www.allocine.fr/series/ficheserie_gen_cserie=" + uneSerie.idAlloCine + ".html"
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            
            let textRatings : String = try doc.select("div [class^='rating-holder rating-holder-']").text()
            let mots : [String] = textRatings.components(separatedBy: " ")
            
            for i in 0..<mots.count {
                if (mots[i] == "Spectateurs") {
                    let uneNote : Double = Double(mots[i+1].replacingOccurrences(of: ",", with: "."))!
                    uneSerie.ratingAlloCine = Int(uneNote * 20.0)

                    chrono = chrono + Date().timeIntervalSince(startChrono)
                    return uneSerie
                }
            }
        }
        catch let error as NSError { print("AlloCine scrapping failed for \(serie): \(error.localizedDescription)") }
        
        print("==> AlloCine - Note non trouvée : \(serie)")
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return uneSerie
    }
    
    
    func getID(serie: String) -> String {
        let reqURL : String = "https://www.allocine.fr/_/autocomplete/\(serie.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "toto")"
        
        let reqResult : NSDictionary = loadAPI(reqAPI: reqURL) as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "results") != nil) {
            for oneResult in (reqResult.object(forKey: "results") as! NSArray) {
                if ((((oneResult as! NSDictionary).object(forKey: "entity_type")) as? String ?? "") == "series") {
                    let label : String = ((oneResult as! NSDictionary).object(forKey: "original_label")) as? String ?? "???"
                    let id : String = ((oneResult as! NSDictionary).object(forKey: "entity_id")) as? String ?? "---"
                    
                    if (label.lowercased() == serie.lowercased()) {return id}
                }
            }
        }
        
        return "0"
    }
    

    func getPopularShows() -> (names : [String], ids : [String]) {
        let startChrono : Date = Date()
        var showNames : [String] = []
        var showIds : [String] = []
        
        do {
            let page : String = try String(contentsOf: URL(string : "http://www.allocine.fr/series/meilleures/")!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            let showList = try doc.select("div [class='data_box']")
            
            for oneShow in showList {
                let showName : String = try oneShow.select("h2").text()
                let AlloCineID : String = try oneShow.select("a").attr("href").components(separatedBy: "=")[1].components(separatedBy: ".")[0]

                showNames.append(showName)
                showIds.append(AlloCineID)
            }
        }
        catch let error as NSError { print("AlloCine failed for getShowList : \(error.localizedDescription)") }
                
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return (showNames, showIds)
    }
    

    func getTrendingShows() -> (names : [String], ids : [String]) {
        let startChrono : Date = Date()
        var showNames : [String] = []
        var showIds : [String] = []
        
        do {
            let page : String = try String(contentsOf: URL(string : "http://www.allocine.fr/series/top/")!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            let showList = try doc.select("div [class='card entity-card entity-card-list cf']")
            
            for oneShow in showList {
                let showName : String = try oneShow.select("h2").text()
                let AlloCineID : String = try oneShow.select("a").attr("href").components(separatedBy: "=")[1].components(separatedBy: ".")[0]

                showNames.append(showName)
                showIds.append(AlloCineID)
            }
        }
        catch let error as NSError { print("AlloCine failed for getShowList : \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return (showNames, showIds)
    }
    
    
    func getCritics(serie: String, saison: Int) -> [Critique] {
        let startChrono : Date = Date()
        var result : [Critique] = []
        
        var idAlloCine : String = String(indexWebPage[serie] ?? 0)
        if (idAlloCine == "0") { idAlloCine = getID(serie: serie) }
        if (idAlloCine == "0") {
            print("AlloCine::getCritics no ID for \(serie)")
            return result
        }

        let webPage : String = "http://www.allocine.fr/series/ficheserie-" + idAlloCine + "/critiques/presse/"
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            
            let critics = try doc.select("div [class='item hred']")
            
            for oneCritic in critics {
                let uneCritique : Critique = Critique()
                
                uneCritique.source = srcAlloCine
                uneCritique.journal = try oneCritic.select("h2").text()
                uneCritique.auteur = try oneCritic.select("div [class='eval-holder']").text().replacingOccurrences(of: "par ", with: "")
                uneCritique.texte = try oneCritic.select("p").text()
                uneCritique.saison = 0

                result.append(uneCritique)
            }
        }
        catch let error as NSError { print("AlloCine getCritics failed for \(serie): \(error.localizedDescription)") }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
}
