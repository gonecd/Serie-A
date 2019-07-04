//
//  ViewAccueil.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import SeriesCommon

class ViewAccueil: UIViewController  {
    
    @IBOutlet weak var cptSeriesFinies: UITextField!
    @IBOutlet weak var cptSeriesEnCours: UITextField!
    @IBOutlet weak var cptSeriesAbandonnees: UITextField!
    @IBOutlet weak var cptSaisonsOnTheAir: UITextField!
    @IBOutlet weak var cptSaisonsDiffusees: UITextField!
    @IBOutlet weak var cptSaisonsAnnoncees: UITextField!
    @IBOutlet weak var cptWatchList: UITextField!

    @IBOutlet weak var cadreSaisonAvenir: UIView!
    @IBOutlet weak var cadreSaisonAvoir: UIView!
    @IBOutlet weak var cadreSaisonEncours: UIView!
    @IBOutlet weak var cadreSerieAbandonnee: UIView!
    @IBOutlet weak var cadreSerieWatchlist: UIView!
    @IBOutlet weak var cadreSerieEncours: UIView!
    @IBOutlet weak var cadreSerieFinie: UIView!
    @IBOutlet weak var cadreRecherche: UIView!
    @IBOutlet weak var cadreConseil: UIView!
    @IBOutlet weak var cadreConfiguration: UIView!
    @IBOutlet weak var cadreReload: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkDirectories()
        
        // Faire des jolis carrés dégradés à coins ronds
        makeGradiant(carre: cadreSerieAbandonnee, couleur : "Bleu")
        makeGradiant(carre: cadreSerieEncours, couleur : "Bleu")
        makeGradiant(carre: cadreSerieFinie, couleur : "Bleu")
        makeGradiant(carre: cadreSaisonAvoir, couleur : "Rouge")
        makeGradiant(carre: cadreSaisonAvenir, couleur : "Rouge")
        makeGradiant(carre: cadreSaisonEncours, couleur : "Rouge")
        makeGradiant(carre: cadreSerieWatchlist, couleur : "Vert")
        makeGradiant(carre: cadreRecherche, couleur : "Vert")
        makeGradiant(carre: cadreConseil, couleur : "Vert")
        makeGradiant(carre: cadreConseil, couleur : "Vert")
        makeGradiant(carre: cadreConfiguration, couleur : "Gris")
        makeGradiant(carre: cadreReload, couleur : "Gris")

        // Faire des jolis compteurs à coins ronds
        arrondir(texte: cptSeriesFinies, radius : 10.0)
        arrondir(texte: cptSeriesEnCours, radius : 10.0)
        arrondir(texte: cptSeriesAbandonnees, radius : 10.0)
        arrondir(texte: cptSaisonsOnTheAir, radius : 10.0)
        arrondir(texte: cptSaisonsDiffusees, radius : 10.0)
        arrondir(texte: cptSaisonsAnnoncees, radius : 10.0)
        arrondir(texte: cptWatchList, radius : 10.0)
        
        border(texte: cptSeriesFinies)
        border(texte: cptSeriesEnCours)
        border(texte: cptSeriesAbandonnees)
        border(texte: cptSaisonsOnTheAir)
        border(texte: cptSaisonsDiffusees)
        border(texte: cptSaisonsAnnoncees)
        border(texte: cptWatchList)

        // Initialisation sources de données
        _ = trakt.start()
        theTVdb.initializeToken()
        imdb.loadDataFile()
        
        // Chargement des dates de refresh
        let defaults = UserDefaults.standard
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        //defaults.set(dateFormatter.string(from: Date()), forKey: "RefreshDates")
        
        if ((defaults.object(forKey: "RefreshDates")) != nil) {
            relodDates = dateFormatter.date(from: defaults.string(forKey: "RefreshDates")!)!
        }
        
//        if ((defaults.object(forKey: "RefreshIMDB")) != nil) {
//            relodIMDB = dateFormatter.date(from: defaults.string(forKey: "RefreshIMDB")!)!
//        }

