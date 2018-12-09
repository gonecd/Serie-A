//
//  RottenTomatoes.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup

class RottenTomatoes
{    
    init() {
    
    }
    
    func getSerieGlobalInfos(serie : String) -> Serie {
        let uneSerie : Serie = Serie(serie: serie)
        
        do {
            let webPage : String = try String(contentsOf: URL(string : "https://www.rottentomatoes.com/tv/\(serie.lowercased().replacingOccurrences(of: "%", with: "_").replacingOccurrences(of: "'", with: "_").replacingOccurrences(of: " ", with: "_"))")!)
            let doc : Document = try SwiftSoup.parse(webPage)
            
            let topCritics : Elements = try doc.select("div [id='top-critics-numbers']")
            let allCritics : Elements = try doc.select("div [id='all-critics-numbers']")
            let audienceScore : Elements = try doc.select("div [class='audience-score meter']")

            let textTop : String = try topCritics.text()
            let textAll : String = try allCritics.text()
            let textAudience : String = try audienceScore.text()

            let ratingRottenTopCritics = Int(textTop.components(separatedBy: CharacterSet.decimalDigits.inverted).first!) ?? 0
            let ratingRottenAllCritics = Int(textAll.components(separatedBy: CharacterSet.decimalDigits.inverted).first!) ?? 0
            let ratingRottenAudience = Int(textAudience.components(separatedBy: CharacterSet.decimalDigits.inverted).first!) ?? 0
            
            var nbValidValues : Int = 0
            var total : Int = 0
            
            if ((ratingRottenTopCritics != 0) && (ratingRottenTopCritics != 100)) { nbValidValues = nbValidValues + 1; total = total + ratingRottenTopCritics }
            if ((ratingRottenAllCritics != 0) && (ratingRottenAllCritics != 100)) { nbValidValues = nbValidValues + 1; total = total + ratingRottenAllCritics }
            if ((ratingRottenAudience != 0) && (ratingRottenAudience != 100)) { nbValidValues = nbValidValues + 1; total = total + ratingRottenAudience }

            if (nbValidValues != 0) { uneSerie.ratingRottenTomatoes = Int(Double(total)/Double(nbValidValues)) }
        }
        catch let error as NSError { print("RottenTomatoes failed: \(error.localizedDescription)") }
        
        return uneSerie
    }
    
}
