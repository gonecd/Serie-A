//
//  IMdb.swift
//  SerieA
//
//  Created by Cyril Delamare on 04/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SeriesCommon
import Gzip

class IMdb : NSObject {
    var IMDBrates : NSMutableDictionary = NSMutableDictionary()
    var chronoGlobal : TimeInterval = 0
    var chronoRatings : TimeInterval = 0
    var chronoOther : TimeInterval = 0

    override init() {
        super.init()
    }
    
    func getChrono() -> TimeInterval {
        return chronoGlobal+chronoRatings+chronoOther
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
        chronoOther = chronoOther + Date().timeIntervalSince(startChrono)
    }

    
    func downloadData() {
        let startChrono : Date = Date()
        if FileManager.default.fileExists(atPath: IMdbDir.appendingPathComponent("ratings.tsv").path) {
            try! FileManager.default.removeItem(at: IMdbDir.appendingPathComponent("ratings.tsv"))
        }
        
        let rawData = NSData(contentsOf: URL(string: "https://datasets.imdbws.com/title.ratings.tsv.gz")!)
        let unzippedData : Data = rawData! as Data
        try! unzippedData.gunzipped().write(to: IMdbDir.appendingPathComponent("ratings.tsv"))
        chronoOther = chronoOther + Date().timeIntervalSince(startChrono)
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

        chronoRatings = chronoRatings + Date().timeIntervalSince(startChrono)
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
        
        chronoGlobal = chronoGlobal + Date().timeIntervalSince(startChrono)
        return uneSerie
    }

}

