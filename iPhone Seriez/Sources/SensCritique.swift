//
//  SensCritique.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 06/06/2022.
//  Copyright © 2022 Home. All rights reserved.
//

import Foundation
import SwiftSoup

class SensCritique {
    var chrono : TimeInterval = 0
    let dateSensCritique = DateFormatter()

    init() {
        dateSensCritique.dateFormat = "MMM dd, yyyy"
    }
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()
        
        var request = URLRequest(url: URL(string: reqAPI)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("SensCritique::error \(response.statusCode) received for req=\(reqAPI) "); ended = true; return; }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("SensCritique::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
            } else { print(error as Any); ended = true; }
        }
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }

    
    func postAPI(reqAPI: String, body: String) -> NSObject {
        let startChrono : Date = Date()
        var request = URLRequest(url: URL(string: reqAPI)!)
        var result : NSObject = NSObject()
        var ended : Bool = false

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("https://www.senscritique.com", forHTTPHeaderField: "Referer")
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if ( response.statusCode == 200 ) {
                        result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                        ended = true
                    }
                    else {
                        print("SensCritique::post error \(response.statusCode) received for \(reqAPI) with body = \(body)")
                        ended = true
                        return
                    }
                } catch let error as NSError { print("SensCritique::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
                
            } else { print(error as Any) }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }

    func getSerieGlobalInfos(serie : String) -> Serie {
        let uneSerie : Serie = Serie(serie: "")
        
        if (serie == "") { return uneSerie }
        
        let stringBody : String = "[ { \"operationName\": \"SearchAutocomplete\", \"variables\": { \"keywords\": \"\(serie)\", \"limit\": 3 }, \"query\": \"query SearchAutocomplete($keywords: String!, $limit: Int) {searchAutocomplete(keywords: $keywords, limit: $limit) {total items {product {dateRelease id originalTitle title universe url rating category synopsis genresInfos {label} stats {currentCount ratingCount recommendCount reviewCount wishCount } } } } }\" } ]"
        let reqResult : NSArray = postAPI(reqAPI: "https://apollo.senscritique.com/", body: stringBody) as? NSArray ?? NSArray()

        if (reqResult.count > 0) {
            let fichesProduct = (((reqResult[0] as AnyObject).object(forKey: "data")! as AnyObject).object(forKey: "searchAutocomplete")! as AnyObject).object(forKey: "items")! as? NSArray ?? NSArray()

            if (fichesProduct.count > 0) {
                for fiche in fichesProduct {
                    
                    if (((fiche as AnyObject).object(forKey: "product")) as! NSObject).isEqual(NSNull()) {
                        continue
                    }
                    
                    let title1 = ((fiche as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "originalTitle") as? String ?? ""
                    let title2 = ((fiche as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "title") as? String ?? ""
                    let type = ((fiche as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "category") as? String ?? ""
                    
                    if (type == "Série") && ( (title1 == serie) || (title2 == serie) ) {
                        
                        uneSerie.serie = serie
                        uneSerie.idSensCritique = String( ((fiche as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "id") as? Int ?? 0 )
                        uneSerie.ratingSensCritique = Int ( 10 * (((fiche as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "rating") as? Double ?? 0.0))
                        uneSerie.resumeFR = ((fiche as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "synopsis") as? String ?? ""

                        for i in 0..<((((fiche as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "genresInfos") as? NSArray ?? []).count) {
                            let unGenre : String = (((((fiche as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "genresInfos") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "label")) as? String ?? ""
                            uneSerie.genres.append(unGenre)
                        }
                    }
                    
                    return uneSerie
                }
            }
        }

        return uneSerie
    }

    
    
    func getEpisodesRatings(serie : Serie) {
        //if (serie.idSensCritique.components(separatedBy: "/").count <= 1) { return }
        let today : Date = Date()

        if (serie.idSensCritique == "") { return }
        
        for uneSaison in serie.saisons {
            if ((uneSaison.starts == ZeroDate) || (uneSaison.starts.compare(today) == .orderedDescending) ) { continue }
            
            let stringBody : String = "[ { \"operationName\": \"ProductSeasonEpisodes\", \"variables\": { \"id\": \(serie.idSensCritique), \"seasonNumber\": \(uneSaison.saison), \"offset\": 0, \"limit\": 50 }, \"query\": \"query ProductSeasonEpisodes($id: Int!, $seasonNumber: Int!, $offset: Int, $limit: Int) { product(id: $id) { season(seasonNumber: $seasonNumber) { episodes(offset: $offset, limit: $limit) {rating episodeNumber seasonNumber} } } }\" } ]"
            let reqResult : NSArray = postAPI(reqAPI: "https://apollo.senscritique.com/", body: stringBody) as? NSArray ?? NSArray()
            
            if (reqResult.count > 0) {
                let ficheProduct = ((reqResult[0] as AnyObject).object(forKey: "data")! as AnyObject).object(forKey: "product")! as AnyObject
                let ficheSeason  = ficheProduct.object(forKey: "season")! as AnyObject
                if (ficheSeason.description == "<null>") { print ("SensCritique::getEpisodesRatings failed for \(serie.serie) saison \(uneSaison.saison)"); return; }
                
                for fiche in (ficheSeason.object(forKey: "episodes") as? NSArray ?? NSArray()) {
                    let unEpisode : AnyObject = (fiche as AnyObject)
                    let ssRating = unEpisode.object(forKey: "rating") as? Double ?? 0.0
                    let ssEpisode = unEpisode.object(forKey: "episodeNumber") as? Int ?? 0
                    let ssSaison = unEpisode.object(forKey: "seasonNumber") as? Int ?? 0
                    
                    if (uneSaison.saison == ssSaison) {
                        if ((uneSaison.episodes.count > ssEpisode-1) && (ssEpisode != 0)) {
                            serie.saisons[ssSaison-1].episodes[ssEpisode-1].ratingSensCritique = Int(10*ssRating)
                        }
                    }
                }
            }
        }
    }
    
    func getTrendingShows() -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        
        do {
            let page : String = try String(contentsOf: URL(string : "https://www.senscritique.com/series/actualite")!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            let regex = #/( \(20[0-9][0-9]\))/#

            let showList = try doc.select("h2")

            for oneShow in showList {
                let showName = try oneShow.text().replacing(regex.ignoresCase(), with: "")
                
                if (!showNames.contains(showName)) {
                    showNames.append(showName)
                    showIds.append("")
                }
            }
        }
        catch let error as NSError { print("SensCritique failed for getShowList : \(error.localizedDescription)") }
        
        return (showNames, showIds)
    }
    
}
