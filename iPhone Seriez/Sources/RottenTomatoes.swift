//
//  RottenTomatoes.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup
import SeriesCommon

class RottenTomatoes
{    
    init() {
    }
    
    func getSerieGlobalInfos(serie : String) -> Serie {
        let uneSerie : Serie = Serie(serie: serie)
        let webPage : String = getPath(serie: serie)
        
        if (webPage == "") { return uneSerie }
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            
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
    
        
    func getEpisodesRatings(_ uneSerie: Serie) {
        let webPage : String = getPath(serie: uneSerie.serie)
        if (webPage == "") { return }
        
        for uneSaison in uneSerie.saisons {
            var notes : [String] = []
            
            do {
                let page : String = try String(contentsOf: URL(string : webPage+"/s0"+String(uneSaison.saison))!)
                let doc : Document = try SwiftSoup.parse(page)
                notes = try doc.select("div [class='pull-left tomatometer']").text().components(separatedBy: " ")
            }
            catch let error as NSError { print("RottenTomatoes failed: \(error.localizedDescription)") }
            
            for unEpisode in uneSaison.episodes {
                if (unEpisode.episode<notes.count) {
                    //unEpisode.ratingRottenTomatoes = Int(notes[unEpisode.episode-1].components(separatedBy: CharacterSet.decimalDigits.inverted).first!) ?? 0
                }
                else {
                    print("RottenTomatoes.getEpisodesRatings::Not found for \(unEpisode.serie) S\(unEpisode.saison)E\(unEpisode.episode)")
                }
            }
        }
    }
    
    
    func getEpisodeDetails(_ uneSerie: Serie, saison: Int, episode: Int) -> Int {
        let webPage : String = getPath(serie: uneSerie.serie)
        if (webPage == "") { return 0 }
        
        let labelEps = String(format: "/s%02d/e%02d", saison, episode)
        var note : String = ""
        var critic : String = ""
        
        do {
            print("URL = \(webPage+labelEps)")
            let page : String = try String(contentsOf: URL(string : webPage+labelEps)!)
            let doc : Document = try SwiftSoup.parse(page)
            //note = try doc.select("div [id='scoreStats'] div").first()?.text() ?? ""
            note = try (doc.select("div [id='scoreStats'] div").first()?.text().components(separatedBy: " ")[2].components(separatedBy: "/")[0])!
            critic = try doc.select("div [class='col-sm-12 tomato-info hidden-xs pad-left']").text()
        }
        catch let error as NSError { print("RottenTomatoes failed: \(error.localizedDescription)") }

        print("Note = \(note)")
        print("Avis = \(critic)")

        return 0
    }
    
    
    func getPath(serie : String) -> String {
        switch serie {
        case "The End of the F***ing World":
            return "https://www.rottentomatoes.com/tv/the_end_of_the_f_ing_world"
            
        case "Money Heist":
            return "https://www.rottentomatoes.com/tv/la_casa_de_papel"
            
        case "Mr. Robot":
            return "https://www.rottentomatoes.com/tv/mr_robot"
            
        case "The Marvelous Mrs. Maisel":
            return "https://www.rottentomatoes.com/tv/the_marvelous_mrs_maisel"
            
        case "Bref.":
            return "https://www.rottentomatoes.com/tv/bref"
            
        case "The Haunting":
            return "https://www.rottentomatoes.com/tv/the_haunting_of_hill_house"
            
        case "Brooklyn Nine-Nine":
            return "https://www.rottentomatoes.com/tv/brooklyn_nine_nine"
            
        case "Hero Corp",
             "Call My Agent",
             "Baron Noir",
             "WorkinGirls",
             "Guyane",
             "Kaboul Kitchen",
             "Hard",
             "Glue",
             "Kaamelott",
             "Mafiosa",
             "Real Humans",
             "Braquo",
             "XIII",
             "Maison close":
            return ""
            
        default:
            return "https://www.rottentomatoes.com/tv/\(serie.lowercased().replacingOccurrences(of: "%", with: "_").replacingOccurrences(of: "'", with: "_").replacingOccurrences(of: " ", with: "_"))"
        }
    }
}
