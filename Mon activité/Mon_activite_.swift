//
//  Mon_activite_.swift
//  Mon activité
//
//  Created by Cyril DELAMARE on 03/10/2021.
//  Copyright © 2021 Home. All rights reserved.
//

import WidgetKit
import SwiftUI


let nbSources : Int = 6

let americans = Data4MonActivite (
    serie: "The Americans",
    channel: "FX",
    saison: 2,
    nbEps: 13,
    nbWatched: 8,
    poster: "https://image.tmdb.org/t/p/w92/qB7WPVQnmODg2mZ1xUmPOrCa0wL.jpg",
    rateGlobal: 77,
    rateTrakt: 83,
    rateIMDB: 84,
    rateMovieDB: 79,
    rateTVmaze: 85,
    rateRottenTomatoes: 96,
    rateBetaSeries: 90
)

let noSerie = Data4MonActivite (
    serie: "N/A",
    channel: "-",
    saison: 0,
    nbEps: 100,
    nbWatched: 1,
    poster: "https://image.tmdb.org/t/p/w92/qB7WPVQnmODg2mZ1xUmPOrCa0wL.jpg",
    rateGlobal: 50,
    rateTrakt: 50,
    rateIMDB: 50,
    rateMovieDB: 50,
    rateTVmaze: 50,
    rateRottenTomatoes: 50,
    rateBetaSeries: 50
)


struct MonActiviteProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonActiviteData {
        MonActiviteData(dataWidget1: americans, dataWidget2: noSerie)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MonActiviteData) -> ()) {
        var entry = MonActiviteData(dataWidget1: americans, dataWidget2: noSerie)
        
        let url : URL = URL(string: entry.data1.poster)!
        let imageData = try? Data(contentsOf: url)
        entry.poster1 = UIImage(data: imageData!)!

        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries : [Data4MonActivite] = []
        
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"MonActivite") as? Data {
            entries = try! PropertyListDecoder().decode(Array<Data4MonActivite>.self, from: data)
        }
        
        var widgetContent : [MonActiviteData] = []
        let currentDate = Date()

        if (entries.count == 0) {
            var uneActivite : MonActiviteData = MonActiviteData(dataWidget1: noSerie, dataWidget2: noSerie)
            uneActivite.date = currentDate
            
            uneActivite.poster1 = #imageLiteral(resourceName: "Capture d’écran 2018-11-03 à 14.41.14.png")
            uneActivite.poster2 = #imageLiteral(resourceName: "Capture d’écran 2018-11-03 à 14.41.14.png")

            widgetContent.append(uneActivite)
        } else if (entries.count == 1) {
            var uneActivite : MonActiviteData = MonActiviteData(dataWidget1: entries[0], dataWidget2: noSerie)
            uneActivite.date = currentDate
            
            let url1 : URL = URL(string: entries[0].poster)!
            let imageData1 = try? Data(contentsOf: url1)
            uneActivite.poster1 = UIImage(data: imageData1!)!
                
            uneActivite.poster2 = #imageLiteral(resourceName: "Capture d’écran 2018-11-03 à 14.41.14.png")
                
            widgetContent.append(uneActivite)
        } else {
            var uneActivite : MonActiviteData = MonActiviteData(dataWidget1: entries[0], dataWidget2: entries[1])
            uneActivite.date = currentDate
            
            let url1 : URL = URL(string: entries[0].poster)!
            let imageData1 = try? Data(contentsOf: url1)
            uneActivite.poster1 = UIImage(data: imageData1!)!
                
            let url2 : URL = URL(string: entries[1].poster)!
            let imageData2 = try? Data(contentsOf: url2)
            uneActivite.poster2 = UIImage(data: imageData2!)!
                
            widgetContent.append(uneActivite)
        }
        
        let timeline = Timeline(entries: widgetContent, policy: .atEnd)
        completion(timeline)
    }
}

@main
struct Mon_activite_: Widget {
    let kind: String = "Mon_activite_"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MonActiviteProvider()) { entry in
            MonActiviteView(model: entry)
        }
        .configurationDisplayName("Une Série")
        .description("Saisons en cours de visionnage")
        .supportedFamilies([.systemLarge])
    }
}
