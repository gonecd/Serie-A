//
//  Allocine.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SwiftSoup

class AlloCine : NSObject
{    
    override init()
    {
        do {
            let webPage : String = try String(contentsOf: URL(string : "http://www.allocine.fr/series/ficheserie_gen_cserie=7634.html")!)
            let doc : Document = try SwiftSoup.parse(webPage)

            let starsRates : [Element] = try doc.select("div [class='stareval stareval-medium']").array()
            
            let textPresse : String = try starsRates[0].text()
            let textSpectateurs : String = try starsRates[1].text()

            
            print ("On a : \(textPresse) & \(textSpectateurs)")
        }
        catch let error as NSError { print("AlloCine failed: \(error.localizedDescription)") }
        
    }
}
