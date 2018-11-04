//
//  Database.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/05/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation

class Database : NSObject
{

    var shows : [Serie] = []
    var valSeriesFinies : Int = 0
    var valSeriesEnCours : Int = 0
    var valSaisonsOnTheAir : Int = 0
    var valSaisonsDiffusees : Int = 0
    var valSaisonsAnnoncees : Int = 0
    var valWatchList : Int = 0
    var valSeriesAbandonnees : Int = 0

    override init()
    {
    }
    
    func refreshSeasonDates()
    {
        for uneSerie in shows
        {
            for uneSaison in uneSerie.saisons
            {
                if ((uneSaison.starts == ZeroDate) && uneSaison.episodes != []) { uneSaison.starts = uneSaison.episodes[0].date }
                if ((uneSaison.ends == ZeroDate) && uneSaison.episodes != []) { uneSaison.ends = uneSaison.episodes[uneSaison.episodes.count-1].date }
            }
        }
    }
    
    func downloadGlobalInfo(serie : Serie)
    {
        let dataTVdb : Serie = theTVdb.getSerieGlobalInfos(idTVdb: serie.idTVdb)
        let dataMoviedb : Serie = theMoviedb.getSerieGlobalInfos(idMovieDB: serie.idMoviedb)
        let dataBetaSeries : Serie = betaSeries.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb)
        let dataTrakt : Serie = trakt.getSerieGlobalInfos(idTraktOrIMDB: serie.idIMdb)
        let dataIMDB : Serie = imdb.getSerieGlobalInfos(idIMDB: serie.idIMdb)
        
        serie.cleverMerge(TVdb: dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB)
        
        if (serie.unfollowed == false)
        {
            for numsaison in 0..<serie.saisons.count
            {
                //                if (saison.watched == false)
                //                {
                //serie.saisons[saison.saison - 1].ends = trakt.getLastEpisodeDate(traktID : serie.idTrakt, saison : saison.saison, episode : serie.saisons[saison.saison - 1].nbEpisodes)
                serie.saisons[numsaison].ends = betaSeries.getLastEpisodeDate(TVdbId : serie.idTVdb, saison : numsaison+1, episode : serie.saisons[numsaison].nbEpisodes)
                //                }
            }
        }
    }
    
    func saveDB ()
    {
        let pathToSVG = AppDir.appendingPathComponent("SerieA.db")
        if (NSKeyedArchiver.archiveRootObject(shows, toFile: pathToSVG.path) == false) {
            print ("Echec de la sauvegarde")
        }
    }
    
    func loadDB ()
    {
        let pathToSVG = AppDir.appendingPathComponent("SerieA.db")
        if (FileManager.default.fileExists(atPath: pathToSVG.path))
        {
            shows = (NSKeyedUnarchiver.unarchiveObject(withFile: pathToSVG.path) as? [Serie])!
            shows = shows.sorted(by:  { $0.serie < $1.serie })
            
            refreshSeasonDates()
        }
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
                if (dbSerie.idIMdb == uneSerie.idIMdb) { dbSerie.mergeStatuses(uneSerie) }
            }
        }
        return db
    }
    
    func updateCompteurs()
    {
        let today : Date = Date()
        valSeriesFinies = 0
        valSeriesEnCours = 0
        valSaisonsOnTheAir = 0
        valSaisonsDiffusees = 0
        valSaisonsAnnoncees = 0
        valWatchList = 0
        valSeriesAbandonnees = 0

        for uneSerie in db.shows
        {
            if (uneSerie.unfollowed) { valSeriesAbandonnees = valSeriesAbandonnees + 1 }
            if (uneSerie.watchlist) { valWatchList = valWatchList + 1 }
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
        
    }
    
    

}
