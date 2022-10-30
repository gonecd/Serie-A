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

    
    func getEpisodesRatings(serie : Serie) {
        if (serie.idSensCritique.components(separatedBy: "/").count <= 1) { return }
        
        for uneSaison in serie.saisons {
            let stringBody : String = "[ { \"operationName\": \"ProductSeasonEpisodes\", \"variables\": { \"id\": \(serie.idSensCritique.components(separatedBy: "/")[1]), \"seasonNumber\": \(uneSaison.saison), \"offset\": 0, \"limit\": 50 }, \"query\": \"query ProductSeasonEpisodes($id: Int!, $seasonNumber: Int!, $offset: Int, $limit: Int) { product(id: $id) { season(seasonNumber: $seasonNumber) { episodes(offset: $offset, limit: $limit) {rating episodeNumber seasonNumber} } } }\" } ]"
            let reqResult : NSArray = postAPI(reqAPI: "https://apollo.senscritique.com/", body: stringBody) as? NSArray ?? NSArray()
            
            if (reqResult.count > 0) {
                //let fiches : NSArray = try ((((reqResult[0] as AnyObject).object(forKey: "data")! as AnyObject).object(forKey: "product")! as AnyObject).object(forKey: "season")! as AnyObject).object(forKey: "episodes") as? NSArray ?? NSArray()
                let ficheProduct = ((reqResult[0] as AnyObject).object(forKey: "data")! as AnyObject).object(forKey: "product")! as AnyObject
                let ficheSeason  = ficheProduct.object(forKey: "season")! as AnyObject
                if (ficheSeason.description == "<null>") { print ("SensCritique::getEpisodesRatings failed for \(serie.serie) saison \(uneSaison.saison)"); return; }
                
                for fiche in (ficheSeason.object(forKey: "episodes") as? NSArray ?? NSArray()) {
                    let unEpisode : AnyObject = (fiche as AnyObject)
                    let ssRating = unEpisode.object(forKey: "rating") as? Double ?? 0.0
                    let ssEpisode = unEpisode.object(forKey: "episodeNumber") as? Int ?? 0
                    let ssSaison = unEpisode.object(forKey: "seasonNumber") as? Int ?? 0
                    
                    if (uneSaison.saison == ssSaison) {
                        if(uneSaison.episodes.count > ssEpisode-1) {
                            serie.saisons[ssSaison-1].episodes[ssEpisode-1].ratingSensCritique = Int(10*ssRating)
                        }
                    }
                }
            }
        }
    }
}
