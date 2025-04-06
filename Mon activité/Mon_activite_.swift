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


struct MonActiviteProvider: TimelineProvider {
    func placeholder(in context: Context) -> MonActiviteData {
        MonActiviteData(dataWidget1: americans, dataWidget2: noSerie, dataWidget3: noSerie)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MonActiviteData) -> ()) {
        var entry = MonActiviteData(dataWidget1: americans, dataWidget2: noSerie, dataWidget3: noSerie)
        
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

        if (entries.count == 1) {
            var uneActivite : MonActiviteData = MonActiviteData(dataWidget1: entries[0], dataWidget2: noSerie, dataWidget3: noSerie)
            uneActivite.date = currentDate
            
            uneActivite.poster1 = getImage(entries[0].poster)
            uneActivite.poster2 = #imageLiteral(resourceName: "Capture d’écran 2018-11-03 à 14.41.14.png")
            uneActivite.poster3 = #imageLiteral(resourceName: "Capture d’écran 2018-11-03 à 14.41.14.png")

            widgetContent.append(uneActivite)
        } else if (entries.count == 2) {
            var uneActivite : MonActiviteData = MonActiviteData(dataWidget1: entries[0], dataWidget2: entries[1], dataWidget3: noSerie)
            uneActivite.date = currentDate
            
            uneActivite.poster1 = getImage(entries[0].poster)
            uneActivite.poster2 = getImage(entries[1].poster)
            uneActivite.poster3 = #imageLiteral(resourceName: "Capture d’écran 2018-11-03 à 14.41.14.png")

            widgetContent.append(uneActivite)
        } else {
            var uneActivite : MonActiviteData = MonActiviteData(dataWidget1: entries[0], dataWidget2: entries[1], dataWidget3: entries[2])
            uneActivite.date = currentDate
            
            uneActivite.poster1 = getImage(entries[0].poster)
            uneActivite.poster2 = getImage(entries[1].poster)
            uneActivite.poster3 = getImage(entries[2].poster)

            widgetContent.append(uneActivite)
        }
    
    let timeline = Timeline(entries: widgetContent, policy: .never)
    completion(timeline)
}

}

@main
struct Mon_activite_: Widget {
    let kind: String = "Mon_activite_"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MonActiviteProvider()) { entry in
            if #available(iOS 17.0, *) {
                MonActiviteView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MonActiviteView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Une Série")
        .description("Saisons en cours de visionnage")
        .supportedFamilies([.systemLarge])
    }
}



//#Preview(as: .systemLarge) {
//    Mon_activite_()
//} timeline: {
////    MonActiviteData(date: Date(),
////                    poster1: UIImage(), data1: americans, diffuseur1: UIImage(),
////                    poster2: UIImage(), data2: americans, diffuseur2: UIImage(),
////                    poster3: UIImage(), data3: noSerie, diffuseur3: UIImage())
//    
//    MonActiviteData(dataWidget1 : americans, dataWidget2 : noSerie, dataWidget3 : noSerie)
//}


func getImage(_ url: String) -> UIImage {
    if (url == "") { return UIImage() }
    
    let imageData = NSData(contentsOf: URL(string: url)!)
    if (imageData != nil) { return UIImage(data: imageData! as Data)! }
    else { return UIImage() }
}
