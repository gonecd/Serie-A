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
    
    var allSeries: [Serie] = [Serie]()
    var imagesCache : NSCache = NSCache<NSString, UIImage>()

    @IBOutlet weak var cptAnciennes: UITextField!
    @IBOutlet weak var cptAjour: UITextField!
    @IBOutlet weak var cptAttendre: UITextField!
    @IBOutlet weak var cptAvoir: UITextField!
    @IBOutlet weak var cptAvenir: UITextField!
    @IBOutlet weak var cptAdecouvrir: UITextField!
    @IBOutlet weak var cptAbandonnees: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Affichage du gradient
        let gradientLayer : CAGradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.darkGray.cgColor, UIColor.white.cgColor]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
            gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Connexion aux sources de données
        trakt.start()
        theTVdb.initializeToken()
        
        // Chargement de la dernière sauvegarde
        loadDB()
        allSeries = allSeries.sorted(by:  { $0.serie < $1.serie })
        updateCompteurs()
    }
    
    @IBAction func downloadAll(_ sender: Any) {
        allSeries = trakt.getWatched()
        allSeries = self.merge(allSeries, adds: trakt.getStopped())
        allSeries = self.merge(allSeries, adds: trakt.getWatchlist())
        
        let infoWindow : UIAlertController = UIAlertController(title: "Loading ...", message: "", preferredStyle: UIAlertControllerStyle.alert)
        var compteur : Int = 0
        
        self.present(infoWindow, animated: true, completion: { })
        
        DispatchQueue.global(qos: .utility).async {

            let totalCompteur : Int = self.allSeries.count
            for uneSerie in self.allSeries
            {
                compteur = compteur + 1
                DispatchQueue.main.async { infoWindow.message = "\(uneSerie.serie) (\(compteur)/\(totalCompteur))" }
                
                self.theTVdb.getSerieInfos(uneSerie)
                self.theTVdb.getEpisodesRatings(uneSerie)
                self.trakt.getEpisodesRatings(uneSerie)
                self.betaSeries.getEpisodesRatings(uneSerie)
                uneSerie.computeSerieInfos()
            }
            
            infoWindow.dismiss(animated: true, completion: { })
            
            DispatchQueue.main.async {
                self.saveDB()
                self.updateCompteurs()
            }
        }
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
        var buildListMessages = [String]()
        var buildListSaisons = [Int]()
        let today : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"

        switch (bouton.titleLabel?.text ?? "") {
        case "A decouvrir":
            let viewController = segue.destination as! ViewSeries
            viewController.title = "Séries à découvrir"
            viewController.accueil = self
            for uneSerie in allSeries
            {
                if (uneSerie.watchlist)
                {
                    uneSerie.message = "\(uneSerie.saisons.count) saisons"
                    buildList.append(uneSerie)
                }
            }
            viewController.viewList = buildList

        case "Abandonnees":
            let viewController = segue.destination as! ViewSeries
            viewController.title = "Séries abandonnées"
            viewController.accueil = self
            for uneSerie in allSeries
            {
                if (uneSerie.unfollowed)
                {
                    var totalEpisodes : Int = 0
                    var viewedEpisodes : Int = 0
                    var viewedRatio : Int = 0

                    for uneSaison in uneSerie.saisons {
                        for unEpisode in uneSaison.episodes {
                            totalEpisodes = totalEpisodes + 1
                            if (unEpisode.watched) { viewedEpisodes = viewedEpisodes + 1 }
                        }
                    }
                    if (totalEpisodes != 0) { viewedRatio = Int(100 * viewedEpisodes / totalEpisodes) }
                    uneSerie.message = "\(viewedRatio)% vue"
                    buildList.append(uneSerie)
                }
            }
            viewController.viewList = buildList
            
        case "Anciennes":
            let viewController = segue.destination as! ViewSeries
            viewController.title = "Séries anciennes et finies"
            viewController.accueil = self
            for uneSerie in allSeries
            {
                if ( (uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == true) && (uneSerie.status == "Ended") )
                {
                    uneSerie.message = "\(uneSerie.saisons.count) saisons"
                    buildList.append(uneSerie)
                }
            }
            viewController.viewList = buildList
            
        case "A jour":
            let viewController = segue.destination as! ViewSeries
            viewController.title = "Séries à jour"
            viewController.accueil = self
            for uneSerie in allSeries
            {
                if ( (uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == true) && (uneSerie.status != "Ended") )
                {
                    buildList.append(uneSerie)
                }
            }
            viewController.viewList = buildList
            
        case "Attendre":
            let viewController = segue.destination as! ViewSaisons
            viewController.title = "Saisons en cours de diffusion"
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
                        //uneSerie.message = dateFormatter.string(from: uneSaison.episodes[uneSaison.episodes.count - 1].date)
                        buildList.append(uneSerie)
                        buildListMessages.append(dateFormatter.string(from: uneSaison.episodes[uneSaison.episodes.count - 1].date))
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allMessages = buildListMessages
            viewController.allSaisons = buildListSaisons

        case "A voir":
            let viewController = segue.destination as! ViewSaisons
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
                        //uneSerie.message = "Saison \(uneSaison.saison)"
                        buildList.append(uneSerie)
                        buildListMessages.append("Saison \(uneSaison.saison)")
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allMessages = buildListMessages
            viewController.allSaisons = buildListSaisons

        case "A venir":
            let viewController = segue.destination as! ViewSaisons
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
                        if ( uneSaison.episodes[0].date.compare(dateFormatter.date(from: "01 Jan 90")!) == .orderedAscending)
                        {
                            //uneSerie.message = "TBA"
                            buildListMessages.append("TBA")
                        }
                        else
                        {
                            //uneSerie.message = dateFormatter.string(from: uneSaison.episodes[0].date)
                            buildListMessages.append(dateFormatter.string(from: uneSaison.episodes[0].date))
                        }
                        buildList.append(uneSerie)
                        buildListSaisons.append(uneSaison.saison)
                    }
                }
            }
            viewController.viewList = buildList
            viewController.allMessages = buildListMessages
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
            if ( (uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == true) && (uneSerie.status != "Ended") ) { valAjour = valAjour + 1 }

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
            uneSerie.computeSerieInfos()
            self.allSeries.append(uneSerie)
            self.saveDB()
            
            return true
        }
        return false
    }
    
    
    
}
