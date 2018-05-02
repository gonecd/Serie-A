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
        trace(texte : "<< BetaSeries : init >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< BetaSeries : init >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        super.init()
        
        trace(texte : "<< BetaSeries : init >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie)
    {
        trace(texte : "<< BetaSeries : getEpisodesRatings >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< BetaSeries : getEpisodesRatings >> Params : uneSerie :\(uneSerie)", logLevel : logFuncParams, scope : scopeSource)
        
        var url : URL
        var request : URLRequest
        var task : URLSessionDataTask
        let today : Date = Date()

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
                                        if (saison.episodes[cetEpisode].date.compare(today) == .orderedAscending)
                                        {
                                            saison.episodes[cetEpisode].ratingBetaSeries = Int(20 * (((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
                                            saison.episodes[cetEpisode].ratersBetaSeries = ((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "total") as? Int ?? 0
                                        }
                                        
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
        trace(texte : "<< BetaSeries : getEpisodesRatings >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    
    func getSerieGlobalInfos(idTVDB : String, idIMDB : String) -> Serie
    {
        trace(texte : "<< BetaSeries : getSerieGlobalInfos >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< BetaSeries : getSerieGlobalInfos >> Params : idTVDB=\(idTVDB), idIMDB=\(idIMDB)", logLevel : logFuncParams, scope : scopeSource)
        
        let uneSerie : Serie = Serie(serie: "")
        var request : URLRequest
        
        if (idTVDB != "")       { request = URLRequest(url: URL(string: "https://api.betaseries.com/shows/display?v=3.0&imdb_id=\(idIMDB)")!) }
        else if (idTVDB != "")  { request = URLRequest(url: URL(string: "https://api.betaseries.com/shows/display?v=3.0&thetvdb_id=\(idTVDB)")!) }
        else                    { return uneSerie }
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(BetaSeriesUserkey)", forHTTPHeaderField: "X-BetaSeries-Key")

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("BetaSeries::getSerieGlobalInfos error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let show = jsonResponse.object(forKey: "show") as! NSDictionary
                    
                    uneSerie.serie = show.object(forKey: "title") as? String ?? ""
                    uneSerie.idIMdb = show.object(forKey: "imdb_id") as? String ?? ""
                    uneSerie.idTVdb = String(show.object(forKey: "thetvdb_id") as? Int ?? 0)
                    uneSerie.resume = show.object(forKey: "description") as? String ?? ""
                    uneSerie.network = show.object(forKey: "network") as? String ?? ""
                    uneSerie.banner = (show.object(forKey: "images")! as AnyObject).object(forKey: "banner") as? String ?? ""
                    uneSerie.poster = (show.object(forKey: "images")! as AnyObject).object(forKey: "poster") as? String ?? ""
                    uneSerie.status = show.object(forKey: "status") as? String ?? ""
                    uneSerie.genres = show.object(forKey: "genres") as? [String] ?? []
                    uneSerie.year = Int(show.object(forKey: "creation") as? String ?? "0")!
                    uneSerie.ratingBetaSeries = Int(20 * ((show.object(forKey: "notes")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
                    uneSerie.ratersBetaSeries = (show.object(forKey: "notes")! as AnyObject).object(forKey: "total") as? Int ?? 0
                    uneSerie.language = show.object(forKey: "language") as? String ?? ""
                    uneSerie.runtime = Int(show.object(forKey: "length") as? String ?? "0")!
                    uneSerie.nbEpisodes = Int(show.object(forKey: "episodes") as? String ?? "0")!
                    uneSerie.nbSaisons = Int(show.object(forKey: "seasons") as? String ?? "0")!
                    uneSerie.certification = show.object(forKey: "rating") as? String ?? ""
                    
                } catch let error as NSError { print("BetaSeries::getSerieGlobalInfos failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }

        trace(texte : "<< BetaSeries : getSerieGlobalInfos >> Return : uneSerie=\(uneSerie)", logLevel : logFuncReturn, scope : scopeSource)
        return uneSerie
    }
    
    func getSimilarShows(TVDBid : String) -> (names : [String], ids : [String])
    {
        trace(texte : "<< BetaSeries : getSimilarShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< BetaSeries : getSimilarShows >> Params : TVDBid=\(TVDBid)", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false
        var compteur : Int = 0
        
        var request : URLRequest = URLRequest(url: URL(string: "https://api.betaseries.com/shows/similars?v=3.0&thetvdb_id=\(TVDBid)")!)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(BetaSeriesUserkey)", forHTTPHeaderField: "X-BetaSeries-Key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("BetaSeries::getSimilarShows error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    for oneShow in (jsonResponse.object(forKey: "similars") as! NSArray)
                    {
                        let titre : String = ((oneShow as! NSDictionary).object(forKey: "show_title")) as? String ?? ""
                        let idTVDB : String = String(((oneShow as! NSDictionary).object(forKey: "thetvdb_id")) as? Int ?? 0)
                        
                        if (compteur < similarShowsPerSource)
                        {
                            compteur = compteur + 1
                            showNames.append(titre)
                            showIds.append(idTVDB)
                        }
                    }
                    
                    ended = true
                    
                } catch let error as NSError { print("BetaSeries::getSimilarShows failed: \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }

        trace(texte : "<< BetaSeries : getSerieGlobalInfos >> Return : showNames=\(showNames), showIds=\(showIds)", logLevel : logFuncReturn, scope : scopeSource)
        return (showNames, showIds)
    }
    
    func getTrendingShows() -> (names : [String], ids : [String])
    {
        trace(texte : "<< BetaSeries : getTrendingShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< BetaSeries : getTrendingShows >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false

        var request : URLRequest = URLRequest(url: URL(string: "https://api.betaseries.com/shows/discover?v=3.0&limit=\(popularShowsPerSource)")!)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(BetaSeriesUserkey)", forHTTPHeaderField: "X-BetaSeries-Key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("BetaSeries::getSimilarShows error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    for oneShow in (jsonResponse.object(forKey: "shows") as! NSArray)
                    {
                        let titre : String = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
                        let idTVDB : String = String(((oneShow as! NSDictionary).object(forKey: "thetvdb_id")) as? Int ?? 0)
                        
                            showNames.append(titre)
                            showIds.append(idTVDB)
                    }
                    
                    ended = true
                    
                } catch let error as NSError { print("BetaSeries::getSimilarShows failed: \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< BetaSeries : getTrendingShows >> Return : showNames=\(showNames), showIds=\(showIds)", logLevel : logFuncReturn, scope : scopeSource)
        return (showNames, showIds)
    }

    func getPopularShows() -> (names : [String], ids : [String])
    {
        trace(texte : "<< BetaSeries : getPopularShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< BetaSeries : getPopularShows >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false
        
        var request : URLRequest = URLRequest(url: URL(string: "https://api.betaseries.com/shows/list?v=3.0&order=popularity&limit=\(popularShowsPerSource)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(BetaSeriesUserkey)", forHTTPHeaderField: "X-BetaSeries-Key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("BetaSeries::getSimilarShows error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    for oneShow in (jsonResponse.object(forKey: "shows") as! NSArray)
                    {
                        let titre : String = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
                        let idTVDB : String = String(((oneShow as! NSDictionary).object(forKey: "thetvdb_id")) as? Int ?? 0)
                        
                        showNames.append(titre)
                        showIds.append(idTVDB)
                    }
                    
                    ended = true
                    
                } catch let error as NSError { print("BetaSeries::getSimilarShows failed: \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< BetaSeries : getTrendingShows >> Return : showNames=\(showNames), showIds=\(showIds)", logLevel : logFuncReturn, scope : scopeSource)
        return (showNames, showIds)
    }
    
    
    
    func getLastEpisodeDate(TVdbId : String, saison : Int, episode : Int) -> Date
    {
        trace(texte : "<< BetaSeries : getLastEpisodeDate >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< BetaSeries : getLastEpisodeDate >> Params : TVdbId=\(TVdbId), saison=\(saison), episode=\(episode)", logLevel : logFuncParams, scope : scopeSource)
        
        var ended : Bool = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var uneDate : Date = Date()
        
        var request : URLRequest = URLRequest(url: URL(string: "https://api.betaseries.com/shows/episodes?v=3.0&thetvdb_id=\(TVdbId)&season=\(saison)&episode=\(episode)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(BetaSeriesUserkey)", forHTTPHeaderField: "X-BetaSeries-Key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("BetaSeries::getLastEpisodeDate error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let episodeArray : NSArray = (jsonResponse.object(forKey: "episodes")) as! NSArray
                    
                    if (episodeArray.count > 0)
                    {
                        let stringDate : String = ((episodeArray.object(at: 0) as! NSDictionary).object(forKey: "date")) as? String ?? ""
                        if (stringDate !=  "") { uneDate = dateFormatter.date(from: stringDate)! }
                    }
                    else
                    {
                        uneDate = ZeroDate
                    }
                    
                    ended = true
                    
                } catch let error as NSError { print("BetaSeries::getSimilarShows failed: \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< BetaSeries : getLastEpisodeDate >> Return : getLastEpisodeDate = \(uneDate)", logLevel : logFuncReturn, scope : scopeSource)
        return (uneDate)
    }
    
    
    
}
