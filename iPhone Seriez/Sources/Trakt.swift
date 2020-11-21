//
//  Trakt.swift
//  Seriez
//
//  Created by Cyril Delamare on 18/09/2016.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation
import SeriesCommon

class Trakt : NSObject {
    var chrono : TimeInterval = 0

    let TraktURL : String = "https://api.trakt.tv/oauth/token"
    let TraktClientID : String = "44e9b9a92278adc49099f599d6b2a5be19b63e4812dbb7b335b459f8d0eb195c"
    let TraktClientSecret : String = "b085eac8d1ada5758f4edaa36290c06e131d33f0ce5c8aeb1f81e802b3818bd2"
    var Token : String = ""
    var RefreshToken : String = ""
    var TokenExpiration : Date!
    
    override init() {
        super.init()
    }
    
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()

        var request = URLRequest(url: URL(string: reqAPI)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("Trakt::error \(response.statusCode) received for req=\(reqAPI) "); ended = true; return; }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("Trakt::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
            } else { print(error as Any); ended = true; }
        }
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func postAPI(reqAPI: String, body: String) -> Bool {
        let startChrono : Date = Date()
        var success : Bool = false
        var request = URLRequest(url: URL(string: reqAPI)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        request.httpBody = body.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response as? HTTPURLResponse {
                if ( (response.statusCode == 200) || (response.statusCode == 201) || (response.statusCode == 204) ){
                    success = true
                    return
                }
                else {
                    print("Trakt::post error \(response.statusCode) received for \(reqAPI) with body = \(body)")
                    success = false
                    return
                }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return success
    }
    
    
    func start() {
        let defaults = UserDefaults.standard
        
        if ((defaults.object(forKey: "TraktToken")) != nil) {
            self.Token = defaults.string(forKey: "TraktToken")!
            self.RefreshToken = defaults.string(forKey: "TraktRefreshToken")!
            let expiration: Double = defaults.double(forKey: "TraktTokenExpiration")
            self.TokenExpiration = Date.init(timeIntervalSince1970: (expiration))
            
            // On refresh le token s'il expire dans moins de 2 mois
            if (self.TokenExpiration.timeIntervalSinceNow < 5000000) {
                self.refreshToken(self.RefreshToken)
            }
        }
        else {
            webAutenth()
//            self.downloadToken(key: "1DCAC123")
        }
    }
    
    
    func webAutenth() {
        let path : String = "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(TraktClientID)&redirect_uri=UneSerie://Trakt"
        let url : URL = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        UIApplication.shared.open(url)
    }
    
    
    func downloadToken(key : String) {
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/oauth/token")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{  \"code\": \"\(key)\",  \"client_id\": \"\(TraktClientID)\",  \"client_secret\": \"\(TraktClientSecret)\",  \"redirect_uri\": \"UneSerie://Trakt\",  \"grant_type\": \"authorization_code\"}".data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Trakt::downloadToken error \(response.statusCode) received "); return; }
                let defaults = UserDefaults.standard
                
                do {
                    let jsonToken : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "TraktToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as? String ?? ""
                    defaults.set(self.RefreshToken, forKey: "TraktRefreshToken")
                    
                    let create: Double = jsonToken.object(forKey: "created_at") as! Double
                    let expire: Double = jsonToken.object(forKey: "expires_in") as! Double
                    self.TokenExpiration = Date.init(timeIntervalSince1970: (create+expire))
                    defaults.set(create+expire, forKey: "TraktTokenExpiration")
                    
                } catch let error as NSError { print("Trakt::downloadToken failed: \(error.localizedDescription)") }
                
            } else { print("Trakt::downloadToken failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
    
    
    func refreshToken (_ refresher: String) {
        let url = URL(string: self.TraktURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\n  \"refresh_token\": \"\(refresher)\",\n  \"client_id\": \"\(self.TraktClientID)\",\n  \"client_secret\": \"\(self.TraktClientSecret)\",\n  \"redirect_uri\": \"urn:ietf:wg:oauth:2.0:oob\",\n  \"grant_type\": \"refresh_token\"\n}".data(using: String.Encoding.utf8);
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                if (response.statusCode != 200) { print("Trakt::getToken error \(response.statusCode) received "); return; }
                let defaults = UserDefaults.standard
                
                do {
                    let jsonToken : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "TraktToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as? String ?? ""
                    defaults.set(self.RefreshToken, forKey: "TraktRefreshToken")
                    
                    let create: Double = jsonToken.object(forKey: "created_at") as! Double
                    let expire: Double = jsonToken.object(forKey: "expires_in") as! Double
                    self.TokenExpiration = Date.init(timeIntervalSince1970: (create+expire))
                    defaults.set(create+expire, forKey: "TraktTokenExpiration")
                    
                } catch let error as NSError { print("Trakt::refreshToken failed: \(error.localizedDescription)") }
                
            } else {
                print("Trakt::refreshToken failed: \(error!.localizedDescription)")
            }
        })
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }

    
    func getIDs(serie: Serie) -> Bool {
        let uneSerie : Serie = Serie(serie: "")
        var request : String = ""
        var found : Bool = false
        
        if (serie.idIMdb != "") { request = "https://api.trakt.tv/shows/\(serie.idIMdb)" }
        else                    { request = "https://api.trakt.tv/shows/\(serie.slug())" }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: request) as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "ids") != nil) {
            found = true
            uneSerie.idIMdb = (reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            uneSerie.idTVdb = String((reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
            uneSerie.idTrakt = String((reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
            uneSerie.idMoviedb = String((reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
        }

        return found
    }
    
    
    func recherche(serieArechercher : String, aChercherDans : String) -> [Serie] {
        var serieListe : [Serie] = []
        
        if (aChercherDans == "") { return serieListe }
        
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/search/show?fields=\(aChercherDans)&query=\(serieArechercher.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)") as! NSArray
        
        for fiche in reqResult {
            let newSerie : Serie = Serie(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
            newSerie.year = ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "year") as? Int ?? 0
            newSerie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            newSerie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
            newSerie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
            newSerie.idMoviedb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
            newSerie.watchlist = true
            
            serieListe.append(newSerie)
        }
        
        return serieListe
    }
    
    
    func rechercheParTitre(serieArechercher : String) -> [Serie] {
        var serieListe : [Serie] = []

        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/search/show?extended=full,fields=title,translations&query=\(serieArechercher.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)") as! NSArray
        
        for fiche in reqResult {
            let oneShow : AnyObject = ((fiche as AnyObject).object(forKey: "show")! as AnyObject)
            let newSerie : Serie = Serie(serie: oneShow.object(forKey: "title") as! String)
            
            newSerie.year = oneShow.object(forKey: "year") as? Int ?? 0
            newSerie.idIMdb = (oneShow.object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            newSerie.idTVdb = String((oneShow.object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
            newSerie.idTrakt = String((oneShow.object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
            newSerie.idMoviedb = String((oneShow.object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
            newSerie.network = oneShow.object(forKey: "network") as? String ?? ""
            newSerie.status = oneShow.object(forKey: "status") as? String ?? ""
            newSerie.resume = oneShow.object(forKey: "overview") as? String ?? ""
            newSerie.genres = oneShow.object(forKey: "genres") as? [String] ?? []
            newSerie.ratingTrakt = Int(10 * (oneShow.object(forKey: "rating") as? Double ?? 0.0))
            newSerie.ratersTrakt = oneShow.object(forKey: "votes") as? Int ?? 0
            newSerie.country = (oneShow.object(forKey: "country") as? String ?? "").uppercased()
            newSerie.language = oneShow.object(forKey: "language") as? String ?? ""
            newSerie.runtime = oneShow.object(forKey: "runtime") as? Int ?? 0
            newSerie.homepage = oneShow.object(forKey: "homepage") as? String ?? ""
            newSerie.nbEpisodes = oneShow.object(forKey: "aired_episodes") as? Int ?? 0
            newSerie.certification = oneShow.object(forKey: "certification") as? String ?? ""
            newSerie.watchlist = true
            
            serieListe.append(newSerie)
        }
        
        return serieListe
    }
    
    
    func addToHistory(tvdbID : Int) -> Bool {
        return postAPI(reqAPI: "https://api.trakt.tv/sync/history", body: "{ \"episodes\": [ { \"ids\": { \"tvdb\": \(tvdbID) } } ]}")
    }
    
    
    func addToWatchlist(theTVdbId : String) -> Bool {
        return postAPI(reqAPI: "https://api.trakt.tv/sync/watchlist", body: "{ \"shows\": [ { \"ids\": { \"tvdb\": \(theTVdbId) } } ]}")
    }
    
    
    func removeFromWatchlist(theTVdbId : String) -> Bool {
        return  postAPI(reqAPI: "https://api.trakt.tv/sync/watchlist/remove", body: "{ \"shows\": [ { \"ids\": { \"tvdb\": \(theTVdbId) } } ]}")
    }
    
    
    func addToAbandon(theTVdbId : String) -> Bool {
        return postAPI(reqAPI: "https://api.trakt.tv/users/gonecd/lists/Abandon/items", body: "{ \"shows\": [ { \"ids\": { \"tvdb\": \(theTVdbId) } } ]}")
    }
    
    
    func removeFromAbandon(theTVdbId : String) -> Bool {
        return  postAPI(reqAPI: "https://api.trakt.tv/users/gonecd/lists/Abandon/items/remove", body: "{ \"shows\": [ { \"ids\": { \"tvdb\": \(theTVdbId) } } ]}")
    }
    
    
    func getWatchlist() -> [Serie] {
        var returnSeries: [Serie] = [Serie]()
        var serie: Serie = Serie(serie: "")
        
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/users/gonecd/watchlist/shows") as! NSArray
        
        for fiche in reqResult {
            serie = Serie.init(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
            serie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            serie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
            serie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
            serie.idMoviedb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
            serie.watchlist = true

            returnSeries.append(serie)
        }
        
        return returnSeries
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let today : Date = Date()
        
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/shows/\(uneSerie.idTrakt)/seasons?extended=episodes,full") as! NSArray
        
        for uneSaison in reqResult {
            if (((uneSaison as AnyObject).object(forKey: "number") as? Int ?? 0) == 0) { continue }
            
            for unEpisode in (uneSaison as AnyObject).object(forKey: "episodes") as! NSArray {
                let saisonNum : Int = (unEpisode as AnyObject).object(forKey: "season") as? Int ?? -1
                let episodeNum : Int = (unEpisode as AnyObject).object(forKey: "number") as? Int ?? -1

                if ( (saisonNum > 0) && (saisonNum <= uneSerie.saisons.count) ) {
                    if ( (episodeNum > 0) && (episodeNum <= uneSerie.saisons[saisonNum-1].episodes.count) ) {
                        if ( (uneSerie.saisons[saisonNum-1].episodes[episodeNum-1].date.compare(today) == .orderedAscending) && (uneSerie.saisons[saisonNum-1].episodes[episodeNum-1].date.compare(ZeroDate) != .orderedSame) ) {
                            uneSerie.saisons[saisonNum-1].episodes[episodeNum-1].ratingTrakt = Int(10 * ((unEpisode as AnyObject).object(forKey: "rating") as? Double ?? 0.0))
                            uneSerie.saisons[saisonNum-1].episodes[episodeNum-1].ratersTrakt = (unEpisode as AnyObject).object(forKey: "votes") as? Int ?? -1
                        }
                    }
                }
            }
        }
    }
    
    
    func getStopped() -> [Serie] {
        var returnSeries: [Serie] = [Serie]()
        var serie: Serie = Serie(serie: "")

        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/users/gonecd/lists/Abandon/items/shows") as! NSArray
        
        for fiche in reqResult {
            serie = Serie.init(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
            serie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            serie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
            serie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
            serie.idMoviedb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
            serie.unfollowed = true
            
            returnSeries.append(serie)
        }
        
        return returnSeries
    }
    
    
    func getWatched() -> [Serie] {
        var returnSeries: [Serie] = [Serie]()
        var serie: Serie = Serie(serie: "")

        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/sync/watched/shows") as! NSArray
        
        for fiche in reqResult {
            serie = Serie.init(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
            serie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            serie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
            serie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
            serie.idMoviedb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
            
            for fichesaisons in (fiche as AnyObject).object(forKey: "seasons") as! NSArray {
                let uneSaison : Saison = Saison(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String,
                                                saison: (fichesaisons as AnyObject).object(forKey: "number") as! Int)
                uneSaison.nbWatchedEps = ((fichesaisons as AnyObject).object(forKey: "episodes") as! NSArray).count
                
                serie.saisons.append(uneSaison)
            }
            
            returnSeries.append(serie)
        }
        
        return returnSeries
    }
    
    
    func getSerieGlobalInfos(idTraktOrIMDB : String) -> Serie {
        let uneSerie : Serie = Serie(serie: "")
        
        if (idTraktOrIMDB == "") { return uneSerie }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.trakt.tv/shows/\(idTraktOrIMDB)?extended=full") as! NSDictionary

        uneSerie.serie = reqResult.object(forKey: "title") as? String ?? ""
        uneSerie.idIMdb = (reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
        uneSerie.idTVdb = String((reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
        uneSerie.idTrakt = String((reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
        uneSerie.idMoviedb = String((reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
        uneSerie.network = reqResult.object(forKey: "network") as? String ?? ""
        uneSerie.status = reqResult.object(forKey: "status") as? String ?? ""
        uneSerie.resume = reqResult.object(forKey: "overview") as? String ?? ""
        uneSerie.genres = reqResult.object(forKey: "genres") as? [String] ?? []
        uneSerie.year = reqResult.object(forKey: "year") as? Int ?? 0
        uneSerie.ratingTrakt = Int(10 * (reqResult.object(forKey: "rating") as? Double ?? 0.0))
        uneSerie.ratersTrakt = reqResult.object(forKey: "votes") as? Int ?? 0
        uneSerie.country = (reqResult.object(forKey: "country") as? String ?? "").uppercased()
        uneSerie.language = reqResult.object(forKey: "language") as? String ?? ""
        uneSerie.runtime = reqResult.object(forKey: "runtime") as? Int ?? 0
        uneSerie.homepage = reqResult.object(forKey: "homepage") as? String ?? ""
        uneSerie.nbEpisodes = reqResult.object(forKey: "aired_episodes") as? Int ?? 0
        uneSerie.certification = reqResult.object(forKey: "certification") as? String ?? ""

        return uneSerie
    }
    
       
    func getEpisodes(uneSerie : Serie) {
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/shows/\(uneSerie.idTrakt)/seasons?extended=episodes") as! NSArray
        
        for uneSaison in reqResult {
            let saisonNum : Int = ((uneSaison as! NSDictionary).object(forKey: "number")) as? Int ?? 0
            
            if (saisonNum != 0) {
                var ficheSaison : Saison
                
                // Création de la structure de saison ou récupération de la saison existente
                if (saisonNum > uneSerie.saisons.count) {
                    ficheSaison = Saison(serie: uneSerie.serie, saison: saisonNum)
                    uneSerie.saisons.append(ficheSaison)
                }
                else {
                    ficheSaison = uneSerie.saisons[saisonNum-1]
                }
                
                // On parse les épisodes
                for unEpisode in ((uneSaison as! NSDictionary).object(forKey: "episodes")) as! NSArray {
                    let episodeNum : Int = ((unEpisode as! NSDictionary).object(forKey: "number")) as? Int ?? 0
                    
                    if (episodeNum != 0) {
                        var ficheEpisode : Episode
                        
                        // Création de la structure de épisode ou récupération de l'épisode existent
                        if (episodeNum > ficheSaison.episodes.count) {
                            ficheEpisode = Episode(serie: uneSerie.serie, fichier: "", saison: saisonNum, episode: episodeNum)
                            ficheSaison.episodes.append(ficheEpisode)
                        }
                        else {
                            ficheEpisode = ficheSaison.episodes[episodeNum-1]
                        }
                        
                        // Récupération des données dans le message
                        ficheEpisode.titre = (unEpisode as! NSDictionary).object(forKey: "title")! as? String ?? ""
                        ficheEpisode.idIMdb = ((unEpisode as! NSDictionary).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
                        ficheEpisode.idTVdb = ((unEpisode as! NSDictionary).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0
                    }
                }

                // On update les compteurs de la saison
                ficheSaison.nbEpisodes = ficheSaison.episodes.count
            }
 
            
        }
    }
    
    func getSimilarShows(IMDBid : String) -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/shows/\(IMDBid)/related") as! NSArray

        for oneShow in reqResult {
            let titre : String = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
            let idIMDB : String =  ((oneShow as! NSDictionary).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            
            if (compteur < similarShowsPerSource) {
                compteur = compteur + 1
                showNames.append(titre)
                showIds.append(idIMDB)
            }
        }
        
        return (showNames, showIds)
    }
    
    
    func getPopularShows() -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/shows/popular") as! NSArray

        for oneShow in reqResult {
            let titre : String = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
            let idIMDB : String =  ((oneShow as! NSDictionary).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            
            if (compteur < popularShowsPerSource) {
                compteur = compteur + 1
                showNames.append(titre)
                showIds.append(idIMDB)
            }
        }
        
        return (showNames, showIds)
    }
    
    
    func getTrendingShows() -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/shows/trending") as! NSArray

        for oneShow in reqResult {
            let titre : String = (((oneShow as! NSDictionary).object(forKey: "show") as! NSDictionary).object(forKey: "title")) as? String ?? ""
            let idIMDB : String =  (((oneShow as! NSDictionary).object(forKey: "show") as! NSDictionary).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
            
            if (compteur < popularShowsPerSource) {
                compteur = compteur + 1
                showNames.append(titre)
                showIds.append(idIMDB)
            }
        }
        
        return (showNames, showIds)
    }
    
    
    func getComments(IMDBid : String, season : Int, episode : Int) -> [Critique] {
        var stringURL : String = ""
        var result : [Critique] = []
        
        if (episode == 0) {
            if (season == 0) { stringURL = "https://api.trakt.tv/shows/\(IMDBid)/comments/likes" }
            else { stringURL = "https://api.trakt.tv/shows/\(IMDBid)/seasons/\(season)/comments/likes" }
        } else { stringURL = "https://api.trakt.tv/shows/\(IMDBid)/seasons/\(season)/episodes/\(episode)/comments/likes" }
        
        let reqResult : NSArray = loadAPI(reqAPI: stringURL) as! NSArray
        
        for oneComment in reqResult {
            let uneCritique : Critique = Critique()
            
            uneCritique.source = srcTrakt
            uneCritique.texte = ((oneComment as! NSDictionary).object(forKey: "comment")) as? String ?? ""
            uneCritique.date = ((oneComment as! NSDictionary).object(forKey: "created_at")) as? String ?? ""
            //uneCritique.hasSpoiler = ((oneComment as! NSDictionary).object(forKey: "spoiler")) as? Bool ?? false
            //uneCritique.isReview = ((oneComment as! NSDictionary).object(forKey: "review")) as? Bool ?? false
            //uneCritique.nbLikes = ((oneComment as! NSDictionary).object(forKey: "likes")) as? Int ?? 0
            
            result.append(uneCritique)
        }
        
        return result
    }
    
    func getMyRatings() -> [String:Int] {
        var results : Dictionary = [String:Int]()

        var show : String = ""
        var rate : Int = 0
        
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.trakt.tv/sync/ratings/shows") as! NSArray

        for oneShow in reqResult {
            rate = ((oneShow as! NSDictionary).object(forKey: "rating")) as? Int ?? 0
            show = (((oneShow as! NSDictionary).object(forKey: "show") as! NSDictionary).object(forKey: "title")) as? String ?? ""

            results[show] = rate
        }
        
        return results
    }


    func setMyRating(tvdbID: String, rating: Int) -> Bool {
        return postAPI(reqAPI: "https://api.trakt.tv/sync/ratings", body: "{ \"shows\": [ { \"rating\": \(rating), \"ids\": { \"tvdb\": \(tvdbID) } } ]}")
    }

}
