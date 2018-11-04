//
//  Serie.swift
//  Seriez
//
//  Created by Cyril Delamare on 02/01/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation



class Serie : NSObject, NSCoding
{
    // Source Trakt
    var serie : String
    var saisons : [Saison] = [Saison]()
    var idIMdb : String = String()
    var idTrakt : String = String()
    var idTVdb : String = String()
    var idMoviedb : String = String()
    
    var unfollowed : Bool = false
    var watchlist : Bool = false
    
    // Source TheTVdb
    var network : String = String()
    var banner : String = String()
    var poster : String = String()
    var status : String = String()
    var resume : String = String()
    var genres : [String] = []
    var year : Int = 0
    
    // General infos
    var ratingIMDB : Int = 0
    var ratersIMDB : Int = 0
    var ratingTVDB : Int = 0
    var ratersTVDB : Int = 0
    var ratingTrakt : Int = 0
    var ratersTrakt: Int = 0
    var ratingBetaSeries : Int = 0
    var ratersBetaSeries : Int = 0
    var ratingMovieDB : Int = 0
    var ratersMovieDB : Int = 0
    var country : String = ""
    var language : String = ""
    var runtime : Int = 0
    var homepage : String = ""
    var nbSaisons : Int = 0
    var nbEpisodes : Int = 0
    var certification : String = ""
    
    
    init(serie:String)
    {
        self.serie = serie
    }
    
    
    required init(coder decoder: NSCoder) {
        self.serie = decoder.decodeObject(forKey: "serie") as? String ?? ""
        self.saisons = decoder.decodeObject(forKey: "saisons") as? [Saison] ?? []
        self.idIMdb = decoder.decodeObject(forKey: "idIMdb") as? String ?? ""
        self.idTrakt = decoder.decodeObject(forKey: "idTrakt") as? String ?? ""
        self.idTVdb = decoder.decodeObject(forKey: "idTVdb") as? String ?? ""
        self.idMoviedb = decoder.decodeObject(forKey: "idMoviedb") as? String ?? ""
        
        self.unfollowed = decoder.decodeBool(forKey: "unfollowed")
        self.watchlist = decoder.decodeBool(forKey: "watchlist")
        
        self.network = decoder.decodeObject(forKey: "network") as? String ?? ""
        self.banner = decoder.decodeObject(forKey: "banner") as? String ?? ""
        self.poster = decoder.decodeObject(forKey: "poster") as? String ?? ""
        self.status = decoder.decodeObject(forKey: "status") as? String ?? ""
        self.resume = decoder.decodeObject(forKey: "resume") as? String ?? ""
        self.genres = decoder.decodeObject(forKey: "genres") as? [String] ?? []
        
        self.year = decoder.decodeInteger(forKey: "year")
        
        self.ratingIMDB = decoder.decodeInteger(forKey: "ratingIMDB")
        self.ratersIMDB = decoder.decodeInteger(forKey: "ratersIMDB")
        self.ratingTVDB = decoder.decodeInteger(forKey: "ratingTVDB")
        self.ratersTVDB = decoder.decodeInteger(forKey: "ratersTVDB")
        self.ratingTrakt = decoder.decodeInteger(forKey: "ratingTrakt")
        self.ratersTrakt = decoder.decodeInteger(forKey: "ratersTrakt")
        self.ratingBetaSeries = decoder.decodeInteger(forKey: "ratingBetaSeries")
        self.ratersBetaSeries = decoder.decodeInteger(forKey: "ratersBetaSeries")
        self.ratingMovieDB = decoder.decodeInteger(forKey: "ratingMovieDB")
        self.ratersMovieDB = decoder.decodeInteger(forKey: "ratersMovieDB")
        
        self.country = decoder.decodeObject(forKey: "country") as? String ?? ""
        self.language = decoder.decodeObject(forKey: "language") as? String ?? ""
        self.runtime = decoder.decodeInteger(forKey: "runtime")
        self.homepage = decoder.decodeObject(forKey: "homepage") as? String ?? ""
        self.nbSaisons = decoder.decodeInteger(forKey: "nbSaisons")
        self.nbEpisodes = decoder.decodeInteger(forKey: "nbEpisodes")
        self.certification = decoder.decodeObject(forKey: "certification") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.serie, forKey: "serie")
        coder.encode(self.saisons, forKey: "saisons")
        coder.encode(self.idIMdb, forKey: "idIMdb")
        coder.encode(self.idTrakt, forKey: "idTrakt")
        coder.encode(self.idTVdb, forKey: "idTVdb")
        coder.encode(self.idMoviedb, forKey: "idMoviedb")
        
