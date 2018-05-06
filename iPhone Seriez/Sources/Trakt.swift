//
//  Trakt.swift
//  Seriez
//
//  Created by Cyril Delamare on 18/09/2016.
//  Copyright © 2016 Home. All rights reserved.
//

import Foundation

class Trakt : NSObject
{
    let TraktURL : String = "https://api.trakt.tv/oauth/token"
    let TraktClientID : String = "44e9b9a92278adc49099f599d6b2a5be19b63e4812dbb7b335b459f8d0eb195c"
    let TraktClientSecret : String = "b085eac8d1ada5758f4edaa36290c06e131d33f0ce5c8aeb1f81e802b3818bd2"
    var Token : String = ""
    var RefreshToken : String = ""
    var TokenExpiration : Date!
    
    override init()
    {
        trace(texte : "<< Trakt : init >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : init >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        super.init()
        
        trace(texte : "<< Trakt : init >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    
    func start() -> Bool
    {
        trace(texte : "<< Trakt : start >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : start >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        let defaults = UserDefaults.standard
        
        if ((defaults.object(forKey: "TraktToken")) != nil) {
            self.Token = defaults.string(forKey: "TraktToken")!
            self.RefreshToken = defaults.string(forKey: "TraktRefreshToken")!
            let expiration: Double = defaults.double(forKey: "TraktTokenExpiration")
            self.TokenExpiration = Date.init(timeIntervalSince1970: (expiration))
            
            // On refresh le token s'il expire dans moins de 2 mois
            if (self.TokenExpiration.timeIntervalSinceNow < 5000000)
            {
                self.refreshToken(self.RefreshToken)
            }
            
            trace(texte : "<< Trakt : start >> Return : true", logLevel : logFuncReturn, scope : scopeSource)
            return true
        }
        else
        {
            self.downloadToken(key: "61B43659")
            
            trace(texte : "<< Trakt : start >> Return : false", logLevel : logFuncReturn, scope : scopeSource)
            return false
        }
    }
    
    
    func downloadToken(key : String)
    {
        trace(texte : "<< Trakt : downloadToken >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : downloadToken >> Params : key = \(key)", logLevel : logFuncParams, scope : scopeSource)
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/oauth/token")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{  \"code\": \"\(key)\",  \"client_id\": \"\(self.TraktClientID)\",  \"client_secret\": \"\(self.TraktClientSecret)\",  \"redirect_uri\": \"urn:ietf:wg:oauth:2.0:oob\",  \"grant_type\": \"authorization_code\"}".data(using: String.Encoding.utf8);
        
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
        
        trace(texte : "<< Trakt : downloadToken >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    
    func refreshToken (_ refresher: String)
    {
        trace(texte : "<< Trakt : refreshToken >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : refreshToken >> Params : refresher = \(refresher)", logLevel : logFuncParams, scope : scopeSource)
        
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
        
        trace(texte : "<< Trakt : refreshToken >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    
    
    
    func recherche(serieArechercher : String) -> [Serie]
    {
        trace(texte : "<< Trakt : recherche >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : recherche >> Params : serieArechercher = \(serieArechercher)", logLevel : logFuncParams, scope : scopeSource)
        
        var serieListe : [Serie] = []
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/search/show?fields=title&query=\(serieArechercher.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)")!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    
                    if (response.statusCode != 200) { print("Trakt::recherche error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for fiche in jsonResponse {
                        
                        let newSerie : Serie = Serie(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
                        
                        newSerie.year = ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "year") as? Int ?? 0
                        newSerie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
                        newSerie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
                        newSerie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
                        newSerie.idMoviedb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
                        newSerie.watchlist = true
                        
                        serieListe.append(newSerie)
                    }
                } catch let error as NSError { print("Trakt::recherche failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
        
        trace(texte : "<< Trakt : recherche >> Return : serieListe = \(serieListe)", logLevel : logFuncReturn, scope : scopeSource)
        return serieListe
    }
    
    
    func addToWatchlist(theTVdbId : String) -> Bool
    {
        trace(texte : "<< Trakt : addToWatchlist >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : addToWatchlist >> Params : theTVdbId = \(theTVdbId)", logLevel : logFuncParams, scope : scopeSource)
        
        var success : Bool = false
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/sync/watchlist")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        request.httpBody = "{ \"shows\": [ { \"ids\": { \"tvdb\": \(theTVdbId) } } ]}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response as? HTTPURLResponse {
                if (response.statusCode == 201)
                {
                    success = true
                    return
                }
                else
                {
                    print("Trakt::addToWatchlist error \(response.statusCode) received ")
                    success =  false
                    return
                }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        trace(texte : "<< Trakt : addToWatchlist >> Return : success = \(success)", logLevel : logFuncReturn, scope : scopeSource)
        return success
    }
    
    
    func removeFromWatchlist(theTVdbId : String) -> Bool
    {
        trace(texte : "<< Trakt : removeFromWatchlist >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : removeFromWatchlist >> Params : theTVdbId = \(theTVdbId)", logLevel : logFuncParams, scope : scopeSource)
        
       var success : Bool = false
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/sync/watchlist/remove")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        request.httpBody = "{ \"shows\": [ { \"ids\": { \"tvdb\": \(theTVdbId) } } ]}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response as? HTTPURLResponse {
                if (response.statusCode == 200)
                {
                    success = true
                    return
                }
                else
                {
                    print("Trakt::recherche error \(response.statusCode) received ")
                    success =  false
                    return
                }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        trace(texte : "<< Trakt : removeFromWatchlist >> Return : success = \(success)", logLevel : logFuncReturn, scope : scopeSource)
        return success
    }
    
    
    func getWatchlist() -> [Serie]
    {
        trace(texte : "<< Trakt : getWatchlist >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getWatchlist >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/users/gonecd/watchlist/shows")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        var returnSeries: [Serie] = [Serie]()
        var serie: Serie = Serie(serie: "")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    
                    if (response.statusCode != 200) { print("Trakt::getWatchlist error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for fiche in jsonResponse {
                        serie = Serie.init(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
                        serie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as! String
                        serie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as! Int)
                        serie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as! Int)
                        serie.idMoviedb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
                        serie.watchlist = true
                        
                        returnSeries.append(serie)
                    }
                } catch let error as NSError { print("Trakt::getWatchlist failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
        
        trace(texte : "<< Trakt : getWatchlist >> Return : returnSeries = \(returnSeries)", logLevel : logFuncReturn, scope : scopeSource)
        return returnSeries
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie)
    {
        trace(texte : "<< Trakt : getEpisodesRatings >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getEpisodesRatings >> Params : uneSerie = \(uneSerie)", logLevel : logFuncParams, scope : scopeSource)

        let today : Date = Date()
        
        for uneSaison in uneSerie.saisons
        {
            var tableauDeTaches: [URLSessionTask] = []
            var globalStatus: URLSessionTask.State = URLSessionTask.State.running
            
            for unEpisode in uneSaison.episodes
            {
                if (unEpisode.date.compare(today) == .orderedAscending)
                {
                    var request = URLRequest(url: URL(string: "https://api.trakt.tv/shows/\(uneSerie.idTrakt)/seasons/\(uneSaison.saison)/episodes/\(unEpisode.episode)/ratings")!)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
                    request.addValue("2", forHTTPHeaderField: "trakt-api-version")
                    request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
                    
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        if let data = data, let response = response as? HTTPURLResponse {
                            
                            if (response.statusCode != 200) { print("Trakt::getSerieInfos error \(response.statusCode) received for \(uneSerie.serie) s\(uneSaison.saison) e\(unEpisode.episode)"); return; }
                            
                            do {
                                let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                
                                var totRating : Int = 0
                                var totRaters : Int = 0
                                
                                for i:Int in 1..<11
                                {
                                    totRating = totRating + ( ((jsonResponse.object(forKey: "distribution")! as AnyObject).object(forKey: String(i)) as? Int ?? 0) * i )
                                    totRaters = totRaters + ((jsonResponse.object(forKey: "distribution")! as AnyObject).object(forKey: String(i)) as? Int ?? 0)
                                }
                                
                                if (totRaters > 0)
                                {
                                    unEpisode.ratersTrakt = totRaters
                                    unEpisode.ratingTrakt = Int(10 * Double(totRating) / Double(totRaters))
                                }
                                
                            } catch let error as NSError { print("Trakt::getSerieInfos failed for \(uneSerie.serie) s\(uneSaison.saison) e\(unEpisode.episode): \(error.localizedDescription)") }
                        } else {
                            print(error as Any)
                        }
                    })
                    
                    tableauDeTaches.append(task)
                    
                    task.resume()
                }
            }
            
            while (globalStatus == URLSessionTask.State.running)
            {
                globalStatus = URLSessionTask.State.completed
                
                for uneTache in tableauDeTaches
                {
                    if (uneTache.state == URLSessionTask.State.running) { globalStatus = URLSessionTask.State.running }
                }
                
                usleep(1000)
            }
        }
        trace(texte : "<< Trakt : getEpisodesRatings >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    func getStopped() -> [Serie]
    {
        trace(texte : "<< Trakt : getStopped >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getStopped >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/users/gonecd/lists/Abandon/items/shows")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        var returnSeries: [Serie] = [Serie]()
        var serie: Serie = Serie(serie: "")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    
                    if (response.statusCode != 200) { print("Trakt::getStopped error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for fiche in jsonResponse {
                        serie = Serie.init(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
                        serie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as! String
                        serie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as! Int)
                        serie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as! Int)
                        serie.idMoviedb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
                        serie.unfollowed = true
                        
                        returnSeries.append(serie)
                    }
                } catch let error as NSError { print("Trakt::getStopped failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
 
        trace(texte : "<< Trakt : getStopped >> Return : returnSeries = \(returnSeries)", logLevel : logFuncReturn, scope : scopeSource)
        return returnSeries
    }
    
    
    func getWatched() -> [Serie]
    {
        trace(texte : "<< Trakt : getWatched >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getWatched >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/sync/watched/shows")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        var returnSeries: [Serie] = [Serie]()
        var serie: Serie = Serie(serie: "")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for fiche in jsonResponse {
                        
                        serie = Serie.init(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
                        serie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as! String
                        serie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as! Int)
                        serie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as! Int)
                        serie.idMoviedb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
                        
                        for fichesaisons in (fiche as AnyObject).object(forKey: "seasons") as! NSArray
                        {
                            let uneSaison : Saison = Saison(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String,
                                                            saison: (fichesaisons as AnyObject).object(forKey: "number") as! Int)
                            uneSaison.watched = true
                            uneSaison.nbEpisodes = ((fichesaisons as AnyObject).object(forKey: "episodes") as! NSArray).count
                            
                            serie.saisons.append(uneSaison)
                        }
                        returnSeries.append(serie)
                    }
                } catch let error as NSError { print("Trakt::getWatched failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        }
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
 
        trace(texte : "<< Trakt : getWatched >> Return : returnSeries = \(returnSeries)", logLevel : logFuncReturn, scope : scopeSource)
        return returnSeries
    }
    

    func getSerieGlobalInfos(idTraktOrIMDB : String) -> Serie
    {
        trace(texte : "<< Trakt : getSerieGlobalInfos >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getSerieGlobalInfos >> Params : idTraktOrIMDB = \(idTraktOrIMDB)", logLevel : logFuncParams, scope : scopeSource)
        
        let uneSerie : Serie = Serie(serie: "")
        var request : URLRequest
        
        if (idTraktOrIMDB != "")  { request = URLRequest(url: URL(string: "https://api.trakt.tv/shows/\(idTraktOrIMDB)?extended=full")!) }
        else                      { return uneSerie }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("Trakt::getSerieGlobalInfos error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    uneSerie.serie = jsonResponse.object(forKey: "title") as? String ?? ""
                    uneSerie.idIMdb = (jsonResponse.object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
                    uneSerie.idTVdb = String((jsonResponse.object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? Int ?? 0)
                    uneSerie.idTrakt = String((jsonResponse.object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as? Int ?? 0)
                    uneSerie.idMoviedb = String((jsonResponse.object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? Int ?? 0)
                    uneSerie.network = jsonResponse.object(forKey: "network") as? String ?? ""
                    uneSerie.status = jsonResponse.object(forKey: "status") as? String ?? ""
                    uneSerie.resume = jsonResponse.object(forKey: "overview") as? String ?? ""
                    uneSerie.genres = jsonResponse.object(forKey: "genres") as? [String] ?? []
                    uneSerie.year = jsonResponse.object(forKey: "year") as? Int ?? 0
                    uneSerie.ratingTrakt = Int(10 * (jsonResponse.object(forKey: "rating") as? Double ?? 0.0))
                    uneSerie.ratersTrakt = jsonResponse.object(forKey: "votes") as? Int ?? 0
                    uneSerie.country = (jsonResponse.object(forKey: "country") as? String ?? "").uppercased()
                    uneSerie.language = jsonResponse.object(forKey: "language") as? String ?? ""
                    uneSerie.runtime = jsonResponse.object(forKey: "runtime") as? Int ?? 0
                    uneSerie.homepage = jsonResponse.object(forKey: "homepage") as? String ?? ""
                    uneSerie.nbEpisodes = jsonResponse.object(forKey: "aired_episodes") as? Int ?? 0
                    uneSerie.certification = jsonResponse.object(forKey: "certification") as? String ?? ""
                    
                } catch let error as NSError { print("Trakt::getSerieGlobalInfos failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        trace(texte : "<< Trakt : getSerieGlobalInfos >> Return : uneSerie = \(uneSerie)", logLevel : logFuncReturn, scope : scopeSource)
        return uneSerie
    }
    
    func getSaisons(uneSerie : Serie)
    {
        trace(texte : "<< Trakt : getSaisons >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getSaisons >> Params : uneSerie = \(uneSerie)", logLevel : logFuncParams, scope : scopeSource)
        
       let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/shows/\(uneSerie.idTrakt)/seasons?extended=full")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("Trakt::getSaisons for \(uneSerie) : error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for uneSaison in jsonResponse
                    {
                        let saisonNum : Int = ((uneSaison as! NSDictionary).object(forKey: "number")) as? Int ?? 0
                        
                        if (saisonNum != 0)
                        {
                            if (saisonNum <= uneSerie.saisons.count)
                            {
                                let nbEps : Int = ((uneSaison as! NSDictionary).object(forKey: "episode_count")) as? Int ?? 0
                                if ( (uneSerie.saisons[saisonNum - 1].nbEpisodes < nbEps) && (uneSerie.serie != "Salem") && (uneSerie.serie != "Penny Dreadful") && (uneSerie.serie != "Seinfeld"))
                                {
                                    uneSerie.saisons[saisonNum - 1].nbEpisodes = nbEps
                                    uneSerie.saisons[saisonNum - 1].watched = false
                                }
                                
                                let stringDate : String = ((uneSaison as! NSDictionary).object(forKey: "first_aired")) as? String ?? ""
                                if (stringDate !=  "") { uneSerie.saisons[saisonNum - 1].starts = dateFormatter.date(from: stringDate)! }
                            }
                            else
                            {
                                let ficheSaison : Saison = Saison(serie: uneSerie.serie, saison: saisonNum)
                                ficheSaison.nbEpisodes = ((uneSaison as! NSDictionary).object(forKey: "episode_count")) as? Int ?? 0
                                let stringDate : String = ((uneSaison as! NSDictionary).object(forKey: "first_aired")) as? String ?? ""
                                if (stringDate !=  "") { ficheSaison.starts = dateFormatter.date(from: stringDate)! }
                                
                                uneSerie.saisons.append(ficheSaison)
                            }
                        }
                    }
                } catch let error as NSError { print("Trakt::getSaisons failed for \(uneSerie): \(error.localizedDescription)") }
            } else { print(error as Any) }
        }
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }

        trace(texte : "<< Trakt : getSaisons >> Return : No Return", logLevel : logFuncReturn, scope : scopeSource)
    }
    
    
    func getLastEpisodeDate(traktID : String, saison : Int, episode : Int) -> Date
    {
        trace(texte : "<< Trakt : getLastEpisodeDate >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getLastEpisodeDate >> Params : traktID = \(traktID), saison = \(saison), episode = \(episode)", logLevel : logFuncParams, scope : scopeSource)
        
        var diffDate : Date = ZeroDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/shows/\(traktID)/seasons/\(saison)/episodes/\(episode)?extended=full")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("Trakt::getLastEpisodeDate for \(traktID) \(saison) \(episode) : error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    let stringDate : String = (jsonResponse.object(forKey: "first_aired")) as? String ?? ""
                    if (stringDate !=  "") { diffDate = dateFormatter.date(from: stringDate)! }
                    
                    
                } catch let error as NSError { print("Trakt::getLastEpisodeDate failed for \(traktID) \(saison) \(episode): \(error.localizedDescription)") }
            } else { print(error as Any) }
        }
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        trace(texte : "<< Trakt : getSerieGlobalInfos >> Return : getLastEpisodeDate = \(diffDate)", logLevel : logFuncReturn, scope : scopeSource)
        return diffDate
    }
    
    func getSimilarShows(IMDBid : String) -> (names : [String], ids : [String])
    {
        trace(texte : "<< Trakt : getSimilarShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getSimilarShows >> Params : IMDBid = \(IMDBid)", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false
        var compteur : Int = 0
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/shows/\(IMDBid)/related")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("Trakt::getSimilarShows for \(IMDBid) : error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for oneShow in jsonResponse
                    {
                        let titre : String = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
                        let idIMDB : String =  ((oneShow as! NSDictionary).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
                        
                        if (compteur < similarShowsPerSource)
                        {
                            compteur = compteur + 1
                            showNames.append(titre)
                            showIds.append(idIMDB)
                        }
                    }
                    
                    ended = true
                    
                } catch let error as NSError { print("Trakt::getSimilarShows failed for \(IMDBid) : \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        }
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< Trakt : getSerieGlobalInfos >> Return : showNames = \(showNames), showIds = \(showIds)", logLevel : logFuncReturn, scope : scopeSource)
        return (showNames, showIds)
    }
    
    func getPopularShows() -> (names : [String], ids : [String])
    {
        trace(texte : "<< Trakt : getPopularShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getPopularShows >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false
        var compteur : Int = 0
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/shows/popular")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("Trakt::getPopularShows : error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for oneShow in jsonResponse
                    {
                        let titre : String = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
                        let idIMDB : String =  ((oneShow as! NSDictionary).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
                        
                        if (compteur < popularShowsPerSource)
                        {
                            compteur = compteur + 1
                            showNames.append(titre)
                            showIds.append(idIMDB)
                        }
                    }
                    
                    ended = true
                    
                } catch let error as NSError { print("Trakt::getPopularShows : \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        }
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< Trakt : getPopularShows >> Return : showNames = \(showNames), showIds = \(showIds)", logLevel : logFuncReturn, scope : scopeSource)
       return (showNames, showIds)
    }
    
    func getTrendingShows() -> (names : [String], ids : [String])
    {
        trace(texte : "<< Trakt : getTrendingShows >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getTrendingShows >> Params : No Params", logLevel : logFuncParams, scope : scopeSource)
        
        var showNames : [String] = []
        var showIds : [String] = []
        var ended : Bool = false
        var compteur : Int = 0
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/shows/trending")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("Trakt::getTrendingShows : error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for oneShow in jsonResponse
                    {
                        let titre : String = (((oneShow as! NSDictionary).object(forKey: "show") as! NSDictionary).object(forKey: "title")) as? String ?? ""
                        let idIMDB : String =  (((oneShow as! NSDictionary).object(forKey: "show") as! NSDictionary).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
                        
                        if (compteur < popularShowsPerSource)
                        {
                            compteur = compteur + 1
                            showNames.append(titre)
                            showIds.append(idIMDB)
                        }
                    }
                    
                    ended = true
                    
                } catch let error as NSError { print("Trakt::getTrendingShows : \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        }
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< Trakt : getTrendingShows >> Return : showNames = \(showNames), showIds = \(showIds)", logLevel : logFuncReturn, scope : scopeSource)
        return (showNames, showIds)
    }
    
    
    func getComments(IMDBid : String, season : Int, episode : Int) -> (comments : [String], likes : [Int], dates : [Date], source : [Int])
    {
        trace(texte : "<< Trakt : getComments >>", logLevel : logFuncCalls, scope : scopeSource)
        trace(texte : "<< Trakt : getComments >> Params : IMDBid=\(IMDBid), season=\(season), IMDBid=\(episode)", logLevel : logFuncParams, scope : scopeSource)
        
        var stringURL : String = ""
        var ended : Bool = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        var foundComments : [String] = []
        var foundLikes : [Int] = []
        var foundDates : [Date] = []
        var foundSource : [Int] = []

        if (episode == 0)
        {
            if (season == 0)
            {
                stringURL = "https://api.trakt.tv/shows/\(IMDBid)/comments/likes"
            }
            else
            {
                stringURL = "https://api.trakt.tv/shows/\(IMDBid)/seasons/\(season)/comments/likes"
            }
        }
        else
        {
            stringURL = "https://api.trakt.tv/shows/\(IMDBid)/seasons/\(season)/episodes/\(episode)/comments/likes"
        }

        
        var request = URLRequest(url: URL(string: stringURL)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("Trakt::getComments : error \(response.statusCode) received "); return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for oneComment in jsonResponse
                    {
                        let comment : String = ((oneComment as! NSDictionary).object(forKey: "comment")) as? String ?? ""
                        //let spoiler : Bool = ((oneComment as! NSDictionary).object(forKey: "spoiler")) as? Bool ?? false
                        //let review : Bool = ((oneComment as! NSDictionary).object(forKey: "review")) as? Bool ?? false
                        let oneLike : Int = ((oneComment as! NSDictionary).object(forKey: "likes")) as? Int ?? 0
                        let stringDate : String = ((oneComment as! NSDictionary).object(forKey: "created_at")) as? String ?? ""
                        var oneDate : Date = ZeroDate
                        if (stringDate !=  "") { oneDate = dateFormatter.date(from: stringDate)! }
                        
                        foundComments.append(comment)
                        foundLikes.append(oneLike)
                        foundDates.append(oneDate)
                        foundSource.append(sourceTrakt)
                    }
                    
                    ended = true
                    
                } catch let error as NSError { print("Trakt::getComments : \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        }
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        trace(texte : "<< Trakt : getComments >> Return : foundComments=\(foundComments), foundLikes=\(foundLikes), foundDates=\(foundDates), foundSource=\(foundSource)", logLevel : logFuncReturn, scope : scopeSource)
        return (foundComments, foundLikes, foundDates, foundSource)
    }

}





