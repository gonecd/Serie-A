//
//  YaQuoiCommeSerie.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 07/06/2022.
//  Copyright © 2022 Home. All rights reserved.
//
import Foundation


class YaQuoiCommeSerie {
    var chrono      : TimeInterval          = 0

    init() {
    }
        
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()

        var request : URLRequest = URLRequest(url: URL(string: reqAPI)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("YaQuoiCommeSerie::error \(response.statusCode) received for req=\(reqAPI)"); ended = true; return }
                    
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                } catch let error as NSError { print("YaQuoiCommeSerie::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }

        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func getAllInfos(title : String, idIMDB: String, idAlloCine: String, idSensCritique: String) -> Serie {
        var reqURL : String = "https://yqcsapi.herokuapp.com/shows?"
        let result : Serie = Serie(serie: "")
        
        if ( idIMDB != "" ) { reqURL = reqURL + "imdbId=\(idIMDB)" }
        else if ( idAlloCine != "" ) { reqURL = reqURL + "allocineId=\(idAlloCine)" }
        else if ( idSensCritique != "" ) { reqURL = reqURL + "senscritiqueId=\(idSensCritique)" }
        else if ( title != "" ) { reqURL = reqURL + "title=\(title)" }
        else { return result }

        let reqResult : NSArray = loadAPI(reqAPI: reqURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) as! NSArray
        
        for oneResult in reqResult {
            let ratingAllocine : Double = (((oneResult as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "allocine")! as AnyObject).object(forKey: "usersRating") as? Double ?? 0.0
            let ratingBetaSeries : Double = (((oneResult as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "betaseries")! as AnyObject).object(forKey: "usersRating") as? Double ?? 0.0
            let ratingIMDB : Double = (((oneResult as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "imdb")! as AnyObject).object(forKey: "usersRating") as? Double ?? 0.0
            let ratingSensCritique : Double = (((oneResult as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "senscritique")! as AnyObject).object(forKey: "usersRating") as? Double ?? 0.0
            
            result.ratingAlloCine = Int(20*ratingAllocine)
            result.ratingBetaSeries = Int(20*ratingBetaSeries)
            result.ratingIMDB = Int(10*ratingIMDB)
            result.ratingSensCritique = Int(10*ratingSensCritique)

            let codeAllocine : Int = (((oneResult as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "allocine")! as AnyObject).object(forKey: "id") as? Int ?? 0
            if (codeAllocine == 0) { result.idAlloCine = "" } else { result.idAlloCine = String(codeAllocine) }

            result.idIMdb = (((oneResult as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "imdb")! as AnyObject).object(forKey: "id") as? String ?? ""
            result.idSensCritique = (((oneResult as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "senscritique")! as AnyObject).object(forKey: "id") as? String ?? ""

            let title : String = ((oneResult as AnyObject).object(forKey: "show")! as AnyObject).object(forKey: "title") as? String ?? ""
            result.serie = title
            }

        return result
    }
        
}

