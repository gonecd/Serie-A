//
//  TVmaze.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup
import SeriesCommon

class TVmaze {
    var chronoGlobal : TimeInterval = 0
    var chronoRatings : TimeInterval = 0
    var chronoOther : TimeInterval = 0

    init() {
    }
    
    func getChrono() -> TimeInterval {
        return chronoGlobal+chronoRatings+chronoOther
    }

    func getSerieGlobalInfos(idTVDB : String, idIMDB : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: "")
        var request : URLRequest
        var ended : Bool = false
        
        if (idIMDB != "")       { request = URLRequest(url: URL(string: "http://api.tvmaze.com/lookup/shows?imdb=\(idIMDB)")!) }
        else if (idTVDB != "")  { request = URLRequest(url: URL(string: "http://api.tvmaze.com/lookup/shows?thetvdb=\(idTVDB)")!) }
        else                    { return uneSerie }
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("TVmaze::getSerieGlobalInfos error \(response.statusCode) received for id=\(idTVDB) / \(idIMDB)"); ended = true; return; }
                    
                    let show : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    uneSerie.serie = show.object(forKey: "name") as? String ?? ""
                    uneSerie.idTVmaze = String(show.object(forKey: "id") as? Int ?? 0)
                    uneSerie.resume = show.object(forKey: "summary") as? String ?? ""
                    uneSerie.status = show.object(forKey: "status") as? String ?? ""
                    uneSerie.genres = show.object(forKey: "genres") as? [String] ?? []
                    uneSerie.language = show.object(forKey: "language") as? String ?? ""
                    uneSerie.runtime = show.object(forKey: "runtime") as? Int ?? 0
                    uneSerie.homepage = show.object(forKey: "url") as? String ?? ""
                    uneSerie.ratingTVmaze = Int(10 * ((show.object(forKey: "rating")! as AnyObject).object(forKey: "average") as? Double ?? 0.0))
                    
                    ended = true
                } catch let error as NSError { print("TVmaze::getSerieGlobalInfos failed: \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chronoGlobal = chronoGlobal + Date().timeIntervalSince(startChrono)
        return uneSerie
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono : Date = Date()
        let webPage : String = getPath(serie: uneSerie.serie, id: uneSerie.idTVmaze)
        
        if (webPage == "") {
            return
        }
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            let regex = try! NSRegularExpression(pattern: ".*([0-9]{1,2})x([0-9]{1,2}).*?", options: NSRegularExpression.Options.caseInsensitive)
            let epidodeList : Array<Element> = try doc.select("article [class='grid-x episode-row']").array()
            
            for oneEpisode in epidodeList {
                let lienEpisode : String = try! oneEpisode.select("[class='small-4 medium-6 cell']").select("a").attr("href")
                let result = regex.firstMatch(in: lienEpisode, options: [], range: NSMakeRange(0, lienEpisode.count))
                
                if (result != nil) {
                    let numSais : Int = Int(lienEpisode[Range(result!.range(at: 1), in: lienEpisode)!]) ?? 0
                    let numEps : Int = Int(lienEpisode[Range(result!.range(at: 2), in: lienEpisode)!]) ?? 0
                    
                    if ( (numSais > 0) && (numSais < uneSerie.saisons.count+1) ) {
                        if ( (numEps > 0) && (numEps < uneSerie.saisons[numSais-1].episodes.count+1) ) {
                            if (try! oneEpisode.select("div [class='dropdown-pane small']").text() != "(waiting for more votes)") {
                                uneSerie.saisons[numSais-1].episodes[numEps-1].ratingTVMaze = Int(10.0*(Double(try! oneEpisode.select("div [class='dropdown-pane small']").text().components(separatedBy: " ")[0]) ?? 0.0))
                                uneSerie.saisons[numSais-1].episodes[numEps-1].ratersTVMaze  = Int(try! oneEpisode.select("div [class='dropdown-pane small']").text().components(separatedBy: " ")[1].replacingOccurrences(of: "(", with: "")) ?? 0
                            }
                        }
                    }
                }
            }
        }
        catch let error as NSError { print("TVmaze scrapping failed for \(uneSerie.serie): \(error.localizedDescription)") }

        chronoRatings = chronoRatings + Date().timeIntervalSince(startChrono)
    }
    
    
    func getPath(serie : String, id : String) -> String {
        if (id == "") { return ""}
        
        return "https://www.tvmaze.com/shows/" + id + "/Hello/episodes?all=1"
    }
    
    
    func getSeasonsDates(idTVmaze : String) -> (saisons : [Int], nbEps : [Int], debuts : [Date], fins : [Date]) {
        let startChrono : Date = Date()
        var foundSaisons : [Int] = []
        var foundEps : [Int] = []
        var foundDebuts : [Date] = []
        var foundFins : [Date] = []
        var ended : Bool = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if (idTVmaze == "") {
            print("TVmaze::getSeasonsDates failed : no ID")
            return (foundSaisons, foundEps, foundDebuts, foundFins)
        }
        
        var request : URLRequest = URLRequest(url: URL(string: "http://api.tvmaze.com/shows/\(idTVmaze)/seasons")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("TVmaze::getSeasonsDates error \(response.statusCode) received for id=\(idTVmaze)"); ended = true; return }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    
                    for uneSaison in jsonResponse
                    {
                        let saison : Int = ((uneSaison as! NSDictionary).object(forKey: "number")) as? Int ?? 0
                        let nbEp : Int = ((uneSaison as! NSDictionary).object(forKey: "episodeOrder")) as? Int ?? 0
                        
                        let debutStr : String = ((uneSaison as! NSDictionary).object(forKey: "premiereDate")) as? String ?? ""
                        var debutDate : Date = ZeroDate
                        if (debutStr !=  "") { debutDate = dateFormatter.date(from: debutStr)! }
                        
                        let finStr : String = ((uneSaison as! NSDictionary).object(forKey: "endDate")) as? String ?? ""
                        var finDate : Date = ZeroDate
                        if (finStr !=  "") { finDate = dateFormatter.date(from: finStr)! }
                        
                        foundSaisons.append(saison)
                        foundEps.append(nbEp)
                        foundDebuts.append(debutDate)
                        foundFins.append(finDate)
                    }
                    
                    ended = true
                } catch let error as NSError { print("TVmaze::getSeasonsDates failed: \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chronoOther = chronoOther + Date().timeIntervalSince(startChrono)
        return (foundSaisons, foundEps, foundDebuts, foundFins)
    }
    
    
    func rechercheParTitre(serieArechercher : String) -> [Serie]
    {
        let startChrono : Date = Date()
        var serieListe : [Serie] = []
        var ended : Bool = false
        
        var request : URLRequest = URLRequest(url: URL(string: "http://api.tvmaze.com/search/shows?q=\(serieArechercher.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("TVmaze::rechercheParTitre error \(response.statusCode) received"); ended = true; return; }
                    
                    let jsonResponse : NSArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for fiche in jsonResponse {
                        
                        let oneShow : AnyObject = ((fiche as AnyObject).object(forKey: "show")! as AnyObject)
                        let newSerie : Serie = Serie(serie: oneShow.object(forKey: "name") as! String)
                        
                        newSerie.idTVmaze = String(oneShow.object(forKey: "id") as? Int ?? 0)
                        newSerie.idIMdb = (oneShow.object(forKey: "externals")! as AnyObject).object(forKey: "imdb") as? String ?? ""
                        newSerie.idTVdb = String((oneShow.object(forKey: "externals")! as AnyObject).object(forKey: "thetvdb") as? Int ?? 0)
                        
                        newSerie.resume = oneShow.object(forKey: "summary") as? String ?? ""
                        newSerie.status = oneShow.object(forKey: "status") as? String ?? ""
                        newSerie.genres = oneShow.object(forKey: "genres") as? [String] ?? []
                        newSerie.language = oneShow.object(forKey: "language") as? String ?? ""
                        newSerie.runtime = oneShow.object(forKey: "runtime") as? Int ?? 0
                        newSerie.homepage = oneShow.object(forKey: "url") as? String ?? ""
                        newSerie.ratingTVmaze = Int(10 * ((oneShow.object(forKey: "rating")! as AnyObject).object(forKey: "average") as? Double ?? 0.0))
                        
                        newSerie.watchlist = true
                        
                        serieListe.append(newSerie)
                    }
                    ended = true
                } catch let error as NSError { print("TVmaze::rechercheParTitre failed: \(error.localizedDescription)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chronoOther = chronoOther + Date().timeIntervalSince(startChrono)
        return serieListe
    }
    
    func getTrendingShows() -> (names : [String], ids : [String]) {
        return getShowList(url: "https://www.tvmaze.com/shows")
    }
    
    
    func getPopularShows() -> (names : [String], ids : [String]) {
        return getShowList(url: "https://www.tvmaze.com/shows?Show[sort]=7")
    }
    

    func getShowList(url : String) -> (names : [String], ids : [String]) {
        let startChrono : Date = Date()
        var showNames : [String] = []
        var showIds : [String] = []
        
        do {
            let page : String = try String(contentsOf: URL(string : url)!)
            let doc : Document = try SwiftSoup.parse(page)
            let showList = try doc.select("div [class='card primary grid-x']")
            
            for oneShow in showList {
                let showName : String = try oneShow.select("div [class='content auto cell']").select("a")[0].text()
                let TVMazeID : String = try oneShow.select("div [class='content auto cell']").select("a")[0].attr("href").components(separatedBy: "/")[1]

                showNames.append(showName)
                showIds.append(TVMazeID)
            }
        }
        catch let error as NSError { print("TVMaze failed for getShowList : \(error.localizedDescription)") }
        
        
        chronoOther = chronoOther + Date().timeIntervalSince(startChrono)
        return (showNames, showIds)
    }
    
}
