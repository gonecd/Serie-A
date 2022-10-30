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
    @IBOutlet weak var cadreConfiguration: UIView!
    @IBOutlet weak var cadreReload: UIView!
    @IBOutlet weak var cadreDashboard: UIView!

    @IBOutlet weak var cadreSeries: UIView!
    @IBOutlet weak var cadreSaisons: UIView!
    @IBOutlet weak var cadreDecouverte: UIView!
    @IBOutlet weak var cadreDivers: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize date formatters
        dateFormShort.locale = Locale.current
        dateFormShort.dateFormat = "dd MMM yy"
        dateFormLong.locale = Locale.current
        dateFormLong.dateFormat = "dd MMM yyyy"
        dateFormSource.locale = Locale.current
        dateFormSource.dateFormat = "yyyy-MM-dd"
        
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
        makeGradiant(carre: cadreConfiguration, couleur : "Gris")
        makeGradiant(carre: cadreReload, couleur : "Gris")
        
        // iPad spécific
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            makeGradiant(carre: cadreConseil, couleur : "Vert")
            makeGradiant(carre: cadreDashboard, couleur : "Gris")
            
            makeGradiant(carre: cadreSeries, couleur: "Blanc")
            makeGradiant(carre: cadreSaisons, couleur: "Blanc")
            makeGradiant(carre: cadreDecouverte, couleur: "Blanc")
            makeGradiant(carre: cadreDivers, couleur: "Blanc")
        }

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
        trakt.start()
        theTVdb.initializeToken()
        imdb.loadDataFile()
        imdb.prepareEpisodes()
        justWatch.initDiffuseurs()
        
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
        let targetController : UIViewController
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
//            targetController = segue.destination.children[0]
            targetController = segue.destination
        }
        else {
            targetController = segue.destination
        }

        
        switch (bouton.restorationIdentifier ?? "") {
        case "Watchlist":
            let viewController = targetController as! ViewSerieListe
            viewController.title = "Watchlist"
            for uneSerie in db.shows { if (uneSerie.watchlist) { buildList.append(uneSerie) } }
            viewController.viewList = buildList
            viewController.modeAffichage = modeWatchlist
            
        case "Abandonnées":
            let viewController = targetController as! ViewSerieListe
            viewController.title = "Séries abandonnées"
            for uneSerie in db.shows { if (uneSerie.unfollowed) { buildList.append(uneSerie) } }
            viewController.viewList = buildList
            viewController.modeAffichage = modeAbandon

        case "Finies":
            let viewController = targetController as! ViewSerieListe
            viewController.title = "Séries anciennes et finies"
            for uneSerie in db.shows {
                if (uneSerie.saisons.count > 0) {
                    if ( (uneSerie.saisons[uneSerie.saisons.count - 1].watched() == true) && (uneSerie.status == "Ended") ) {
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.modeAffichage = modeFinie

        case "En cours":
            let viewController = targetController as! ViewSerieListe
            viewController.title = "Séries en cours"
            for uneSerie in db.shows {
                if (uneSerie.saisons.count > 0) {
                    if ( ((uneSerie.saisons[uneSerie.saisons.count - 1].watched() == false) || (uneSerie.status != "Ended")) && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) ) {
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.modeAffichage = modeEnCours

        case "On the air":
            let viewController = targetController as! ViewSaisonListe
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
            let viewController = targetController as! ViewSaisonListe
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
            let viewController = targetController as! ViewSaisonListe
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
            let viewController = targetController as! ViewPropals
            viewController.title = "Propositions de séries"

        default:
            print("Passer à la fenêtre \(bouton.titleLabel?.text ?? "")")
            
        }
    }
    
 
    @IBAction func quickReload(_ sender: Any) {

//        // Print all series rates
//        print("serie;IMDB;Trakt;BetaSeries;MovieDB;TVmaze;RottenTomatoes;MetaCritic;AlloCine;")
//        for uneSerie in db.shows {
//            print("\(uneSerie.serie);\(uneSerie.ratingIMDB);\(uneSerie.ratingTrakt);\(uneSerie.ratingBetaSeries);\(uneSerie.ratingMovieDB);\(uneSerie.ratingTVmaze);\(uneSerie.ratingRottenTomatoes);\(uneSerie.ratingMetaCritic);\(uneSerie.ratingAlloCine);")
//        }
        
//        // Print all episodes rates
//        print("serie;saison;episode;ratingTVdb;ratersTVdb;ratingTrakt;ratersTrakt;ratingBetaSeries;ratersBetaSeries;ratingIMdb;ratersIMdb;ratingMoviedb;ratersMoviedb;")
//        for uneSerie in db.shows {
//            for uneSaison in uneSerie.saisons {
//                for unEpisode in uneSaison.episodes {
//                    print("\(unEpisode.serie);\(unEpisode.saison);\(unEpisode.episode);\(unEpisode.ratingTVdb);\(unEpisode.ratersTVdb);\(unEpisode.ratingTrakt);\(unEpisode.ratersTrakt);\(unEpisode.ratingBetaSeries);\(unEpisode.ratersBetaSeries);\(unEpisode.ratingIMdb);\(unEpisode.ratersIMdb);\(unEpisode.ratingMoviedb);\(unEpisode.ratersMoviedb);")
//                }
//            }
//        }

//        // Regenerate Refresh Dates
//        let defaults = UserDefaults.standard
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
//        defaults.set(dateFormatter.string(from: Date()), forKey: "RefreshDates")
//        defaults.set(dateFormatter.string(from: Date()), forKey: "RefreshIMDB")

        
//        // Calculate the coefficients for FairRates computation
//        db.computeFairRates()

        
        // Testing IMDB episodes loading
//        imdb.downloadEpisodes()
//        imdb.prepareEpisodes()
//        print ("tt7134908 saison 3 épisode 5 = \(imdb.getEpisodeID(serieID: "tt7134908", saison: 3, episode: 5))")
        
        
        
        // Initiate Refresh Infos
//        var infoZero : InfosRefresh = InfosRefresh(refreshDates: ZeroDate, refreshIMDB: ZeroDate, refreshViewed: ZeroDate)
//        db.saveRefreshInfo(info: infoZero)
        
        
        
//        let uneSerie : Serie = Serie(serie: "Stranger Things")
//        db.downloadGlobalInfo(serie: uneSerie)
        
        //yaqcs.getAllInfos(title: "Stranger Things", idIMDB: "", idAlloCine: "", idSensCritique: "")
        
        // Liste des genres dans TheMovieDB
        //theMoviedb.getGenres()
        
//        db.checkSeasonDates()
        
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
