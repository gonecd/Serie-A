//
//  News.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 01/03/2025.
//  Copyright © 2025 Home. All rights reserved.
//

import Foundation
import WidgetKit



class News : Codable, Identifiable {
    let id = UUID()
    
    var serie    : String = ""
    var source   : Int = 0
    var date     : Date = Date()
    var methode  : Int = 0
    var info     : String = ""
    var type     : Int = 0
    
    init () { }
    
    init(serie: String, source: Int = 0, methode: Int = 0, texte: String, type: Int = 0, date: Date = Date()) {
        self.serie = serie
        self.source = source
        self.methode = methode
        self.info = texte
        self.type = type
    }
}


class Journal : NSObject {
    var articles : [News] = []
    
    override init() { }
    
    func addInfo(serie: String, source: Int, methode: Int, texte: String, type: Int, date: Date = Date()) {
        let nouvelle : News = News()
        nouvelle.date = date
        nouvelle.serie = serie
        nouvelle.source = source
        nouvelle.info = texte
        nouvelle.methode = methode
        nouvelle.type = type

        articles.append(nouvelle)
        save()
    }
    
    func purge() {
        // Suppression des articles qui ont plus de un mois
        articles.removeAll(where: { $0.date < Date().addingTimeInterval(-2592000) })
    }
    
    func removeDuplicates() {
        var newArticles : [News] = []
        for uneNews in articles {
            if !newArticles.contains(where: {(($0.info == uneNews.info) && ($0.serie == uneNews.serie)) }) {
                let newNews : News = News(serie: uneNews.serie, source: uneNews.source, methode: uneNews.methode, texte: uneNews.info, type: uneNews.type, date: uneNews.date)
                newArticles.append(newNews)
            }
        }

        articles = newArticles
    }
    
    func save() {
        let sharedContainer = UserDefaults(suiteName: "group.Series")
        sharedContainer?.set(try? PropertyListEncoder().encode(articles), forKey: "News")
        WidgetCenter.shared.reloadTimelines(ofKind: "SerieNews")

    }
    
    func load() {
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"News") as? Data {
            articles = try! PropertyListDecoder().decode(Array<News>.self, from: data)
        }

    }

}
