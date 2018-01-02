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
    var idTVRage : String = String()
    
    // Source TheTVdb
    var ratingTVdb : Double = 0.0
    var ratersTVdb : Int = 0
    var network : String = String()
    var banner : String = String()
    var poster : String = String()
    var status : String = String()
    var resume : String = String()
    var genres : [String] = []
    
    // computed infos
    var year : Int = 0
    
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
        self.idTVRage = decoder.decodeObject(forKey: "idTVRage") as? String ?? ""
        
        self.ratingTVdb = decoder.decodeDouble(forKey: "ratingTVdb")
        self.network = decoder.decodeObject(forKey: "network") as? String ?? ""
        self.banner = decoder.decodeObject(forKey: "banner") as? String ?? ""
        self.poster = decoder.decodeObject(forKey: "poster") as? String ?? ""
        self.status = decoder.decodeObject(forKey: "status") as? String ?? ""
        self.resume = decoder.decodeObject(forKey: "resume") as? String ?? ""
        self.genres = decoder.decodeObject(forKey: "genres") as? [String] ?? []
        
        self.year = decoder.decodeInteger(forKey: "year")
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.serie, forKey: "serie")
        coder.encode(self.saisons, forKey: "saisons")
        coder.encode(self.idIMdb, forKey: "idIMdb")
        coder.encode(self.idTrakt, forKey: "idTrakt")
        coder.encode(self.idTVdb, forKey: "idTVdb")
        coder.encode(self.idTVRage, forKey: "idTVRage")
        
        coder.encode(self.ratingTVdb, forKey: "ratingTVdb")
        coder.encode(self.network, forKey: "network")
        coder.encode(self.banner, forKey: "banner")
        coder.encode(self.poster, forKey: "poster")
        coder.encode(self.status, forKey: "status")
        coder.encode(self.resume, forKey: "resume")
        coder.encode(self.genres, forKey: "genres")
        
        coder.encodeCInt(Int32(self.year), forKey: "year")
        coder.encodeCInt(Int32(self.ratersTVdb), forKey: "ratersTVdb")
    }
    
    func computeSerieInfos() {
        for saison in self.saisons{
            saison.computeSaisonInfos()
        }
    }
    
    func merge(_ uneSerie : Serie)
    {
        if (uneSerie.ratingTVdb != 0.0)     { self.ratingTVdb = uneSerie.ratingTVdb }
        if (uneSerie.ratersTVdb != 0)       { self.ratersTVdb = uneSerie.ratersTVdb }
        if (uneSerie.network != "")         { self.network = uneSerie.network }
        if (uneSerie.banner != "")          { self.banner = uneSerie.banner }
        if (uneSerie.poster != "")          { self.banner = uneSerie.poster }
        if (uneSerie.status != "")          { self.status = uneSerie.status }
        if (uneSerie.resume != "")          { self.resume = uneSerie.resume }
        if (uneSerie.genres != [])          { self.genres = uneSerie.genres }
        if (uneSerie.idIMdb != "")          { self.idIMdb = uneSerie.idIMdb }
        if (uneSerie.idTrakt != "")         { self.idTrakt = uneSerie.idTrakt }
        if (uneSerie.idTVdb != "")          { self.idTVdb = uneSerie.idTVdb }
        if (uneSerie.idTVRage != "")        { self.idTVRage = uneSerie.idTVRage }
        if (uneSerie.year != 0)             { self.year = uneSerie.year }

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
        
        self.computeSerieInfos()
    }
    
}

