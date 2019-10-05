//
//  Database.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/05/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SeriesCommon

class Database : NSObject
{

    var shows : [Serie] = []
    var index : Dictionary = [String:Int]()
    
    var valSeriesFinies : Int = 0
    var valSeriesEnCours : Int = 0
    var valSaisonsOnTheAir : Int = 0
    var valSaisonsDiffusees : Int = 0
    var valSaisonsAnnoncees : Int = 0
    var valWatchList : Int = 0
    var valSeriesAbandonnees : Int = 0

    override init() {
    }
    
    func quickRefresh() {
        // Mise à jour des épisodes vus
        for uneSerie in trakt.getWatched() {
            let indexDB : Int = index[uneSerie.serie] ?? -1
            
            if (indexDB == -1) {
                print("Ajout (watched) de \(uneSerie.serie)")
                // Nouvelle série on l'ajoute telle que
                index[uneSerie.serie] = shows.count
                downloadGlobalInfo(serie: uneSerie)
                shows.append(uneSerie)
            }
            else {
                for uneSaison in uneSerie.saisons {
                    if (uneSaison.saison-1 < shows[indexDB].saisons.count) {
                        shows[indexDB].saisons[uneSaison.saison-1].nbWatchedEps = uneSaison.nbWatchedEps
                    }
                }
            }
        }

        for uneSerie in shows {
            uneSerie.unfollowed = false
            uneSerie.watchlist = false
        }

        // Mise à jour des séries arrêtées
        for uneSerie in trakt.getStopped() {
            let indexDB : Int = index[uneSerie.serie] ?? -1
            
            if (indexDB == -1) {
                // Nouvelle série on l'ajoute telle que
                index[uneSerie.serie] = shows.count
                downloadGlobalInfo(serie: uneSerie)
                shows.append(uneSerie)
            }
            else {
                shows[indexDB].unfollowed = true
            }
        }
        
        // Mise à jour de la watchlist
        for uneSerie in trakt.getWatchlist() {
            let indexDB : Int = index[uneSerie.serie] ?? -1
            
            if (indexDB == -1) {
                // Nouvelle série on l'ajoute telle que
                index[uneSerie.serie] = shows.count
                downloadGlobalInfo(serie: uneSerie)
                shows.append(uneSerie)
            }
            else {
                shows[indexDB].watchlist = true
            }
        }
    }
    
    
    func downloadGlobalInfo(serie : Serie)
    {
        var timeStamp : Date = Date()
        let dataTVdb : Serie = theTVdb.getSerieGlobalInfos(idTVdb: serie.idTVdb)
        timerTheTVdb = timerTheTVdb + Date().timeIntervalSince(timeStamp)
        
        timeStamp = Date()
        let dataMoviedb : Serie = theMoviedb.getSerieGlobalInfos(idMovieDB: serie.idMoviedb)
        timerTheMovieDB = timerTheMovieDB + Date().timeIntervalSince(timeStamp)
        
        timeStamp = Date()
        let dataBetaSeries : Serie = betaSeries.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb)
        timerBetaSeries = timerBetaSeries + Date().timeIntervalSince(timeStamp)
        
        timeStamp = Date()
        let dataTrakt : Serie = trakt.getSerieGlobalInfos(idTraktOrIMDB: serie.idIMdb)
        timerTrakt = timerTrakt + Date().timeIntervalSince(timeStamp)
        
        timeStamp = Date()
        let dataIMDB : Serie = imdb.getSerieGlobalInfos(idIMDB: serie.idIMdb)
        timerIMdb = timerIMdb + Date().timeIntervalSince(timeStamp)
        
