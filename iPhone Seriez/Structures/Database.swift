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

    override init()
    {
        trace(texte : "<< Database : init >>", logLevel : logFuncCalls, scope : scopeHelper)
        trace(texte : "<< Database : init >> Params : No Params", logLevel : logFuncParams, scope : scopeHelper)
        trace(texte : "<< Database : init >> Return : No Return", logLevel : logFuncReturn, scope : scopeHelper)
    }
    
    
    func downloadGlobalInfo(serie : Serie)
    {
        trace(texte : "<< Database : downloadGlobalInfo >>", logLevel : logFuncCalls, scope : scopeHelper)
        trace(texte : "<< Database : downloadGlobalInfo >> Params : serie = \(serie)", logLevel : logFuncParams, scope : scopeHelper)
        
        let dataTVdb : Serie = theTVdb.getSerieGlobalInfos(idTVdb: serie.idTVdb)
        let dataMoviedb : Serie = theMoviedb.getSerieGlobalInfos(idMovieDB: serie.idMoviedb)
        let dataBetaSeries : Serie = betaSeries.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb)
        let dataTrakt : Serie = trakt.getSerieGlobalInfos(idTraktOrIMDB: serie.idIMdb)
        let dataIMDB : Serie = imdb.getSerieGlobalInfos(idIMDB: serie.idIMdb)
        
        serie.cleverMerge(TVdb: dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB)
        
        if ( (serie.watchlist == false) && (serie.unfollowed == false) )
        {
            for saison in serie.saisons
            {
                if (saison.watched == false)
                {
                    serie.saisons[saison.saison - 1].ends = trakt.getLastEpisodeDate(traktID : serie.idTrakt, saison : saison.saison, episode : serie.saisons[saison.saison - 1].nbEpisodes)
                }
            }
        }
        trace(texte : "<< Database : downloadGlobalInfo >> Return : No Return", logLevel : logFuncReturn, scope : scopeHelper)
    }
    
//    func downloadSerieDetails(serie : Serie)
//    {
//        trace(texte : "<< Database : downloadSerieDetails >>", logLevel : logFuncCalls, scope : scopeHelper)
//        trace(texte : "<< Database : downloadSerieDetails >> Params : serie = \(serie)", logLevel : logFuncParams, scope : scopeHelper)
//        
//        theTVdb.getSerieInfosLight(uneSerie: serie)
//        if (serie.idTVdb != "") { theTVdb.getEpisodesRatings(serie) }
//        if (serie.idTrakt != "") { trakt.getEpisodesRatings(serie) }
//        if (serie.idTVdb != "") { betaSeries.getEpisodesRatings(serie) }
//        if (serie.idMoviedb != "") { theMoviedb.getEpisodesRatings(serie) }
//        imdb.getEpisodesRatings(serie)
//        
//        trace(texte : "<< Database : downloadSerieDetails >> Return : No Return", logLevel : logFuncReturn, scope : scopeHelper)
//    }
    
    func saveDB ()
    {
        trace(texte : "<< Database : saveDB >>", logLevel : logFuncCalls, scope : scopeHelper)
        trace(texte : "<< Database : saveDB >> Params : No Params", logLevel : logFuncParams, scope : scopeHelper)
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathToSVG = dir.appendingPathComponent("SerieA.db")
            let success : Bool = NSKeyedArchiver.archiveRootObject(shows, toFile: pathToSVG.path)
            trace(texte : "<< Database : loadDB >> DB saved witch success = \(success)", logLevel : logDebug, scope : scopeHelper)
        }
        
        trace(texte : "<< Database : saveDB >> Return : No Return", logLevel : logFuncReturn, scope : scopeHelper)
    }
    
    func loadDB ()
    {
        trace(texte : "<< Database : loadDB >>", logLevel : logFuncCalls, scope : scopeHelper)
        trace(texte : "<< Database : loadDB >> Params : No Params", logLevel : logFuncParams, scope : scopeHelper)
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathToSVG = dir.appendingPathComponent("SerieA.db")
            if (FileManager.default.fileExists(atPath: pathToSVG.path))
            {
                shows = (NSKeyedUnarchiver.unarchiveObject(withFile: pathToSVG.path) as? [Serie])!
                shows = shows.sorted(by:  { $0.serie < $1.serie })

                trace(texte : "<< Database : loadDB >> DB loaded", logLevel : logDebug, scope : scopeHelper)
            }
        }
        trace(texte : "<< Database : loadDB >> Return : No Return", logLevel : logFuncReturn, scope : scopeHelper)
    }
    
    func merge(_ db : [Serie], adds : [Serie]) -> [Serie]
    {
        trace(texte : "<< Database : merge >>", logLevel : logFuncCalls, scope : scopeHelper)
        trace(texte : "<< Database : merge >> Params : db = \(db), adds = \(adds)", logLevel : logFuncParams, scope : scopeHelper)
        
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
        
        trace(texte : "<< Database : mergeStatuses >> Return : newDB = \(newDB)", logLevel : logFuncReturn, scope : scopeHelper)
        return newDB
    }
    
    func mergeStatuses(_ db : [Serie], adds : [Serie]) -> [Serie]
    {
        trace(texte : "<< Database : mergeStatuses >>", logLevel : logFuncCalls, scope : scopeHelper)
        trace(texte : "<< Database : mergeStatuses >> Params : db = \(db), adds = \(adds)", logLevel : logFuncParams, scope : scopeHelper)
        
        for uneSerie in adds {
            for dbSerie in db {
                if (dbSerie.idTrakt == uneSerie.idTrakt) { dbSerie.mergeStatuses(uneSerie) }
            }
        }
        trace(texte : "<< Database : mergeStatuses >> Return : db = \(db)", logLevel : logFuncReturn, scope : scopeHelper)
        return db
    }
    
    
    

}
