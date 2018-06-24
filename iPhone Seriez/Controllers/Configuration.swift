//
//  Configuration.swift
//  SerieA
//
//  Created by Cyril Delamare on 17/06/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class Configuration: UIViewController
{
    @IBOutlet weak var progresData: UIProgressView!
    @IBOutlet weak var progresSource: UIProgressView!
    @IBOutlet weak var labelIMDB: UILabel!
    @IBOutlet weak var boutonIMDB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progresData.isHidden = true
        progresSource.isHidden = true
        labelIMDB.isHidden = true
        boutonIMDB.layer.cornerRadius = 8.0
        boutonIMDB.layer.masksToBounds = true
    }
    

    @IBAction func loadPosters(_ sender: Any) {
        progresData.setProgress(0.0, animated: false)
        progresData.isHidden = false
        
        DispatchQueue.global(qos: .utility).async {
            
            // Vidange du cache
            for uneURL in try! FileManager.default.contentsOfDirectory(at: PosterDir, includingPropertiesForKeys: nil, options: []) {
                try! FileManager.default.removeItem(at: uneURL)
            }
            
            let nbShows : Float = Float(db.shows.count)
            var showNum : Int = 0
            for uneSerie in db.shows
            {
                showNum = showNum + 1
                getImage(uneSerie.banner)
                getImage(uneSerie.poster)
                DispatchQueue.main.async { self.progresData.setProgress(Float(showNum)/nbShows, animated: true) }
            }

            DispatchQueue.main.async { self.progresData.isHidden = true }
        }
    }
    
    
    
    @IBAction func loadStatuses(_ sender: Any) {
        var reloadSeries : [Serie] = [Serie]()
        reloadSeries = trakt.getWatched()
        for uneSerie in db.shows { trakt.getSaisons(uneSerie: uneSerie) }
        reloadSeries = db.merge(reloadSeries, adds: trakt.getStopped())
        reloadSeries = db.merge(reloadSeries, adds: trakt.getWatchlist())
        
        db.shows = db.mergeStatuses(db.shows, adds: reloadSeries)
        db.saveDB()
        db.updateCompteurs()
    }
    
    
    
    @IBAction func loadDatesSaisons(_ sender: Any) {
        progresData.setProgress(0.0, animated: false)
        progresData.isHidden = false
        
        DispatchQueue.global(qos: .utility).async {
            
            let nbShows : Float = Float(db.shows.count)
            var showNum : Int = 0
            for uneSerie in db.shows
            {
                showNum = showNum + 1
                if ( (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) && (uneSerie.status != "Ended") )
                {
                    for uneSaison in uneSerie.saisons
                    {
                        uneSerie.saisons[uneSaison.saison - 1].ends = betaSeries.getLastEpisodeDate(TVdbId : uneSerie.idTVdb, saison : uneSaison.saison, episode : uneSerie.saisons[uneSaison.saison - 1].nbEpisodes)
                    }
                    
                }
                DispatchQueue.main.async { self.progresData.setProgress(Float(showNum)/nbShows, animated: true) }
            }
            DispatchQueue.main.async {
                self.progresData.isHidden = true
                db.saveDB()
                db.updateCompteurs()
            }
        }
    }
    
    
    
    @IBAction func loadAll(_ sender: Any) {
        
        progresData.setProgress(0.0, animated: false)
        progresData.isHidden = false
        
        db.shows = trakt.getWatched()
        for uneSerie in db.shows { trakt.getSaisons(uneSerie: uneSerie) }
        db.shows = db.merge(db.shows, adds: trakt.getStopped())
        db.shows = db.merge(db.shows, adds: trakt.getWatchlist())
        
        DispatchQueue.global(qos: .utility).async {
            
            let nbShows : Float = Float(db.shows.count)
            var showNum : Int = 0

            for uneSerie in db.shows
            {
                showNum = showNum + 1
                DispatchQueue.main.async { self.progresData.setProgress(Float(showNum)/nbShows, animated: true) }
                db.downloadGlobalInfo(serie: uneSerie)
            }
            
            DispatchQueue.main.async {
                db.saveDB()
                db.updateCompteurs()
                self.progresData.isHidden = true
            }
        }
    }
    
    
    
    @IBAction func loadSaisonDetails(_ sender: Any) {
        progresData.setProgress(0.0, animated: false)
        progresData.isHidden = false
        
        DispatchQueue.global(qos: .utility).async {
            
            let nbShows : Float = Float(db.shows.count)
            var showNum : Int = 0
            for uneSerie in db.shows
            {
                showNum = showNum + 1
                
                if ((uneSerie.watchlist == false) && (uneSerie.unfollowed == false))
                {
                    if (uneSerie.saisons[uneSerie.saisons.count - 1].watched == false)
                    {
                        theTVdb.getSerieInfosLight(uneSerie: uneSerie)
                        if (uneSerie.idTVdb != "") { theTVdb.getEpisodesRatings(uneSerie) }
                        if (uneSerie.idTVdb != "") { betaSeries.getEpisodesRatings(uneSerie) }
                        if (uneSerie.idMoviedb != "") { theMoviedb.getEpisodesRatings(uneSerie) }
                        imdb.getEpisodesRatings(uneSerie)
                        if (uneSerie.idTrakt != "") { trakt.getEpisodesRatings(uneSerie) }
                    }
                }
                
                DispatchQueue.main.async { self.progresData.setProgress(Float(showNum)/nbShows, animated: true) }
            }
            DispatchQueue.main.async {
                self.progresData.isHidden = true
                db.saveDB()
                db.updateCompteurs()
            }
        }
    }
    
    
    
    @IBAction func LoadIMDB(_ sender: Any) {
        progresSource.setProgress(0.0, animated: false)
        progresSource.isHidden = false
        labelIMDB.isHidden = false

        DispatchQueue.global(qos: .utility).async {
            
            DispatchQueue.main.async { self.labelIMDB.text = "Téléchargement ..." }
            imdb.downloadData()
            
            DispatchQueue.main.async { self.labelIMDB.text = "Lecture ..." }
            imdb.loadDataFile()
            
            DispatchQueue.main.async { self.labelIMDB.text = "Distribution ..." }
            let nbShows : Float = Float(db.shows.count)
            var showNum : Int = 0
            var tmpSerie : Serie
            
            for uneSerie in db.shows
            {
                showNum = showNum + 1
                tmpSerie = imdb.getSerieGlobalInfos(idIMDB: uneSerie.idIMdb)
                uneSerie.ratersIMDB = tmpSerie.ratersIMDB
                uneSerie.ratingIMDB = tmpSerie.ratingIMDB

                DispatchQueue.main.async { self.progresData.setProgress(Float(showNum)/nbShows, animated: true) }
            }
            
            DispatchQueue.main.async {
                self.progresSource.isHidden = true
                self.labelIMDB.isHidden = true
                db.saveDB()
            }
        }
    }
}
