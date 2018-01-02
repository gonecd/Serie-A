//
//  ViewAccueil.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit


class ViewAccueil: UIViewController  {
 
    var trakt : Trakt = Trakt.init()
    var theTVdb : TheTVdb = TheTVdb.init()
    let betaSeries : BetaSeries = BetaSeries.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("Hello world")
        trakt.start()
        theTVdb.initializeToken()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bouton = sender as! UIButton
        
        switch (bouton.titleLabel?.text ?? "") {
        case "A decouvrir":
            print("Passer à la fenêtre A decouvrir")
            
        case "Abandonnees":
            print("Passer à la fenêtre Abandonnees")
            let viewController = segue.destination as! ViewAbandonnees
            viewController.trakt = trakt
            viewController.theTVdb = theTVdb

        default:
            print("Passer à une fenêtre inconnue")

        }
    }
}
