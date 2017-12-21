//
//  TheTVdb.swift
//  Seriez
//
//  Created by Cyril Delamare on 03/01/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation


class TheTVdb : NSObject
{
    var TokenPath : String = String()
    let TheTVdbUserkey : String = "FA20954ED9DB5200"
    let TheTVdbUsername : String = "gonecd"
    let TheTVdbAPIkey : String = "8168E8621729A50F"
    var Token : String = ""
    
    override init()
    {
        super.init()
    }
    
    func initializeToken()
    {
        // Première connection pour récupérer un token valable ??? temps ( = 24h ? ) et le dumper dans un fichier /tmp/TheTVdbToken
        
        var request = URLRequest(url: URL(string: "https://api.thetvdb.com/login")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.TheTVdbAPIkey)", forHTTPHeaderField: "Authorization")
        request.httpBody = "{\n  \"apikey\": \"\(self.TheTVdbAPIkey)\",\n  \"username\": \"\(self.TheTVdbUsername)\",\n  \"userkey\": \"\(self.TheTVdbUserkey)\"\n}".data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    
                    do {
                        let jsonToken : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        self.Token = jsonToken.object(forKey: "token") as! String!
                    } catch let error as NSError { print("TheTVdb::getToken failed: \(error.localizedDescription)") }
                }
                else { print("TheTVdb::getToken error code \(response.statusCode)") }
            } else { print("TheTVdb::getToken failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
    
    
    func getSerieInfos(_ uneSerie: Serie)
    {
        var pageToLoad : Int = 1
        var continuer : Bool = true
        var url = URL(string: "https://api.thetvdb.com/series/\(uneSerie.idTVdb)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        
        var session = URLSession.shared
        var task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                do {
                    if response.statusCode == 200 {
                        
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        uneSerie.banner = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "banner") as! String
                        uneSerie.status = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "status") as! String
                        uneSerie.ratingTVdb = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "siteRating") as! Double
                        uneSerie.network = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "network") as! String
                        uneSerie.resume = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "overview") as? String ?? ""
                        uneSerie.genres = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "genre") as! [String]
                    }
                    else
                    {
                        print ("TheTVdb::getSerieInfos failed: code erreur \(response.statusCode)")
                    }
                } catch let error as NSError { print("TheTVdb::getSerieInfos failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        
        while ( continuer )
        {
            // Parsing de la saison
            url = URL(string: "https://api.thetvdb.com/series/\(uneSerie.idTVdb)/episodes?page=\(pageToLoad)")!
            request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            session = URLSession.shared
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse {
                    do {
                        if response.statusCode == 200 {
                            
                            let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            for fiche in jsonResponse.object(forKey: "data")! as! NSArray
                            {
                                if (((fiche as AnyObject).object(forKey: "airedSeason") as? Int ?? 0) != 0)
                                {
                                    if (((fiche as AnyObject).object(forKey: "airedSeason") as? Int ?? 0) > uneSerie.saisons.count)
                                    {
                                        // Il manque une saison, on crée toutes les saisons manquantes
                                        var uneSaison : Saison
                                        
                                        for i:Int in uneSerie.saisons.count ..< ((fiche as AnyObject).object(forKey: "airedSeason") as! Int)
                                        {
                                            uneSaison = Saison(serie: uneSerie.serie, saison: i+1)
                                            uneSerie.saisons.append(uneSaison)
                                        }
                                    }
                                    
                                    if (((fiche as AnyObject).object(forKey: "airedEpisodeNumber") as! Int) > uneSerie.saisons[((fiche as AnyObject).object(forKey: "airedSeason") as! Int) - 1].episodes.count)
                                    {
                                        // Il manque un épisode, on crée tous les épisodes manquants
                                        var unEpisode : Episode
                                        
                                        for i:Int in uneSerie.saisons[((fiche as AnyObject).object(forKey: "airedSeason") as! Int) - 1].episodes.count ..< ((fiche as AnyObject).object(forKey: "airedEpisodeNumber") as! Int)
                                        {
                                            unEpisode = Episode(serie: uneSerie.serie,
                                                                fichier: "",
                                                                saison: (fiche as AnyObject).object(forKey: "airedSeason") as! Int,
                                                                episode: i+1)
                                            uneSerie.saisons[((fiche as AnyObject).object(forKey: "airedSeason") as! Int) - 1].episodes.append(unEpisode)
                                        }
                                    }
                                    
                                    uneSerie.saisons[((fiche as AnyObject).object(forKey: "airedSeason") as! Int) - 1].episodes[((fiche as AnyObject).object(forKey: "airedEpisodeNumber") as! Int) - 1].idTVdb = (fiche as AnyObject).object(forKey: "id") as? Int ?? 0
                                }
                            }
                        }
                        else if response.statusCode == 404
                        {
                            continuer = false
                        }
                        else
                        {
                            print ("TheTVdb::getSerieInfos failed: code erreur \(response.statusCode)")
                        }
                    } catch let error as NSError { print("TheTVdb::getSerieInfos failed: \(error.localizedDescription)") }
                } else { print(error as Any) }
            })
            
            task.resume()
            
            while (task.state != URLSessionTask.State.completed) { usleep(10000) }
            
            pageToLoad = pageToLoad + 1
        }
        
        // Récupération des ratings
        for saison in uneSerie.saisons
        {
            var tableauDeTaches: [URLSessionTask] = []
            var globalStatus: URLSessionTask.State = URLSessionTask.State.running
            
            for episode in saison.episodes
            {
                if (episode.idTVdb != 0)
                {
                    url = URL(string: "https://api.thetvdb.com/episodes/\(episode.idTVdb)")!
                    request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
                    
                    session = URLSession.shared
                    task = session.dataTask(with: request, completionHandler: { data, response, error in
                        if let data = data, let response = response as? HTTPURLResponse {
                            do {
                                if response.statusCode == 200 {
                                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                    
                                    episode.ratingTVdb = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "siteRating") as? Double ?? 0.0
                                    episode.ratersTVdb = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "siteRatingCount") as? Int ?? 0
                                }
                            } catch let error as NSError { print("TheTVdb::getSerieInfos failed for \(uneSerie.serie) s\(saison.saison) e\(episode.episode): \(error.localizedDescription)") }
                        } else { print(error as Any) }
                    })
                    
                    tableauDeTaches.append(task)
                    task.resume()
                }
                
                while (globalStatus == URLSessionTask.State.running)
                {
                    globalStatus = URLSessionTask.State.completed
                    usleep(1000)
                    for uneTache in tableauDeTaches
                    {
                        if (uneTache.state == URLSessionTask.State.running) { globalStatus = URLSessionTask.State.running }
                    }
                }
            }
        }
    }
}





