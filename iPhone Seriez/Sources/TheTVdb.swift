//
//  TheTVdb.swift
//  Seriez
//
//  Created by Cyril Delamare on 03/01/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import SeriesCommon

class TheTVdb : NSObject {
    var chronoGlobal : TimeInterval = 0
    var chronoRatings : TimeInterval = 0
    var chronoOther : TimeInterval = 0

    var TokenPath : String = String()
    let TheTVdbUserkey : String = "MO3XCCVP74QJR7GF"
    //let TheTVdbUserkey : String = "FA20954ED9DB5200"
    let TheTVdbUsername : String = "gonecd"
    let TheTVdbAPIkey : String = "8168E8621729A50F"
    var Token : String = ""
    
    override init() {
        super.init()
    }
    
    func getChrono() -> TimeInterval {
        return chronoGlobal+chronoRatings+chronoOther
    }

    func initializeToken() {
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
                        self.Token = jsonToken.object(forKey: "token") as? String ?? ""
                        print("Token = \(self.Token)")
                    } catch let error as NSError { print("TheTVdb::getToken failed: \(error.localizedDescription)") }
                }
                else { print("TheTVdb::getToken error code \(response.statusCode)") }
            } else { print("TheTVdb::getToken failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }

    }
    

    func getEpisodesDetailsAndRating(uneSerie: Serie) {
        let startChrono : Date = Date()
        var pageToLoad  : Int = 1
        var continuer   : Bool = true
        
        var url         : URL
        var request     : URLRequest
        var session     : URLSession
        var task        : URLSessionDataTask
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        while ( continuer ) {
            // Parsing de la saison
            url = URL(string: "https://api.thetvdb.com/series/\(uneSerie.idTVdb)/episodes?page=\(pageToLoad)")!
            request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("en", forHTTPHeaderField: "Accept-Language")
            request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
            
            session = URLSession.shared
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse {
                    do {
                        if response.statusCode == 200 {
                            
                            let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            for fiche in jsonResponse.object(forKey: "data")! as! NSArray {
                                let laSaison : Int = ((fiche as AnyObject).object(forKey: "airedSeason") as? Int ?? 0)
                                
                                if (laSaison != 0) {
                                    if (laSaison > uneSerie.saisons.count) {
                                        // Il manque une (ou des) saison(s), on crée toutes les saisons manquantes
                                        var uneSaison : Saison
                                        for i:Int in uneSerie.saisons.count ..< laSaison {
                                            uneSaison = Saison(serie: uneSerie.serie, saison: i+1)
                                            uneSerie.saisons.append(uneSaison)
                                        }
                                    }
                                    
                                    let lEpisode : Int = ((fiche as AnyObject).object(forKey: "airedEpisodeNumber") as! Int)
                                    if (lEpisode > uneSerie.saisons[laSaison - 1].episodes.count) {
                                        // Il manque un (ou des) épisode(s), on crée tous les épisodes manquants
                                        var unEpisode : Episode
                                        for i:Int in uneSerie.saisons[laSaison - 1].episodes.count ..< lEpisode {
                                            unEpisode = Episode(serie: uneSerie.serie, fichier: "", saison: laSaison, episode: i+1)
                                            uneSerie.saisons[laSaison - 1].episodes.append(unEpisode)
                                        }
                                    }
                                    
                                    if (lEpisode != 0) {
                                        uneSerie.saisons[laSaison - 1].episodes[lEpisode - 1].titre = (fiche as AnyObject).object(forKey: "episodeName") as? String ?? ""
                                        uneSerie.saisons[laSaison - 1].episodes[lEpisode - 1].resume = (fiche as AnyObject).object(forKey: "overview") as? String ?? ""
                                        
                                        uneSerie.saisons[laSaison - 1].episodes[lEpisode - 1].ratingTVdb = Int(10 * ((fiche as AnyObject).object(forKey: "siteRating") as? Double ?? 0.0))
                                        uneSerie.saisons[laSaison - 1].episodes[lEpisode - 1].ratersTVdb = (fiche as AnyObject).object(forKey: "siteRatingCount") as? Int ?? 0
                                        uneSerie.saisons[laSaison - 1].episodes[lEpisode - 1].idIMdb = (fiche as AnyObject).object(forKey: "imdbId") as? String ?? ""
                                        uneSerie.saisons[laSaison - 1].episodes[lEpisode - 1].idTVdb = (fiche as AnyObject).object(forKey: "id") as? Int ?? 0

                                        let stringDate : String = (fiche as AnyObject).object(forKey: "firstAired") as? String ?? ""
                                        if (stringDate ==  "") {
                                            uneSerie.saisons[laSaison - 1].episodes[lEpisode - 1].date = ZeroDate
                                        }
                                        else {
                                            uneSerie.saisons[laSaison - 1].episodes[lEpisode - 1].date = dateFormatter.date(from: stringDate)!
                                        }
                                    }
                                    else {
                                        print ("TheTVdb::getEpisodesDetailsAndRating failed on episode = 0 \(uneSerie.serie) saison \(laSaison)")
                                    }
                                }
                            }
                        }
                        else if response.statusCode == 404 {
                            // On a été une page trop loin, il n'y a plus d'autres épisodes
                            continuer = false
                        }
                        else {
                            print ("TheTVdb::getEpisodesDetailsAndRating failed (episodes de \(uneSerie.serie)) : code erreur \(response.statusCode)")
                        }
                    } catch let error as NSError { print("TheTVdb::getEpisodesDetailsAndRating failed (episodes de \(uneSerie.serie)) : \(error.localizedDescription)") }
                } else { print(error as Any) }
            })
            
            task.resume()
            
            while (task.state != URLSessionTask.State.completed) { usleep(10000) }
            
            pageToLoad = pageToLoad + 1
        }

        chronoOther = chronoOther + Date().timeIntervalSince(startChrono)
    }
    
    
    func getSerieGlobalInfos(idTVdb : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: "")
        var request : URLRequest
        
        if (idTVdb != "")  { request = URLRequest(url: URL(string: "https://api.thetvdb.com/series/\(idTVdb)")!) }
        else               { return uneSerie }
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("en", forHTTPHeaderField: "Accept-Language")
        request.addValue("Bearer \(self.Token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                do {
                    if response.statusCode == 200 {
                        
                        let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        uneSerie.serie = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "seriesName") as? String ?? ""
                        uneSerie.status = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "status") as? String ?? ""
                        uneSerie.network = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "network") as? String ?? ""
                        uneSerie.resume = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "overview") as? String ?? ""
                        uneSerie.genres = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "genre") as? [String] ?? []
                        
                        uneSerie.banner = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "banner") as? String ?? ""
                        if (uneSerie.banner != "") { uneSerie.banner = "https://www.thetvdb.com/banners/" + uneSerie.banner }
                        
                        uneSerie.ratingTVDB = 10 * Int((jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "siteRating") as? Double ?? 0.0)
                        uneSerie.ratersTVDB = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "siteRatingCount") as? Int ?? 0
                        uneSerie.idTVdb = String((jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "id") as? Int ?? 0)
                        uneSerie.idIMdb = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "imdbId") as? String ?? ""
                        
                        let textRuntime : String = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "runtime") as? String ?? "0"
                        if (textRuntime != "" ) { uneSerie.runtime = Int(textRuntime)! }

                        uneSerie.certification = (jsonResponse.object(forKey: "data")! as AnyObject).object(forKey: "rating") as? String ?? ""
                    }
                    else {
                        print ("TheTVdb::getSerieInfos failed (general infos de \(uneSerie.serie)): code erreur \(response.statusCode)")
                    }
                } catch let error as NSError { print("TheTVdb::getSerieInfos failed (general infos de \(uneSerie.serie)) : \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        chronoGlobal = chronoGlobal + Date().timeIntervalSince(startChrono)

        return uneSerie
    }
    
}
