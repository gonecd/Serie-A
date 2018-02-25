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
        super.init()
    }
    
    
    func start() -> Bool
    {
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
            
            return true
        }
        else
        {
            self.downloadToken(key: "78C58EAD")
            return false
        }
    }
    
    
    func downloadToken(key : String)
    {
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
                    
                    self.Token = jsonToken.object(forKey: "access_token") as! String!
                    defaults.set(self.Token, forKey: "TraktToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as! String!
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
    
    
    func refreshToken (_ refresher: String)
    {
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
                    
                    self.Token = jsonToken.object(forKey: "access_token") as! String!
                    defaults.set(self.Token, forKey: "TraktToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as! String!
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
    
    

    
    func recherche(serieArechercher : String) -> [Serie]
    {
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
                        newSerie.watchlist = true
                        
                        serieListe.append(newSerie)
                    }
                } catch let error as NSError { print("Trakt::recherche failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
        
        return serieListe
    }
    
    
    func addToWatchlist(theTVdbId : String) -> Bool
    {
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
                    print("Trakt::recherche error \(response.statusCode) received ")
                    success =  false
                    return
                }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        return success
    }
    
    
    func removeFromWatchlist(theTVdbId : String) -> Bool
    {
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

        return success
}
    
    
    func getWatchlist() -> [Serie]
    {
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
                        serie.watchlist = true
                        
                        returnSeries.append(serie)
                    }
                } catch let error as NSError { print("Trakt::getWatchlist failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
        
        return returnSeries
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie)
    {
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
    }
    
    func getStopped() -> [Serie]
    {
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
                        serie.unfollowed = true
                        
                        returnSeries.append(serie)
                    }
                } catch let error as NSError { print("Trakt::getStopped failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
        return returnSeries
    }

    func getWatched() -> [Serie]
    {
        let url = URL(string: "https://api.trakt.tv/sync/watched/shows")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("\(self.TraktClientID)", forHTTPHeaderField: "trakt-api-key")
        
        //        let session = URLSession.shared
        var returnSeries: [Serie] = [Serie]()
        var serie: Serie = Serie(serie: "")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                do {
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for fiche in jsonResponse {
                        
                        serie = Serie.init(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String)
                        serie.idIMdb = (((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as! String
                        serie.idTVdb = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as! Int)
                        serie.idTrakt = String((((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "trakt") as! Int)
                        
                        for fichesaisons in (fiche as AnyObject).object(forKey: "seasons") as! NSArray
                        {
                            let uneSaison : Saison = Saison(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String,
                                                            saison: (fichesaisons as AnyObject).object(forKey: "number") as! Int)
                            
                            for ficheepisodes in (fichesaisons as AnyObject).object(forKey: "episodes") as! NSArray
                            {
                                let unEpisode : Episode = Episode(serie: ((fiche as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as! String,
                                                                  fichier: "",
                                                                  saison: (fichesaisons as AnyObject).object(forKey: "number") as! Int,
                                                                  episode: (ficheepisodes as AnyObject).object(forKey: "number") as! Int)
                                unEpisode.watched = true
                                uneSaison.episodes.append(unEpisode)
                            }
                            
                            serie.saisons.append(uneSaison)
                        }
                        
                        returnSeries.append(serie)
                    }
                } catch let error as NSError { print("Trakt::getWatched failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        }
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
        return returnSeries
    }

}





