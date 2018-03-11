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
    
    @IBOutlet weak var cptAnciennes: UITextField!
    @IBOutlet weak var cptAjour: UITextField!
    @IBOutlet weak var cptAttendre: UITextField!
    @IBOutlet weak var cptAvoir: UITextField!
    @IBOutlet weak var cptAvenir: UITextField!
    @IBOutlet weak var cptAdecouvrir: UITextField!
    @IBOutlet weak var cptAbandonnees: UITextField!
    
    @IBOutlet weak var cadreSaisonAvenir: UIView!
    @IBOutlet weak var cadreSaisonAvoir: UIView!
    @IBOutlet weak var cadreSaisonEncours: UIView!
    @IBOutlet weak var cadreSerieAbandonnee: UIView!
    @IBOutlet weak var cadreSerieWatchlist: UIView!
    @IBOutlet weak var cadreSerieEncours: UIView!
    @IBOutlet weak var cadreSerieFinie: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Faire des jolis carrés dégradés à coins ronds
        makeBlueGradiant(carre: cadreSerieAbandonnee)
        makeBlueGradiant(carre: cadreSerieWatchlist)
        makeBlueGradiant(carre: cadreSerieEncours)
        makeBlueGradiant(carre: cadreSerieFinie)
        makeRedGradiant(carre: cadreSaisonAvoir)
        makeRedGradiant(carre: cadreSaisonAvenir)
        makeRedGradiant(carre: cadreSaisonEncours)

        // Faire des jolis compteurs à coins ronds
        makeJolisCompteurs(compteur: cptAnciennes)
        makeJolisCompteurs(compteur: cptAjour)
        makeJolisCompteurs(compteur: cptAttendre)
        makeJolisCompteurs(compteur: cptAvoir)
        makeJolisCompteurs(compteur: cptAvenir)
        makeJolisCompteurs(compteur: cptAdecouvrir)
        makeJolisCompteurs(compteur: cptAbandonnees)

        // Connexion aux sources de données
        trakt.start()
        theTVdb.initializeToken()
        imdb.loadDB()
        
        // Chargement de la dernière sauvegarde
        loadDB()
        allSeries = allSeries.sorted(by:  { $0.serie < $1.serie })
        updateCompteurs()

