//
//  ViewAccueil.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit


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
    
    
    override func viewDidLoad()
    {
        trace(texte : "<< ViewAccueil : viewDidLoad >>", logLevel : logFuncCalls, scope : scopeController)
        trace(texte : "<< ViewAccueil : viewDidLoad >> Params : No Params", logLevel : logFuncParams, scope : scopeController)
        
        super.viewDidLoad()

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

        // Faire des jolis compteurs à coins ronds
        arrondir(texte: cptSeriesFinies, radius : 10.0)
        arrondir(texte: cptSeriesEnCours, radius : 10.0)
        arrondir(texte: cptSeriesAbandonnees, radius : 10.0)
        arrondir(texte: cptSaisonsOnTheAir, radius : 10.0)
        arrondir(texte: cptSaisonsDiffusees, radius : 10.0)
        arrondir(texte: cptSaisonsAnnoncees, radius : 10.0)
        arrondir(texte: cptWatchList, radius : 10.0)
        
        // Initialisation sources de données
        if (trakt.start() == false)
        {
            trace(texte : "<< ViewAccueil : downloadStatuses >> Problème d'initialisation de la connexion à Trakt", logLevel : logWarnings, scope : scopeController)
        }
        theTVdb.initializeToken()
        imdb.loadDataFile()
        
        // Chargement de la dernière sauvegarde
        db.loadDB()
        updateCompteurs()

        trace(texte : "<< ViewAccueil : viewDidLoad >> Return : No Return", logLevel : logFuncReturn, scope : scopeController)
    }
    
    @IBAction func downloadStatuses(_ sender: Any)
    {
        trace(texte : "<< ViewAccueil : downloadStatuses >>", logLevel : logFuncCalls, scope : scopeController)
        trace(texte : "<< ViewAccueil : downloadStatuses >> Params : sender = \(sender)", logLevel : logFuncParams, scope : scopeController)
        
        var reloadSeries : [Serie] = [Serie]()
        reloadSeries = trakt.getWatched()
        reloadSeries = db.merge(reloadSeries, adds: trakt.getStopped())
        reloadSeries = db.merge(reloadSeries, adds: trakt.getWatchlist())
        
        db.shows = db.mergeStatuses(db.shows, adds: reloadSeries)
        db.saveDB()
        
        self.updateCompteurs()
        self.view.setNeedsDisplay()

        trace(texte : "<< ViewAccueil : downloadStatuses >> Return : No Return", logLevel : logFuncReturn, scope : scopeController)
    }
   
    
    @IBAction func downloadAll(_ sender: Any)
    {
        trace(texte : "<< ViewAccueil : downloadAll >>", logLevel : logFuncCalls, scope : scopeController)
        trace(texte : "<< ViewAccueil : downloadAll >> Params : sender = \(sender)", logLevel : logFuncParams, scope : scopeController)
        
        db.shows = trakt.getWatched()
        for uneSerie in db.shows { trakt.getSaisons(uneSerie: uneSerie) }
        db.shows = db.merge(db.shows, adds: trakt.getStopped())
        db.shows = db.merge(db.shows, adds: trakt.getWatchlist())
        
        let infoWindow : UIAlertController = UIAlertController(title: "Loading ...", message: "", preferredStyle: UIAlertControllerStyle.alert)
        self.present(infoWindow, animated: true, completion: { })
        
        DispatchQueue.global(qos: .utility).async {
            
            let totalCompteur : Int = db.shows.count
            var compteur : Int = 0
            
            for uneSerie in db.shows
            {
                compteur = compteur + 1
                DispatchQueue.main.async { infoWindow.message = "\(uneSerie.serie) (\(compteur)/\(totalCompteur))" }
                db.downloadGlobalInfo(serie: uneSerie)
            }
            
            infoWindow.dismiss(animated: true, completion: { })
            
            DispatchQueue.main.async {
                db.saveDB()
                self.updateCompteurs()
            }
        }
        trace(texte : "<< ViewAccueil : downloadAll >> Return : No Return", logLevel : logFuncReturn, scope : scopeController)
  }
    

    override func didReceiveMemoryWarning() {
        trace(texte : "<< ViewAccueil : didReceiveMemoryWarning >>", logLevel : logFuncCalls, scope : scopeController)
        trace(texte : "<< ViewAccueil : didReceiveMemoryWarning >> Params : No Params", logLevel : logFuncParams, scope : scopeController)
        
        super.didReceiveMemoryWarning()
        
        trace(texte : "<< ViewAccueil : didReceiveMemoryWarning >> Return : No Return", logLevel : logFuncReturn, scope : scopeController)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        trace(texte : "<< ViewAccueil : prepare >>", logLevel : logFuncCalls, scope : scopeController)
        trace(texte : "<< ViewAccueil : prepare >> Params : segue = \(segue), sender = \(String(describing: sender))", logLevel : logFuncParams, scope : scopeController)
        
        let bouton = sender as! UIButton
        var buildList = [Serie]()
        var buildListSaisons = [Int]()
        let today : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"
        
        switch (bouton.titleLabel?.text ?? "") {
        case "  Watchlist":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Watchlist"
            viewController.isWatchlist = true
            for uneSerie in db.shows { if (uneSerie.watchlist) { buildList.append(uneSerie) } }
            viewController.viewList = buildList
            
        case "  Abandonnées":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries abandonnées"
            for uneSerie in db.shows { if (uneSerie.unfollowed) { buildList.append(uneSerie) } }
            viewController.viewList = buildList
            
        case "  Finies":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries anciennes et finies"
            for uneSerie in db.shows
            {
                if (uneSerie.saisons.count > 0)
                {
                    if ( (uneSerie.saisons[uneSerie.saisons.count - 1].watched == true) && (uneSerie.status == "Ended") )
                    {
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.viewList = buildList
            
        case "  En cours":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries en cours"
            for uneSerie in db.shows
            {
                if (uneSerie.saisons.count > 0)
                {
                    if ( ((uneSerie.saisons[uneSerie.saisons.count - 1].watched == false) || (uneSerie.status != "Ended")) && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) )
                    {
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.viewList = buildList
            
        case "  On the air":
            let viewController = segue.destination as! ViewSaisonListe
            viewController.title = "Saisons en diffusion"
            for uneSerie in db.shows
            {
                for uneSaison in uneSerie.saisons
                {
                    if ( (uneSaison.starts != ZeroDate) &&
                        (uneSaison.starts.compare(today) == .orderedAscending) &&
                        ((uneSaison.ends.compare(today) == .orderedDescending)  || (uneSaison.ends == ZeroDate)) &&
                        (uneSaison.watched == false)  &&
                        (uneSerie.watchlist == false) &&
                        (uneSerie.unfollowed == false) )
                    {
                        buildList.append(uneSerie)
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allSaisons = buildListSaisons
            
        case "  Diffusées":
            let viewController = segue.destination as! ViewSaisonListe
            viewController.title = "Saisons prêtes à voir"
            for uneSerie in db.shows
            {
                for uneSaison in uneSerie.saisons
                {
                    if ( (uneSaison.starts != ZeroDate) &&
                        (uneSaison.ends.compare(today) == .orderedAscending ) &&
                        (uneSaison.ends != ZeroDate) &&
                        (uneSaison.watched == false) &&
                        (uneSerie.watchlist == false) &&
                        (uneSerie.unfollowed == false) )
                    {
                        buildList.append(uneSerie)
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allSaisons = buildListSaisons
            
        case "  Annoncées":
            let viewController = segue.destination as! ViewSaisonListe
            viewController.title = "Nouvelles saisons annoncées"
            for uneSerie in db.shows
            {
                for uneSaison in uneSerie.saisons
                {
                    if ( (uneSaison.starts.compare(today) == .orderedDescending) &&
                        (uneSerie.watchlist == false) &&
                        (uneSerie.unfollowed == false) )
                    {
                        buildList.append(uneSerie)
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allSaisons = buildListSaisons
            
        case "  Conseil":
            let viewController = segue.destination as! ViewConseil
            viewController.title = "Séries conseillées"

        default:
            print("Passer à la fenêtre \(bouton.titleLabel?.text ?? "")")
            
        }
        trace(texte : "<< ViewAccueil : prepare >> Return : No Return", logLevel : logFuncReturn, scope : scopeController)
    }
    
    func updateCompteurs()
    {
        trace(texte : "<< ViewAccueil : updateCompteurs >>", logLevel : logFuncCalls, scope : scopeController)
        trace(texte : "<< ViewAccueil : updateCompteurs >> Params : No Params", logLevel : logFuncParams, scope : scopeController)
        
        var valSeriesFinies : Int = 0
        var valSeriesEnCours : Int = 0
        var valSaisonsOnTheAir : Int = 0
        var valSaisonsDiffusees : Int = 0
        var valSaisonsAnnoncees : Int = 0
        var ValWatchList : Int = 0
        var valSeriesAbandonnees : Int = 0
        let today : Date = Date()
        
        for uneSerie in db.shows
        {
            if (uneSerie.unfollowed) { valSeriesAbandonnees = valSeriesAbandonnees + 1 }
            if (uneSerie.watchlist) { ValWatchList = ValWatchList + 1 }
            if (uneSerie.saisons.count > 0)
            {
                let lastSaison : Saison = uneSerie.saisons[uneSerie.saisons.count - 1]
                
                if ( (lastSaison.watched == true) && (uneSerie.status == "Ended") ) { valSeriesFinies = valSeriesFinies + 1 }
                if ( ((lastSaison.watched == false) || (uneSerie.status != "Ended")) && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) ) { valSeriesEnCours = valSeriesEnCours + 1 }
            }
            
            for uneSaison in uneSerie.saisons
            {
                if ( (uneSaison.starts != ZeroDate) &&
                    (uneSaison.starts.compare(today) == .orderedAscending) &&
                    ((uneSaison.ends.compare(today) == .orderedDescending)  || (uneSaison.ends == ZeroDate)) &&
                    (uneSaison.watched == false)  &&
                    (uneSerie.watchlist == false) &&
                    (uneSerie.unfollowed == false) )
                { valSaisonsOnTheAir = valSaisonsOnTheAir + 1 }

                if ( (uneSaison.starts != ZeroDate) &&
                    (uneSaison.ends.compare(today) == .orderedAscending) &&
                    (uneSaison.ends != ZeroDate) &&
                    (uneSaison.watched == false) &&
                    (uneSerie.watchlist == false) &&
                    (uneSerie.unfollowed == false) )
                { valSaisonsDiffusees = valSaisonsDiffusees + 1 }

                if ( (uneSaison.starts.compare(today) == .orderedDescending) &&
                    (uneSerie.watchlist == false) &&
                    (uneSerie.unfollowed == false) )
                { valSaisonsAnnoncees = valSaisonsAnnoncees + 1 }
            }
        }
        
        cptSeriesFinies.text = String(valSeriesFinies)
        cptSeriesEnCours.text = String(valSeriesEnCours)
        cptSaisonsOnTheAir.text = String(valSaisonsOnTheAir)
        cptSaisonsDiffusees.text = String(valSaisonsDiffusees)
        cptSaisonsAnnoncees.text = String(valSaisonsAnnoncees)
        cptWatchList.text = String(ValWatchList)
        cptSeriesAbandonnees.text = String(valSeriesAbandonnees)

        trace(texte : "<< ViewAccueil : updateCompteurs >> Return : No Return", logLevel : logFuncReturn, scope : scopeController)
    }
    
 
    func printRatings()
    {
    print("serie;saison;episode;ratingTrakt;ratersTrakt;ratingTVdb;ratersTVdb;ratingMoviedb;ratersMoviedb;ratingBetaSeries;ratersBetaSeries;ratingIMdb;ratersIMdb")
        for uneSerie in db.shows
        {
            for uneSaison in uneSerie.saisons
            {
                for unEpisode in uneSaison.episodes
                {
                    print("\(unEpisode.serie);\(unEpisode.saison);\(unEpisode.episode);\(unEpisode.ratingTrakt);\(unEpisode.ratersTrakt);\(unEpisode.ratingTVdb);\(unEpisode.ratersTVdb);\(unEpisode.ratingMoviedb);\(unEpisode.ratersMoviedb);\(unEpisode.ratingBetaSeries);\(unEpisode.ratersBetaSeries);\(unEpisode.ratingIMdb);\(unEpisode.ratersIMdb)")
                }
            }
        }
        
        print()
        print()
        print()
        
        print("source;moyenne;ecartType")
        print("Trakt;\(moyenneTrakt);\(ecartTypeTrakt)")
        print("TVdb;\(moyenneTVdb);\(ecartTypeTVdb)")
        print("MovieDB;\(moyenneMovieDB);\(ecartTypeMovieDB)")
        print("BetaSeries;\(moyenneBetaSeries);\(ecartTypeBetaSeries)")
        print("IMDB;\(moyenneIMDB);\(ecartTypeIMDB)")
        
    }
}
