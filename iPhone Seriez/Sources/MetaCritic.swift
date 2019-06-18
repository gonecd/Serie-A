//
//  MetaCritic.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 01/06/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


import Foundation
import SwiftSoup
import SeriesCommon

class MetaCritic
{
    init() {
    }
    
    func getSerieGlobalInfos(serie : String) -> Serie {
        let uneSerie : Serie = Serie(serie: serie)
        let webPage : String = getPath(serie: serie)
        
        if (webPage == "") {
            return uneSerie
        }
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            let extract : String = try doc.select("div [class='product_header']").text()
            let rating : String = extract.components(separatedBy: " ")[2]
            
            uneSerie.ratingMetaCritic = Int(rating) ?? 0
        }
        catch let error as NSError { print("MetaCritic failed: \(error.localizedDescription)") }
        
        return uneSerie
    }

    
    func getPath(serie : String) -> String {
        switch serie {
            
        case "12 Monkeys":
            return "https://www.metacritic.com/tv/12-monkeys-2015"
            
        case "Absolutely Fabulous":
            return "https://www.metacritic.com/tv/absolutely-fabulous-uk"
            
        case "Dirk Gently's Holistic Detective Agency":
            return "https://www.metacritic.com/tv/dirk-gentlys-holistic-detective-agency"
            
        case "Maniac":
            return "https://www.metacritic.com/tv/maniac-2018"
            
        case "Marco Polo":
            return "https://www.metacritic.com/tv/marco-polo-2014"
            
        case "Mr. Robot":
            return "https://www.metacritic.com/tv/mr-robot"
            
        case "Outlander":
            return "https://www.metacritic.com/tv/outlander-2014"
            
        case "Shameless":
            return "https://www.metacritic.com/tv/shameless-us"
            
        case "The End of the F***ing World":
            return "https://www.metacritic.com/tv/the-end-of-the-fing-world"
            
        case "The Handmaid's Tale":
            return "https://www.metacritic.com/tv/the-handmaids-tale"
            
        case "The Haunting":
            return "https://www.metacritic.com/tv/the-haunting-of-hill-house"
            
        case "The Marvelous Mrs. Maisel":
            return "https://www.metacritic.com/tv/the-marvelous-mrs-maisel"
            
        case "What We Do in the Shadows":
            return "https://www.metacritic.com/tv/what-we-do-in-the-shadows-2019"
            
        case "Hero Corp",
             "Call My Agent",
             "3%",
             "A Very Secret Service",
             "Baron Noir",
             "Borgia",
             "Braquo",
             "Bref.",
             "Fawlty Towers",
             "Glue",
             "Guyane",
             "Hard",
             "Kaamelott",
             "Kaboul Kitchen",
             "Mafiosa",
             "Maison close",
             "Money Heist",
             "Monty Python's Flying Circus",
             "Real Humans",
             "Spiral",
             "The Bureau",
             "Utopia",
             "Wentworth",
             "WorkinGirls":
            return ""
            
        default:
            return "https://www.metacritic.com/tv/\(serie.lowercased().replacingOccurrences(of: "%", with: "-").replacingOccurrences(of: "'", with: "-").replacingOccurrences(of: " ", with: "-"))"
        }
    }
}


/*

 Page = https://www.metacritic.com/tv/12-monkeys
 Page = https://www.metacritic.com/tv/3-
 Page = https://www.metacritic.com/tv/a-very-secret-service
 Page = https://www.metacritic.com/tv/absolutely-fabulous
 Page = https://www.metacritic.com/tv/baron-noir
 Page = https://www.metacritic.com/tv/borgia
 Page = https://www.metacritic.com/tv/braquo
 Page = https://www.metacritic.com/tv/bref.
 Loading MetaCritic for Call My Agent
 Page = https://www.metacritic.com/tv/dirk-gently-s-holistic-detective-agency
 Page = https://www.metacritic.com/tv/fawlty-towers
 Page = https://www.metacritic.com/tv/glue
 Page = https://www.metacritic.com/tv/guyane
 Page = https://www.metacritic.com/tv/hard
 Loading MetaCritic for Hero Corp
 Page = https://www.metacritic.com/tv/kaamelott
 Page = https://www.metacritic.com/tv/kaboul-kitchen
 Page = https://www.metacritic.com/tv/mafiosa
 Page = https://www.metacritic.com/tv/maison-close
 Page = https://www.metacritic.com/tv/maniac
 Page = https://www.metacritic.com/tv/marco-polo
 Page = https://www.metacritic.com/tv/money-heist
 Page = https://www.metacritic.com/tv/monty-python-s-flying-circus
 Page = https://www.metacritic.com/tv/mr.-robot
 Page = https://www.metacritic.com/tv/outlander
 Page = https://www.metacritic.com/tv/real-humans
 Page = https://www.metacritic.com/tv/shameless
 Page = https://www.metacritic.com/tv/spiral
 Page = https://www.metacritic.com/tv/the-bureau
 Page = https://www.metacritic.com/tv/the-end-of-the-f***ing-world
 Page = https://www.metacritic.com/tv/the-handmaid-s-tale
 Page = https://www.metacritic.com/tv/the-haunting
 Page = https://www.metacritic.com/tv/the-marvelous-mrs.-maisel
 Page = https://www.metacritic.com/tv/utopia
 Page = https://www.metacritic.com/tv/wentworth
 Page = https://www.metacritic.com/tv/what-we-do-in-the-shadows
 Page = https://www.metacritic.com/tv/workingirls

 
 
 
 
 
 */

