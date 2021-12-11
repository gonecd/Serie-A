//
//  JustWatch.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 28/03/2020.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import SwiftSoup


class Provider {
    var ID : Int = 0
    var name : String = ""
    var logo : String = ""
    
    init(initID: Int, initName: String, initLogo: String) {
        ID = initID
        name = initName
        logo = initLogo
    }
}

class Diffuseur {
    var name : String = ""
    var logo : String = ""
    var prix : String = ""
    var contenu : String = ""
    var qualite : String = ""
    var mode : String = ""
}


class JustWatch {
    var chrono      : TimeInterval          = 0
    var providers   : NSMutableDictionary   = NSMutableDictionary()
    let noProvider  : Provider              = Provider(initID: 0, initName: "", initLogo: "")

    init() {
    }
    
    // get_season : https://apis.justwatch.com/content/titles/show_season/{season_id}/locale/fr_FR
    // get_title : https://apis.justwatch.com/content/titles/{content_type}/{title_id}/locale/fr_FR
    

    
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
                    if (response.statusCode != 200) { print("JustWatch::error \(response.statusCode) received for req=\(reqAPI)"); ended = true; return }
                    
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                } catch let error as NSError { print("JustWatch::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }

        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func postAPI(reqAPI: String, body: String) -> NSObject {
        let startChrono : Date = Date()
        var request = URLRequest(url: URL(string: reqAPI)!)
        var result : NSObject = NSObject()
        var ended : Bool = false

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if ( response.statusCode == 200 ) {
                        result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                        ended = true
                    }
                    else {
                        print("JustWatch::post error \(response.statusCode) received for \(reqAPI) with body = \(body)")
                        ended = true
                        return
                    }
                } catch let error as NSError { print("JustWatch::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
                
            } else { print(error as Any) }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func initDiffuseurs() {
        let reqResult : NSArray = loadAPI(reqAPI: "https://apis.justwatch.com/content/providers/locale/fr_FR") as? NSArray ?? NSArray()

        for oneResult in reqResult {
            let providerID: Int = (oneResult as AnyObject).object(forKey: "id")! as? Int ?? 0
            let providerName: String = (oneResult as AnyObject).object(forKey: "clear_name")! as? String ?? ""
            var providerLogo: String = (oneResult as AnyObject).object(forKey: "icon_url")! as? String ?? ""

            if providerLogo.contains("{profile}") {
                providerLogo = "https://images.justwatch.com" + providerLogo.replacingOccurrences(of: "{profile}", with: "s100")
            }
            
            let provider : Provider = Provider(initID: providerID, initName: providerName, initLogo: providerLogo)

            providers.setValue(provider, forKey: String(providerID))
        }
    }
    
    func getDiffuseurs(serie : String) -> [Diffuseur] {
        let reqURL : String = "https://apis.justwatch.com/content/titles/fr_FR/popular"
        let reqBody : String = "{ \"query\": \"\(serie)\", \"content_types\":[\"show\"] }"
        var result : [Diffuseur] = []
        let reqResult : NSDictionary = postAPI(reqAPI: reqURL, body: reqBody) as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "items") != nil) {
            for oneShow in reqResult.object(forKey: "items")! as! NSArray {
                let title: String = (oneShow as AnyObject).object(forKey: "title")! as? String ?? ""
                
                if (title.uppercased().contains(serie.uppercased())) {
                    if ((oneShow as AnyObject).object(forKey: "offers") != nil) {
                        for oneOffer in (oneShow as AnyObject).object(forKey: "offers")! as! NSArray {
                            let providerID: Int = (oneOffer as AnyObject).object(forKey: "provider_id") as? Int ?? 0
                            let qualite: String = (oneOffer as AnyObject).object(forKey: "presentation_type") as? String ?? "" // 4k / hd / sd
                            let prix: Double = (oneOffer as AnyObject).object(forKey: "retail_price") as? Double ?? 0.0
                            let currency: String = (oneOffer as AnyObject).object(forKey: "currency") as? String ?? ""
                            let nbElements: Int = (oneOffer as AnyObject).object(forKey: "element_count") as? Int ?? 0
                            let mode: String = (oneOffer as AnyObject).object(forKey: "monetization_type") as? String ?? "" // buy (achat) / rent (location) / flatrate (abonnement) / free (??)

                            let unDiffuseur : Diffuseur = Diffuseur.init()
                            unDiffuseur.qualite = qualite.uppercased()
                            unDiffuseur.mode = mode
                            if (prix != 0.0) { unDiffuseur.prix = String(prix) + " " + currency }
                            unDiffuseur.contenu = String(nbElements) + " saisons"

                            let monDiffuseur : Provider = providers[String(providerID)] as? Provider ?? noProvider
                            if monDiffuseur.ID != 0 {
                                unDiffuseur.name = monDiffuseur.name
                                unDiffuseur.logo = monDiffuseur.logo
                                
                                var trouve : Bool = false

                                for (unDiffConnu) in result {
                                    if ((unDiffConnu.name == unDiffuseur.name) && (unDiffConnu.mode == unDiffuseur.mode)) {
                                        unDiffConnu.qualite = unDiffConnu.qualite + " " + unDiffuseur.qualite
                                        trouve = true
                                    }
                                }
                                
                                if (trouve == false) {
                                    result.append(unDiffuseur)
                                }
                            }
                            else {
                                unDiffuseur.name = "Inconnu"
                                unDiffuseur.logo = ""
                                print("JustWatch::diffuseur inconnu pour \(serie) : ID = \(providerID)")
                            }
                        }
                    }

                    return result
                }
            }
        }

        return result
    }
    
    
    
    
    
}
