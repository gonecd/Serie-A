//
//  SerieNews.swift
//  SerieNews
//
//  Created by Cyril DELAMARE on 22/03/2025.
//  Copyright © 2025 Home. All rights reserved.
//

import WidgetKit
import SwiftUI

let DateZero : Date = Date.init(timeIntervalSince1970: 0)

struct SerieNewsProvider: TimelineProvider {
    func placeholder(in context: Context) -> SerieNewsEntry {
        SerieNewsEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SerieNewsEntry) -> ()) {
        let entry = SerieNewsEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SerieNewsEntry] = []

        var entry : SerieNewsEntry = SerieNewsEntry(date: Date())
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"News") as? Data {
            entry.articles = try! PropertyListDecoder().decode(Array<News>.self, from: data)
            entry.articles.removeAll(where: { $0.type == 1 })
            entry.articles = entry.articles.sorted(by: {$0.date > $1.date})
            if (entry.articles.count > 6) {
                entry.articles =  entry.articles.dropLast(entry.articles.count - 6)
            }
        }

        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SerieNewsEntry: TimelineEntry, Codable {
    let date : Date
    var articles : [News] = []
}

struct SerieNewsEntryView : View {
    var entry: SerieNewsProvider.Entry
    let iconSize : CGFloat = 10

    var body: some View {
        VStack (alignment: .leading) {
            HStack  (alignment: .center){
                Text("Une Série ?").font(.system(size: 20, weight: .heavy))
                Spacer(minLength: 1)
                Text("News des séries").font(.system(size: 14))
                Image(uiImage: #imageLiteral(resourceName: "120.png")).resizable().frame(width: 30, height: 30, alignment: .trailing)
            }

            Spacer(minLength: 30)
                        
            Grid(alignment: .leading) {
                ForEach (entry.articles) { article in
                    GridRow {
                        switch article.source {
                        case 1: Image(uiImage: #imageLiteral(resourceName: "trakt.ico")).resizable().frame(width: 24, height: 24, alignment: .leading)
                        case 6: Image(uiImage: #imageLiteral(resourceName: "tvmaze.ico")).resizable().frame(width: 24, height: 24, alignment: .leading)
                        case 13: Image(uiImage: #imageLiteral(resourceName: "120.png")).resizable().frame(width: 24, height: 24, alignment: .leading)
                        default:Image(systemName: "questionmark.app").frame(width: iconSize, height: iconSize, alignment: .center).foregroundStyle(.purple)
                        }

                        Text("  ")
                        HStack {
                            VStack(alignment: .leading) {
                                Text(article.serie).font(.system(size: 16, weight: .heavy))
                                Text(article.info).font(.system(size: 12))
                            }
                            Spacer()
                        }
                        Text(" ")

                        switch article.type {
                        case 0: Image(systemName: "calendar").frame(width: iconSize, height: iconSize, alignment: .center).foregroundStyle(.blue)
                        case 1: Image(systemName: "eye").frame(width: iconSize, height: iconSize, alignment: .center).foregroundStyle(.blue)
                        case 2: Image(systemName: "xmark.square").frame(width: iconSize, height: iconSize, alignment: .center).foregroundStyle(.blue)
                        case 3: Image(systemName: "antenna.radiowaves.left.and.right").frame(width: iconSize, height: iconSize, alignment: .center).foregroundStyle(.blue)
                        case 4: Image(systemName: "arrowshape.left.arrowshape.right").frame(width: iconSize, height: iconSize, alignment: .center).foregroundStyle(.blue)
                        default: Image(systemName: "questionmark.app").frame(width: iconSize, height: iconSize, alignment: .center).foregroundStyle(.blue)
                        }
                        Text("  ")
                    }
                    Spacer()
                }
            }
        }
    }
}

struct SerieNews: Widget {
    let kind: String = "SerieNews"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SerieNewsProvider()) { entry in
            if #available(iOS 17.0, *) {
                SerieNewsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SerieNewsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Une Serie ?")
        .description("Series new informations")
        .supportedFamilies([.systemLarge])
    }
}

#Preview(as: .systemLarge) {
    SerieNews()
} timeline: {
    SerieNewsEntry(date: .now, articles: [News(serie: "Game of Thrones", texte: "Blabla"), News(serie: "Game of Thrones", texte: "Blabla"), News(serie: "Game of Thrones", texte: "Blabla")])
    SerieNewsEntry(date: .now)
}