        coder.encode(self.unfollowed, forKey: "unfollowed")
        coder.encode(self.watchlist, forKey: "watchlist")
        
        coder.encode(self.network, forKey: "network")
        coder.encode(self.banner, forKey: "banner")
        coder.encode(self.poster, forKey: "poster")
        coder.encode(self.status, forKey: "status")
        coder.encode(self.resume, forKey: "resume")
        coder.encode(self.genres, forKey: "genres")
        
        coder.encodeCInt(Int32(self.year), forKey: "year")
        
        coder.encodeCInt(Int32(self.ratingIMDB), forKey: "ratingIMDB")
        coder.encodeCInt(Int32(self.ratersIMDB), forKey: "ratersIMDB")
        coder.encodeCInt(Int32(self.ratingTVDB), forKey: "ratingTVDB")
        coder.encodeCInt(Int32(self.ratersTVDB), forKey: "ratersTVDB")
        coder.encodeCInt(Int32(self.ratingTrakt), forKey: "ratingTrakt")
        coder.encodeCInt(Int32(self.ratersTrakt), forKey: "ratersTrakt")
        coder.encodeCInt(Int32(self.ratingBetaSeries), forKey: "ratingBetaSeries")
        coder.encodeCInt(Int32(self.ratersBetaSeries), forKey: "ratersBetaSeries")
        coder.encodeCInt(Int32(self.ratingMovieDB), forKey: "ratingMovieDB")
        coder.encodeCInt(Int32(self.ratersMovieDB), forKey: "ratersMovieDB")
        
