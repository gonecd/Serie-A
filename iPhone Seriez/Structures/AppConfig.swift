//
//  AppConfig.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 28/12/2024.
//  Copyright © 2024 Home. All rights reserved.
//

import Foundation
import UIKit

class AppConfig : NSObject {
    
    var couleur             : String       = "Gris"
    var modeCouleurSerie    : Bool          = false
    
    
    override public init() { }

    func save() {
        let defaults = UserDefaults.standard

        defaults.set(self.couleur, forKey: "CouleurUI")
        defaults.set(self.modeCouleurSerie, forKey: "modeCouleurSeries")
        defaults.synchronize()
    }
    
    func load() {
        let defaults = UserDefaults.standard

        if ((defaults.object(forKey: "CouleurUI")) != nil) {
            self.couleur = defaults.string(forKey: "CouleurUI")!
            self.modeCouleurSerie = defaults.bool(forKey: "modeCouleurSeries")
        }
        else {
            defaults.set("Gray", forKey: "CouleurUI")
            defaults.set(false, forKey: "modeCouleurSeries")
        }
        
        setColors()
    }
    
    func setColors() {
        var color : UIColor = .systemGray
        
        switch couleur {
        case "Gris" : color = .systemGray
        case "Blanc" : color = .systemBackground
        case "Rouge" : color = .systemRed
        case "Vert" : color = .systemGreen
        case "Bleu" : color = .systemBlue
        case "Orange" : color = .systemOrange
        case "Jaune" : color = .systemYellow
        case "Menthe" : color = .systemMint
        default: color = .systemGray
        }

        mainUIcolor = color
        UIcolor1 = mainUIcolor.withAlphaComponent(0.3)
        UIcolor2 = mainUIcolor.withAlphaComponent(0.1)
        SerieColor1 = UIcolor1
        SerieColor2 = UIcolor2
    }
}
