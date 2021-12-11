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

let snapshotData = Data4MonActivite (
    serie: "Shameless US",
    channel: "Canal+",
    saison: 2,
    nbEps: 8,
    nbWatched: 6,
    poster: "Chicagoan Frank Gallagher is the proud single dad of six smart, industrious, independent kids",
    rateGlobal: 1,
    rateTrakt: 2,
    rateIMDB: 3,
    rateMovieDB: 4,
    rateTVmaze: 5,
    rateRottenTomatoes: 6,
    rateBetaSeries: 7
)


struct MonActiviteProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonActiviteData {
        MonActiviteData(dataWidget: snapshotData)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MonActiviteData) -> ()) {
        let entry = MonActiviteData(dataWidget: snapshotData)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries : [Data4MonActivite] = []
        
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"MonActivite") as? Data {
            entries = try! PropertyListDecoder().decode(Array<Data4MonActivite>.self, from: data)
        }
        
        var widgetContent : [MonActiviteData] = []
        let currentDate = Date()
        let interval = 60 / entries.count
        for index in 0 ..< entries.count {
            var uneActivite : MonActiviteData = MonActiviteData(dataWidget: entries[index])
            uneActivite.date = Calendar.current.date(byAdding: .second, value: index * interval, to: currentDate)!
            
            let url : URL = URL(string: entries[index].poster)!
            let imageData = try? Data(contentsOf: url)
            uneActivite.posterImage = UIImage(data: imageData!)!
                
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
        .supportedFamilies([.systemMedium])
    }
}
