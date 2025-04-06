//
//  JustWatch.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 28/03/2020.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation

class Diffuseur {
    var name : String = ""
    var logo : String = ""
    var contenu : String = ""
    var qualite : String = ""
    var mode : String = ""
    var premier : Int = 0
    var dernier : Int = 0
    var sourceDiffuseur : Int = 0
}


class JustWatch {
    var chrono      : TimeInterval          = 0
    var providers   : NSMutableDictionary   = NSMutableDictionary()
    
    init() {
    }

    
    func postAPI(reqAPI: String, body: String) -> NSObject {
        let startChrono : Date = Date()
        var request = URLRequest(url: URL(string: reqAPI)!,timeoutInterval: Double.infinity)
        var result : NSObject = NSObject()
        var ended : Bool = false
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("https://www.justwatch.com", forHTTPHeaderField: "Referer")
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
    
    
    func getDiffuseurs(serie : String, saison : Int) -> [Diffuseur] {
        var result : [Diffuseur] = []
        let foundPath : String = getSeriePath(serie: serie)
        var path : String = ""
        var scope : String = ""

        if (foundPath == "") { return result }
        
        if (saison == 0) {
            path = foundPath
            scope = "Show"
        }
        else {
            path = foundPath + "/saison-" + String(saison)
            scope = "Season"
        }
        
        // Recherche des diffuseurs de la serie sur JustWatch
        let reqURL : String = "https://apis.justwatch.com/graphql"
        let reqBody : String = "{\"operationName\":\"GetUrlTitleDetails\",\"variables\":{\"platform\":\"WEB\",\"fullPath\":\"\(path)\",\"country\":\"FR\"},\"query\":\"query GetUrlTitleDetails($fullPath: String!, $country: Country!, $platform: Platform! = WEB) { urlV2(fullPath: $fullPath) { heading1 node { ...TitleDetails } } } fragment TitleDetails on Node { id ... on \(scope) { offers(country: $country, platform: $platform) { presentationType monetizationType elementCount package { clearName icon(profile: S100, format:PNG) } } } } \"}"
        let reqResult : NSDictionary = postAPI(reqAPI: reqURL, body: reqBody) as? NSDictionary ?? NSDictionary()
        
        
        if (reqResult.object(forKey: "data") != nil) {
            if ((reqResult.object(forKey: "data") as! NSDictionary).object(forKey: "urlV2") != nil) {
                if (((reqResult.object(forKey: "data") as! NSDictionary).object(forKey: "urlV2") as! NSDictionary).object(forKey: "node") != nil) {
                    let foundOffers = (((reqResult.object(forKey: "data") as! NSDictionary).object(forKey: "urlV2") as! NSDictionary).object(forKey: "node") as! NSDictionary).object(forKey: "offers") as! NSArray
                    
                    for oneOffer in foundOffers {
                        let mode: String = (oneOffer as AnyObject).object(forKey: "monetizationType") as? String ?? "" // buy (achat) / rent (location) / flatrate (abonnement) / free (??)
                        let qualite: String = (oneOffer as AnyObject).object(forKey: "presentationType") as? String ?? "" // 4k / hd / sd
                        let diffuseur : String = ((oneOffer as AnyObject).object(forKey: "package") as! NSDictionary).object(forKey: "clearName")! as? String ?? ""
                        let logo : String = ((oneOffer as AnyObject).object(forKey: "package") as! NSDictionary).object(forKey: "icon")! as? String ?? ""
                        let nbElements: Int = (oneOffer as AnyObject).object(forKey: "elementCount") as? Int ?? 0
                        
                        
                        let unDiffuseur : Diffuseur = Diffuseur.init()
                        var trouve : Bool = false
                        
                        unDiffuseur.qualite = qualite.uppercased().replacingOccurrences(of: "_", with: "")
                        unDiffuseur.logo = "https://www.justwatch.com/images" + logo
                        unDiffuseur.contenu = String(nbElements) + " saisons"
                        unDiffuseur.name = diffuseur
                        unDiffuseur.sourceDiffuseur = srcJustWatch

                        switch mode {
                        case "BUY": unDiffuseur.mode = "Achat"
                        case "RENT": unDiffuseur.mode = "Location"
                        case "FLATRATE": unDiffuseur.mode = "Streaming"
                        case "FREE": unDiffuseur.mode = "Free"
                        default: unDiffuseur.mode = mode + " ???"
                        }
                        
                        for (unDiffConnu) in result {
                            if ((unDiffConnu.name == unDiffuseur.name) && (unDiffConnu.mode == unDiffuseur.mode)) {
                                unDiffConnu.qualite = unDiffConnu.qualite + " " + unDiffuseur.qualite
                                trouve = true
                            }
                        }
                        
                        if (trouve == false) { result.append(unDiffuseur) }
                    }
                }
            }
        }
        
        return result
    }
    
    
    func getSeriePath(serie: String) -> String {
        var foundPath : String = ""
        
        let reqURL : String = "https://apis.justwatch.com/graphql"
        var reqBody : String = "{\"operationName\":\"GetSuggestedTitles\",\"variables\":{\"country\":\"FR\",\"language\":\"fr\",\"first\":1,\"filter\":{\"searchQuery\":\"\(serie)\",\"includeTitlesWithoutUrl\":true}},\"query\":\"query GetSuggestedTitles($country: Country!, $language: Language!, $first: Int!, $filter: TitleFilter) { popularTitles(country: $country, first: $first, filter: $filter) { edges { node { ...SuggestedTitle } } } } fragment SuggestedTitle on Show { content(country: $country, language: $language) { title fullPath } } \"}"
        var reqResult : NSDictionary = postAPI(reqAPI: reqURL, body: reqBody) as? NSDictionary ?? NSDictionary()
        
        if (((reqResult.object(forKey: "data") as! NSDictionary).object(forKey: "popularTitles") as! NSDictionary).object(forKey: "edges") != nil) {
            let foundSeries = ((reqResult.object(forKey: "data") as! NSDictionary).object(forKey: "popularTitles") as! NSDictionary).object(forKey: "edges") as! NSArray
            
            for oneNode in foundSeries {
                if ( ((oneNode as! NSDictionary).object(forKey: "node") != nil) && (((oneNode as! NSDictionary).object(forKey: "node") as! NSDictionary) != NSDictionary() ) ){
                    foundPath = (((oneNode as! NSDictionary).object(forKey: "node") as! NSDictionary).object(forKey: "content") as! NSDictionary).object(forKey: "fullPath") as? String ?? ""
                }
            }
        }
        
        if (foundPath == "") {
            reqBody = "{\"operationName\":\"GetSuggestedTitles\",\"variables\":{\"country\":\"FR\",\"language\":\"fr\",\"first\":1,\"filter\":{\"searchQuery\":\"\(serie.lowercased())\",\"includeTitlesWithoutUrl\":true}},\"query\":\"query GetSuggestedTitles($country: Country!, $language: Language!, $first: Int!, $filter: TitleFilter) { popularTitles(country: $country, first: $first, filter: $filter) { edges { node { ...SuggestedTitle } } } } fragment SuggestedTitle on Show { content(country: $country, language: $language) { title fullPath } } \"}"
            reqResult = postAPI(reqAPI: reqURL, body: reqBody) as? NSDictionary ?? NSDictionary()
            
            if (((reqResult.object(forKey: "data") as! NSDictionary).object(forKey: "popularTitles") as! NSDictionary).object(forKey: "edges") != nil) {
                let foundSeries = ((reqResult.object(forKey: "data") as! NSDictionary).object(forKey: "popularTitles") as! NSDictionary).object(forKey: "edges") as! NSArray
                
                for oneNode in foundSeries {
                    if ( ((oneNode as! NSDictionary).object(forKey: "node") != nil) && (((oneNode as! NSDictionary).object(forKey: "node") as! NSDictionary) != NSDictionary() ) ){
                        foundPath = (((oneNode as! NSDictionary).object(forKey: "node") as! NSDictionary).object(forKey: "content") as! NSDictionary).object(forKey: "fullPath") as? String ?? ""
                    }
                }
            }
        }
        
        return foundPath
    }
    
}
