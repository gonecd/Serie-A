//
//  Allocine.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup
import SeriesCommon

class AlloCine : NSObject {
    var chronoGlobal : TimeInterval = 0

    let indexWebPage: Dictionary = [
        "24" : "58",
        "A Very Secret Service" : "10224",
        "Bref." : "10520",
        "Call My Agent!" : "5019",
        "Crashing" : "20473",
        "Dark" : "20328",
        "Dirk Gently's Holistic Detective Agency" : "20395",
        "Elite" : "22373",
        "Fargo" : "11042",
        "Fawlty Towers" : "794",
        "Fear the Walking Dead" : "16958",
        "House" : "238",
        "How to Sell Drugs Online (Fast)" : "24940",
        "Lost" : "223",
        "Maniac" : "20388",
        "Marco Polo" : "10841",
        "Mindhunter" : "20143",
        "Money Heist" : "21504",
        "NCIS" : "133",
        "Person of Interest" : "9290",
        "Republican Gangsters" : "19344",
        "Revolution" : "10591",
        "Savages" : "24290",
        "Shameless" : "7634",
        "Spiral" : "538",
        "The 100" : "11871",
        "The 4400" : "251",
        "The Americans" : "10790",
        "The Bureau" : "17907",
        "The Collapse" : "25687",
        "The End of the F***ing World" : "22881",
        "The Handmaid's Tale" : "20677",
        "The Haunting" : "21978",
        "The Man in the High Castle" : "9359",
        "The Marvelous Mrs. Maisel" : "21002",
        "The Office" : "199",
        "The Returned" : "4138",
        "The Tunnel" : "11141",
        "The Unit" : "450",
        "Twin Peaks" : "536",
        "Under the Dome" : "7834",
        "What We Do in the Shadows" : "23200",
        "When They See Us" : "23908",
        "WorkinGirls" : "10289",
        "Years and Years" : "23707"
    ]
    
    
    
    override init() {
    }
    
    func getChrono() -> TimeInterval {
        return chronoGlobal
    }

    func getSerieGlobalInfos(serie : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: serie)
        
        if (uneSerie.idAlloCine == "") {
            uneSerie.idAlloCine = indexWebPage[serie] ?? ""
            if (uneSerie.idAlloCine == "") { uneSerie.idAlloCine = getID(serie: serie) }
            if (uneSerie.idAlloCine == "") { return uneSerie }
        }

        let webPage : String = "http://www.allocine.fr/series/ficheserie_gen_cserie=" + uneSerie.idAlloCine + ".html"
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            
            let textRatings : String = try doc.select("div [class^='rating-holder rating-holder-']").text()
            let mots : [String] = textRatings.components(separatedBy: " ")
            
            for i in 0..<mots.count {
                if (mots[i] == "Spectateurs") {
                    let uneNote : Double = Double(mots[i+1].replacingOccurrences(of: ",", with: "."))!
                    uneSerie.ratingAlloCine = Int(uneNote * 20.0)

                    chronoGlobal = chronoGlobal + Date().timeIntervalSince(startChrono)
                    return uneSerie
                }
            }
        }
        catch let error as NSError { print("AlloCine scrapping failed for \(serie): \(error.localizedDescription)") }
        
        print("==> AlloCine - Note non trouvée : \(serie)")
        chronoGlobal = chronoGlobal + Date().timeIntervalSince(startChrono)
        return uneSerie
    }
    
    
//    func getPath(serie : String) -> String {
//
//        let indexDB : Int = indexWebPage[serie] ?? -1
//
//        if (indexDB == 0) {
//            // Série indexée mais page web non définie
//            return ""
//        } else if (indexDB == -1) {
//            // Série non indexée
//            print("==> AlloCine - Série inconnue : \(serie)")
//            return ""
//        } else {
//            return "http://www.allocine.fr/series/ficheserie_gen_cserie=" + String(indexDB) + ".html"
//        }
//    }
    
    func getID(serie: String) -> String {
        let webPage : String = "http://www.allocine.fr/recherche/6/?q=" + serie.lowercased().replacingOccurrences(of: "%", with: "+").replacingOccurrences(of: "'", with: "+").replacingOccurrences(of: " ", with: "+")
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            let candidats : Elements = try doc.select("div [class='vmargin10t']").select("tr").select("td [style]")

            for unCandidat in candidats {
                let name : String = try unCandidat.select("a").text()
                let href : String = try unCandidat.select("a").attr("href")
                
                if (name == serie) {
                    return href.filter { "0"..."9" ~= $0 }
                }
            }
        } catch let error as NSError { print("AlloCine getID failed for \(serie): \(error.localizedDescription)") }

        print("==> AlloCine - ID non trouvé : \(serie)")
        return ""
    }
}
