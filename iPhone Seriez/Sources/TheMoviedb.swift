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
                                    
                                    if ( (cetEpisode < saison.episodes.count) && (cetEpisode > 0) )
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
                            print("TheMoviedb::getSerieInfos failed for \(uneSerie.serie) saison \(saison.saison) with error code : \(response.statusCode)")
                        }
                    } catch let error as NSError { print("TheMoviedb::getSerieInfos failed for \(uneSerie.serie) saison \(saison.saison) : \(error.localizedDescription)") }
                } else { print(error as Any) }
            })
            task.resume()
            while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        }
    }
    
    
    func chercher(genreIncl: String, genreExcl: String, anneeBeg: String, anneeEnd: String, langue: String, network: String) -> [Serie]
    {
        var listeSeries : [Serie] = []
        
        var buildURL : String = "https://api.themoviedb.org/3/discover/tv?api_key=\(TheMoviedbUserkey)&language=en-US&sort_by=popularity.desc"
        
        if (genreIncl != "Tous")
        {
            buildURL = buildURL + "&with_genres="
            for unGenre in genreIncl.split(separator: "\n") { buildURL = buildURL + String(genresMovieDB[unGenre] as? Int ?? 0) + "," }
            buildURL.removeLast()
        }
        
        if (genreExcl != "Aucun")
        {
            buildURL = buildURL + "&without_genres="
            for unGenre in genreExcl.split(separator: "\n") { buildURL = buildURL + String(genresMovieDB[unGenre] as? Int ?? 0) + "," }
            buildURL.removeLast()
        }
        
        if (network != "Tous")
        {
            buildURL = buildURL + "&with_networks="
            for unNetwork in network.split(separator: "\n") { buildURL = buildURL + String(networksMovieDB[unNetwork] as? Int ?? 0) + "|" }
            buildURL.removeLast()
        }
        
        if (anneeBeg != "N/A") { buildURL = buildURL + "&first_air_date.gte=" + anneeBeg + "-01-01"}
        if (anneeEnd != "N/A") { buildURL = buildURL + "&first_air_date.lte=" + anneeEnd + "-12-31"}

        if (langue != "Toutes")
        {
            buildURL = buildURL + "&with_original_language="
            for uneLangue in langue.split(separator: "\n") { buildURL = buildURL + (languesMovieDB[uneLangue] as? String ?? "") + "|" }
            buildURL.removeLast()
        }
        
        print("Requesting TheMovieDB : \(buildURL)")
        var request : URLRequest = URLRequest(url: NSURL(string: buildURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)! as URL)
        request.httpMethod = "GET"

        let task : URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if response.statusCode == 200
                    {
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

                        if (jsonResponse.object(forKey: "results") != nil)
                        {
                            for uneSerie in jsonResponse.object(forKey: "results")! as! NSArray
                            {
                                let newSerie : Serie = Serie(serie: ((uneSerie as AnyObject).object(forKey: "name") as! String))
                                newSerie.idMoviedb = String(((uneSerie as AnyObject).object(forKey: "id") as! Int))
                                print("Ajout de \(newSerie.serie)")

                                listeSeries.append(newSerie)
                            }
                        }
                    }
                    else
                    {
                        print("TheMoviedb::chercher failed with error \(response.statusCode)")
                    }
                } catch let error as NSError { print("TheMoviedb::chercher failed : \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }

        usleep(5000)
        
        return listeSeries
    }
    
    
    func getIDs(serie: Serie)
    {
       
        var request : URLRequest = URLRequest(url: NSURL(string: "https://api.themoviedb.org/3/tv/\(serie.idMoviedb)/external_ids?api_key=\(TheMoviedbUserkey)&language=en-US")! as URL)
        request.httpMethod = "GET"
        
        let task : URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if response.statusCode == 200
                    {
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if (jsonResponse.object(forKey: "imdb_id") != nil) { serie.idIMdb = (jsonResponse.object(forKey: "imdb_id") as? String ?? "") }
                        if (jsonResponse.object(forKey: "imdb_id") != nil) { serie.idTrakt = (jsonResponse.object(forKey: "imdb_id") as? String ?? "") }
                        if (jsonResponse.object(forKey: "tvdb_id") != nil) { serie.idTVdb = String(jsonResponse.object(forKey: "tvdb_id") as? Int ?? 0) }
                    }
                    else
                    {
                        print("TheMoviedb::getIDs failed for \(serie.serie)")
                    }
                } catch let error as NSError { print("TheMoviedb::getIDs failed for \(serie.serie) : \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
    }
    
    func getSerieGlobalInfos(idMovieDB : String) -> Serie
    {
        let uneSerie : Serie = Serie(serie: "")
        var request : URLRequest
        
        if (idMovieDB != "")  { request = URLRequest(url: URL(string: "https://api.themoviedb.org/3/tv/\(idMovieDB)?api_key=e12674d4eadc7acafcbf7821bc32403b&language=en-US&append_to_response=external_ids,content_ratings")!) }
        else                  { return uneSerie }

        request.httpMethod = "GET"
        
        let task : URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if response.statusCode == 200
                    {
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        uneSerie.serie = jsonResponse.object(forKey: "name") as? String ?? ""
                        uneSerie.idIMdb = (jsonResponse.object(forKey: "external_ids")! as AnyObject).object(forKey: "imdb_id") as? String ?? ""
                        uneSerie.idTVdb = String((jsonResponse.object(forKey: "external_ids")! as AnyObject).object(forKey: "tvdb_id") as? Int ?? 0)
                        uneSerie.idMoviedb = String(jsonResponse.object(forKey: "id") as? Int ?? 0)
                        uneSerie.network = ((jsonResponse.object(forKey: "networks") as! NSArray).object(at: 0) as! NSDictionary).object(forKey: "name") as? String ?? ""
                        uneSerie.poster = jsonResponse.object(forKey: "poster_path") as? String ?? ""
                        if (uneSerie.poster != "") { uneSerie.poster = "https://image.tmdb.org/t/p/w92/" + uneSerie.poster }

                        uneSerie.status = jsonResponse.object(forKey: "status") as? String ?? ""
                        uneSerie.resume = jsonResponse.object(forKey: "overview") as? String ?? ""
                        uneSerie.ratingMovieDB = Int(10 * (jsonResponse.object(forKey: "vote_average") as? Double ?? 0.0))
                        uneSerie.ratersMovieDB = jsonResponse.object(forKey: "vote_count") as? Int ?? 0
                        uneSerie.country = (jsonResponse.object(forKey: "origin_country") as! NSArray).object(at: 0) as? String ?? ""
                        uneSerie.language = jsonResponse.object(forKey: "original_language") as? String ?? ""
                        uneSerie.runtime = (jsonResponse.object(forKey: "episode_run_time") as! NSArray).object(at: 0) as? Int ?? 0
                        uneSerie.homepage = jsonResponse.object(forKey: "homepage") as? String ?? ""
                        uneSerie.nbSaisons = jsonResponse.object(forKey: "number_of_seasons") as? Int ?? 0
                        uneSerie.nbEpisodes = jsonResponse.object(forKey: "number_of_episodes") as? Int ?? 0

                        
//                        for unGenre in (jsonResponse.object(forKey: "genres") as? NSArray ?? [])
//                        {
//                            uneSerie.genres.append((unGenre as! NSDictionary).object(forKey: "name") as? String ?? "")
//                        }
                    }
                    else
                    {
                        print("TheMoviedb::getSerieGlobalInfos failed for \(idMovieDB)")
                    }
                } catch let error as NSError { print("TheMoviedb::getSerieGlobalInfos failed for \(idMovieDB) : \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        return uneSerie
    }
    
}

