//
//  SIMKL.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 20/04/2024.
//  Copyright © 2024 Home. All rights reserved.
//

import Foundation


class SIMKL : NSObject {
    var chrono : TimeInterval = 0
    
    let SIMKLURL : String = "https://api.simkl.com/oauth/token"
    let SIMKLClientID : String = "795030c70cf0ded2456b017304d8ad042cb4b5b85a67fd5ecd2e26a43dd88417"
//    let SIMKLClientSecret : String = "---"
//    var Token : String = ""
//    var RefreshToken : String = ""
//    var TokenExpiration : Date!
//    let dateFormSIMKL   = DateFormatter()
    
    override init() {
        super.init()
//        dateFormSIMKL.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    }
    
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()
        
        var request = URLRequest(url: URL(string: reqAPI)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("SIMKL::error \(response.statusCode) received for req=\(reqAPI) "); ended = true; return; }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("SIMKL::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
            } else { print(error as Any); ended = true; }
        }
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func getSerieGlobalInfos(idSIMKLOrIMDB : String) -> Serie {
        let uneSerie : Serie = Serie(serie: "")
        
        if (idSIMKLOrIMDB == "") { return uneSerie }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.simkl.com/tv/\(idSIMKLOrIMDB)?extended=full&clientid=\(SIMKLClientID)") as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return uneSerie }
        
        uneSerie.serie = reqResult.object(forKey: "title") as? String ?? ""
        uneSerie.idIMdb = (reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "imdb") as? String ?? ""
        uneSerie.idTVdb = (reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "tvdb") as? String ?? ""
        uneSerie.idMoviedb = (reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? String ?? ""
        uneSerie.idSIMKL = String((reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "simkl") as? Int ?? 0)
        uneSerie.homepage = (reqResult.object(forKey: "ids")! as AnyObject).object(forKey: "offen") as? String ?? ""
        uneSerie.poster = reqResult.object(forKey: "poster") as? String ?? ""
        if (uneSerie.poster != "") { uneSerie.poster = "https://simkl.in/posters/" + uneSerie.poster + "_ca.jpg" }
        //if (uneSerie.poster != "") { uneSerie.poster = "https://wsrv.nl/?url=https://simkl.in/posters/" + uneSerie.poster + "_ca.jpg" }

        uneSerie.network = reqResult.object(forKey: "network") as? String ?? ""
        uneSerie.status = reqResult.object(forKey: "status") as? String ?? ""
        uneSerie.resume = reqResult.object(forKey: "overview") as? String ?? ""
        uneSerie.genres = reqResult.object(forKey: "genres") as? [String] ?? []
        uneSerie.year = reqResult.object(forKey: "year") as? Int ?? 0
        
        if ((reqResult.object(forKey: "ratings")! as AnyObject).object(forKey: "simkl") != nil ) {
            uneSerie.ratingSIMKL = Int(10 * (((reqResult.object(forKey: "ratings")! as AnyObject).object(forKey: "simkl")! as AnyObject).object(forKey: "rating") as? Double ?? 0.0))
            uneSerie.ratersSIMKL = ((reqResult.object(forKey: "ratings")! as AnyObject).object(forKey: "simkl")! as AnyObject).object(forKey: "votes") as? Int ?? 0
        }
        if ((reqResult.object(forKey: "ratings")! as AnyObject).object(forKey: "imdb") != nil ) {
            uneSerie.ratingIMDB = Int(10 * (((reqResult.object(forKey: "ratings")! as AnyObject).object(forKey: "imdb")! as AnyObject).object(forKey: "rating") as? Double ?? 0.0))
            uneSerie.ratersIMDB = ((reqResult.object(forKey: "ratings")! as AnyObject).object(forKey: "imdb")! as AnyObject).object(forKey: "votes") as? Int ?? 0
        }
        uneSerie.country = (reqResult.object(forKey: "country") as? String ?? "").uppercased()
        uneSerie.runtime = reqResult.object(forKey: "runtime") as? Int ?? 0
        uneSerie.homepage = reqResult.object(forKey: "homepage") as? String ?? ""
        uneSerie.nbEpisodes = reqResult.object(forKey: "total_episodes") as? Int ?? 0
        uneSerie.certification = reqResult.object(forKey: "certification") as? String ?? ""

        return uneSerie
    }

    func getTrendingShows() -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        
        let reqResult : NSArray = loadAPI(reqAPI: "https://api.simkl.com/tv/trending/week?extended=title,tmdb&client_id=\(SIMKLClientID)") as! NSArray

        for oneShow in reqResult {
            let titre : String = (oneShow as AnyObject).object(forKey: "title") as? String ?? ""
            let idMoviedb : String = ((oneShow as AnyObject).object(forKey: "ids")! as AnyObject).object(forKey: "tmdb") as? String ?? ""
            
            if (compteur < popularShowsPerSource) {
                compteur = compteur + 1
                showNames.append(titre)
                showIds.append(idMoviedb)
            }
        }
        
        return (showNames, showIds)
    }
}
