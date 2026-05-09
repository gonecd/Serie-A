//
//  CommonSensMedia.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 03/05/2026.
//  Copyright © 2026 Home. All rights reserved.
//

import Foundation
import SwiftSoup

class CommonSensMedia {
    
    init() {
    }
    
 
    
    func getParentalGuide(serie : String) -> NSMutableDictionary {
        
        let result : NSMutableDictionary = NSMutableDictionary()
        let url : String = "https://www.commonsensemedia.org/tv-reviews/\(serie.replacingOccurrences(of: " ", with: "-"))"

        result["#nudity"] = "0"
        result["#violence"] = "0"
        result["#profanity"] = "0"
        result["#alcohol"] = "0"
        result["#frightening"] = "0"

        do {
            let page : String = try String(contentsOf: URL(string: url)!, encoding: .utf8)
            let doc : Document = try SwiftSoup.parse(page)
            let GuideItems = try doc.select("div[class='content-grid-content']")
            
            for guideItem in GuideItems {
                let isViolence  = try guideItem.select("button[id='content-grid-item-violence']")
                let isSex       = try guideItem.select("button[id='content-grid-item-sex']")
                let isLanguage  = try guideItem.select("button[id='content-grid-item-language']")
                let isDrugs     = try guideItem.select("button[id='content-grid-item-drugs']")
                let cpt : Int   = try guideItem.select("[class='icon-circle-solid active']").count
                
                if (isViolence.count > 0)   { result["#violence"] = String(cpt) }
                if (isSex.count > 0)        { result["#nudity"] = String(cpt) }
                if (isLanguage.count > 0)   { result["#profanity"] = String(cpt) }
                if (isDrugs.count > 0)      { result["#alcohol"] = String(cpt) }
            }
        }
        catch let error as NSError { print("CommonSensMedia failed for getParentalGuide on \(serie) : \(error.localizedDescription)") }
        
        return result
    }
    
}
