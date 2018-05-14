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
        trace(texte : "<< TheMoviedb : init >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : init >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        super.init()
        
        trace(texte : "<< TheMoviedb : init >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    func getEpisodesRatings(_ uneSerie: Serie)
    {
        trace(texte : "<< TheMoviedb : getEpisodesRatings >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : getEpisodesRatings >> Params : uneSerie :\(uneSerie)", logLevel : logFuncParams, scope : scopeSource)
        
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
        trace(texte : "<< TheMoviedb : getEpisodesRatings >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    
    func chercher(genreIncl: String, genreExcl: String, anneeBeg: String, anneeEnd: String, langue: String, network: String) -> ([Serie], Int)
    {
        trace(texte : "<< TheMoviedb : chercher >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : chercher >> Params : genreIncl :\(genreIncl), genreExcl :\(genreExcl), anneeBeg :\(anneeBeg), anneeEnd :\(anneeEnd), langue :\(langue), network :\(network), ", logLevel : logFuncParams, scope : scopeSource)
        
        var listeSeries : [Serie] = []
        var cpt : Int = 0
        
        var buildURL : String = "https://api.themoviedb.org/3/discover/tv?api_key=\(TheMoviedbUserkey)&language=en-US&sort_by=popularity.desc"
        
        if (genreIncl != "")
        {
            buildURL = buildURL + "&with_genres="
            for unGenre in genreIncl.split(separator: ",") { buildURL = buildURL + String(genresMovieDB[unGenre] as? Int ?? 0) + "," }
            buildURL.removeLast()
        }
        
        if (genreExcl != "")
        {
            buildURL = buildURL + "&without_genres="
            for unGenre in genreExcl.split(separator: ",") { buildURL = buildURL + String(genresMovieDB[unGenre] as? Int ?? 0) + "," }
            buildURL.removeLast()
        }
        
        if (network != "")
        {
            buildURL = buildURL + "&with_networks="
            for unNetwork in network.split(separator: ",") { buildURL = buildURL + String(networksMovieDB[unNetwork] as? Int ?? 0) + "|" }
            buildURL.removeLast()
        }
        
        if (anneeBeg != "") { buildURL = buildURL + "&first_air_date.gte=" + anneeBeg + "-01-01"}
        if (anneeEnd != "") { buildURL = buildURL + "&first_air_date.lte=" + anneeEnd + "-12-31"}
        if (langue != "") { buildURL = buildURL + "&with_original_language=" + langue }
        
        print("Requesting TheMovieDB : \(buildURL)")
        var request : URLRequest = URLRequest(url: NSURL(string: buildURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)! as URL)
        request.httpMethod = "GET"

        let task : URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if response.statusCode == 200
                    {
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

                        cpt = jsonResponse.object(forKey: "total_results") as? Int ?? 0
                        
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
        
        trace(texte : "<< TheMoviedb : chercher >> Return : listeSeries=\(listeSeries), cpt=\(cpt)", logLevel : logFuncReturn, scope : scopeSource)
        return (listeSeries, cpt)
    }
    
    
    func getIDs(serie: Serie)
    {
        trace(texte : "<< TheMoviedb : getIDs >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : getIDs >> Params : serie :\(serie)", logLevel : logFuncParams, scope : scopeSource)
        
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
        trace(texte : "<< TheMoviedb : getIDs >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    func getSerieGlobalInfos(idMovieDB : String) -> Serie
    {
        trace(texte : "<< TheMoviedb : getSerieGlobalInfos >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : getSerieGlobalInfos >> Params : idMovieDB :\(idMovieDB)", logLevel : logFuncParams, scope : scopeSource)
        
        let uneSerie : Serie = Serie(serie: "")
        var request : URLRequest
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
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
                        if ((jsonResponse.object(forKey: "networks") != nil) && ((jsonResponse.object(forKey: "networks") as! NSArray).count > 0) )
                        {
                            uneSerie.network = ((jsonResponse.object(forKey: "networks") as! NSArray).object(at: 0) as! NSDictionary).object(forKey: "name") as? String ?? ""
                        }
                        uneSerie.poster = jsonResponse.object(forKey: "poster_path") as? String ?? ""
                        if (uneSerie.poster != "") { uneSerie.poster = "https://image.tmdb.org/t/p/w92/" + uneSerie.poster }
                        uneSerie.status = jsonResponse.object(forKey: "status") as? String ?? ""
                        uneSerie.resume = jsonResponse.object(forKey: "overview") as? String ?? ""
                        uneSerie.ratingMovieDB = Int(10 * (jsonResponse.object(forKey: "vote_average") as? Double ?? 0.0))
                        uneSerie.ratersMovieDB = jsonResponse.object(forKey: "vote_count") as? Int ?? 0
                        if ((jsonResponse.object(forKey: "origin_country") != nil) && ((jsonResponse.object(forKey: "origin_country") as! NSArray).count > 0) )
                        {
                            uneSerie.country = (jsonResponse.object(forKey: "origin_country") as! NSArray).object(at: 0) as? String ?? ""
                        }
                        uneSerie.language = jsonResponse.object(forKey: "original_language") as? String ?? ""
                        if ((jsonResponse.object(forKey: "episode_run_time") != nil) && ((jsonResponse.object(forKey: "episode_run_time") as! NSArray).count > 0) )
                        {
                            uneSerie.runtime = (jsonResponse.object(forKey: "episode_run_time") as! NSArray).object(at: 0) as? Int ?? 0
                        }
                        uneSerie.homepage = jsonResponse.object(forKey: "homepage") as? String ?? ""
                        uneSerie.nbSaisons = jsonResponse.object(forKey: "number_of_seasons") as? Int ?? 0
                        uneSerie.nbEpisodes = jsonResponse.object(forKey: "number_of_episodes") as? Int ?? 0

                        for i in 0..<((jsonResponse.object(forKey: "genres") as? NSArray ?? []).count)
                        {
                            uneSerie.genres.append((((jsonResponse.object(forKey: "genres") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "name")) as? String ?? "")
                        }

                        for i in 0..<((jsonResponse.object(forKey: "seasons") as? NSArray ?? []).count)
                        {
                            let readSaison : Int = (((jsonResponse.object(forKey: "seasons") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "season_number")) as? Int ?? 0
                            if (readSaison != 0)
                            {
                                let uneSaison : Saison = Saison(serie: uneSerie.serie, saison: readSaison)
                                
                                uneSaison.nbEpisodes = (((jsonResponse.object(forKey: "seasons") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "episode_count")) as? Int ?? 0
                                
                                let stringDate : String = (((jsonResponse.object(forKey: "seasons") as? NSArray ?? []).object(at: i) as! NSDictionary).object(forKey: "air_date")) as? String ?? ""
                                if (stringDate !=  "") { uneSaison.starts = dateFormatter.date(from: stringDate)! }

                                uneSerie.saisons.append(uneSaison)
                            }
                        }
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
        
        trace(texte : "<< TheMoviedb : getSerieGlobalInfos >> Return : uneSerie=\(uneSerie)", logLevel : logFuncReturn, scope : scopeSource)
        return uneSerie
    }
    
    
    func getSimilarShows(movieDBid : String) -> (names : [String], ids : [String])
    {
        trace(texte : "<< TheMoviedb : getSimilarShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : getSimilarShows >> Params : movieDBid=\(movieDBid)", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false
        var compteur : Int = 0

        var request : URLRequest = URLRequest(url: URL(string: "https://api.themoviedb.org/3/tv/\(movieDBid)/similar?api_key=\(TheMoviedbUserkey)&language=en-US&page=1")!)
        //var request : URLRequest = URLRequest(url: URL(string: "https://api.themoviedb.org/3/tv/\(movieDBid)/recommendations?api_key=\(TheMoviedbUserkey)&language=en-US&page=1")!)
        
        request.httpMethod = "GET"
        
        let task : URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if response.statusCode == 200
                    {
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        for oneShow in (jsonResponse.object(forKey: "results") as! NSArray)
                        {
                            let titre : String = ((oneShow as! NSDictionary).object(forKey: "name")) as? String ?? ""
                            let idMovieDB : String = String(((oneShow as! NSDictionary).object(forKey: "id")) as? Int ?? 0)
                            
                            var exclure : Bool = false
                            for i in 0..<((((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).count)
                            {
                                let unGenre : Int = (((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).object(at: i) as? Int ?? 0
                                if ((unGenre == genreAnimation) || (unGenre == genreDocumentaire) ) { exclure = true }
                            }
                            
                            if ( (exclure == false) && (compteur < similarShowsPerSource) )
                            {
                                compteur = compteur + 1
                                showNames.append(titre)
                                showIds.append(idMovieDB)
                            }
                        }
                        
                        ended = true
                    }
                    else
                    {
                        print("TheMoviedb::getSimilarShows failed for \(movieDBid)")
                        ended = true
                    }
                } catch let error as NSError { print("TheMoviedb::getSimilarShows failed for \(movieDBid) : \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< TheMoviedb : getSerieGlobalInfos >> Return : showNames=\(showNames), showIds=\(showIds)", logLevel : logFuncReturn, scope : scopeSource)
        return (showNames, showIds)
    }
    
    func getTrendingShows() -> (names : [String], ids : [String])
    {
        trace(texte : "<< TheMoviedb : getTrendingShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : getTrendingShows >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false
        var compteur : Int = 0

        var request : URLRequest = URLRequest(url: URL(string: "https://api.themoviedb.org/3/tv/top_rated?api_key=\(TheMoviedbUserkey)&language=en-US&page=1")!)
        request.httpMethod = "GET"
        
        let task : URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if response.statusCode == 200
                    {
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        for oneShow in (jsonResponse.object(forKey: "results") as! NSArray)
                        {
                            let titre : String = ((oneShow as! NSDictionary).object(forKey: "name")) as? String ?? ""
                            let idMovieDB : String = String(((oneShow as! NSDictionary).object(forKey: "id")) as? Int ?? 0)
                            
                            var exclure : Bool = false
                            for i in 0..<((((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).count)
                            {
                                let unGenre : Int = (((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).object(at: i) as? Int ?? 0
                                if ((unGenre == genreAnimation) || (unGenre == genreDocumentaire) ) { exclure = true }
                            }
                            
                            if ( (exclure == false) && (compteur < popularShowsPerSource) )
                            {
                                compteur = compteur + 1
                                showNames.append(titre)
                                showIds.append(idMovieDB)
                            }
                        }
                        
                        ended = true
                    }
                    else
                    {
                        print("TheMoviedb::getTrendingShows")
                        ended = true
                    }
                } catch let error as NSError { print("TheMoviedb::getTrendingShows : \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< TheMoviedb : getTrendingShows >> Return : showNames=\(showNames), showIds=\(showIds)", logLevel : logFuncReturn, scope : scopeSource)
        return (showNames, showIds)
    }
    
    func getPopularShows() -> (names : [String], ids : [String])
    {
        trace(texte : "<< TheMoviedb : getPopularShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : getPopularShows >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false
        var compteur : Int = 0

        var request : URLRequest = URLRequest(url: URL(string: "https://api.themoviedb.org/3/tv/popular?api_key=\(TheMoviedbUserkey)&language=en-US&page=1")!)
        
        request.httpMethod = "GET"
        
        let task : URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if response.statusCode == 200
                    {
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        for oneShow in (jsonResponse.object(forKey: "results") as! NSArray)
                        {
                            let titre : String = ((oneShow as! NSDictionary).object(forKey: "name")) as? String ?? ""
                            let idMovieDB : String = String(((oneShow as! NSDictionary).object(forKey: "id")) as? Int ?? 0)
                            
                            var exclure : Bool = false
                            for i in 0..<((((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).count)
                            {
                                let unGenre : Int = (((oneShow as! NSDictionary).object(forKey: "genre_ids")) as? NSArray ?? []).object(at: i) as? Int ?? 0
                                if ((unGenre == genreAnimation) || (unGenre == genreDocumentaire) ) { exclure = true }
                            }
                            
                            if ( (exclure == false) && (compteur < popularShowsPerSource) )
                            {
                                compteur = compteur + 1
                                showNames.append(titre)
                                showIds.append(idMovieDB)
                            }
                        }
                        
                        ended = true
                    }
                    else
                    {
                        print("TheMoviedb::getPopularShows")
                        ended = true
                    }
                } catch let error as NSError { print("TheMoviedb::getPopularShows : \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< TheMoviedb : getPopularShows >> Return : showNames=\(showNames), showIds=\(showIds)", logLevel : logFuncReturn, scope : scopeSource)
        return (showNames, showIds)
    }
    
    
    func getReviews(movieDBid : String) -> (comments : [String], likes : [Int], dates : [Date], source : [Int])
    {
        trace(texte : "<< TheMoviedb : getReviews >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< TheMoviedb : getReviews >> Params : movieDBid=\(movieDBid)", logLevel : logFuncParams, scope : scopeSource)
        
        var ended : Bool = false
        var foundComments : [String] = []
        var foundLikes : [Int] = []
        var foundDates : [Date] = []
        var foundSource : [Int] = []

        var request : URLRequest = URLRequest(url: URL(string: "https://api.themoviedb.org/3/tv/\(movieDBid)/reviews?api_key=\(TheMoviedbUserkey)&language=en-US&page=1")!)
        
        request.httpMethod = "GET"
        
        let task : URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if response.statusCode == 200
                    {
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        for oneReview in (jsonResponse.object(forKey: "results") as! NSArray)
                        {
                            let review : String = ((oneReview as! NSDictionary).object(forKey: "content")) as? String ?? ""
                            
                            foundComments.append(review)
                            foundLikes.append(0)
                            foundDates.append(ZeroDate)
                            foundSource.append(sourceMovieDB)
                        }
                        
                        ended = true
                    }
                    else
                    {
                        print("TheMoviedb::getReviews failed for \(movieDBid)")
                        ended = true
                    }
                } catch let error as NSError { print("TheMoviedb::getReviews failed for \(movieDBid) : \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< TheMoviedb : getReviews >> Return : foundComments=\(foundComments), foundLikes=\(foundLikes), foundDates=\(foundDates), foundSource=\(foundSource)", logLevel : logFuncReturn, scope : scopeSource)
        return (foundComments, foundLikes, foundDates, foundSource)
    }
}

