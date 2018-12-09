//
//  TVmaze.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation

class TVmaze
{
    init()
    {
        
    }
    
    func getSerieGlobalInfos(idTVDB : String, idIMDB : String) -> Serie
    {
        let uneSerie : Serie = Serie(serie: "")
        var request : URLRequest
        
        if (idIMDB != "")       { request = URLRequest(url: URL(string: "http://api.tvmaze.com/lookup/shows?imdb=\(idIMDB)")!) }
        else if (idTVDB != "")  { request = URLRequest(url: URL(string: "http://api.tvmaze.com/lookup/shows?thetvdb=\(idTVDB)")!) }
        else                    { return uneSerie }
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("TVmaze::getSerieGlobalInfos error \(response.statusCode) received "); return; }
                    
                    let show : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    uneSerie.serie = show.object(forKey: "name") as? String ?? ""
                    uneSerie.resume = show.object(forKey: "summary") as? String ?? ""
                    uneSerie.status = show.object(forKey: "status") as? String ?? ""
                    uneSerie.genres = show.object(forKey: "genres") as? [String] ?? []
                    uneSerie.language = show.object(forKey: "language") as? String ?? ""
                    uneSerie.runtime = show.object(forKey: "runtime") as? Int ?? 0
                    uneSerie.homepage = show.object(forKey: "url") as? String ?? ""
                    uneSerie.ratingTVmaze = Int(10 * ((show.object(forKey: "rating")! as AnyObject).object(forKey: "average") as? Double ?? 0.0))
                    
                } catch let error as NSError { print("TVmaze::getSerieGlobalInfos failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
        
        return uneSerie
    }
}
