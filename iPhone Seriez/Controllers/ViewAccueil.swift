//
//  ViewAccueil.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import WidgetKit

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
    @IBOutlet weak var cadreExplorer: UIView!
    @IBOutlet weak var cadreAdvisors: UIView!
    @IBOutlet weak var cadreJournal: UIView!
 
    @IBOutlet weak var cadreCalendrier: UIView!
    @IBOutlet weak var cadreAdvisorsPhone: UIView!
    @IBOutlet weak var cadreJournalPhone: UIView!

    @IBOutlet weak var cadreGo1: UIView!
    @IBOutlet weak var cadreGo2: UIView!
    @IBOutlet weak var cadreGo3: UIView!
    
    @IBOutlet weak var cadreSeries: UIView!
    @IBOutlet weak var cadreSaisons: UIView!
    @IBOutlet weak var cadreDecouverte: UIView!
    @IBOutlet weak var cadreDivers: UIView!
    @IBOutlet weak var cadreASuivre: UIView!
    
    
    @IBOutlet weak var bannerASuivre1: UIImageView!
    @IBOutlet weak var bannerASuivre2: UIImageView!
    @IBOutlet weak var bannerASuivre3: UIImageView!
    @IBOutlet weak var episodeASuivre1: UILabel!
    @IBOutlet weak var episodeASuivre2: UILabel!
    @IBOutlet weak var episodeASuivre3: UILabel!
    @IBOutlet weak var diffuseurASuivre1: UIImageView!
    @IBOutlet weak var diffuseurASuivre2: UIImageView!
    @IBOutlet weak var diffuseurASuivre3: UIImageView!
    
    var seriesASuivre : [Serie] = []
    var saisonsASuivre : [Int] = []
    var episodesASuivre : [Int] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        appConfig.load()
        reqAccessToContacts()
        
        // Initialisation sources de données
        trakt.start()
        theTVdb.initializeToken()
        
        let queue : OperationQueue = OperationQueue()
        let opeIMDB = BlockOperation(block: {
            imdb.loadDataFile()
        } )
        queue.addOperation(opeIMDB)

        // Chargement de la dernière sauvegarde
        db.loadDB()
        db.updateCompteurs()

        // Initialize date formatters
        dateFormShort.locale = Locale.current
        dateFormShort.dateFormat = "dd MMM yy"
        dateFormLong.locale = Locale.current
        dateFormLong.dateFormat = "dd MMM yyyy"
        dateFormSource.locale = Locale.current
        dateFormSource.dateFormat = "yyyy-MM-dd"

        journal.load()
