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
    
    // Source TheTVdb
    var ratingTVdb : Double = 0.0
    var ratersTVdb : Int = 0
    var idTVdb : Int = 0
    
    // Source Trakt
    var ratingTrakt : Double = 0.0
    var ratersTrakt : Int = 0

    // Source BetaSeries
    var ratingBetaSeries : Double = 0.0
    var ratersBetaSeries : Int = 0
    
    // Source IMdb
    var ratingIMdb : Double = 0.0
    var ratersIMdb : Int = 0
    
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
        self.ratingTVdb = decoder.decodeDouble(forKey: "ratingTVdb")
        self.idTVdb = decoder.decodeInteger(forKey: "idTVdb")
        self.ratersTVdb = decoder.decodeInteger(forKey: "ratersTVdb")
        self.ratingTrakt = decoder.decodeDouble(forKey: "ratingTrakt")
        self.ratersTrakt = decoder.decodeInteger(forKey: "ratersTrakt")
        self.ratingBetaSeries = decoder.decodeDouble(forKey: "ratingBetaSeries")
        self.ratersBetaSeries = decoder.decodeInteger(forKey: "ratersBetaSeries")
        self.ratingIMdb = decoder.decodeDouble(forKey: "ratingIMdb")
        self.ratersIMdb = decoder.decodeInteger(forKey: "ratersIMdb")
   }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.serie, forKey: "serie")
        coder.encodeCInt(Int32(self.saison), forKey: "saison")
        coder.encodeCInt(Int32(self.episode), forKey: "episode")
        coder.encode(self.ratingTVdb, forKey: "ratingTVdb")
        coder.encodeCInt(Int32(self.idTVdb), forKey: "idTVdb")
        coder.encodeCInt(Int32(self.ratersTVdb), forKey: "ratersTVdb")
        coder.encode(self.ratingTrakt, forKey: "ratingTrakt")
        coder.encodeCInt(Int32(self.ratersTrakt), forKey: "ratersTrakt")
        coder.encode(self.ratingBetaSeries, forKey: "ratingBetaSeries")
        coder.encodeCInt(Int32(self.ratersBetaSeries), forKey: "ratersBetaSeries")
        coder.encode(self.ratingIMdb, forKey: "ratingIMdb")
        coder.encodeCInt(Int32(self.ratersIMdb), forKey: "ratersIMdb")
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
    
    
    func merge(_ unEpisode : Episode)
    {
        if (unEpisode.serie != "")         { self.serie = unEpisode.serie }
        if (unEpisode.saison != 0)         { self.saison = unEpisode.saison }
        if (unEpisode.episode != 0)        { self.episode = unEpisode.episode }
        if (unEpisode.ratingTVdb != 0.0)   { self.ratingTVdb = unEpisode.ratingTVdb }
        if (unEpisode.ratersTVdb != 0)     { self.ratersTVdb = unEpisode.ratersTVdb }
        if (unEpisode.idTVdb != 0)         { self.idTVdb = unEpisode.idTVdb }
        if (unEpisode.ratingTrakt != 0.0)      { self.ratingTrakt = unEpisode.ratingTrakt }
        if (unEpisode.ratersTrakt != 0)        { self.ratersTrakt = unEpisode.ratersTrakt }
        if (unEpisode.ratingBetaSeries != 0.0) { self.ratingBetaSeries = unEpisode.ratingBetaSeries }
        if (unEpisode.ratersBetaSeries != 0)   { self.ratersBetaSeries = unEpisode.ratersBetaSeries }
        if (unEpisode.ratingIMdb != 0.0)       { self.ratingIMdb = unEpisode.ratingIMdb }
        if (unEpisode.ratersIMdb != 0)         { self.ratersIMdb = unEpisode.ratersIMdb }
    }
}