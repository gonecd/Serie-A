//
//  BetaSeries.swift
//  Seriez
//
//  Created by Cyril Delamare on 08/05/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import SeriesCommon

class BetaSeries : NSObject {
    var chrono : TimeInterval = 0

    let BetaSeriesUserkey : String = "aa6120d2cf7e"
    
    override init() {
        super.init()
    }
    
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()
        
        var request : URLRequest = URLRequest(url: URL(string: reqAPI)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(BetaSeriesUserkey)", forHTTPHeaderField: "X-BetaSeries-Key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("BetaSeries::error \(response.statusCode) received for req=\(reqAPI)"); ended = true; return }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("BetaSeries::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let today : Date = Date()
        
        // Récupération des ratings
        for saison in uneSerie.saisons {
            // Création de la liste de tous les épisodes d'une saison
            var listeEpisodes: String = ""
            for episode in saison.episodes {
                if (episode.idTVdb != 0) {
                    if (listeEpisodes != "") { listeEpisodes = listeEpisodes+"," }
                    listeEpisodes = listeEpisodes+String(episode.idTVdb)
                }
            }
            
            let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.betaseries.com/episodes/display?thetvdb_id=\(listeEpisodes)") as? NSDictionary ?? NSDictionary()
            
            if (reqResult.object(forKey: "episodes") != nil) {
                for unEpisode in reqResult.object(forKey: "episodes")! as! NSArray {
                    let cetEpisode: Int = ((unEpisode as AnyObject).object(forKey: "episode")! as! Int)-1
                    
                    if (cetEpisode < saison.episodes.count) {
                        if (saison.episodes[cetEpisode].date.compare(today) == .orderedAscending) {
                            saison.episodes[cetEpisode].ratingBetaSeries = Int(20 * (((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
                            saison.episodes[cetEpisode].ratersBetaSeries = ((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "total") as? Int ?? 0
                        }
                        
                    }
                }
            }
        }
    }
    
    func getEpisodesRatingsBis(_ uneSerie: Serie) {
        let today : Date = Date()
        var listeEpisodes: String = ""
        
        // Création de la liste de tous les épisodes
        for saison in uneSerie.saisons {
            for episode in saison.episodes {
                if (episode.idTVdb != 0) {
                    if (listeEpisodes != "") { listeEpisodes = listeEpisodes+"," }
                    listeEpisodes = listeEpisodes+String(episode.idTVdb)
                }
            }
        }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.betaseries.com/episodes/display?thetvdb_id=\(listeEpisodes)") as! NSDictionary
        
        if (reqResult.object(forKey: "episodes") != nil) {
            for unEpisode in reqResult.object(forKey: "episodes")! as! NSArray {
                let cetteSaison: Int = ((unEpisode as AnyObject).object(forKey: "season")! as! Int)-1
                let cetEpisode: Int = ((unEpisode as AnyObject).object(forKey: "episode")! as! Int)-1
                
                if (cetteSaison < uneSerie.saisons.count) {
                    if (cetEpisode < uneSerie.saisons[cetteSaison].episodes.count) {
                        if (uneSerie.saisons[cetteSaison].episodes[cetEpisode].date.compare(today) == .orderedAscending) {
                            uneSerie.saisons[cetteSaison].episodes[cetEpisode].ratingBetaSeries = Int(20 * (((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
                            uneSerie.saisons[cetteSaison].episodes[cetEpisode].ratersBetaSeries = ((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "total") as? Int ?? 0
                        }
                        
                    }
                }
            }
        }
    }

    
    func getSerieGlobalInfos(idTVDB : String, idIMDB : String) -> Serie {
        let uneSerie : Serie = Serie(serie: "")
        var reqURL : String = ""
        
        if (idIMDB != "")       { reqURL = "https://api.betaseries.com/shows/display?v=3.0&imdb_id=\(idIMDB)" }
        else if (idTVDB != "")  { reqURL = "https://api.betaseries.com/shows/display?v=3.0&thetvdb_id=\(idTVDB)" }
        else                    { return uneSerie }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: reqURL) as! NSDictionary
        let show = reqResult.object(forKey: "show") as! NSDictionary
        
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
        
        return uneSerie
    }
    
    
    func getSimilarShows(TVDBid : String) -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.betaseries.com/shows/similars?v=3.0&thetvdb_id=\(TVDBid)") as! NSDictionary
        
        for oneShow in (reqResult.object(forKey: "similars") as! NSArray) {
            let titre : String = ((oneShow as! NSDictionary).object(forKey: "show_title")) as? String ?? ""
            let idTVDB : String = String(((oneShow as! NSDictionary).object(forKey: "thetvdb_id")) as? Int ?? 0)
            
            if (compteur < similarShowsPerSource) {
                compteur = compteur + 1
                showNames.append(titre)
                showIds.append(idTVDB)
            }
        }
        
        return (showNames, showIds)
    }
    
    
    func getTrendingShows() -> (names : [String], ids : [String]) { return getShowList(url: "https://api.betaseries.com/shows/discover?v=3.0&limit=\(popularShowsPerSource)") }
    
    func getPopularShows() -> (names : [String], ids : [String]) { return getShowList(url: "https://api.betaseries.com/shows/list?v=3.0&order=popularity&limit=\(popularShowsPerSource)") }
    
    func getShowList(url : String) -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        let reqResult : NSDictionary = loadAPI(reqAPI: url) as! NSDictionary
        
        for oneShow in (reqResult.object(forKey: "shows") as! NSArray) {
            let titre : String = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
            let idIMDB : String = ((oneShow as! NSDictionary).object(forKey: "imdb_id")) as? String ?? ""
            
            showNames.append(titre)
            showIds.append(idIMDB)
        }
        
        return (showNames, showIds)
    }
        
    
    func rechercheParTitre(serieArechercher : String) -> [Serie] {
        var serieListe : [Serie] = []
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.betaseries.com/shows/search?title=\(serieArechercher.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)&v=3.0&order=popularity") as! NSDictionary
        
        for oneItem in (reqResult.object(forKey: "shows") as! NSArray) {
            let oneShow : NSDictionary = oneItem as! NSDictionary
            let newSerie : Serie = Serie(serie: oneShow.object(forKey: "title") as! String)
            
            newSerie.idIMdb = oneShow.object(forKey: "imdb_id") as? String ?? ""
            newSerie.idTVdb = String(oneShow.object(forKey: "thetvdb_id") as? Int ?? 0)
            newSerie.resume = oneShow.object(forKey: "description") as? String ?? ""
            newSerie.network = oneShow.object(forKey: "network") as? String ?? ""
            newSerie.banner = (oneShow.object(forKey: "images")! as AnyObject).object(forKey: "banner") as? String ?? ""
            newSerie.poster = (oneShow.object(forKey: "images")! as AnyObject).object(forKey: "poster") as? String ?? ""
            newSerie.status = oneShow.object(forKey: "status") as? String ?? ""
            newSerie.genres = oneShow.object(forKey: "genres") as? [String] ?? []
            newSerie.year = Int(oneShow.object(forKey: "creation") as? String ?? "0")!
            newSerie.ratingBetaSeries = Int(20 * ((oneShow.object(forKey: "notes")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
            newSerie.ratersBetaSeries = (oneShow.object(forKey: "notes")! as AnyObject).object(forKey: "total") as? Int ?? 0
            newSerie.language = oneShow.object(forKey: "language") as? String ?? ""
            newSerie.runtime = Int(oneShow.object(forKey: "length") as? String ?? "0")!
            newSerie.nbEpisodes = Int(oneShow.object(forKey: "episodes") as? String ?? "0")!
            newSerie.nbSaisons = Int(oneShow.object(forKey: "seasons") as? String ?? "0")!
            newSerie.certification = oneShow.object(forKey: "rating") as? String ?? ""
            newSerie.watchlist = true
            
            serieListe.append(newSerie)
        }
        
        return serieListe
    }

}
