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
        "Fargo" : 11042,
        "Breaking Bad" : 3517,
        "Better Call Saul" : 16950,
        "The Returned" : 4138,
        "The Americans" : 10790,
        "Silicon Valley" : 11701,
        "Stranger Things" : 19156,
        "Game of Thrones" : 7157,
        "Spotless" : 17467,
        "Mozart in the Jungle" : 17046,
        "The Night Of" : 11461,
        "Twin Peaks" : 536,
        "Louie" : 7389,
        "The Handmaid's Tale" : 20677,
        "The Tunnel" : 11141,
        "Brooklyn Nine-Nine" : 11542,
        "Damages" : 3273,
        "Killing Eve" : 22269,
        "Black Mirror" : 10855,
        "Lost" : 223,
        "Legion" : 19873,
        "Orphan Black" : 11450,
        "Fringe" : 3584,
        "Halt and Catch Fire" : 11662,
        "Rome" : 535,
        "Absolutely Fabulous" : 283,
        "DARK" : 20328,
        "Luther" : 8551,
        "The 4400" : 251,
        "The Shield" : 56,
        "House" : 238,
        "New Girl" : 9889,
        "Penny Dreadful" : 11787,
        "Person of Interest" : 9290,
        "The Haunting of Hill House" : 21978,
        "Fleabag" : 20611,
        "Chuck" : 3213,
        "Orange Is the New Black" : 10368,
        "Arrow" : 10839,
        "3%" : 19610,
        "Big Little Lies" : 18542,
        "Modern Family" : 6085,
        "The Affair" : 11939,
        "Community" : 5496,
        "Lilyhammer" : 10859,
        "Billions" : 17408,
        "Last Resort" : 10478,
        "Sense8" : 11498,
        "The Strain" : 11467,
        "Sherlock" : 4528,
        "24" : 58,
        "Angie Tribeca" : 17305,
        "Homeland" : 9285,
        "Shameless" : 7634,
        "The IT Crowd" : 3202,
        "The Leftovers" : 10423,
        "Norsemen" : 0,
        "The Lost Room" : 3086,
        "Westworld" : 16930,
        "Vikings" : 10214,
        "The Walking Dead" : 7330,
        "Misfits" : 7684,
        "How I Met Your Mother" : 446,
        "The Last Man on Earth" : 17329,
        "The 100" : 11871,
        "The Unit" : 450,
        "Seinfeld" : 287,
        "Designated Survivor" : 20098,
        "House of Cards" : 7663,
        "FlashForward" : 4963,
        "Friends" : 49,
        "The Big Bang Theory" : 3247,
        "Revenge" : 9959,
        "Banshee" : 10430,
        "Dexter" : 3004,
        "House of Lies" : 9554,
        "True Detective" : 11058,
        "NCIS" : 133,
        "12 Monkeys" : 16835,
        "Weeds" : 513,
        "Desperate Housewives" : 221,
        "Black Sails" : 11103,
        "Falling Skies" : 6200,
        "Once Upon a Time" : 9430,
        "Helix" : 11800,
        "Defiance" : 10861,
        "Ozark" : 19792,
        "Wayward Pines" : 12199,
        "True Blood" : 3675,
        "American Horror Story" : 10001,
        "Wentworth" : 16818,
        "Altered Carbon" : 20198,
        "Fear the Walking Dead" : 16958,
        "Prison Break" : 451,
        "Daria" : 822,
        "Salem" : 12250,
        "Revolution" : 10591,
        "The Brink" : 17072,
        "Mad Dogs" : 10218,
        "The Event" : 8049,
        "Under the Dome" : 7834,
        "Terra Nova" : 8270,
        "Californication" : 3376,
        "Heroes" : 812,
        "Marco Polo" : 10841,
        "The River" : 9232,
        "Alcatraz" : 9231,
        "Utopia" : 11346,
        "Hemlock Grove" : 10774,
        "Persons Unknown" : 4227,
        "A Very Secret Service" : 10224,
        "Baron Noir" : 19344,
        "Republican Gangsters" : 19344,
        "Black Books" : 788,
        "Borgia" : 5521,
        "Braquo" : 3516,
        "Bref." : 10520,
        "Call My Agent" : 5019,
        "Fawlty Towers" : 794,
        "Glue" : 12054,
        "Guyane" : 19603,
        "Hard" : 3703,
        "Kaamelott" : 334,
        "Kaboul Kitchen" : 9253,
        "Mafiosa" : 3061,
        "Maison close" : 7321,
        "Money Heist" : 21504,
        "Monty Python's Flying Circus" : 4627,
        "Mr. Robot" : 17966,
        "Real Humans" : 10946,
        "Skins" : 3184,
        "Spiral" : 538,
        "The Bureau" : 17907,
        "WorkinGirls" : 10289,
        "XIII" : 3490,
        "Barry" : 20185,
        "Peaky Blinders" : 11303,
        "Death Note" : 3550,
        "Hero Corp" : 3953,
        "The Marvelous Mrs. Maisel" : 21002,
        "Dirk Gently's Holistic Detective Agency" : 20395,
        "The End of the F***ing World" : 22881,
        "Dark" : 20328,
        "Elite" : 22373,
        "The OA" : 18968,
        "Ray Donovan" : 10472,
        "The Deuce" : 19617,
        "Outlander" : 11266,
        "The Office" : 199,
        "Maniac" : 20388,
        "Treme" : 4139,
        "The Man in the High Castle" : 9359,
        "How to Sell Drugs Online (Fast)" : 24940,
        "Catch-22" : 22979,
        "What We Do in the Shadows" : 23200,
        "Chernobyl" : 22429,
        "Crashing" : 20473,
        "After Life" : 23630,
        "Call My Agent!" : 5019,
        "Jett" : 23569,
        "Years and Years" : 23707,
        "Deutschland 83" : 18781,
        "Vernon Subutex" : 20413,
        "Mindhunter" : 20143,
        "When They See Us" : 23908,
        "The Collapse" : 25687,
        "Savages" : 24290,
        "Undone" : 23387,
        "The Haunting" : 21978
    ]
    
    override init() {
    }
    
    func getChrono() -> TimeInterval {
        return chronoGlobal
    }

    func getSerieGlobalInfos(serie : String) -> Serie {
        let startChrono : Date = Date()
        let uneSerie : Serie = Serie(serie: serie)
        let webPage : String = getPath(serie: serie)
        
        if (webPage == "") {
            return uneSerie
        }
        
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
    
    
    func getPath(serie : String) -> String {
        
        let indexDB : Int = indexWebPage[serie] ?? -1

        if (indexDB == 0) {
            // Série indexée mais page web non définie
            return ""
        } else if (indexDB == -1) {
            // Série non indexée
            print("==> AlloCine - Série inconnue : \(serie)")
            return ""
        } else {
            return "http://www.allocine.fr/series/ficheserie_gen_cserie=" + String(indexDB) + ".html"
        }
    }
    
    func getID(serie: String) -> Int {
        
        print("Recherche de l'ID AlloCine pour \(serie) : ")
        print("  ... je dois trouver \(indexWebPage[serie] ?? -1)")
        
        let webPage : String = "http://www.allocine.fr/recherche/6/?q=" + serie.lowercased().replacingOccurrences(of: "%", with: "+").replacingOccurrences(of: "'", with: "+").replacingOccurrences(of: " ", with: "+")
        
        do {
            let page : String = try String(contentsOf: URL(string : webPage)!)
            let doc : Document = try SwiftSoup.parse(page)
            
            let href : String = try doc.select("div [class='vmargin10t']").select("a").attr("href")
            let name : String = try doc.select("div [class='vmargin10t']").select("a").text()
            
             print("  ... je trouve \(name) - \(href)")
        }
        catch let error as NSError { print("AlloCine getID failed for \(serie): \(error.localizedDescription)") }

        print()
        
        return -1
    }
}
