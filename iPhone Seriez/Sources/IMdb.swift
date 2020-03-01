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
    
    let knownIDs : Dictionary = [
        "tt4922804-s2-e1" : "tt6324336",
        "tt4922804-s2-e2" : "tt8343068",
        "tt4922804-s2-e3" : "tt8343074",
        "tt4922804-s2-e4" : "tt8343080",
        "tt4922804-s2-e5" : "tt8343086",
        "tt4922804-s2-e6" : "tt8343088",
        "tt4922804-s2-e7" : "tt8343094",
        "tt4922804-s2-e8" : "tt8343100",
        "tt4922804-s2-e9" : "tt8343098",
        "tt4922804-s2-e10" : "tt8343102",
        "tt4835480-s2-e2" : "tt7898958",
        "tt4835480-s2-e3" : "tt7898960",
        "tt4835480-s2-e4" : "tt7898962",
        "tt4835480-s2-e5" : "tt7976264",
        "tt4835480-s2-e6" : "tt7976278",
        "tt4835480-s2-e7" : "tt7976282",
        "tt4835480-s2-e8" : "tt7976286",
        "tt4835480-s3-e1" : "tt11784442",
        "tt4835480-s3-e2" : "tt11784484",
        "tt4835480-s3-e3" : "",
        "tt4835480-s3-e4" : "",
        "tt7134908-s2-e2" : "tt9141170",
        "tt7134908-s2-e3" : "tt9141174",
        "tt7134908-s2-e4" : "tt9141176",
        "tt7134908-s2-e5" : "tt9141178",
        "tt7134908-s2-e6" : "tt9141180",
        "tt7134908-s2-e7" : "tt9141182",
        "tt7134908-s2-e8" : "tt9141184",
        "tt3006802-s5-e2" : "tt8394320",
        "tt1586680-s10-e4" : "tt10547564",
        "tt1586680-s10-e5" : "tt10547570",
        "tt1586680-s10-e6" : "tt10547578",
        "tt1586680-s10-e7" : "tt10547580",
        "tt1586680-s10-e8" : "tt10547584",
        "tt1586680-s10-e9" : "tt10740404",
        "tt1586680-s10-e10" : "tt10547586",
        "tt1586680-s10-e11" : "tt10547592",
        "tt1586680-s10-e12" : "tt10001184",
        "tt1492179-s1-e1" : "tt1497810",
        "tt1492179-s1-e2" : "tt1497811",
        "tt1492179-s1-e3" : "tt1497812",
        "tt1492179-s1-e4" : "tt1497813",
        "tt1492179-s1-e5" : "tt1497814",
        "tt1492179-s1-e6" : "tt1497815",
        "tt1492179-s2-e1" : "tt1942639",
        "tt1492179-s2-e2" : "tt1942641",
        "tt1492179-s2-e3" : "tt1942642",
        "tt1492179-s2-e4" : "tt1942643",
        "tt1492179-s2-e5" : "tt1942644",
        "tt1492179-s3-e2" : "tt2389288",
        "tt1492179-s3-e3" : "tt2241914",
        "tt1492179-s3-e4" : "tt2296730",
        "tt1492179-s3-e5" : "tt2248372",
        "tt1492179-s3-e6" : "tt2248246",
        "tt1492179-s3-e7" : "tt2226400",
        "tt1492179-s3-e8" : "tt2234470",
        "tt1492179-s3-e9" : "tt2279736",
        "tt1492179-s3-e10" : "tt2325936",
        "tt1492179-s6-e9" : "tt7165098",
        "tt2661044-s6-e1" : "tt8422676",
        "tt2661044-s6-e2" : "tt8883538",
        "tt2661044-s6-e3" : "tt9275110",
        "tt2661044-s6-e4" : "tt9297040",
        "tt2661044-s6-e5" : "tt9317300",
        "tt2661044-s6-e6" : "tt9330104",
        "tt2661044-s6-e7" : "tt9243844",
        "tt2661044-s6-e8" : "tt9348158",
        "tt2661044-s6-e9" : "tt9348162",
        "tt2661044-s6-e10" : "tt9348164",
        "tt2661044-s6-e11" : "tt9348166",
        "tt2661044-s6-e12" : "tt9348168",
        "tt2661044-s6-e13" : "tt9348172",
        "tt4063800-s1-e1" : "tt4352356",
        "tt4063800-s1-e2" : "tt4352372",
        "tt4063800-s1-e3" : "tt4352376",
        "tt4063800-s1-e4" : "tt4352378",
        "tt4063800-s1-e5" : "tt4352380",
        "tt4063800-s1-e6" : "tt4352384",
        "tt4063800-s1-e7" : "tt4352386",
        "tt4063800-s1-e8" : "tt4352390",
        "tt4063800-s1-e9" : "tt4352396",
        "tt4063800-s1-e10" : "tt4352400",
        "tt4063800-s2-e1" : "tt5157964",
        "tt4063800-s2-e2" : "tt5157974",
        "tt4063800-s2-e3" : "tt5278952",
        "tt4063800-s2-e4" : "tt5278956",
        "tt4063800-s2-e5" : "tt5338546",
        "tt4063800-s2-e6" : "tt5274308",
        "tt4063800-s2-e7" : "tt5338554",
        "tt4063800-s2-e8" : "tt5222168",
        "tt4063800-s2-e9" : "tt5338562",
        "tt4063800-s2-e10" : "tt5346526",
        "tt4063800-s3-e1" : "tt6242192",
        "tt4063800-s3-e2" : "tt6242194",
        "tt4063800-s3-e3" : "tt6242196",
        "tt4063800-s3-e4" : "tt6242198",
        "tt4063800-s3-e5" : "tt6242202",
        "tt4063800-s3-e6" : "tt6242204",
        "tt4063800-s3-e7" : "tt6242208",
        "tt4063800-s3-e8" : "tt6242210",
        "tt4063800-s3-e9" : "tt6242212",
        "tt4063800-s3-e10" : "tt6242214",
        "tt1520211-s10-e9" : "tt9729164"
    ]
    
    override init() {
        super.init()
    }

    
    func downloadData() {
        downloadRatings()
        //downloadEpisodes()
    }

    
    func loadDataFile() {
        let startChrono  :  Date = Date()
        if FileManager.default.fileExists(atPath :  IMdbDir.appendingPathComponent("ratings.tsv").path) {
            let contents = try! String(contentsOfFile :  IMdbDir.appendingPathComponent("ratings.tsv").path)
            let rows = contents.components(separatedBy :  "\n")
            for row in rows {
                let columns = row.components(separatedBy :  "\t")
                IMDBrates.setValue(row, forKey :  columns[0])
            }
        }
        chrono = chrono + Date().timeIntervalSince(startChrono)
    }

    
    func downloadRatings() {
        let startChrono  :  Date = Date()
        if FileManager.default.fileExists(atPath: IMdbDir.appendingPathComponent("ratings.tsv").path) {
            try! FileManager.default.removeItem(at: IMdbDir.appendingPathComponent("ratings.tsv"))
        }
        
        let rawData = NSData(contentsOf :  URL(string :  "https://datasets.imdbws.com/title.ratings.tsv.gz")!)
        let unzippedData  :  Data = rawData! as Data
        try! unzippedData.gunzipped().write(to :  IMdbDir.appendingPathComponent("ratings.tsv"))
        chrono = chrono + Date().timeIntervalSince(startChrono)
    }
    
    func getEpisodeID(serieID: String, saison: Int, episode: Int) -> String {
        let key: String = serieID + "-s" + String(saison) + "-e" + String(episode)
        return knownIDs[key] ?? ""
    }

    func getEpisodeID(serieID: String, saison: Int) -> NSMutableDictionary {
        let IMDBepisodes: NSMutableDictionary = NSMutableDictionary()
        let startChrono: Date = Date()

        if FileManager.default.fileExists(atPath: IMdbDir.appendingPathComponent("episode.tsv").path) {
            let contents = try! String(contentsOfFile: IMdbDir.appendingPathComponent("episode.tsv").path)
            let rows = contents.components(separatedBy: .newlines)

            for row in rows {
                if row.contains(serieID + "\t" + String(saison)) {
                    let columns = row.components(separatedBy: "\t")
                    IMDBepisodes.setValue(columns[0], forKey: columns[3])
                }
            }
        }
        chrono = chrono + Date().timeIntervalSince(startChrono)
        
       return IMDBepisodes
    }

    
    func downloadEpisodes() {
        let startChrono: Date = Date()
        if FileManager.default.fileExists(atPath: IMdbDir.appendingPathComponent("episode.tsv").path) {
            try! FileManager.default.removeItem(at: IMdbDir.appendingPathComponent("episode.tsv"))
        }
        
        let rawData = NSData(contentsOf :  URL(string: "https://datasets.imdbws.com/title.episode.tsv.gz")!)
        let unzippedData: Data = rawData! as Data
        try! unzippedData.gunzipped().write(to: IMdbDir.appendingPathComponent("episode.tsv"))
        chrono = chrono + Date().timeIntervalSince(startChrono)
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono: Date = Date()
        for uneSaison in uneSerie.saisons {
            for unEpisode in uneSaison.episodes {
                if (unEpisode.idIMdb != "") {
                    if (IMDBrates[unEpisode.idIMdb] != nil) {
                        let columns = (IMDBrates[unEpisode.idIMdb] as! String).components(separatedBy: "\t")

                        unEpisode.ratersIMdb = Int(columns[2])!
                        unEpisode.ratingIMdb = Int(10 * Double(columns[1])!)
                    }
                    else {
                        print("IMdb.getEpisodesRatings: Not found for \(unEpisode.serie) S\(unEpisode.saison)E\(unEpisode.episode)")
                    }
                }
            }
        }

        chrono = chrono + Date().timeIntervalSince(startChrono)
    }
    
    
    func getSerieGlobalInfos(idIMDB: String) -> Serie {
        let startChrono: Date = Date()
        let uneSerie: Serie = Serie(serie :  "")
        
        if ( (IMDBrates[idIMDB] != nil) && (idIMDB != "") ) {
            let columns = (IMDBrates[idIMDB] as! String).components(separatedBy :  "\t")
            
            uneSerie.ratersIMDB = Int(columns[2])!
            uneSerie.ratingIMDB = Int(10 * Double(columns[1])!)
        }
        else {
            print("IMDB : getSerieGlobalInfos : Not found for id = \(idIMDB)")
        }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return uneSerie
    }

    
    func getTrendingShows() -> (names: [String], ids: [String]) {
        return getShowList(url: "https://www.imdb.com/chart/tvmeter")
    }
    
    
    func getPopularShows() -> (names: [String], ids: [String]) {
        return getShowList(url: "https://www.imdb.com/chart/toptv")
    }
    

    func getShowList(url: String) -> (names: [String], ids: [String]) {
        let startChrono: Date = Date()
        var showNames: [String] = []
        var showIds: [String] = []
        
        do {
            let page : String = try String(contentsOf: URL(string: url)!)
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
            let page : String = try String(contentsOf: URL(string: url)!)
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