        coder.encode(self.country, forKey: "country")
        coder.encode(self.language, forKey: "language")
        coder.encodeCInt(Int32(self.runtime), forKey: "runtime")
        coder.encode(self.homepage, forKey: "homepage")
        coder.encodeCInt(Int32(self.nbSaisons), forKey: "nbSaisons")
        coder.encodeCInt(Int32(self.nbEpisodes), forKey: "nbEpisodes")
        coder.encode(self.certification, forKey: "certification")
        
    }
    
    func merge(_ uneSerie : Serie)
    {
        if (uneSerie.network != "")         { self.network = uneSerie.network }
        if (uneSerie.banner != "")          { self.banner = uneSerie.banner }
        if (uneSerie.poster != "")          { self.banner = uneSerie.poster }
        if (uneSerie.status != "")          { self.status = uneSerie.status }
        if (uneSerie.resume != "")          { self.resume = uneSerie.resume }
        if (uneSerie.genres != [])          { self.genres = uneSerie.genres }
        if (uneSerie.idIMdb != "")          { self.idIMdb = uneSerie.idIMdb }
        if (uneSerie.idTrakt != "")         { self.idTrakt = uneSerie.idTrakt }
        if (uneSerie.idTVdb != "")          { self.idTVdb = uneSerie.idTVdb }
        if (uneSerie.idMoviedb != "")       { self.idMoviedb = uneSerie.idMoviedb }
        if (uneSerie.unfollowed != false)   { self.unfollowed = uneSerie.unfollowed }
        if (uneSerie.watchlist != false)    { self.watchlist = uneSerie.watchlist }
        
        if (uneSerie.year != 0)             { self.year = uneSerie.year }
        
        if (uneSerie.ratingIMDB != 0)       { self.ratingIMDB = uneSerie.ratingIMDB }
        if (uneSerie.ratersIMDB != 0)       { self.ratersIMDB = uneSerie.ratersIMDB }
        if (uneSerie.ratingTVDB != 0)       { self.ratingTVDB = uneSerie.ratingTVDB }
        if (uneSerie.ratersTVDB != 0)       { self.ratersTVDB = uneSerie.ratersTVDB }
        if (uneSerie.ratingTrakt != 0)      { self.ratingTrakt = uneSerie.ratingTrakt }
        if (uneSerie.ratersTrakt != 0)      { self.ratersTrakt = uneSerie.ratersTrakt }
        if (uneSerie.ratingBetaSeries != 0) { self.ratingBetaSeries = uneSerie.ratingBetaSeries }
        if (uneSerie.ratersBetaSeries != 0) { self.ratersBetaSeries = uneSerie.ratersBetaSeries }
        if (uneSerie.ratingMovieDB != 0)    { self.ratingMovieDB = uneSerie.ratingMovieDB }
        if (uneSerie.ratersMovieDB != 0)    { self.ratersMovieDB = uneSerie.ratersMovieDB }
        
        if (uneSerie.country != "")         { self.country = uneSerie.country }
        if (uneSerie.language != "")        { self.language = uneSerie.language }
        if (uneSerie.runtime != 0)          { self.runtime = uneSerie.runtime }
        if (uneSerie.homepage != "")        { self.homepage = uneSerie.homepage }
        if (uneSerie.nbSaisons != 0)        { self.nbSaisons = uneSerie.nbSaisons }
        if (uneSerie.nbEpisodes != 0)       { self.nbEpisodes = uneSerie.nbEpisodes }
        if (uneSerie.certification != "")   { self.certification = uneSerie.certification }
        
        for uneSaison in uneSerie.saisons
        {
            if (uneSaison.saison <= self.saisons.count)
            {
                self.saisons[uneSaison.saison - 1].merge(uneSaison)
            }
            else
            {
                self.saisons.append(uneSaison)
            }
        }
    }
    
    func mergeStatuses(_ updatedSerie : Serie)
    {
        self.unfollowed = updatedSerie.unfollowed
        self.watchlist = updatedSerie.watchlist
        
        for updatedSaison in updatedSerie.saisons
        {
            if (updatedSaison.saison <= self.saisons.count)
            {
                self.saisons[updatedSaison.saison - 1].mergeStatuses(updatedSaison)
            }
        }
    }
    
    
    func getGlobalRating() -> Int
    {
        var total : Int = 0
        var nb : Int = 0
        
        if (getFairGlobalRatingTrakt() != 0)
        {
            total = total + getFairGlobalRatingTrakt()
            nb = nb + 1
        }
        
        if (getFairGlobalRatingTVdb() != 0)
        {
            total = total + getFairGlobalRatingTVdb()
            nb = nb + 1
        }
        
        if (getFairGlobalRatingBetaSeries() != 0)
        {
            total = total + getFairGlobalRatingBetaSeries()
            nb = nb + 1
        }
        
        if (getFairGlobalRatingMoviedb() != 0)
        {
            total = total + getFairGlobalRatingMoviedb()
            nb = nb + 1
        }
        
        if (getFairGlobalRatingIMdb() != 0)
        {
            total = total + getFairGlobalRatingIMdb()
            nb = nb + 1
        }
        
        if (nb > 0)
        {
            return Int(Double(total) / Double(nb))
        }
        else
        {
            return 0
        }
    }
    
    func getFairRatingTrakt() -> Int
    {
        var total : Int = 0
        var nb : Int = 0
        
        for saison in self.saisons {
            if (saison.getFairRatingTrakt() != 0)
            {
                total = total + saison.getFairRatingTrakt()
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
        
        for saison in self.saisons {
            if (saison.getFairRatingTVdb() != 0)
            {
                total = total + saison.getFairRatingTVdb()
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
        
        for saison in self.saisons {
            if (saison.getFairRatingBetaSeries() != 0)
            {
                total = total + saison.getFairRatingBetaSeries()
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
        
        for saison in self.saisons {
            if (saison.getFairRatingMoviedb() != 0)
            {
                total = total + saison.getFairRatingMoviedb()
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
        
        for saison in self.saisons {
            if (saison.getFairRatingIMdb() != 0)
            {
                total = total + saison.getFairRatingIMdb()
                nb = nb + 1
            }
        }
        
        if (nb != 0) { return Int(Double(total) / Double(nb)) }
        return 0
    }
    
    func cleverMerge(TVdb : Serie, Moviedb : Serie, Trakt : Serie, BetaSeries : Serie, IMDB : Serie)
    {
        if (Trakt.serie != "") { self.serie = Trakt.serie }
        else if (Moviedb.serie != "") { self.serie = Moviedb.serie }
        else if (BetaSeries.serie != "") { self.serie = BetaSeries.serie }
        else { self.serie = TVdb.serie }
        
        if (Trakt.idIMdb != "") { self.idIMdb = Trakt.idIMdb }
        else if (Moviedb.idIMdb != "") { self.idIMdb = Moviedb.idIMdb }
        else if (BetaSeries.idIMdb != "") { self.idIMdb = BetaSeries.idIMdb }
        else { self.idIMdb = TVdb.idIMdb }
        
        if (Trakt.idTrakt != "") { self.idTrakt = Trakt.idTrakt }
        
        if (Trakt.idTVdb != "") { self.idTVdb = Trakt.idTVdb }
        else if (TVdb.idTVdb != "") { self.idTVdb = TVdb.idTVdb }
        else if (Moviedb.idTVdb != "") { self.idTVdb = Moviedb.idTVdb }
        else { self.idTVdb = BetaSeries.idTVdb }
        
        if (Moviedb.idMoviedb != "") { self.idMoviedb = Moviedb.idMoviedb }
        else { self.idMoviedb = Trakt.idMoviedb }
        
        self.ratingTrakt = Trakt.ratingTrakt
        self.ratingTVDB = TVdb.ratingTVDB
        self.ratingBetaSeries = BetaSeries.ratingBetaSeries
        self.ratingMovieDB = Moviedb.ratingMovieDB
        self.ratingIMDB = IMDB.ratingIMDB
        
        self.ratersTrakt = Trakt.ratersTrakt
        self.ratersTVDB = TVdb.ratersTVDB
        self.ratersBetaSeries = BetaSeries.ratersBetaSeries
        self.ratersMovieDB = Moviedb.ratersMovieDB
        self.ratersIMDB = IMDB.ratersIMDB
        
        if (Trakt.country != "") { self.country = Trakt.country }
        else { self.country = Moviedb.country }
        
        if (TVdb.banner != "") { self.banner = TVdb.banner }
        else { self.banner = BetaSeries.banner }
        
        if (Moviedb.poster != "") { self.poster = Moviedb.poster }
        else { self.poster = BetaSeries.poster }
        
        if (Trakt.year != 0) { self.year = Trakt.year }
        else { self.year = BetaSeries.year }
        
        if (Trakt.homepage != "") { self.homepage = Trakt.homepage }
        else { self.homepage = Moviedb.homepage }
        
        if (Trakt.language != "") { self.language = Trakt.language }
        else if (BetaSeries.language != "") { self.language = BetaSeries.language }
        else { self.language = Moviedb.language }
        
        if (BetaSeries.nbSaisons != 0) { self.nbSaisons = BetaSeries.nbSaisons }
        else { self.nbSaisons = Moviedb.nbSaisons }

        if (Trakt.nbEpisodes != 0) { self.nbEpisodes = Trakt.nbEpisodes }
        else if (Moviedb.nbEpisodes != 0) { self.nbEpisodes = Moviedb.nbEpisodes }
        else { self.nbEpisodes = BetaSeries.nbEpisodes }
        
        if (Trakt.runtime != 0) { self.runtime = Trakt.runtime }
        else if (TVdb.runtime != 0) { self.runtime = TVdb.runtime }
        else if (BetaSeries.runtime != 0) { self.runtime = BetaSeries.runtime }
        else { self.runtime = Moviedb.runtime }
        
        if (Trakt.network != "") { self.network = Trakt.network }
        else if (Moviedb.network != "") { self.network = Moviedb.network }
        else if (BetaSeries.network != "") { self.network = BetaSeries.network }
        else { self.network = TVdb.network }
        
        if (Trakt.certification != "") { self.certification = Trakt.certification }
        else if (BetaSeries.certification != "") { self.certification = BetaSeries.certification }
        else { self.certification = TVdb.certification }
        
        if (Trakt.resume != "") { self.resume = Trakt.resume }
        else if (Moviedb.resume != "") { self.resume = Moviedb.resume }
        else if (BetaSeries.resume != "") { self.resume = BetaSeries.resume }
        else { self.resume = TVdb.resume }
        
        if (Moviedb.genres != []) { self.genres = Moviedb.genres }
        else if (TVdb.genres != []) { self.genres = TVdb.genres }
        else if (BetaSeries.genres != []) { self.genres = BetaSeries.genres }
        else { self.genres = Trakt.genres }
        
        if (TVdb.status != "") { self.status = TVdb.status }
        else if (BetaSeries.status != "") { self.status = BetaSeries.status }
        else if (Trakt.status != "") { self.status = Trakt.status }
        else { self.status = Moviedb.status }
        
        for uneSaison in self.saisons
        {
            if (Moviedb.saisons.count >= uneSaison.saison)
            {
                if (uneSaison.starts == ZeroDate) { uneSaison.starts = Moviedb.saisons[uneSaison.saison - 1].starts }
            }
        }

//        for uneSaison in self.saisons
//        {
//            if (uneSaison.saison <= Moviedb.saisons.count)
//            {
//                if (uneSaison.nbEpisodes < Moviedb.saisons[uneSaison.saison - 1].nbEpisodes) { uneSaison.watched = false }
//                if (Moviedb.saisons[uneSaison.saison - 1].nbEpisodes != 0) { uneSaison.nbEpisodes = Moviedb.saisons[uneSaison.saison - 1].nbEpisodes }
//                if (Moviedb.saisons[uneSaison.saison - 1].starts != ZeroDate) { uneSaison.starts = Moviedb.saisons[uneSaison.saison - 1].starts }
//            }
//        }
//        
//        if (self.saisons.count == 0)
//        {
//            self.saisons = Moviedb.saisons
//        }
//        else if (self.saisons.count < Moviedb.saisons.count)
//        {
//            for idSaison in (self.saisons.count + 1)...Moviedb.saisons.count
//            {
//                self.saisons.append(Moviedb.saisons[idSaison - 1])
//            }
//        }
    }
    
    func getFairGlobalRatingTrakt() -> Int
    {
        if (ratersTrakt == 0) { return 0 }
        let val : Int = Int( notesMid + (notesRange * Double(ratingTrakt - moyenneTrakt) / ecartTypeTrakt))
        
        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    func getFairGlobalRatingTVdb() -> Int
    {
        if (ratersTVDB == 0) { return 0 }
        let val : Int =  Int( notesMid + (notesRange * Double(ratingTVDB - moyenneTVdb) / ecartTypeTVdb))
        
        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    func getFairGlobalRatingMoviedb() -> Int
    {
        if (ratersMovieDB == 0) { return 0 }
        let val : Int =  Int( notesMid + (notesRange * Double(ratingMovieDB - moyenneMovieDB) / ecartTypeMovieDB))
        
        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    func getFairGlobalRatingBetaSeries() -> Int
    {
        if (ratersBetaSeries == 0) { return 0 }
        let val : Int =  Int( notesMid + (notesRange * Double(ratingBetaSeries - moyenneBetaSeries) / ecartTypeBetaSeries))
        
        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    func getFairGlobalRatingIMdb() -> Int
    {
        if (ratersIMDB == 0) { return 0 }
        let val : Int =  Int( notesMid + (notesRange * Double(ratingIMDB - moyenneIMDB) / ecartTypeIMDB))
        
        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
}

