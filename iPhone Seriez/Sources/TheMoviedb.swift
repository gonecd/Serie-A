//
//  TheMoviedb.swift
//  SerieA
//
//  Created by Cyril Delamare on 04/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SeriesCommon

class TheMoviedb : NSObject {
    var chrono : TimeInterval = 0

    let TheMoviedbUserkey : String = "e12674d4eadc7acafcbf7821bc32403b"
    
    override init() {
        super.init()
    }
    
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()
        
        var request : URLRequest = URLRequest(url: URL(string: reqAPI)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("TheMoviedb::error \(response.statusCode) received for req=\(reqAPI)"); ended = true; return }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("TheMoviedb::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
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
            if ((saison.starts.compare(today) == .orderedAscending) && (saison.starts.compare(ZeroDate) != .orderedSame) ) {
                let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.themoviedb.org/3/tv/\(uneSerie.idMoviedb)/season/\(saison.saison)?language=en-US&api_key=\(TheMoviedbUserkey)") as? NSDictionary ?? NSDictionary()
                
                if (reqResult.object(forKey: "episodes") != nil) {
                    for unEpisode in reqResult.object(forKey: "episodes")! as! NSArray {
                        let epIndex: Int = ((unEpisode as AnyObject).object(forKey: "episode_number")! as! Int)-1
                        
                        if ( (epIndex < saison.episodes.count) && (epIndex > 0) ) {
                            if (saison.episodes[epIndex].date.compare(today) == .orderedAscending) {
                                saison.episodes[epIndex].ratingMoviedb = Int(10 * (((unEpisode as AnyObject).object(forKey: "vote_average")! as AnyObject) as? Double ?? 0.0))
                                saison.episodes[epIndex].ratersMoviedb = ((unEpisode as AnyObject).object(forKey: "vote_count")! as AnyObject) as? Int ?? 0
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func chercher(genreIncl: String, genreExcl: String, anneeBeg: String, anneeEnd: String, langue: String, network: String) -> ([Serie], Int) {
        var listeSeries : [Serie] = []
        var cpt : Int = 0
        
        var buildURL : String = "https://api.themoviedb.org/3/discover/tv?api_key=\(TheMoviedbUserkey)&language=en-US&sort_by=popularity.desc"
        
        if (genreIncl != "") {
            buildURL = buildURL + "&with_genres="
            for unGenre in genreIncl.split(separator: ",") { buildURL = buildURL + String(genresMovieDB[unGenre] as? Int ?? 0) + "," }
            buildURL.removeLast()
        }
        
        if (genreExcl != "") {
            buildURL = buildURL + "&without_genres="
            for unGenre in genreExcl.split(separator: ",") { buildURL = buildURL + String(genresMovieDB[unGenre] as? Int ?? 0) + "," }
            buildURL.removeLast()
        }
        
        if (network != "") {
            buildURL = buildURL + "&with_networks="
            for unNetwork in network.split(separator: ",") { buildURL = buildURL + String(networksMovieDB[unNetwork] as? Int ?? 0) + "|" }
            buildURL.removeLast()
        }
        
        if (anneeBeg != "") { buildURL = buildURL + "&first_air_date.gte=" + anneeBeg + "-01-01"}
        if (anneeEnd != "") { buildURL = buildURL + "&first_air_date.lte=" + anneeEnd + "-12-31"}
        if (langue != "") { buildURL = buildURL + "&with_original_language=" + langue }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: buildURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "total_results") != nil) {
            cpt = reqResult.object(forKey: "total_results") as? Int ?? 0
            
            if (reqResult.object(forKey: "results") != nil) {
                for uneSerie in reqResult.object(forKey: "results")! as! NSArray {
                    let newSerie : Serie = Serie(serie: ((uneSerie as AnyObject).object(forKey: "name") as! String))
                    newSerie.idMoviedb = String(((uneSerie as AnyObject).object(forKey: "id") as! Int))
                    let dateTexte : String = (uneSerie as AnyObject).object(forKey: "first_air_date") as? String ?? ""
                    if (dateTexte.count > 3) {
                        newSerie.year = Int(dateTexte.split(separator: "-")[0])!
                    }
                    
                    listeSeries.append(newSerie)
                }
            }
        }

        return (listeSeries, cpt)
    }
    
    
    func getIDs(serie: Serie) -> Bool {
        var found : Bool = false
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.themoviedb.org/3/tv/\(serie.idMoviedb)/external_ids?api_key=\(TheMoviedbUserkey)&language=en-US") as? NSDictionary ?? NSDictionary()
               
        if (reqResult.object(forKey: "imdb_id") != nil) {
            found = true
            serie.idIMdb = (reqResult.object(forKey: "imdb_id") as? String ?? "")
            serie.idTrakt = serie.idIMdb
        }
        
        if (reqResult.object(forKey: "tvdb_id") != nil) {
            found = true
            serie.idTVdb = String(reqResult.object(forKey: "tvdb_id") as? Int ?? 0)
        }
        
        return found
    }
    
    
    func getSerieGlobalInfos(idMovieDB : String) -> Serie {
        let uneSerie : Serie = Serie(serie: "")
        
        if ((idMovieDB == "") || (idMovieDB == "0"))  {
            print("TheMoviedb::getSerieGlobalInfos failed : no ID")
            return uneSerie
        }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.themoviedb.org/3/tv/\(idMovieDB)?api_key=\(TheMoviedbUserkey)&language=en-US&append_to_response=external_ids,content_ratings") as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "external_ids") != nil) {
            uneSerie.serie = reqResult.object(forKey: "name") as? String ?? ""
            uneSerie.idIMdb = (reqResult.object(forKey: "external_ids")! as AnyObject).object(forKey: "imdb_id") as? String ?? ""
            uneSerie.idTVdb = String((reqResult.object(forKey: "external_ids")! as AnyObject).object(forKey: "tvdb_id") as? Int ?? 0)
            uneSerie.idMoviedb = String(reqResult.object(forKey: "id") as? Int ?? 0)
            if ((reqResult.object(forKey: "networks") != nil) && ((reqResult.object(forKey: "networks") as! NSArray).count > 0) ) {
                uneSerie.network = ((reqResult.object(forKey: "networks") as! NSArray).object(at: 0) as! NSDictionary).object(forKey: "name") as? String ?? ""
            }
            uneSerie.poster = reqResult.object(forKey: "poster_path") as? String ?? ""
            if (uneSerie.poster != "") { uneSerie.poster = "https://image.tmdb.org/t/p/w92" + uneSerie.poster }
            uneSerie.status = reqResult.object(forKey: "status") as? String ?? ""
            uneSerie.resume = reqResult.object(forKey: "overview") as? String ?? ""
            uneSerie.ratingMovieDB = Int(10 * (reqResult.object(forKey: "vote_average") as? Double ?? 0.0))
            uneSerie.ratersMovieDB = reqResult.object(forKey: "vote_count") as? Int ?? 0
            if ((reqResult.object(forKey: "origin_country") != nil) && ((reqResult.object(forKey: "origin_country") as! NSArray).count > 0) ) {
                uneSerie.country = (reqResult.object(forKey: "origin_country") as! NSArray).object(at: 0) as? String ?? ""
            }
            uneSerie.language = reqResult.object(forKey: "original_language") as? String ?? ""
            if ((reqResult.object(forKey: "episode_run_time") != nil) && ((reqResult.object(forKey: "episode_run_time") as! NSArray).count > 0) ) {
                uneSerie.runtime = (reqResult.object(forKey: "episode_run_time") as! NSArray).object(at: 0) as? Int ?? 0
            }
            uneSerie.homepage = reqResult.object(forKey: "homepage") as? String ?? ""
            uneSerie.nbSaisons = reqResult.object(forKey: "number_of_seasons") as? Int ?? 0
            uneSerie.nbEpisodes = reqResult.object(forKey: "number_of_episodes") as? Int ?? 0
            
            for i in 0..<((reqResult.object(forKey: "genres") as? NSArray ?? []).count) {
                uneSerie.genres.append((((reqResult.object(forKey: "genres") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "name")) as? String ?? "")
            }
            
            for i in 0..<((reqResult.object(forKey: "seasons") as? NSArray ?? []).count) {
                let readSaison : Int = (((reqResult.object(forKey: "seasons") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "season_number")) as? Int ?? 0
                if (readSaison != 0) {
                    let uneSaison : Saison = Saison(serie: uneSerie.serie, saison: readSaison)
                    
                    uneSaison.nbEpisodes = (((reqResult.object(forKey: "seasons") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "episode_count")) as? Int ?? 0
                    
                    let stringDate : String = (((reqResult.object(forKey: "seasons") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "air_date")) as? String ?? ""
                    if (stringDate !=  "") { uneSaison.starts = dateFormSource.date(from: stringDate)! }
                    
                    uneSerie.saisons.append(uneSaison)
                }
            }
        }
        
        return uneSerie
    }
    
    
    func getSimilarShows(movieDBid : String) -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.themoviedb.org/3/tv/\(movieDBid)/similar?api_key=\(TheMoviedbUserkey)&language=en-US&page=1")  as? NSDictionary ?? NSDictionary()
        //let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.themoviedb.org/3/tv/\(movieDBid)/recommendations?api_key=\(TheMoviedbUserkey)&language=en-US&page=1") as! NSDictionary
        
        if (reqResult.object(forKey: "results") != nil) {
            for oneShow in (reqResult.object(forKey: "results") as! NSArray) {
                let titre : String = ((oneShow as! NSDictionary).object(forKey: "name")) as? String ?? ""
                let idMovieDB : String = String(((oneShow as! NSDictionary).object(forKey: "id")) as? Int ?? 0)
                
                var exclure : Bool = false
                for i in 0..<((((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).count) {
                    let unGenre : Int = (((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).object(at: i) as? Int ?? 0
                    if ((unGenre == genreAnimation) || (unGenre == genreDocumentaire) ) { exclure = true }
                }
                
                if ( (exclure == false) && (compteur < similarShowsPerSource) ) {
                    compteur = compteur + 1
                    showNames.append(titre)
                    showIds.append(idMovieDB)
                }
            }
        }
        
        return (showNames, showIds)
    }
    
    
    func getTrendingShows() -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.themoviedb.org/3/tv/top_rated?api_key=\(TheMoviedbUserkey)&language=en-US&page=1") as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "results") != nil) {
            for oneShow in (reqResult.object(forKey: "results") as! NSArray) {
                let titre : String = ((oneShow as! NSDictionary).object(forKey: "name")) as? String ?? ""
                let idMovieDB : String = String(((oneShow as! NSDictionary).object(forKey: "id")) as? Int ?? 0)
                
                var exclure : Bool = false
                for i in 0..<((((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).count) {
                    let unGenre : Int = (((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).object(at: i) as? Int ?? 0
                    if ((unGenre == genreAnimation) || (unGenre == genreDocumentaire) ) { exclure = true }
                }
                
                if ( (exclure == false) && (compteur < popularShowsPerSource) ) {
                    compteur = compteur + 1
                    showNames.append(titre)
                    showIds.append(idMovieDB)
                }
            }
        }
        
        return (showNames, showIds)
    }
    
    
    func getPopularShows() -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.themoviedb.org/3/tv/popular?api_key=\(TheMoviedbUserkey)&language=en-US&page=1") as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "results") != nil) {
            for oneShow in (reqResult.object(forKey: "results") as! NSArray) {
                let titre : String = ((oneShow as! NSDictionary).object(forKey: "name")) as? String ?? ""
                let idMovieDB : String = String(((oneShow as! NSDictionary).object(forKey: "id")) as? Int ?? 0)
                
                var exclure : Bool = false
                for i in 0..<((((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).count) {
                    let unGenre : Int = (((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).object(at: i) as? Int ?? 0
                    if ((unGenre == genreAnimation) || (unGenre == genreDocumentaire) ) { exclure = true }
                }
                
                if ( (exclure == false) && (compteur < popularShowsPerSource) ) {
                    compteur = compteur + 1
                    showNames.append(titre)
                    showIds.append(idMovieDB)
                }
            }
        }
        
        return (showNames, showIds)
    }
    
    
    func rechercheParTitre(serieArechercher : String) -> [Serie] {
        var serieListe : [Serie] = []
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.themoviedb.org/3/search/tv?api_key=\(TheMoviedbUserkey)&query=\(serieArechercher.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)&page=1") as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "results") != nil) {
            for oneItem in (reqResult.object(forKey: "results") as! NSArray) {
                let oneShow : NSDictionary = oneItem as! NSDictionary
                let newSerie : Serie = Serie(serie: oneShow.object(forKey: "name") as! String)
                
                newSerie.idMoviedb = String(oneShow.object(forKey: "id") as? Int ?? 0)
                newSerie.ratingMovieDB = Int(10 * (oneShow.object(forKey: "vote_average") as? Double ?? 0.0))
                newSerie.ratersMovieDB = oneShow.object(forKey: "vote_count") as? Int ?? 0
                newSerie.resume = oneShow.object(forKey: "overview") as? String ?? ""
                newSerie.language = oneShow.object(forKey: "original_language") as? String ?? ""
                
                if ((oneShow.object(forKey: "origin_country") != nil) && ((oneShow.object(forKey: "origin_country") as! NSArray).count > 0) ) {
                    newSerie.country = (oneShow.object(forKey: "origin_country") as! NSArray).object(at: 0) as? String ?? ""
                }
                
                newSerie.poster = oneShow.object(forKey: "poster_path") as? String ?? ""
                if (newSerie.poster != "") { newSerie.poster = "https://image.tmdb.org/t/p/w92" + newSerie.poster }
                
                newSerie.watchlist = true
                
                serieListe.append(newSerie)
            }
        }
        
        return serieListe
    }
}
