//
//  Saison.swift
//  Seriez
//
//  Created by Cyril Delamare on 02/01/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation


class Saison : NSObject, NSCoding
{
    var serie : String
    var saison : Int
    var episodes : [Episode] = [Episode]()

    var ratingTrakt : Double = 0.0
    var ratingTVdb : Double = 0.0
    var ratingBetaSeries : Double = 0.0
    var ratingIMdb : Double = 0.0
    
    init(serie:String, saison:Int)
    {
        self.serie = serie
        self.saison = saison
    }
    
    required init(coder decoder: NSCoder) {
        self.serie = decoder.decodeObject(forKey: "serie") as? String ?? ""
        self.saison = decoder.decodeInteger(forKey: "saison")
        self.episodes = decoder.decodeObject(forKey: "episodes") as? [Episode] ?? []
        self.ratingTrakt = decoder.decodeDouble(forKey: "ratingTrakt")
        self.ratingTVdb = decoder.decodeDouble(forKey: "ratingTVdb")
        self.ratingBetaSeries = decoder.decodeDouble(forKey: "ratingBetaSeries")
        self.ratingIMdb = decoder.decodeDouble(forKey: "ratingIMdb")
  }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.serie, forKey: "serie")
        coder.encodeCInt(Int32(self.saison), forKey: "saison")
        coder.encode(self.episodes, forKey: "episodes")
        coder.encode(self.ratingTrakt, forKey: "ratingTrakt")
        coder.encode(self.ratingTVdb, forKey: "ratingTVdb")
        coder.encode(self.ratingBetaSeries, forKey: "ratingBetaSeries")
        coder.encode(self.ratingIMdb, forKey: "ratingIMdb")
    }

    func computeSaisonInfos() {
        
        var totTrakt : Double = 0.0
        var totTVdb : Double = 0.0
        var totBetaSeries : Double = 0.0
        var totIMdb : Double = 0.0
        var nbTrakt : Int = 0
        var nbTVdb : Int = 0
        var nbBetaSeries : Int = 0
        var nbIMdb : Int = 0
        
        for episode in self.episodes {
            if (episode.ratingTrakt != 0.0)
            {
                totTrakt = totTrakt + episode.ratingTrakt
                nbTrakt = nbTrakt + 1
            }
            
            if (episode.ratingTVdb != 0.0)
            {
                totTVdb = totTVdb + episode.ratingTVdb
                nbTVdb = nbTVdb + 1
            }
            
            if (episode.ratingBetaSeries != 0.0)
            {
                totBetaSeries = totBetaSeries + episode.ratingBetaSeries
                nbBetaSeries = nbBetaSeries + 1
            }
            
            if (episode.ratingIMdb != 0.0)
            {
                totIMdb = totIMdb + episode.ratingIMdb
                nbIMdb = nbIMdb + 1
            }
            
            if (nbTrakt != 0) { self.ratingTrakt = totTrakt / Double(nbTrakt) }
            if (nbTVdb != 0) { self.ratingTVdb = totTVdb / Double(nbTVdb) }
            if (nbBetaSeries != 0) { self.ratingBetaSeries = totBetaSeries / Double(nbBetaSeries) }
            if (nbIMdb != 0) { self.ratingIMdb = totIMdb / Double(nbIMdb) }
        }
    }
    
    func merge(_ uneSaison : Saison)
    {
        if (uneSaison.serie != "")         { self.serie = uneSaison.serie }
        if (uneSaison.saison != 0)         { self.saison = uneSaison.saison }
        
        for unEpisode in uneSaison.episodes
        {
            if (unEpisode.episode <= self.episodes.count)
            {
                self.episodes[unEpisode.episode - 1].merge(unEpisode)
            }
            else
            {
                self.episodes.append(unEpisode)
            }
        }
        
        self.computeSaisonInfos()
    }

    func mergeStatuses(_ uneSaison : Saison)
    {
        for unEpisode in uneSaison.episodes
        {
            if (unEpisode.episode <= self.episodes.count)
            {
                self.episodes[unEpisode.episode - 1].mergeStatuses(unEpisode)
            }
        }
    }

}
