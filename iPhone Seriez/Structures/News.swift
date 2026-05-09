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
    
    func removeInfo(uneNews : News) {
        articles.removeAll() { $0.id == uneNews.id }
        save()
    }
    
    func purge() {
        // Suppression des articles qui ont plus de un mois
        articles.removeAll(where: { $0.date < Date().addingTimeInterval(-2592000) })
    }
    
    func clean() {
        articles.removeAll(where: { $0.source == 1  && $0.methode == 2 } )
        //articles.removeAll(where: { $0.info.contains("commencée") } )
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
            
//        articles.removeAll(where: { $0.methode == 2 } )
//        for unArticle in articles {
//            if unArticle.info.contains("entièrement diffusée") {
//                let saison : String = String(unArticle.info.split(separator: " ")[2])
//                unArticle.info = "Saison \(saison) diffusée"
//            }
//            
//            if unArticle.type == 4  {
//                if unArticle.info.contains("La série est vue entièrement") {
//                    unArticle.info = "Série visionnée"
//                    unArticle.type = 9
//                }
//                
//                if unArticle.info.contains("Série ajoutée en watchlist") {
//                    unArticle.type = 5
//                }
//                
//                if unArticle.info.contains("Abandon de la série") {
//                    unArticle.type = 6
//                }
//
//                if unArticle.info.contains("Visionnage d'un nouvelle série") {
//                    unArticle.info = "Visionnage d'une nouvelle série"
//                    unArticle.type = 8
//                }
//
//                if unArticle.info.contains("Changement de status de la série") {
//                    unArticle.info = "ended -> returning series"
//                    unArticle.type = 2
//                }
//            }
//        }
//        
//        save()
    }

}
