//
//  BetaSeries.swift
//  Seriez
//
//  Created by Cyril Delamare on 08/05/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation

class BetaSeries : NSObject
{
    let BetaSeriesUserkey : String = "aa6120d2cf7e"
    
    override init()
    {
        super.init()
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie)
    {
        var url : URL
        var request : URLRequest
        var task : URLSessionDataTask
        
        // Récupération des ratings
        for saison in uneSerie.saisons
        {
            // Création de la liste de tous les épisodes d'une saison
            var listeEpisodes: String = ""
            for episode in saison.episodes
            {
                if (episode.idTVdb != 0)
                {
                    if (listeEpisodes != "") { listeEpisodes = listeEpisodes+"," }
                    listeEpisodes = listeEpisodes+String(episode.idTVdb)
                }
            }
            
            url = URL(string: "https://api.betaseries.com/episodes/display?thetvdb_id=\(listeEpisodes)")!
            request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("\(BetaSeriesUserkey)", forHTTPHeaderField: "X-BetaSeries-Key")
            request.addValue("2.4", forHTTPHeaderField: "X-BetaSeries-Version")
            
            task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse {
                    do {
                        if response.statusCode == 200
                        {
                            let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            if (jsonResponse.object(forKey: "episodes") != nil)
                            {
                                for unEpisode in jsonResponse.object(forKey: "episodes")! as! NSArray
                                {
                                    let cetEpisode: Int = ((unEpisode as AnyObject).object(forKey: "episode")! as! Int)-1
                                    
                                    if (cetEpisode < saison.episodes.count)
                                    {
                                        saison.episodes[cetEpisode].ratingBetaSeries = 2 * (((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0)
                                        saison.episodes[cetEpisode].ratersBetaSeries = ((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "total") as? Int ?? 0
                                        
                                    }
                                }
                            }
                        }
                    } catch let error as NSError { print("BetaSeries::getSerieInfos failed: \(error.localizedDescription)") }
                } else { print(error as Any) }
            })
            task.resume()
            while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        }
    }
    
}
