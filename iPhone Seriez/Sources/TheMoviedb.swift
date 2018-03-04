//
//  TheMoviedb.swift
//  SerieA
//
//  Created by Cyril Delamare on 04/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation

class TheMoviedb : NSObject
{
    let TheMoviedbUserkey : String = "e12674d4eadc7acafcbf7821bc32403b"
    
    override init()
    {
        super.init()
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie)
    {
        var request : URLRequest
        var task : URLSessionDataTask
        let today : Date = Date()

        // Récupération des ratings
        for saison in uneSerie.saisons
        {
            request = URLRequest(url: NSURL(string: "https://api.themoviedb.org/3/tv/\(uneSerie.idMoviedb)/season/\(saison.saison)?language=en-US&api_key=\(TheMoviedbUserkey)")! as URL)
            request.httpMethod = "GET"

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
                                    let cetEpisode: Int = ((unEpisode as AnyObject).object(forKey: "episode_number")! as! Int)-1

                                    if (cetEpisode < saison.episodes.count)
                                    {
                                        if (saison.episodes[cetEpisode].date.compare(today) == .orderedAscending)
                                        {
                                            saison.episodes[cetEpisode].ratingMoviedb = Int(10 * (((unEpisode as AnyObject).object(forKey: "vote_average")! as AnyObject) as? Double ?? 0.0))
                                            saison.episodes[cetEpisode].ratersMoviedb = ((unEpisode as AnyObject).object(forKey: "vote_count")! as AnyObject) as? Int ?? 0
                                        }

                                    }
                                }
                            }
                        }
                        else
                        {
                            print("TheMoviedb::getSerieInfos failed with error code : \(response.statusCode)")
                        }
                    } catch let error as NSError { print("TheMoviedb::getSerieInfos failed: \(error.localizedDescription)") }
                } else { print(error as Any) }
            })
            task.resume()
            while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        }
    }
    
}
