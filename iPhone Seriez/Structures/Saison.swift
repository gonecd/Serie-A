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

    var nbEpisodes : Int = 0
    var nbWatchedEps : Int = 0
    var starts : Date = ZeroDate
    var ends : Date = ZeroDate
    
    init(serie:String, saison:Int)
    {
        self.serie = serie
        self.saison = saison
    }
    
    required init(coder decoder: NSCoder) {
        self.serie = decoder.decodeObject(forKey: "serie") as? String ?? ""
        self.saison = decoder.decodeInteger(forKey: "saison")
        self.episodes = decoder.decodeObject(forKey: "episodes") as? [Episode] ?? []
        
        self.nbEpisodes = decoder.decodeInteger(forKey: "nbEpisodes")
        self.nbWatchedEps = decoder.decodeInteger(forKey: "nbWatchedEps")
        self.starts = decoder.decodeObject(forKey: "starts") as? Date ?? ZeroDate
        self.ends = decoder.decodeObject(forKey: "ends") as? Date ?? ZeroDate
  }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.serie, forKey: "serie")
        coder.encodeCInt(Int32(self.saison), forKey: "saison")
        coder.encode(self.episodes, forKey: "episodes")
        
        coder.encodeCInt(Int32(self.nbEpisodes), forKey: "nbEpisodes")
        coder.encodeCInt(Int32(self.nbWatchedEps), forKey: "nbWatchedEps")
        coder.encode(self.starts, forKey: "starts")
        coder.encode(self.ends, forKey: "ends")
    }

    func watched() -> Bool {
        return ((nbWatchedEps == nbEpisodes) && (nbEpisodes != 0))
    }
    
    
    func nbEpisodesDiffuses() -> Int {
        var cpt : Int = 0
        let today : Date = Date()
        
        for unEpisode in episodes {
            if (unEpisode.date.compare(today) == .orderedAscending) { cpt = cpt + 1 }
        }
        
        return cpt
    }
    
    func getFairRatingTrakt() -> Int
    {
        var total : Int = 0
        var nb : Int = 0

        for episode in self.episodes {
            if (episode.getFairRatingTrakt() != 0)
            {
                total = total + episode.getFairRatingTrakt()
                nb = nb + 1
            }
        }

        if (nb != 0) { return Int(Double(total) / Double(nb)) }
        return 0
    }

    func getFairRatingTVdb() -> Int
    {
        var total : Int = 0
        var nb : Int = 0

        for episode in self.episodes {
            if (episode.getFairRatingTVdb() != 0)
            {
                total = total + episode.getFairRatingTVdb()
                nb = nb + 1
            }
        }

        if (nb != 0) { return Int(Double(total) / Double(nb)) }
        return 0
    }

    func getFairRatingBetaSeries() -> Int
    {
        var total : Int = 0
        var nb : Int = 0

        for episode in self.episodes {
            if (episode.getFairRatingBetaSeries() != 0)
            {
                total = total + episode.getFairRatingBetaSeries()
                nb = nb + 1
            }
        }

        if (nb != 0) { return Int(Double(total) / Double(nb)) }
        return 0
    }

    func getFairRatingIMdb() -> Int
    {
        var total : Int = 0
        var nb : Int = 0

        for episode in self.episodes {
            if (episode.getFairRatingIMdb() != 0)
            {
                total = total + episode.getFairRatingIMdb()
                nb = nb + 1
            }
        }

        if (nb != 0) { return Int(Double(total) / Double(nb)) }
        return 0
    }



    func getFairRatingMoviedb() -> Int
    {
        var total : Int = 0
        var nb : Int = 0

        for episode in self.episodes {
            if (episode.getFairRatingMoviedb() != 0)
            {
                total = total + episode.getFairRatingMoviedb()
                nb = nb + 1
            }
        }

        if (nb != 0) { return Int(Double(total) / Double(nb)) }
        return 0
    }
    
    
    func merge(_ uneSaison : Saison)
    {
        if (uneSaison.serie != "")         { self.serie = uneSaison.serie }
        if (uneSaison.saison != 0)         { self.saison = uneSaison.saison }
        if (uneSaison.nbWatchedEps != 0)   { self.nbWatchedEps = uneSaison.nbWatchedEps }

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
        if (uneSaison.nbEpisodes != 0)    { self.nbEpisodes = uneSaison.nbEpisodes }
        if (uneSaison.starts != ZeroDate) { self.starts = uneSaison.starts }
        if (uneSaison.ends != ZeroDate)   { self.ends = uneSaison.ends }
    }

}
