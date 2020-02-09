//
//  IMdb.swift
//  SerieA
//
//  Created by Cyril Delamare on 04/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SeriesCommon
import SwiftSoup
import Gzip

class IMdb : NSObject {
    var IMDBrates : NSMutableDictionary = NSMutableDictionary()
    var chrono : TimeInterval = 0
    
    override init() {
        super.init()
    }
    

    func loadDataFile() {
        let startChrono : Date = Date()
        if FileManager.default.fileExists(atPath: IMdbDir.appendingPathComponent("ratings.tsv").path) {
            let contents = try! String(contentsOfFile: IMdbDir.appendingPathComponent("ratings.tsv").path)
            let rows = contents.components(separatedBy: "\n")
            for row in rows {
                let columns = row.components(separatedBy: "\t")
                IMDBrates.setValue(row, forKey: columns[0])
            }
        }
        chrono = chrono + Date().timeIntervalSince(startChrono)
    }

    
    func downloadData() {
        let startChrono : Date = Date()
        if FileManager.default.fileExists(atPath: IMdbDir.appendingPathComponent("ratings.tsv").path) {
            try! FileManager.default.removeItem(at: IMdbDir.appendingPathComponent("ratings.tsv"))
        }
        
        let rawData = NSData(contentsOf: URL(string: "https://datasets.imdbws.com/title.ratings.tsv.gz")!)
        let unzippedData : Data = rawData! as Data
        try! unzippedData.gunzipped().write(to: IMdbDir.appendingPathComponent("ratings.tsv"))
        chrono = chrono + Date().timeIntervalSince(startChrono)
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono : Date = Date()
        for uneSaison in uneSerie.saisons {
            for unEpisode in uneSaison.episodes {
                if (unEpisode.idIMdb != "") {
                    if (IMDBrates[unEpisode.idIMdb] != nil) {
                        let columns = (IMDBrates[unEpisode.idIMdb] as! String).components(separatedBy: "\t")

                        unEpisode.ratersIMdb = Int(columns[2])!
                        unEpisode.ratingIMdb = Int(10 * Double(columns[1])!)
                    }
                    else {
                        print("IMdb.getEpisodesRatings::Not found for \(unEpisode.serie) S\(unEpisode.saison)E\(unEpisode.episode)")
                    }
                }
            }
        }

        chrono = chrono + Date().timeIntervalSince(startChrono)
    }
    
    
    func getSerieGlobalInfos(idIMDB : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: "")
        
        if ( (IMDBrates[idIMDB] != nil) && (idIMDB != "") ) {
            let columns = (IMDBrates[idIMDB] as! String).components(separatedBy: "\t")
            
            uneSerie.ratersIMDB = Int(columns[2])!
            uneSerie.ratingIMDB = Int(10 * Double(columns[1])!)
        }
        else {
            print("IMDB::getSerieGlobalInfos::Not found for id = \(idIMDB)")
        }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return uneSerie
    }

    
    func getTrendingShows() -> (names : [String], ids : [String]) {
        return getShowList(url: "https://www.imdb.com/chart/tvmeter")
    }
    
    
    func getPopularShows() -> (names : [String], ids : [String]) {
        return getShowList(url: "https://www.imdb.com/chart/toptv")
    }
    

    func getShowList(url : String) -> (names : [String], ids : [String]) {
        let startChrono : Date = Date()
        var showNames : [String] = []
        var showIds : [String] = []
        
        do {
            let page : String = try String(contentsOf: URL(string : url)!)
            let doc : Document = try SwiftSoup.parse(page)
            let showList = try doc.select("tr")
            
            for oneShow in showList {
                if (try oneShow.select("td").count > 1) {
                    let showName : String = try oneShow.select("td")[1].select("a").text()
                    let IMDBid : String = try oneShow.select("td")[1].select("a").attr("href").components(separatedBy: "/")[2]
                    
                    showNames.append(showName)
                    showIds.append(IMDBid)
                }
            }
        }
        catch let error as NSError { print("IMdb failed for getShowList : \(error.localizedDescription)") }
        
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return (showNames, showIds)
    }
    

    func getComments(IMDBid : String) -> [Critique] {
        let startChrono : Date = Date()
        var result : [Critique] = []
        let url : String = "https://www.imdb.com/title/\(IMDBid)/reviews?spoiler=hide&sort=helpfulnessScore&dir=desc&ratingFilter=0"
        
        do {
            let page : String = try String(contentsOf: URL(string : url)!)
            let doc : Document = try SwiftSoup.parse(page)
            let commentList = try doc.select("div [class='review-container']")
            
            for oneComment in commentList {
                let uneCritique : Critique = Critique()
                
                uneCritique.source = srcIMdb
                uneCritique.journal = try oneComment.select("[class='title']").text()
                uneCritique.auteur = try oneComment.select("[class='display-name-link']").text()
                uneCritique.texte = try oneComment.select("div [class='text']").text()
                uneCritique.date = try oneComment.select("[class='review-date']").text()
                uneCritique.note = try oneComment.select("[class='rating-other-user-rating']").text()
                
                result.append(uneCritique)
            }
        }
        catch let error as NSError { print("IMdb failed for getShowList : \(error.localizedDescription)") }

        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
}

