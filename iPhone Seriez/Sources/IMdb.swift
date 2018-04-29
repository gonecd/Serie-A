//
//  IMdb.swift
//  SerieA
//
//  Created by Cyril Delamare on 04/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation

// Path to data source = https://datasets.imdbws.com/title.ratings.tsv.gz


class IMdb : NSObject
{
    var IMDBrates : NSMutableDictionary = NSMutableDictionary()
    
    override init()
    {
        super.init()
    }
    
    func loadDB()
    {
        print("IMdb::Loading Ref")
        
        if let filepath = Bundle.main.path(forResource: "data", ofType: "tsv") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let rows = contents.components(separatedBy: "\n")
                for row in rows {
                    let columns = row.components(separatedBy: "\t")
                    IMDBrates.setValue(row, forKey: columns[0])
                }
            } catch {
                print("IMdb::Loading Ref failed")
            }
        }
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie)
    {
        for uneSaison in uneSerie.saisons
        {
            for unEpisode in uneSaison.episodes
            {
                if (unEpisode.idIMdb != "")
                {
                    if (IMDBrates[unEpisode.idIMdb] != nil)
                    {
                        let columns = (IMDBrates[unEpisode.idIMdb] as! String).components(separatedBy: "\t")

                        unEpisode.ratersIMdb = Int(columns[2])!
                        unEpisode.ratingIMdb = Int(10 * Double(columns[1])!)
                    }
                    else
                    {
                        print("IMdb.getEpisodesRatings::Not found for \(unEpisode.serie) S\(unEpisode.saison)E\(unEpisode.episode)")
                    }
                }
            }
        }
    }
    
    func getSerieGlobalInfos(idIMDB : String) -> Serie
    {
        let uneSerie : Serie = Serie(serie: "")
        
        if ( (IMDBrates[idIMDB] != nil) && (idIMDB != "") )
        {
            let columns = (IMDBrates[idIMDB] as! String).components(separatedBy: "\t")
            
            uneSerie.ratersIMDB = Int(columns[2])!
            uneSerie.ratingIMDB = Int(10 * Double(columns[1])!)
        }
        else
        {
            print("IMDB::getSerieGlobalInfos::Not found for id = \(idIMDB)")
        }
        
        return uneSerie
    }

}

