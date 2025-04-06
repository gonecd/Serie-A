//
//  IMdb.swift
//  SerieA
//
//  Created by Cyril Delamare on 04/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup
import Gzip

class IMdb : NSObject {
    var IMDBrates : NSMutableDictionary = NSMutableDictionary()
    var chrono : TimeInterval = 0
    let dateFormIMDB   = DateFormatter()

    override init() {
        super.init()
        dateFormIMDB.dateFormat = "dd MMM yyyy"
        dateFormIMDB.locale = Locale(identifier: "fr_FR")
    }

    func downloadData() {
        downloadRatings()
    }

    func loadDataFile() {
        let startChrono  :  Date = Date()
        if FileManager.default.fileExists(atPath :  IMdbDir.appendingPathComponent("ratings.tsv").path) {
            let contents = try! String(contentsOfFile :  IMdbDir.appendingPathComponent("ratings.tsv").path, encoding: .utf8)
            let rows = contents.components(separatedBy :  "\n")
            for row in rows {
                let columns = row.components(separatedBy :  "\t")
                IMDBrates.setValue(row, forKey :  columns[0])
            }
        }
        chrono = chrono + Date().timeIntervalSince(startChrono)
        
        print ("Loading duration : \(Date().timeIntervalSince(startChrono))")
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
    
        
    func downloadEpisodes() {
        let startChrono: Date = Date()
//        var listeShows : String = ""
        
        // Loading from IMDB
        if FileManager.default.fileExists(atPath: IMdbDir.appendingPathComponent("episode.tsv").path) {
            try! FileManager.default.removeItem(at: IMdbDir.appendingPathComponent("episode.tsv"))
        }
        print ("REMOVE FILE = \(Date().timeIntervalSince(startChrono))")

        // Unzipping
        //  grep tt1641349 data.tsv | awk -F'\t' '{printf "\""$2"-s"$3"-e"$4"\" : \""$1"\",\n"}' | sort
        let rawData = NSData(contentsOf :  URL(string: "https://datasets.imdbws.com/title.episode.tsv.gz")!)
        print ("DOWNLOAD FILE = \(Date().timeIntervalSince(startChrono))")
//        let unzippedData  :  Data = rawData! as Data
//        try! unzippedData.gunzipped().write(to :  IMdbDir.appendingPathComponent("episode.tsv"))

        
        let unzippedData: Data = try! (rawData! as Data).gunzipped()
        print ("UNZIP FILE = \(Date().timeIntervalSince(startChrono))")

//        // Building my shows list
//        for oneShow in db.shows {
//            listeShows.append(oneShow.idIMdb)
//        }
//        print ("CREATE IDs LIST = \(Date().timeIntervalSince(startChrono)) - \(listeShows.count) lines")
//
//        // Parsing
//        let str = unzippedData.withUnsafeBytes { String(decoding: $0, as: UTF8.self) }
//        //let rows = str.utf8.split(separator: UInt8(ascii: "\n"))
//        let rows = str.components(separatedBy: "\n")
//        print ("SPLITTING FILE = \(Date().timeIntervalSince(startChrono)) - \(rows.count) lines")
//
//        // Selecting my shows
//        var myEpisodes : String = ""
//        for row in rows {
//            //let columns = row.split(separator: UInt8(ascii: "\t"))
//            let columns = row.components(separatedBy: "\t")
//            if (columns.count > 2) {
//                //if(listeShows.contains(String(columns[1])!)) {
//                if( listeShows.contains(columns[1]) ) {
//                    myEpisodes = myEpisodes + row + "\n"
//                }
//            }
//        }
//        print ("PARSING FILE = \(Date().timeIntervalSince(startChrono))")

        // Saving
        //try! myEpisodes.data(using: .utf8)!.write(to: IMdbDir.appendingPathComponent("episode.tsv"))
        try! unzippedData.write(to: IMdbDir.appendingPathComponent("episode.tsv"))
        print ("SAVING FILE = \(Date().timeIntervalSince(startChrono))")

        chrono = chrono + Date().timeIntervalSince(startChrono)
    }

    
    func getSerieIDs(uneSerie: Serie) {
        let startChrono: Date = Date()
        
        // tt7005636 : state of hapinesss
        // tt11080216 : en thérapie
        print ("IMDB : getting episodes IDs for \(uneSerie.serie)")

        let fullFile = try! String(contentsOfFile: IMdbDir.appendingPathComponent("episode.tsv").path, encoding: .utf8)
        let extract = fullFile.components(separatedBy: "\n").filter{ $0.contains(uneSerie.idIMdb) }
        
        for oneLine in extract {
            let columns = oneLine.components(separatedBy: "\t")
            
            let uneSaison : Int = Int(columns[2]) ?? 0
            let unEpisode : Int = Int(columns[3]) ?? 0
            
            if ( (uneSaison != 0) && (unEpisode != 0) && (uneSaison <= uneSerie.saisons.count) && (unEpisode <= uneSerie.saisons[uneSaison-1].episodes.count) ) {
                uneSerie.saisons[uneSaison-1].episodes[unEpisode-1].idIMdb = columns[0]
            }
        }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let startChrono: Date = Date()
        for uneSaison in uneSerie.saisons {
            for unEpisode in uneSaison.episodes {
                if ((unEpisode.idIMdb != "") && (unEpisode.date.compare(startChrono) == .orderedAscending) && (unEpisode.date != ZeroDate) ){
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
        return parseShowList(url: "https://www.imdb.com/chart/tvmeter")
    }
    
    func getPopularShows() -> (names: [String], ids: [String]) {
        return parseShowList(url: "https://www.imdb.com/chart/toptv")
    }

    func parseShowList(url: String) -> (names: [String], ids: [String]) {
        let startChrono: Date = Date()
        var showNames: [String] = []
        var showIds: [String] = []
        var compteur : Int = 0

        do {
            let page : String = try String(contentsOf: URL(string: url)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
//            let showList = try doc.select("tr")
            let showList = try doc.select("div [class='ipc-title ipc-title--base ipc-title--title ipc-title-link-no-icon ipc-title--on-textPrimary sc-a69a4297-2 bqNXEn cli-title with-margin']")
            
            for oneShow in showList {
                if (compteur < popularShowsPerSource) {
//                    let showName : String = try oneShow.select("td")[1].select("a").text()
//                    let IMDBid : String = try oneShow.select("td")[1].select("a").attr("href").components(separatedBy: "/")[2]
                    let showName : String = try oneShow.text()
                    let IMDBid : String = try oneShow.select("a").attr("href").components(separatedBy: "/")[2]

                    compteur = compteur + 1
                    showNames.append(showName)
                    showIds.append(IMDBid)
                }
            }
        }
        catch let error as NSError { print("IMdb failed for getShowList : \(error.localizedDescription)") }
        
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return (showNames, showIds)
    }
    
    func getCritics(IMDBid: String, saison: Int) -> [Critique] {
        let startChrono : Date = Date()
        var result : [Critique] = []
        
        if (IMDBid == "") { return result }
        let webPage : String = "https://www.imdb.com/title/\(IMDBid)/reviews/?ref_=tt_ururv_sm"
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            
            let critics = try doc.select("article")
            
            for oneCritic in critics {
                let uneCritique : Critique = Critique()
                
                uneCritique.source = srcIMdb

                uneCritique.journal = try oneCritic.select("div [data-testid='review-summary']").text()
                uneCritique.note = try oneCritic.select("span [class='ipc-rating-star--rating']").text()
                uneCritique.lien = try "https://www.imdb.com" + oneCritic.select("div [data-testid='review-summary']").select("a").attr("href")
                uneCritique.auteur = try oneCritic.select("[data-testid='author-link']").text()
                uneCritique.texte = try oneCritic.select("[data-testid='review-overflow']").text()
                uneCritique.saison = saison
                
                if (uneCritique.note != "") { uneCritique.note = uneCritique.note + " / 10"}
                
                let dateString : String = try oneCritic.select("[class='ipc-inline-list__item review-date']").text()
                let dateTmp : Date = dateFormIMDB.date(from: dateString) ?? ZeroDate
                uneCritique.date = dateFormLong.string(from: dateTmp)
                
                if (uneCritique.texte != "") { result.append(uneCritique) }
            }
        }
        catch let error as NSError { print("IMDB getCritics failed for id \(IMDBid): \(error.localizedDescription)") }

        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    func getComments(IMDBid : String) -> [Critique] {
        let startChrono : Date = Date()
        var result : [Critique] = []
        let url : String = "https://www.imdb.com/title/\(IMDBid)/reviews?spoiler=hide&sort=helpfulnessScore&dir=desc&ratingFilter=0"
        
        do {
            let page : String = try String(contentsOf: URL(string: url)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            let commentList = try doc.select("div [class='review-container']")
            
            for oneComment in commentList {
                let uneCritique : Critique = Critique()
                
                uneCritique.source = srcIMdb
                uneCritique.journal = try oneComment.select("[class='title']").text()
                uneCritique.auteur = try oneComment.select("[class='display-name-link']").text()
                uneCritique.texte = try oneComment.select("div [class='text']").text()
                uneCritique.note = try oneComment.select("[class='rating-other-user-rating']").text()

                let dateString : String = try oneComment.select("[class='review-date']").text()
                let dateTmp : Date = dateFormIMDB.date(from: dateString) ?? ZeroDate
                uneCritique.date = dateFormLong.string(from: dateTmp)

                result.append(uneCritique)
            }
        }
        catch let error as NSError { print("IMdb failed for getShowList : \(error.localizedDescription)") }

        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    func getParentalGuide(IMDBid : String) -> NSMutableDictionary {
        let startChrono : Date = Date()
        let result : NSMutableDictionary = NSMutableDictionary()
        let url : String = "https://www.imdb.com/title/\(IMDBid)/parentalguide"
        
        result["#nudity"] = "Unknown"
        result["#violence"] = "Unknown"
        result["#profanity"] = "Unknown"
        result["#alcohol"] = "Unknown"
        result["#frightening"] = "Unknown"

        do {
            let page : String = try String(contentsOf: URL(string: url)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            let GuideItems = try doc.select("[class*='sc-44677bd0-0 PLgPc']")

            for guideItem in GuideItems {
                let section : String = try guideItem.select("a").attr("href")
                let severity :String = try guideItem.select("div [class='ipc-html-content-inner-div']").text()
                
                if (severity != "") {
                    result[section] = severity
                }
            }
        }
        catch let error as NSError { print("IMdb failed for getShowList : \(error.localizedDescription)") }

        chrono = chrono + Date().timeIntervalSince(startChrono)
        
        return result
    }
    
}
