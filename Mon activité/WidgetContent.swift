//
//  WidgetContent.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 09/10/2021.
//  Copyright © 2021 Home. All rights reserved.
//

import WidgetKit
import UIKit


struct MonActiviteData : TimelineEntry {
    var date        : Date      = Date()
    var poster1     : UIImage   = UIImage()
    let data1       : Data4MonActivite
    var poster2     : UIImage   = UIImage()
    let data2       : Data4MonActivite

    public init(dataWidget1 : Data4MonActivite, dataWidget2 : Data4MonActivite) {
        self.data1 = dataWidget1
        self.data2 = dataWidget2
    }
}


struct Data4MonActivite: Codable {
    let serie: String
    let channel: String
    let saison: Int
    let nbEps: Int
    let nbWatched: Int
    let poster: String
    let rateGlobal: Int
    let rateTrakt: Int
    let rateIMDB: Int
    let rateMovieDB: Int
    let rateTVmaze: Int
    let rateRottenTomatoes: Int
    let rateBetaSeries: Int
    
    public init(serie: String, channel: String, saison: Int, nbEps: Int, nbWatched: Int, poster: String, rateGlobal: Int, rateTrakt: Int, rateIMDB: Int, rateMovieDB: Int, rateTVmaze: Int, rateRottenTomatoes: Int, rateBetaSeries: Int) {
        self.serie = serie
        self.channel = channel
        self.saison = saison
        self.nbEps = nbEps
        self.nbWatched = nbWatched
        self.poster = poster
        self.rateGlobal = rateGlobal
        self.rateTrakt = rateTrakt
        self.rateIMDB = rateIMDB
        self.rateMovieDB = rateMovieDB
        self.rateTVmaze = rateTVmaze
        self.rateRottenTomatoes = rateRottenTomatoes
        self.rateBetaSeries = rateBetaSeries
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(serie, forKey: .serie)
        try container.encode(channel, forKey: .channel)
        try container.encode(saison, forKey: .saison)
        try container.encode(nbEps, forKey: .nbEps)
        try container.encode(nbWatched, forKey: .nbWatched)
        try container.encode(poster, forKey: .poster)
        try container.encode(rateGlobal, forKey: .rateGlobal)
        try container.encode(rateTrakt, forKey: .rateTrakt)
        try container.encode(rateIMDB, forKey: .rateIMDB)
        try container.encode(rateMovieDB, forKey: .rateMovieDB)
        try container.encode(rateTVmaze, forKey: .rateTVmaze)
        try container.encode(rateRottenTomatoes, forKey: .rateRottenTomatoes)
        try container.encode(rateBetaSeries, forKey: .rateBetaSeries)
    }

}
