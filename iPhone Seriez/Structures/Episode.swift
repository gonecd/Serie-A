//
//  Episode.swift
//  Seriez
//
//  Created by Cyril Delamare on 02/09/2015.
//  Copyright (c) 2015 Home. All rights reserved.
//

import Foundation


class Episode : NSObject, NSCoding
{
    var serie : String
    var saison : Int = 0
    var episode : Int = 0
    
    var watched : Bool = false
    
    // Source TheTVdb
    var ratingTVdb : Int = 0
    var ratersTVdb : Int = 0
    var idTVdb : Int = 0
    var idIMdb : String = ""
    var date : Date = Date.init(timeIntervalSince1970: 0)
    var titre : String = String()
    var resume : String = String()
    
    // Source Trakt
    var ratingTrakt : Int = 0
    var ratersTrakt : Int = 0
    
    // Source BetaSeries
    var ratingBetaSeries : Int = 0
    var ratersBetaSeries : Int = 0
    
    // Source IMdb
    var ratingIMdb : Int = 0
    var ratersIMdb : Int = 0
    
    // Source TheMoviedb
    var ratingMoviedb : Int = 0
    var ratersMoviedb : Int = 0
    
    required init(serie:String, fichier:String, saison:Int, episode:Int)
    {
        self.serie = serie
        self.saison = saison
        self.episode = episode
    }
    
