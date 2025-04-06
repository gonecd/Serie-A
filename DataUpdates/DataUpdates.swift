//
//  DataUpdates.swift
//  DataUpdates
//
//  Created by Cyril DELAMARE on 14/02/2025.
//  Copyright © 2025 Home. All rights reserved.
//

import WidgetKit
import SwiftUI


let DateFirst : Date = Date.init(timeIntervalSince1970: 0)


struct DataUpdatesProvider: TimelineProvider {
    func placeholder(in context: Context) -> DataUpdatesEntry {
        DataUpdatesEntry(date: Date(), TVMaze_Dates: DateFirst, Trakt_Viewed: DateFirst, IMDB_Rates: DateFirst, IMDB_Episodes: DateFirst, UneSerieReload: DateFirst, UneSerieWatchedEps: DateFirst)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DataUpdatesEntry) -> ()) {
        let entry = DataUpdatesEntry(date: Date(), TVMaze_Dates: DateFirst, Trakt_Viewed: DateFirst, IMDB_Rates: DateFirst, IMDB_Episodes: DateFirst, UneSerieReload: DateFirst, UneSerieWatchedEps: DateFirst)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DataUpdatesEntry] = []
        
        var dataUpdates : DataUpdatesEntry = DataUpdatesEntry(date: .now, TVMaze_Dates: DateFirst, Trakt_Viewed: DateFirst, IMDB_Rates: DateFirst, IMDB_Episodes: DateFirst, UneSerieReload: DateFirst, UneSerieWatchedEps: DateFirst)
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"DataUpdates") as? Data {
            dataUpdates = try! PropertyListDecoder().decode(DataUpdatesEntry.self, from: data)
        }

        entries.append(dataUpdates)
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct DataUpdatesEntry: TimelineEntry, Codable {
    let date: Date
    
    var TVMaze_Dates: Date
    var Trakt_Viewed: Date
    var IMDB_Rates: Date
    var IMDB_Episodes: Date
    var UneSerieReload : Date
    var UneSerieWatchedEps: Date
}


struct DataUpdatesEntryView : View {
    var entry: DataUpdatesProvider.Entry
       
    func MyBloc(imageName : String, titre: String, date: Date) -> AnyView {
        return AnyView( HStack {
            Image(uiImage: #imageLiteral(resourceName: imageName)).resizable().frame(width: 24, height: 24, alignment: .leading)
            VStack (alignment: .leading) {
                Text(titre).font(.system(size: 14, weight: .bold))
                Text(date.formatted(date: .abbreviated, time: .shortened)).font(.system(size: 10))
            }
        })
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack  (alignment: .center){
                Text("Une Série ?").font(.system(size: 20, weight: .heavy))
                Spacer(minLength: 1)
                Text("Mises à jour").font(.system(size: 14))
                Image(uiImage: #imageLiteral(resourceName: "120.png")).resizable().frame(width: 30, height: 30, alignment: .trailing)
            }
            
            Spacer(minLength: 5)
            
            HStack {
                VStack (alignment: .leading) {
                    Spacer(minLength: 1)
                    MyBloc(imageName: "imdb.ico", titre: "Rates update", date: entry.IMDB_Rates)
                    MyBloc(imageName: "imdb.ico", titre: "Episodes ids", date: entry.IMDB_Episodes)
                    MyBloc(imageName: "120.png", titre: "Rates update", date: entry.UneSerieReload)
                }
                
                Spacer(minLength: 1)

                VStack (alignment: .leading) {
                    Spacer(minLength: 1)
                    MyBloc(imageName: "tvmaze.ico", titre: "Dates des saisons", date: entry.TVMaze_Dates)
                    MyBloc(imageName: "trakt.ico", titre: "Episodes vus", date: entry.Trakt_Viewed)
                    MyBloc(imageName: "120.png", titre: "Episodes à suivre", date: entry.UneSerieWatchedEps)
                }
            }
        }
    }
}

struct DataUpdates: Widget {
    let kind: String = "DataUpdates"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DataUpdatesProvider()) { entry in
            if #available(iOS 17.0, *) {
                DataUpdatesEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DataUpdatesEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Une Série ?")
        .description("Automatic updates")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    DataUpdates()
} timeline: {
    DataUpdatesEntry(date: .now, TVMaze_Dates: DateFirst, Trakt_Viewed: DateFirst, IMDB_Rates: DateFirst, IMDB_Episodes: DateFirst, UneSerieReload: DateFirst, UneSerieWatchedEps: DateFirst)
    DataUpdatesEntry(date: .now, TVMaze_Dates: DateFirst, Trakt_Viewed: DateFirst, IMDB_Rates: DateFirst, IMDB_Episodes: DateFirst, UneSerieReload: DateFirst, UneSerieWatchedEps: DateFirst)
}