//        var total : Int = 0
//        var nb : Int = 0
//
//        for uneSerie in allSeries
//        {
//            for uneSaison in uneSerie.saisons
//            {
//                for unEpisode in uneSaison.episodes
//                {
//                    if (unEpisode.ratingIMdb > 0)
//                    {
//                        total = total + (unEpisode.ratingIMdb * unEpisode.ratersIMdb)
//                        nb = nb + unEpisode.ratersIMdb
//                    }
//                }
//            }
//        }
//        print("Correction = \(Int(total / nb))")
        
        
//        for uneSerie in allSeries
//        {
//            print("Loading \(uneSerie.serie)")
//            self.theTVdb.getEpisodesRatings(uneSerie)
//            self.imdb.getEpisodesRatings(uneSerie)
//        }
//
//        saveDB()
    }

    func makeJolisCompteurs(compteur: UITextField)
    {
        compteur.layer.cornerRadius = 15
        compteur.layer.masksToBounds = true
    }
    
    func makeRedGradiant(carre : UIView)
    {
        let redGradient : CAGradientLayer = CAGradientLayer()
        //redGradient.colors = [UIColor.red.cgColor, UIColor.red.withAlphaComponent(0.1).cgColor]
        redGradient.colors = [UIColor.red.cgColor, UIColor.orange.cgColor]
        redGradient.startPoint = CGPoint(x: 0, y: 0)
        redGradient.endPoint = CGPoint(x: 1, y: 1)
        redGradient.frame = carre.bounds
        
        carre.layer.cornerRadius = 10;
        carre.layer.masksToBounds = true

        carre.layer.insertSublayer(redGradient, at: 0)
    }
    
    func makeBlueGradiant(carre : UIView)
    {
        let blueGradient : CAGradientLayer = CAGradientLayer()
        blueGradient.colors = [UIColor.blue.withAlphaComponent(0.8).cgColor, UIColor.blue.withAlphaComponent(0.2).cgColor]
        blueGradient.startPoint = CGPoint(x: 0, y: 1)
        blueGradient.endPoint = CGPoint(x: 1, y: 0)
        blueGradient.frame = carre.bounds
        
        carre.layer.cornerRadius = 10;
        carre.layer.masksToBounds = true;
        carre.layer.insertSublayer(blueGradient, at: 0)
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
                self.downloadSerieDetails(serie: uneSerie)
            }
            
            infoWindow.dismiss(animated: true, completion: { })
            
            DispatchQueue.main.async {
                self.saveDB()
                self.updateCompteurs()
            }
        }
    }
    
    func downloadSerieDetails(serie : Serie)
    {
        self.theTVdb.getSerieInfos(serie)
        self.theTVdb.getEpisodesRatings(serie)
        self.trakt.getEpisodesRatings(serie)
        self.betaSeries.getEpisodesRatings(serie)
        self.theMoviedb.getEpisodesRatings(serie)
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
                let imageData : Data = try Data.init(contentsOf: URL(string: "https://www.thetvdb.com/banners/\(url)")!)
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
            viewController.title = "Séries à découvrir"
            viewController.accueil = self
            viewController.isWatchlist = true
            for uneSerie in allSeries
            {
                if (uneSerie.watchlist) { buildList.append(uneSerie) }
            }
            viewController.viewList = buildList
            
        case "  Abandonnées":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries abandonnées"
            viewController.accueil = self
            for uneSerie in allSeries
            {
                if (uneSerie.unfollowed) { buildList.append(uneSerie) }
            }
            viewController.viewList = buildList
            
        case "  Finies":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries anciennes et finies"
            viewController.accueil = self
            for uneSerie in allSeries
            {
                if ( (uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == true) && (uneSerie.status == "Ended") )
                {
                    buildList.append(uneSerie)
                }
            }
            viewController.viewList = buildList
            
        case "  En cours":
            let viewController = segue.destination as! ViewSerieListe
            viewController.title = "Séries en cours"
            viewController.accueil = self
            for uneSerie in allSeries
            {
                if ( ((uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == false) || (uneSerie.status != "Ended"))
                    && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) )
                {
                    buildList.append(uneSerie)
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
                    if ( (uneSaison.episodes[0].date.compare(today) == .orderedAscending ) &&
                        (uneSaison.episodes[uneSaison.episodes.count - 1].date.compare(today) == .orderedDescending ) &&
                        (uneSaison.episodes[uneSaison.episodes.count - 1].watched == false)  &&
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
                    if ( (uneSaison.episodes[uneSaison.episodes.count - 1].date.compare(today) == .orderedAscending ) &&
                        (uneSaison.episodes[uneSaison.episodes.count - 1].watched == false) &&
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
                    if ( (uneSaison.episodes[0].date.compare(today) == .orderedDescending ) &&
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
        var valAnciennes : Int = 0
        var valAjour : Int = 0
        var valAttendre : Int = 0
        var valAvoir : Int = 0
        var valAvenir : Int = 0
        var valptAdecouvrir : Int = 0
        var valAbandonnees : Int = 0
        let today : Date = Date()
        
        for uneSerie in allSeries
        {
            if (uneSerie.unfollowed) { valAbandonnees = valAbandonnees + 1 }
            if (uneSerie.watchlist) { valptAdecouvrir = valptAdecouvrir + 1 }
            if ( (uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == true) && (uneSerie.status == "Ended") ) { valAnciennes = valAnciennes + 1 }
            if ( ((uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == false) || (uneSerie.status != "Ended")) && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) ) { valAjour = valAjour + 1 }
            
            for uneSaison in uneSerie.saisons
            {
                if ( (uneSaison.episodes[0].date.compare(today) == .orderedAscending ) &&
                    (uneSaison.episodes[uneSaison.episodes.count - 1].date.compare(today) == .orderedDescending ) &&
                    (uneSaison.episodes[uneSaison.episodes.count - 1].watched == false)  &&
                    (uneSerie.watchlist == false) &&
                    (uneSerie.unfollowed == false) )
                { valAttendre = valAttendre + 1 }
                
                if ( (uneSaison.episodes[uneSaison.episodes.count - 1].date.compare(today) == .orderedAscending ) &&
                    (uneSaison.episodes[uneSaison.episodes.count - 1].watched == false) &&
                    (uneSerie.watchlist == false) &&
                    (uneSerie.unfollowed == false) )
                { valAvoir = valAvoir + 1 }
                
                if ( (uneSaison.episodes[0].date.compare(today) == .orderedDescending ) &&
                    (uneSerie.watchlist == false) &&
                    (uneSerie.unfollowed == false) )
                { valAvenir = valAvenir + 1 }
            }
        }
        
        cptAnciennes.text = String(valAnciennes)
        cptAjour.text = String(valAjour)
        cptAttendre.text = String(valAttendre)
        cptAvoir.text = String(valAvoir)
        cptAvenir.text = String(valAvenir)
        cptAdecouvrir.text = String(valptAdecouvrir)
        cptAbandonnees.text = String(valAbandonnees)
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
            self.theTVdb.getSerieInfos(uneSerie)
            self.trakt.getEpisodesRatings(uneSerie)
            self.betaSeries.getEpisodesRatings(uneSerie)
            self.theMoviedb.getEpisodesRatings(uneSerie)
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
    
}