    required init(coder decoder: NSCoder) {
        self.serie = decoder.decodeObject(forKey: "serie") as? String ?? ""
        self.saison = decoder.decodeInteger(forKey: "saison")
        self.episode = decoder.decodeInteger(forKey: "episode")
        self.watched = decoder.decodeBool(forKey: "watched")
        self.ratingTVdb = decoder.decodeInteger(forKey: "ratingTVdb")
        self.idTVdb = decoder.decodeInteger(forKey: "idTVdb")
        self.idIMdb = decoder.decodeObject(forKey: "idIMdb") as? String ?? ""
        self.date = (decoder.decodeObject(forKey: "date") ?? Date.init(timeIntervalSince1970: 0)) as! Date
        self.titre = decoder.decodeObject(forKey: "titre") as? String ?? ""
        self.resume = decoder.decodeObject(forKey: "resume") as? String ?? ""
        self.ratersTVdb = decoder.decodeInteger(forKey: "ratersTVdb")
        self.ratingTrakt = decoder.decodeInteger(forKey: "ratingTrakt")
        self.ratersTrakt = decoder.decodeInteger(forKey: "ratersTrakt")
        self.ratingBetaSeries = decoder.decodeInteger(forKey: "ratingBetaSeries")
        self.ratersBetaSeries = decoder.decodeInteger(forKey: "ratersBetaSeries")
        self.ratingIMdb = decoder.decodeInteger(forKey: "ratingIMdb")
        self.ratersIMdb = decoder.decodeInteger(forKey: "ratersIMdb")
        self.ratingMoviedb = decoder.decodeInteger(forKey: "ratingMoviedb")
        self.ratersMoviedb = decoder.decodeInteger(forKey: "ratersMoviedb")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.serie, forKey: "serie")
        coder.encodeCInt(Int32(self.saison), forKey: "saison")
        coder.encodeCInt(Int32(self.episode), forKey: "episode")
        coder.encode(self.watched, forKey: "watched")
        coder.encode(self.ratingTVdb, forKey: "ratingTVdb")
        coder.encodeCInt(Int32(self.idTVdb), forKey: "idTVdb")
        coder.encode(self.idIMdb, forKey: "idIMdb")
        coder.encode(self.date, forKey: "date")
        coder.encode(self.titre, forKey: "titre")
        coder.encode(self.resume, forKey: "resume")
        coder.encodeCInt(Int32(self.ratersTVdb), forKey: "ratersTVdb")
        coder.encode(self.ratingTrakt, forKey: "ratingTrakt")
        coder.encodeCInt(Int32(self.ratersTrakt), forKey: "ratersTrakt")
        coder.encode(self.ratingBetaSeries, forKey: "ratingBetaSeries")
        coder.encodeCInt(Int32(self.ratersBetaSeries), forKey: "ratersBetaSeries")
        coder.encode(self.ratingIMdb, forKey: "ratingIMdb")
        coder.encodeCInt(Int32(self.ratersIMdb), forKey: "ratersIMdb")
        coder.encode(self.ratingMoviedb, forKey: "ratingMoviedb")
        coder.encodeCInt(Int32(self.ratersMoviedb), forKey: "ratersMoviedb")
    }
    
    init(fichier:String)
    {
        self.serie = "Error"
        self.saison = 0
        
        let regex = try! NSRegularExpression(pattern: "(.*).s([0-9]{1,2})e([0-9]{1,2})(.*?)(?:.(480p|720p|1080p))*(?:.(hdtv|webrip))*(?:.(x264|xvid))*-(.*).(avi|mkv|mp4|m4v)", options: NSRegularExpression.Options.caseInsensitive)
        let nsString = fichier as NSString
        let results = regex.matches(in: fichier, options: [], range: NSMakeRange(0, nsString.length))
        
        if (results.count > 0)
        {
            for i:Int in 0 ..< results.count
            {
                self.serie = (nsString.substring(with: results[i].range(at: 1)) as NSString).replacingOccurrences(of: ".", with: " ")
                self.saison = (nsString.substring(with: results[i].range(at: 2)) as NSString).integerValue
                self.episode = (nsString.substring(with: results[i].range(at: 3)) as NSString).integerValue
            }
        }
    }
    
    func getFairRatingTrakt() -> Int
    {
        if (ratersTrakt == 0) { return 0 }
        if (date.compare(Date()) == .orderedDescending) { return 0 }
        if (ecartTypeTrakt == 0) { return 0 }

        return Int( notesMid + (notesRange * Double(ratingTrakt - moyenneTrakteps) / ecartTypeTrakteps))
    }
    
    func getFairRatingTVdb() -> Int
    {
        if (ratersTVdb == 0) { return 0 }
        if (date.compare(Date()) == .orderedDescending) { return 0 }
        if (ecartTypeTVdb == 0) { return 0 }

        return Int( notesMid + (notesRange * Double(ratingTVdb - moyenneTVdbeps) / ecartTypeTVdbeps))
    }
    
    func getFairRatingBetaSeries() -> Int
    {
        if (ratersBetaSeries == 0) { return 0 }
        if (date.compare(Date()) == .orderedDescending) { return 0 }
        if (ecartTypeBetaSeries == 0) { return 0 }

        return Int( notesMid + (notesRange * Double(ratingBetaSeries - moyenneBetaSerieseps) / ecartTypeBetaSerieseps))
    }
    
    func getFairRatingMoviedb() -> Int
    {
        if (ratersMoviedb == 0) { return 0 }
        if (date.compare(Date()) == .orderedDescending) { return 0 }
        if (ecartTypeMovieDB == 0) { return 0 }

        return Int( notesMid + (notesRange * Double(ratingMoviedb - moyenneMovieDBeps) / ecartTypeMovieDBeps))
    }
    
    func getFairRatingIMdb() -> Int
    {
        if (ratersIMdb == 0) { return 0 }
        if (date.compare(Date()) == .orderedDescending) { return 0 }
        if (ecartTypeIMDB == 0) { return 0 }

        return Int( notesMid + (notesRange * Double(ratingIMdb - moyenneIMDBeps) / ecartTypeIMDBeps))
    }
    
    
    func merge(_ unEpisode : Episode)
    {
        if (unEpisode.serie != "")             { self.serie = unEpisode.serie }
        if (unEpisode.saison != 0)             { self.saison = unEpisode.saison }
        if (unEpisode.episode != 0)            { self.episode = unEpisode.episode }
        if (unEpisode.watched != false)        { self.watched = unEpisode.watched }
        if (unEpisode.ratingTVdb != 0)         { self.ratingTVdb = unEpisode.ratingTVdb }
        if (unEpisode.ratersTVdb != 0)         { self.ratersTVdb = unEpisode.ratersTVdb }
        if (unEpisode.idTVdb != 0)             { self.idTVdb = unEpisode.idTVdb }
        if (unEpisode.idIMdb != "")            { self.idIMdb = unEpisode.idIMdb }
        if (unEpisode.date != Date.init(timeIntervalSince1970: 0))       { self.date = unEpisode.date }
        if (unEpisode.titre != "")             { self.serie = unEpisode.titre }
        if (unEpisode.resume != "")            { self.serie = unEpisode.resume }
        if (unEpisode.ratingTrakt != 0)        { self.ratingTrakt = unEpisode.ratingTrakt }
        if (unEpisode.ratersTrakt != 0)        { self.ratersTrakt = unEpisode.ratersTrakt }
        if (unEpisode.ratingBetaSeries != 0)   { self.ratingBetaSeries = unEpisode.ratingBetaSeries }
        if (unEpisode.ratersBetaSeries != 0)   { self.ratersBetaSeries = unEpisode.ratersBetaSeries }
        if (unEpisode.ratingIMdb != 0)         { self.ratingIMdb = unEpisode.ratingIMdb }
        if (unEpisode.ratersIMdb != 0)         { self.ratersIMdb = unEpisode.ratersIMdb }
        if (unEpisode.ratingMoviedb != 0)      { self.ratingMoviedb = unEpisode.ratingMoviedb }
        if (unEpisode.ratersMoviedb != 0)      { self.ratersMoviedb = unEpisode.ratersMoviedb }
    }
    
    
    func mergeStatuses(_ updatedEpisode : Episode)
    {
        self.watched = updatedEpisode.watched
    }
    
}