//        journal.removeDuplicates()
//        journal.save()
        
        checkDirectories()
        
        // Faire des jolis carrés dégradés à coins ronds
        makeGradiant(carre: cadreSerieWatchlist, couleur : "Vert")
        makeGradiant(carre: cadreSerieEncours, couleur : "Bleu")
        makeGradiant(carre: cadreConfiguration, couleur : "Gris")
        makeGradiant(carre: cadreReload, couleur : "Gris")
        makeGradiant(carre: cadreSeries, couleur: "Blanc")

        // Faire des jolis compteurs à coins ronds
        arrondir(texte: cptSeriesFinies, radius : 10.0)
        arrondir(texte: cptSeriesEnCours, radius : 10.0)
        arrondir(texte: cptSeriesAbandonnees, radius : 10.0)
        arrondir(texte: cptWatchList, radius : 10.0)
        
        border(texte: cptSeriesFinies)
        border(texte: cptSeriesEnCours)
        border(texte: cptSeriesAbandonnees)
        border(texte: cptWatchList)

        
        // iPhone spécific
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            makeGradiant(carre: cadreSerieAbandonnee, couleur : "Rouge")
            makeGradiant(carre: cadreSerieFinie, couleur : "Gris")

            makeGradiant(carre: cadreRecherche, couleur : "Gris")
            makeGradiant(carre: cadreCalendrier, couleur: "Bleu")
            makeGradiant(carre: cadreJournalPhone, couleur: "Bleu")
            makeGradiant(carre: cadreAdvisorsPhone, couleur: "Bleu")
            
            appConfig.modeCouleurSerie = true
        }
        
        // iPad spécific
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            makeGradiant(carre: cadreConseil, couleur : "Vert")
            makeGradiant(carre: cadreDashboard, couleur : "Gris")
            makeGradiant(carre: cadreExplorer, couleur : "Gris")
            makeGradiant(carre: cadreAdvisors, couleur : "Gris")
            makeGradiant(carre: cadreJournal, couleur : "Gris")
            makeGradiant(carre: cadreSerieAbandonnee, couleur : "Bleu")
            makeGradiant(carre: cadreSerieFinie, couleur : "Bleu")
            makeGradiant(carre: cadreSaisonAvoir, couleur : "Rouge")
            makeGradiant(carre: cadreSaisonAvenir, couleur : "Rouge")
            makeGradiant(carre: cadreSaisonEncours, couleur : "Rouge")
            makeGradiant(carre: cadreRecherche, couleur : "Vert")
            makeGradiant(carre: cadreGo1, couleur : "Rouge")
            makeGradiant(carre: cadreGo2, couleur : "Rouge")
            makeGradiant(carre: cadreGo3, couleur : "Rouge")

            makeGradiant(carre: cadreSaisons, couleur: "Blanc")
            makeGradiant(carre: cadreDecouverte, couleur: "Blanc")
            makeGradiant(carre: cadreDivers, couleur: "Blanc")
            makeGradiant(carre: cadreASuivre, couleur: "Blanc")

            arrondir(texte: cptSaisonsOnTheAir, radius : 10.0)
            arrondir(texte: cptSaisonsDiffusees, radius : 10.0)
            arrondir(texte: cptSaisonsAnnoncees, radius : 10.0)

            border(texte: cptSaisonsOnTheAir)
            border(texte: cptSaisonsDiffusees)
            border(texte: cptSaisonsAnnoncees)
            
            arrondir(fenetre: diffuseurASuivre1, radius: 4)
            arrondir(fenetre: diffuseurASuivre2, radius: 4)
            arrondir(fenetre: diffuseurASuivre3, radius: 4)

            refreshASuivre()
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        cptSeriesFinies.text = String(db.valSeriesFinies)
        cptSeriesEnCours.text = String(db.valSeriesEnCours)
        cptWatchList.text = String(db.valWatchList)
        cptSeriesAbandonnees.text = String(db.valSeriesAbandonnees)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            cptSaisonsOnTheAir.text = String(db.valSaisonsOnTheAir)
            cptSaisonsDiffusees.text = String(db.valSaisonsDiffusees)
            cptSaisonsAnnoncees.text = String(db.valSaisonsAnnoncees)
            
            refreshASuivre()
        }
    }
    
    
    func refreshASuivre() {
        seriesASuivre = []
        episodesASuivre = []
        saisonsASuivre = []
        var monActivite : [Data4MonActivite] = []
        let today = Date()
        
        // Recherche des séries en cours de visionnage
        for uneSerie in db.shows {
            for uneSaison in uneSerie.saisons {
                if ( (uneSaison.starts != ZeroDate) &&
                    (uneSaison.ends.compare(today) == .orderedAscending ) && (uneSaison.ends != ZeroDate) &&
                    (uneSaison.watched() == false) && (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
                    if (uneSaison.nbWatchedEps > 0) {
                        seriesASuivre.append(uneSerie)
                        saisonsASuivre.append(uneSaison.saison)
                        episodesASuivre.append(uneSaison.nbWatchedEps+1)
                        
                        let infoActivite : Data4MonActivite = Data4MonActivite(serie: uneSerie.serie, channel: uneSerie.diffuseur, saison: uneSaison.saison, nbEps: uneSaison.nbEpisodes, nbWatched: uneSaison.nbWatchedEps, poster: uneSerie.poster)
                        
                        monActivite.append(infoActivite)
                    }
                }
            }
        }

        
        // Envoides infos au widget de suivi
        let sharedContainer = UserDefaults(suiteName: "group.Series")
        sharedContainer?.set(try? PropertyListEncoder().encode(monActivite), forKey: "MonActivite")
        WidgetCenter.shared.reloadTimelines(ofKind: "Mon_activite_")

        
        // Mise à jour de la page d'accueil
        if (saisonsASuivre.count > 0) {
            bannerASuivre1.image = getImage(seriesASuivre[0].banner)
            episodeASuivre1.text = String(format: "S%02d E%02d", saisonsASuivre[0], episodesASuivre[0])
            diffuseurASuivre1.image = getLogoDiffuseur(diffuseur: seriesASuivre[0].diffuseur)

            bannerASuivre1.isHidden = false
            episodeASuivre1.isHidden = false
            diffuseurASuivre1.isHidden = false
            cadreGo1.isHidden = false
        }
        else {
            bannerASuivre1.isHidden = true
            episodeASuivre1.isHidden = true
            diffuseurASuivre1.isHidden = true
            cadreGo1.isHidden = true
        }
            
        if (saisonsASuivre.count > 1) {
            bannerASuivre2.image = getImage(seriesASuivre[1].banner)
            episodeASuivre2.text = String(format: "S%02d E%02d", saisonsASuivre[1], episodesASuivre[1])
            diffuseurASuivre2.image = getLogoDiffuseur(diffuseur: seriesASuivre[1].diffuseur)

            bannerASuivre2.isHidden = false
            episodeASuivre2.isHidden = false
            diffuseurASuivre2.isHidden = false
            cadreGo2.isHidden = false
        }
        else {
            bannerASuivre2.isHidden = true
            episodeASuivre2.isHidden = true
            diffuseurASuivre2.isHidden = true
            cadreGo2.isHidden = true
        }
            
        if (saisonsASuivre.count > 2) {
            bannerASuivre3.image = getImage(seriesASuivre[2].banner)
            episodeASuivre3.text = String(format: "S%02d E%02d", saisonsASuivre[2], episodesASuivre[2])
            diffuseurASuivre3.image = getLogoDiffuseur(diffuseur: seriesASuivre[2].diffuseur)

            bannerASuivre3.isHidden = false
            episodeASuivre3.isHidden = false
            diffuseurASuivre3.isHidden = false
            cadreGo3.isHidden = false
        }
        else {
            bannerASuivre3.isHidden = true
            episodeASuivre3.isHidden = true
            diffuseurASuivre3.isHidden = true
            cadreGo3.isHidden = true
        }
            
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var buildList = [Serie]()
        var buildListSaisons = [Int]()
        let today : Date = Date()
        let targetController : UIViewController
        
        targetController = segue.destination
        
        switch (segue.identifier ?? "") {
        case "Watchlist":
            let viewController = targetController as! ViewExplorer
            viewController.title = "Watchlist des séries"
            viewController.typeAffichage = modeWatchlist
            viewController.viewList = db.shows
            
        case "Abandonnées":
            let viewController = targetController as! ViewExplorer
            viewController.title = "Séries abandonnées"
            viewController.typeAffichage = modeAbandon
            viewController.viewList = db.shows

        case "Finies":
            let viewController = targetController as! ViewExplorer
            viewController.title = "Séries anciennes et finies"
            viewController.typeAffichage = modeFinie
            viewController.viewList = db.shows

        case "En cours":
            let viewController = targetController as! ViewExplorer
            viewController.title = "Séries en cours de visionnage"
            viewController.typeAffichage = modeEnCours
            viewController.viewList = db.shows

        case "Watchlist - iPhone":
            let viewController = targetController as! ViewSerieListe
            viewController.title = "Watchlist"
            viewController.viewList = db.shows.filter({ $0.watchlist })
            viewController.modeAffichage = modeWatchlist
            
        case "Abandonnées - iPhone":
            let viewController = targetController as! ViewSerieListe
            viewController.title = "Séries abandonnées"
            viewController.viewList = db.shows.filter({ $0.unfollowed })
            viewController.modeAffichage = modeAbandon

        case "Finies - iPhone":
            let viewController = targetController as! ViewSerieListe
            viewController.title = "Séries anciennes et finies"
            viewController.viewList = db.shows.filter({ ( ($0.watchlist == false) && ($0.enCours() == false) && ($0.unfollowed == false) ) })
            viewController.modeAffichage = modeFinie

        case "En cours - iPhone":
            let viewController = targetController as! ViewSerieListe
            viewController.title = "Séries en cours"
            viewController.viewList = db.shows.filter({ $0.enCours() })
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

        case "Go1":
            let viewController = targetController as! EpisodeFiche
            viewController.title = "Episode à suivre"
            viewController.serie = seriesASuivre[0]
            viewController.saison = saisonsASuivre[0]
            viewController.episode = episodesASuivre[0]
            viewController.image =  getImage(seriesASuivre[0].banner)

        case "Go2":
            let viewController = targetController as! EpisodeFiche
            viewController.title = "Episode à suivre"
            viewController.serie = seriesASuivre[1]
            viewController.saison = saisonsASuivre[1]
            viewController.episode = episodesASuivre[1]
            viewController.image =  getImage(seriesASuivre[1].banner)

        case "Go3":
            let viewController = targetController as! EpisodeFiche
            viewController.title = "Episode à suivre"
            viewController.serie = seriesASuivre[2]
            viewController.saison = saisonsASuivre[2]
            viewController.episode = episodesASuivre[2]
            viewController.image =  getImage(seriesASuivre[2].banner)

        case "Explorer":
            let viewController = targetController as! ViewExplorer
            viewController.title = "Explorer la base de données"
            viewController.viewList = db.shows

        case "Advisors":
            let viewController = targetController as! ViewAdvisors
            viewController.title = "Advisor's bill"
            viewController.viewList = db.shows

        default:
            print("Passer à la fenêtre \(segue.identifier ?? "")")
            
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

        
        
//        let uneSerie : Serie = Serie(serie: "Stranger Things")
//        db.downloadGlobalInfo(serie: uneSerie)
        
        //yaqcs.getAllInfos(title: "Stranger Things", idIMDB: "", idAlloCine: "", idSensCritique: "")
        
        // Liste des genres dans TheMovieDB
        //theMoviedb.getGenres()
        
//        db.checkSeasonDates()
        
        
        
        
        
        
        

        var dataUpdates : DataUpdatesEntry = db.loadDataUpdates()
        db.quickRefresh()
        dataUpdates.Trakt_Viewed = Date()

        for uneSerie in db.shows {
            if ( (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) && (uneSerie.status != "ended") && (uneSerie.status != "canceled") ) {
                db.downloadDates(serie : uneSerie)
            }
        }
        dataUpdates.TVMaze_Dates = Date()
        
        db.saveDataUpdates(dataUpdates: dataUpdates)
        db.finaliseDB()
        self.viewDidAppear(false)
    }
        
}
