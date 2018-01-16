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
    
    @IBOutlet weak var cptAnciennes: UITextField!
    @IBOutlet weak var cptAjour: UITextField!
    @IBOutlet weak var cptAttendre: UITextField!
    @IBOutlet weak var cptAvoir: UITextField!
    @IBOutlet weak var cptAvenir: UITextField!
    @IBOutlet weak var cptAdecouvrir: UITextField!
    @IBOutlet weak var cptAbandonnees: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trakt.start()
        
        theTVdb.initializeToken()
        loadDB()
        
        allSeries = allSeries.sorted(by:  { $0.serie < $1.serie })
        
        updateCompteurs()
    }
    
    @IBAction func downloadAll(_ sender: Any) {
        allSeries = trakt.getWatched()
        allSeries = self.merge(allSeries, adds: trakt.getStopped())
        allSeries = self.merge(allSeries, adds: trakt.getWatchlist())
        
        for uneSerie in allSeries
        {
            print("Loading \(uneSerie.serie)")
            theTVdb.getSerieInfos(uneSerie)
            theTVdb.getEpisodesRatings(uneSerie)
            trakt.getEpisodesRatings(uneSerie)
            betaSeries.getEpisodesRatings(uneSerie)
            uneSerie.computeSerieInfos()
        }
        saveDB()
        
        updateCompteurs()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bouton = sender as! UIButton
        var buildList = [Serie]()
        let viewController = segue.destination as! ViewAbandonnees
        let today : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"
        
        switch (bouton.titleLabel?.text ?? "") {
        case "A decouvrir":
            viewController.title = "Séries à découvrir"
            for uneSerie in allSeries
            {
                if (uneSerie.watchlist)
                {
                    uneSerie.message = "\(uneSerie.saisons.count) saisons"
                    buildList.append(uneSerie)
                }
            }
            viewController.allSeries = buildList

        case "Abandonnees":
            viewController.title = "Séries abandonnées"
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
            viewController.allSeries = buildList
            
        case "Anciennes":
            viewController.title = "Séries anciennes et finies"
            for uneSerie in allSeries
            {
                if ( (uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == true) && (uneSerie.status == "Ended") )
                {
                    uneSerie.message = "\(uneSerie.saisons.count) saisons"
                    buildList.append(uneSerie)
                }
            }
            viewController.allSeries = buildList
            
        case "A jour":
            viewController.title = "Séries à jour"
            for uneSerie in allSeries
            {
                if ( (uneSerie.saisons[uneSerie.saisons.count - 1].episodes[uneSerie.saisons[uneSerie.saisons.count - 1].episodes.count - 1].watched == true) && (uneSerie.status != "Ended") )
                {
                    buildList.append(uneSerie)
                }
            }
            viewController.allSeries = buildList
            
        case "Attendre":
            viewController.title = "Saisons en cours de diffusion"
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
                        uneSerie.message = dateFormatter.string(from: uneSaison.episodes[uneSaison.episodes.count - 1].date)
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.allSeries = buildList
            
        case "A voir":
            viewController.title = "Saisons prêtes à voir"
            for uneSerie in allSeries
            {
                for uneSaison in uneSerie.saisons
                {
                    if ( (uneSaison.episodes[uneSaison.episodes.count - 1].date.compare(today) == .orderedAscending ) &&
                        (uneSaison.episodes[uneSaison.episodes.count - 1].watched == false) &&
                        (uneSerie.watchlist == false) &&
                        (uneSerie.unfollowed == false) )
                    {
                        uneSerie.message = "Saison \(uneSaison.saison)"
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.allSeries = buildList
            
        case "A venir":
            viewController.title = "Nouvelles saisons annoncées"
            for uneSerie in allSeries
            {
                for uneSaison in uneSerie.saisons
                {
                    if ( (uneSaison.episodes[0].date.compare(today) == .orderedDescending ) &&
                        (uneSerie.watchlist == false) &&
                        (uneSerie.unfollowed == false) )
                    {
                        if ( uneSaison.episodes[0].date == Date.distantFuture)
                        {
                            uneSerie.message = "TBA"
                        }
                        else
                        {
                            uneSerie.message = dateFormatter.string(from: uneSaison.episodes[0].date)
                        }
                        buildList.append(uneSerie)
                    }
                }
            }
            viewController.allSeries = buildList
            
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
    
}