        timeStamp = Date()
        let dataTVmaze : Serie = tvMaze.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb)
        timerTVmaze = timerTVmaze + Date().timeIntervalSince(timeStamp)
        
        timeStamp = Date()
        let dataRotten : Serie = rottenTomatoes.getSerieGlobalInfos(serie : serie.serie)
        timerRottenTom = timerRottenTom + Date().timeIntervalSince(timeStamp)

        timeStamp = Date()
        let dataMetaCritic : Serie = metaCritic.getSerieGlobalInfos(serie: serie.serie)
        timerMetaCritic = timerMetaCritic + Date().timeIntervalSince(timeStamp)
        
        timeStamp = Date()
        let dataAlloCine : Serie = alloCine.getSerieGlobalInfos(serie: serie.serie)
        timerAlloCine = timerAlloCine + Date().timeIntervalSince(timeStamp)
        
        serie.cleverMerge(TVdb: dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB, RottenTomatoes: dataRotten, TVmaze: dataTVmaze, MetaCritic: dataMetaCritic, AlloCine: dataAlloCine)
    }
    
    
    func downloadDetailInfo(serie : Serie)
    {
        var timeStamp : Date = Date()

        timeStamp = Date()
        theTVdb.getSerieInfosLight(uneSerie: serie)
        timerTheTVdb = timerTheTVdb + Date().timeIntervalSince(timeStamp)

        if (serie.idTVdb != "") {
            timeStamp = Date()
            theTVdb.getEpisodesRatings(serie)
            timerTheTVdb = timerTheTVdb + Date().timeIntervalSince(timeStamp)
        }
        
        if (serie.idTVdb != "") {
            timeStamp = Date()
            //betaSeries.getEpisodesRatings(serie)
            betaSeries.getEpisodesRatingsBis(serie)
            timerBetaSeries = timerBetaSeries + Date().timeIntervalSince(timeStamp)
        }
        
        if (serie.idMoviedb != "") {
            timeStamp = Date()
            theMoviedb.getEpisodesRatings(serie)
            timerTheMovieDB = timerTheMovieDB + Date().timeIntervalSince(timeStamp)
        }
        
        timeStamp = Date()
        imdb.getEpisodesRatings(serie)
        timerIMdb = timerIMdb + Date().timeIntervalSince(timeStamp)
        
        if (serie.idTrakt != "") {
            timeStamp = Date()
            trakt.getEpisodesRatings(serie)
            timerTrakt = timerTrakt + Date().timeIntervalSince(timeStamp)
        }
    }
    
    
    func downloadDates(serie : Serie)
    {
        // TV Maze est buggué pour Mpney Heist : il compte une saison en trop
        if (serie.serie == "Death Note") { return }

        let tvMazeResults : (saisons : [Int], nbEps : [Int], debuts : [Date], fins : [Date]) = tvMaze.getSeasonsDates(idTVmaze: serie.idTVmaze)
        
        for i:Int in 0..<tvMazeResults.saisons.count {
            let seasonIdx : Int = tvMazeResults.saisons[i]-1
            
            if (seasonIdx < serie.saisons.count) {
                if (tvMazeResults.debuts[i] != ZeroDate) { serie.saisons[seasonIdx].starts = tvMazeResults.debuts[i] }
                if (tvMazeResults.fins[i] != ZeroDate) { serie.saisons[seasonIdx].ends = tvMazeResults.fins[i] }
                if (tvMazeResults.nbEps[i] != 0) { serie.saisons[seasonIdx].nbEpisodes = tvMazeResults.nbEps[i] }
            }
            else {
                // TV Maze est buggué pour Mpney Heist : il compte une saison en trop
                if (serie.serie == "Money Heist") { return }
                
                // Ajout de la saison et de ses informations
                let newSaison : Saison = Saison(serie: serie.serie, saison: seasonIdx+1)
                newSaison.starts = tvMazeResults.debuts[i]
                newSaison.ends = tvMazeResults.fins[i]
                newSaison.nbEpisodes = tvMazeResults.nbEps[i]

                serie.saisons.append(newSaison)
            }
        }
    }

    
    func finaliseDB() {
        
        db.shows = db.shows.sorted(by: { $0.serie < $1.serie })
        db.fillIndex()

        db.shows[db.index["Absolutely Fabulous"]!].saisons[3].nbEpisodes = db.shows[db.index["Absolutely Fabulous"]!].saisons[3].nbWatchedEps
        db.shows[db.index["Kaamelott"]!].saisons[3].nbEpisodes = db.shows[db.index["Kaamelott"]!].saisons[3].nbWatchedEps
        db.shows[db.index["Lost"]!].saisons[0].nbEpisodes = db.shows[db.index["Lost"]!].saisons[0].nbWatchedEps
        db.shows[db.index["Sense8"]!].saisons[1].nbEpisodes = db.shows[db.index["Sense8"]!].saisons[1].nbWatchedEps
        db.shows[db.index["Shameless"]!].saisons[7].nbEpisodes = db.shows[db.index["Shameless"]!].saisons[7].nbWatchedEps
        db.shows[db.index["Terra Nova"]!].saisons[0].nbEpisodes = db.shows[db.index["Terra Nova"]!].saisons[0].nbWatchedEps
        db.shows[db.index["WorkinGirls"]!].saisons[0].nbEpisodes = db.shows[db.index["WorkinGirls"]!].saisons[0].nbWatchedEps
        db.shows[db.index["WorkinGirls"]!].saisons[1].nbEpisodes = db.shows[db.index["WorkinGirls"]!].saisons[1].nbWatchedEps
        db.shows[db.index["WorkinGirls"]!].saisons[2].nbEpisodes = db.shows[db.index["WorkinGirls"]!].saisons[2].nbWatchedEps
        db.shows[db.index["WorkinGirls"]!].saisons[3].nbEpisodes = db.shows[db.index["WorkinGirls"]!].saisons[3].nbWatchedEps
        db.shows[db.index["Hero Corp"]!].saisons[2].nbEpisodes = db.shows[db.index["Hero Corp"]!].saisons[2].nbWatchedEps
        
        updateCompteurs()
    }
    
    
    func saveDB ()
    {
        if (db.shows.count > 0) {
            let pathToSVG = AppDir.appendingPathComponent("SerieA.db")
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: shows, requiringSecureCoding: false)
                try data.write(to: pathToSVG)
            } catch {
                print ("Echec de la sauvegarde de la DB")
            }
        }
    }
    
    func loadDB ()
    {
        let pathToSVG = AppDir.appendingPathComponent("SerieA.db")
        
        if let nsData = NSData(contentsOf: pathToSVG) {
            do {
                let data = Data(referencing:nsData)
                
                shows = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Serie])!
                shows = shows.sorted(by: { $0.serie < $1.serie })
                fillIndex()
            } catch {
                print("Echec de la lecture de la DB")
            }
        }
    }
    
    func fillIndex() {
        index = [String:Int]()
        
        for i:Int in 0..<shows.count {
            index[shows[i].serie] = i
        }
    }
    
    
    func shareWithWidget() {
        var sharedInfos : [Infos] = []
        
        for uneSerie in db.shows {
            if (uneSerie.watching()) {
                for uneSaison in uneSerie.saisons {
                    if(uneSaison.nbWatchedEps > 0) && (uneSaison.nbWatchedEps < uneSaison.nbEpisodes) {
                        let info : Infos = Infos(serie: uneSerie.serie,
                                                 channel: uneSerie.network,
                                                 saison: uneSaison.saison,
                                                 nbEps: uneSaison.nbEpisodes,
                                                 nbWatched: uneSaison.nbWatchedEps,
                                                 poster: uneSerie.poster,
                                                 rateGlobal: uneSerie.getGlobalRating(),
                                                 rateTrakt: uneSerie.getFairGlobalRatingTrakt(),
                                                 rateTVDB: uneSerie.getFairGlobalRatingTVdb(),
                                                 rateIMDB: uneSerie.getFairGlobalRatingIMdb(),
                                                 rateMovieDB: uneSerie.getFairGlobalRatingMoviedb(),
                                                 rateTVmaze: uneSerie.getFairGlobalRatingTVmaze(),
                                                 rateRottenTomatoes: uneSerie.getFairGlobalRatingRottenTomatoes(),
                                                 rateBetaSeries: uneSerie.getFairGlobalRatingBetaSeries())
                        
                        sharedInfos.append(info)
                    }
                }
            }
        }
        
        let sharedContainer = UserDefaults(suiteName: "group.Series")
        sharedContainer?.set(try? PropertyListEncoder().encode(sharedInfos), forKey: "Series")

        print ("Shared last infos with widget")
    }
    

    func merge(_ db : [Serie], adds : [Serie]) -> [Serie] {
        var merged : Bool = false
        var newDB : [Serie] = db
        
        for uneSerie in adds {
            merged = false
            
            // On cherche la serie dans les series de la DB
            for dbSerie in db {
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


    func updateCompteurs() {
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
            if (uneSerie.saisons.count > 0) {
                let lastSaison : Saison = uneSerie.saisons[uneSerie.saisons.count - 1]
                
                if ( (lastSaison.watched() == true) && (uneSerie.status == "Ended") ) { valSeriesFinies = valSeriesFinies + 1 }
                if ( ((lastSaison.watched() == false) || (uneSerie.status != "Ended")) && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) ) { valSeriesEnCours = valSeriesEnCours + 1 }
            }
            
            for uneSaison in uneSerie.saisons {
                if ( (uneSaison.starts != ZeroDate) && (uneSaison.starts.compare(today) == .orderedAscending) &&
                    ((uneSaison.ends.compare(today) == .orderedDescending) || (uneSaison.ends == ZeroDate)) &&
                    (uneSaison.watched() == false)  && (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) )
                { valSaisonsOnTheAir = valSaisonsOnTheAir + 1 }
                
                if ( (uneSaison.starts != ZeroDate) &&
                    (uneSaison.ends.compare(today) == .orderedAscending) && (uneSaison.ends != ZeroDate) &&
                    (uneSaison.watched() == false) && (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) )
                { valSaisonsDiffusees = valSaisonsDiffusees + 1 }
                
                if ( (uneSaison.starts.compare(today) == .orderedDescending) &&
                    (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) )
                { valSaisonsAnnoncees = valSaisonsAnnoncees + 1 }
            }
        }
    }
}
