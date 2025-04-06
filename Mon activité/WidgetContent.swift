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

    var poster3     : UIImage   = UIImage()
    let data3       : Data4MonActivite

    public init(dataWidget1 : Data4MonActivite, dataWidget2 : Data4MonActivite, dataWidget3 : Data4MonActivite) {
        self.data1 = dataWidget1
        self.data2 = dataWidget2
        self.data3 = dataWidget3
    }
}


struct Data4MonActivite: Codable {
    let serie: String
    let channel: String
    let saison: Int
    let nbEps: Int
    let nbWatched: Int
    let poster: String
    
    public init(serie: String, channel: String, saison: Int, nbEps: Int, nbWatched: Int, poster: String) {
        self.serie = serie
        self.channel = channel
        self.saison = saison
        self.nbEps = nbEps
        self.nbWatched = nbWatched
        self.poster = poster
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(serie, forKey: .serie)
        try container.encode(channel, forKey: .channel)
        try container.encode(saison, forKey: .saison)
        try container.encode(nbEps, forKey: .nbEps)
        try container.encode(nbWatched, forKey: .nbWatched)
        try container.encode(poster, forKey: .poster)
    }

}

let americans = Data4MonActivite (
    serie: "The Americans",
    channel: "FX",
    saison: 2,
    nbEps: 13,
    nbWatched: 8,
    poster: "https://image.tmdb.org/t/p/w92/qB7WPVQnmODg2mZ1xUmPOrCa0wL.jpg"
)

let noSerie = Data4MonActivite (
    serie: "N/A",
    channel: "-",
    saison: 0,
    nbEps: 100,
    nbWatched: 1,
    poster: "https://image.tmdb.org/t/p/w92/qB7WPVQnmODg2mZ1xUmPOrCa0wL.jpg"
)