        // Chargement de la dernière sauvegarde
        db.loadDB()
        db.updateCompteurs()
        db.shareWithWidget()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        cptSeriesFinies.text = String(db.valSeriesFinies)
        cptSeriesEnCours.text = String(db.valSeriesEnCours)
        cptSaisonsOnTheAir.text = String(db.valSaisonsOnTheAir)
        cptSaisonsDiffusees.text = String(db.valSaisonsDiffusees)
        cptSaisonsAnnoncees.text = String(db.valSaisonsAnnoncees)
        cptWatchList.text = String(db.valWatchList)
        cptSeriesAbandonnees.text = String(db.valSeriesAbandonnees)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bouton = sender as! UIButton
        var buildList = [Serie]()
        var buildListSaisons = [Int]()
        let today : Date = Date()
        
        switch (bouton.restorationIdentifier ?? "") {
        case "Watchlist":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Watchlist"
            viewController.isWatchlist = true
            for uneSerie in db.shows { if (uneSerie.watchlist) { buildList.append(uneSerie) } }
            viewController.viewList = buildList
            
        case "Abandonnées":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries abandonnées"
            for uneSerie in db.shows { if (uneSerie.unfollowed) { buildList.append(uneSerie) } }
            viewController.viewList = buildList
            
        case "Finies":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries anciennes et finies"
            for uneSerie in db.shows {
                if (uneSerie.saisons.count > 0) {
                    if ( (uneSerie.saisons[uneSerie.saisons.count - 1].watched() == true) && (uneSerie.status == "Ended") ) {
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.viewList = buildList
            
        case "En cours":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries en cours"
            for uneSerie in db.shows {
                if (uneSerie.saisons.count > 0) {
                    if ( ((uneSerie.saisons[uneSerie.saisons.count - 1].watched() == false) || (uneSerie.status != "Ended")) && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) ) {
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.viewList = buildList
            
        case "On the air":
            let viewController = segue.destination as! ViewSaisonListe
            viewController.title = "Saisons en diffusion"
            for uneSerie in db.shows {
                for uneSaison in uneSerie.saisons {
                    if ( (uneSaison.starts != ZeroDate) && (uneSaison.starts.compare(today) == .orderedAscending) &&
                        ((uneSaison.ends.compare(today) == .orderedDescending)  || (uneSaison.ends == ZeroDate)) &&
                        (uneSaison.watched() == false)  && (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
                        buildList.append(uneSerie)
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allSaisons = buildListSaisons
            
        case "Diffusées":
            let viewController = segue.destination as! ViewSaisonListe
            viewController.title = "Saisons prêtes à voir"
            for uneSerie in db.shows {
                for uneSaison in uneSerie.saisons {
                    if ( (uneSaison.starts != ZeroDate) &&
                        (uneSaison.ends.compare(today) == .orderedAscending ) && (uneSaison.ends != ZeroDate) &&
                        (uneSaison.watched() == false) && (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
                        buildList.append(uneSerie)
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allSaisons = buildListSaisons
            
        case "Annoncées":
            let viewController = segue.destination as! ViewSaisonListe
            viewController.title = "Nouvelles saisons annoncées"
            for uneSerie in db.shows {
                for uneSaison in uneSerie.saisons {
                    if ( (uneSaison.starts.compare(today) == .orderedDescending) && (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
                        buildList.append(uneSerie)
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allSaisons = buildListSaisons
            
        case "Conseil":
            let viewController = segue.destination as! ViewPropals
            viewController.title = "Propositions de séries"

        default:
            print("Passer à la fenêtre \(bouton.titleLabel?.text ?? "")")
            
        }
    }
    
 
    @IBAction func quickReload(_ sender: Any) {
//        print("serie;IMDB;TVDB;Trakt;BetaSeries;MovieDB;TVmaze;RottenTomatoes;MetaCritic;AlloCine;")
//
//        for uneSerie in db.shows {
//            print("\(uneSerie.serie);\(uneSerie.ratingIMDB);\(uneSerie.ratingTVDB);\(uneSerie.ratingTrakt);\(uneSerie.ratingBetaSeries);\(uneSerie.ratingMovieDB);\(uneSerie.ratingTVmaze);\(uneSerie.ratingRottenTomatoes);\(uneSerie.ratingMetaCritic);\(uneSerie.ratingAlloCine);")
//        }
//

        db.quickRefresh()
        db.finaliseDB()
        db.shareWithWidget()

        for uneSerie in db.shows {
            if ( (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) && (uneSerie.status != "Ended") ) {
                db.downloadDates(serie : uneSerie)
            }
        }

        db.finaliseDB()
        self.viewDidAppear(false)
    }
    
}
