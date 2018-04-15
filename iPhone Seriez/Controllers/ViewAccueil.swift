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
    var betaSeries : BetaSeries = BetaSeries.init()
    var theMoviedb : TheMoviedb = TheMoviedb.init()
    var imdb : IMdb = IMdb.init()
    
    var allSeries: [Serie] = [Serie]()
    var imagesCache : NSCache = NSCache<NSString, UIImage>()
    
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
    
    
    override func viewDidLoad() {
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
        
        // Connexion aux sources de données
        trakt.start()
        theTVdb.initializeToken()
        imdb.loadDB()
        
        // Chargement de la dernière sauvegarde
        loadDB()
        allSeries = allSeries.sorted(by:  { $0.serie < $1.serie })
        updateCompteurs()
    }
    
    @IBAction func downloadStatuses(_ sender: Any)
    {
        var reloadSeries : [Serie] = [Serie]()
        reloadSeries = trakt.getWatched()
        reloadSeries = self.merge(reloadSeries, adds: trakt.getStopped())
        reloadSeries = self.merge(reloadSeries, adds: trakt.getWatchlist())
        
        allSeries = self.merge(allSeries, adds: reloadSeries)
        self.saveDB()
        self.updateCompteurs()
        self.view.setNeedsDisplay()
    }
   
    
    @IBAction func downloadAll(_ sender: Any) {
        allSeries = trakt.getWatched()
        for uneSerie in allSeries { trakt.getSaisons(uneSerie: uneSerie) }
        allSeries = self.merge(allSeries, adds: trakt.getStopped())
        allSeries = self.merge(allSeries, adds: trakt.getWatchlist())
        
        let infoWindow : UIAlertController = UIAlertController(title: "Loading ...", message: "", preferredStyle: UIAlertControllerStyle.alert)
        self.present(infoWindow, animated: true, completion: { })
        
        DispatchQueue.global(qos: .utility).async {
            
            let totalCompteur : Int = self.allSeries.count
            var compteur : Int = 0
            
            for uneSerie in self.allSeries
            {
                compteur = compteur + 1
                DispatchQueue.main.async { infoWindow.message = "\(uneSerie.serie) (\(compteur)/\(totalCompteur))" }
                self.downloadGlobalInfo(serie: uneSerie)
            }
            
            infoWindow.dismiss(animated: true, completion: { })
            
            DispatchQueue.main.async {
                self.saveDB()
                self.updateCompteurs()
            }
        }
    }
    
    func downloadGlobalInfo(serie : Serie)
    {
        let dataTVdb : Serie = self.theTVdb.getSerieGlobalInfos(idTVdb: serie.idTVdb)
        let dataMoviedb : Serie = self.theMoviedb.getSerieGlobalInfos(idMovieDB: serie.idMoviedb)
        let dataBetaSeries : Serie = self.betaSeries.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb)
        let dataTrakt : Serie = self.trakt.getSerieGlobalInfos(idTraktOrIMDB: serie.idIMdb)
        let dataIMDB : Serie = self.imdb.getSerieGlobalInfos(idIMDB: serie.idIMdb)

        serie.cleverMerge(TVdb: dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB)
        
        if ( (serie.watchlist == false) && (serie.unfollowed == false) )
        {
            for saison in serie.saisons
            {
                if (saison.watched == false)
                {
                    serie.saisons[saison.saison - 1].ends = self.trakt.getLastEpisodeDate(traktID : serie.idTrakt, saison : saison.saison, episode : serie.saisons[saison.saison - 1].nbEpisodes)
                }
            }
        }
    }
    
    func downloadSerieDetails(serie : Serie)
    {
        self.theTVdb.getSerieInfos(serie)
        if (serie.idTVdb != "") { self.theTVdb.getEpisodesRatings(serie) }
        if (serie.idTrakt != "") { self.trakt.getEpisodesRatings(serie) }
        if (serie.idTVdb != "") { self.betaSeries.getEpisodesRatings(serie) }
        if (serie.idMoviedb != "") { self.theMoviedb.getEpisodesRatings(serie) }
        self.imdb.getEpisodesRatings(serie)
    }
    
    func saveDB ()
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathToSVG = dir.appendingPathComponent("SerieA.db")
            let success : Bool = NSKeyedArchiver.archiveRootObject(allSeries, toFile: pathToSVG.path)
            print("DB saved : \(success)")
        }
    }
    
    func loadDB ()
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathToSVG = dir.appendingPathComponent("SerieA.db")
            if (FileManager.default.fileExists(atPath: pathToSVG.path))
            {
                allSeries = (NSKeyedUnarchiver.unarchiveObject(withFile: pathToSVG.path) as? [Serie])!
                print("DB loaded")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getImage(_ url: String) -> UIImage
    {
        if (url == "") { return UIImage() }
        
        do {
            if ((imagesCache.object(forKey: url as NSString)) == nil)
            {
                let imageData : Data = try Data.init(contentsOf: URL(string: url)!)
                imagesCache.setObject(UIImage.init(data: imageData)!, forKey: url as NSString)
            }
            return imagesCache.object(forKey: url as NSString)!
        }
        catch let error as NSError { print("getImage failed for \(url) : \(error)") }
        
        return UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
            viewController.accueil = self
            viewController.isWatchlist = true
            for uneSerie in allSeries { if (uneSerie.watchlist) { buildList.append(uneSerie) } }
            viewController.viewList = buildList
            
        case "  Abandonnées":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries abandonnées"
            viewController.accueil = self
            for uneSerie in allSeries { if (uneSerie.unfollowed) { buildList.append(uneSerie) } }
            viewController.viewList = buildList
            
        case "  Finies":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries anciennes et finies"
            viewController.accueil = self
            for uneSerie in allSeries
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
            viewController.accueil = self
            for uneSerie in allSeries
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
            viewController.accueil = self
            for uneSerie in allSeries
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
            viewController.accueil = self
            for uneSerie in allSeries
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
            viewController.accueil = self
            for uneSerie in allSeries
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
            
        default:
            print("Passer à la fenêtre \(bouton.titleLabel?.text ?? "")")
            
        }
    }
    
    func updateCompteurs()
    {
        var valSeriesFinies : Int = 0
        var valSeriesEnCours : Int = 0
        var valSaisonsOnTheAir : Int = 0
        var valSaisonsDiffusees : Int = 0
        var valSaisonsAnnoncees : Int = 0
        var ValWatchList : Int = 0
        var valSeriesAbandonnees : Int = 0
        let today : Date = Date()
        
        for uneSerie in allSeries
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
    }
    
    func merge(_ db : [Serie], adds : [Serie]) -> [Serie]
    {
        var merged : Bool = false
        var newDB : [Serie] = db
        
        for uneSerie in adds
        {
            merged = false
            
            // On cherche la serie dans les series de la DB
            for dbSerie in db
            {
                if (dbSerie.idTrakt == uneSerie.idTrakt) {
                    dbSerie.merge(uneSerie)
                    merged = true
                }
            }
            
            // Nouvelle serie : on l'ajoute à la DB
            if (!merged) { newDB.append(uneSerie) }
        }
        
        return newDB
    }
    
    func mergeStatuses(_ db : [Serie], adds : [Serie]) -> [Serie]
    {
        for uneSerie in adds {
            for dbSerie in db {
                if (dbSerie.idTrakt == uneSerie.idTrakt) { dbSerie.mergeStatuses(uneSerie) }
            }
        }
        return db
    }
    
    
    
    // Fonctions de gestion de la watchlist
    func chercherUneSerieSurTrakt(nomSerie:String) -> [Serie]
    {
        return trakt.recherche(serieArechercher: nomSerie)
    }
    
    func ajouterUneSerieDansLaWatchlistTrakt(uneSerie : Serie) -> Bool
    {
        if (self.trakt.addToWatchlist(theTVdbId: uneSerie.idTVdb))
        {
            self.downloadGlobalInfo(serie: uneSerie)
            self.allSeries.append(uneSerie)
            self.saveDB()
            updateCompteurs()
            return true
        }
        return false
    }
    
    func supprimerUneSerieDansLaWatchlistTrakt(uneSerie: Serie) -> Bool
    {
        if (self.trakt.removeFromWatchlist(theTVdbId: uneSerie.idTVdb))
        {
            self.allSeries.remove(at: self.allSeries.index(of: uneSerie)!)
            self.saveDB()
            updateCompteurs()
            
            return true
        }
        return false
    }
    
 
    func printRatings()
    {
    print("serie;saison;episode;ratingTrakt;ratersTrakt;ratingTVdb;ratersTVdb;ratingMoviedb;ratersMoviedb;ratingBetaSeries;ratersBetaSeries;ratingIMdb;ratersIMdb")
        for uneSerie in allSeries
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
