//
//  Database.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/05/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import SeriesCommon

class Database : NSObject {
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
    
    
    func downloadGlobalInfo(serie : Serie) {
        let queue : OperationQueue = OperationQueue()
        
        var dataTVdb        : Serie = Serie(serie: "")
        var dataBetaSeries  : Serie = Serie(serie: "")
        var dataMoviedb     : Serie = Serie(serie: "")
        var dataTrakt       : Serie = Serie(serie: "")
        var dataTVmaze      : Serie = Serie(serie: "")
        var dataRotten      : Serie = Serie(serie: "")
        var dataMetaCritic  : Serie = Serie(serie: "")
        var dataAlloCine    : Serie = Serie(serie: "")
        var dataIMDB        : Serie = Serie(serie: "")

        queue.addOperation(BlockOperation(block: { dataTVdb = theTVdb.getSerieGlobalInfos(idTVdb: serie.idTVdb) } ) )
        queue.addOperation(BlockOperation(block: { dataBetaSeries = betaSeries.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb) } ) )
        queue.addOperation(BlockOperation(block: { dataMoviedb = theMoviedb.getSerieGlobalInfos(idMovieDB: serie.idMoviedb) } ) )
        queue.addOperation(BlockOperation(block: { dataIMDB = imdb.getSerieGlobalInfos(idIMDB: serie.idIMdb) } ) )
        queue.addOperation(BlockOperation(block: { dataTrakt = trakt.getSerieGlobalInfos(idTraktOrIMDB: serie.idIMdb) } ) )
        queue.addOperation(BlockOperation(block: { dataTVmaze = tvMaze.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb) } ) )
        queue.addOperation(BlockOperation(block: { dataRotten = rottenTomatoes.getSerieGlobalInfos(serie : serie.serie) } ) )
        queue.addOperation(BlockOperation(block: { dataMetaCritic = metaCritic.getSerieGlobalInfos(serie: serie.serie) } ) )
        queue.addOperation(BlockOperation(block: { dataAlloCine = alloCine.getSerieGlobalInfos(serie: serie.serie) } ) )

        queue.waitUntilAllOperationsAreFinished()
        
        serie.cleverMerge(TVdb: dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB, RottenTomatoes: dataRotten, TVmaze: dataTVmaze, MetaCritic: dataMetaCritic, AlloCine: dataAlloCine)
    }
    
    
    func downloadDetailInfo(serie : Serie) {
        theTVdb.getEpisodesDetailsAndRating(uneSerie: serie)
        
        for uneSaison in serie.saisons {
            for unEpisode in uneSaison.episodes {
                if ((unEpisode.idIMdb) == "" && (unEpisode.date.compare(Date()) == .orderedAscending)) {
                    unEpisode.idIMdb = imdb.getEpisodeID(serieID: serie.idIMdb, saison: uneSaison.saison, episode: unEpisode.episode)
                    if (unEpisode.idIMdb == "") { print("No IMDB id for \(serie.serie) saison: \(uneSaison.saison) episode: \(unEpisode.episode)") }
                }
            }
        }

        let queue : OperationQueue = OperationQueue()
        
        queue.addOperation(BlockOperation(block: { if (serie.idTVdb != "") { betaSeries.getEpisodesRatingsBis(serie) } } ) )
        queue.addOperation(BlockOperation(block: { imdb.getEpisodesRatings(serie) } ) )
        queue.addOperation(BlockOperation(block: { if (serie.idTrakt != "") { trakt.getEpisodesRatings(serie) } } ) )
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    func downloadDates(serie : Serie) {
        // TV Maze est buggué pour Death Note
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
                // TV Maze est buggué pour Money Heist : il compte une saison en trop
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
    
    
    func saveDB () {
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
    
    func loadDB () {
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
        var sharedInfos : [InfosEnCours] = []
        
        for uneSerie in db.shows {
            if (uneSerie.watching()) {
                for uneSaison in uneSerie.saisons {
                    if(uneSaison.nbWatchedEps > 0) && (uneSaison.nbWatchedEps < uneSaison.nbEpisodes) {
                        let info : InfosEnCours = InfosEnCours(serie: uneSerie.serie,
                                                               channel: uneSerie.network,
                                                               saison: uneSaison.saison,
                                                               nbEps: uneSaison.nbEpisodes,
                                                               nbWatched: uneSaison.nbWatchedEps,
                                                               poster: uneSerie.poster,
                                                               rateGlobal: uneSerie.getGlobalRating(),
                                                               rateTrakt: uneSerie.getFairGlobalRatingTrakt(),
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
    
    
    func shareRefreshWithWidget(newInfo : InfosRefresh) {
        var sharedInfos : [InfosRefresh] = []
        
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"Refresh") as? Data {
            sharedInfos = try! PropertyListDecoder().decode(Array<InfosRefresh>.self, from: data)
        }

        if (sharedInfos.count == 0) {
            sharedInfos.append(newInfo)
        }
        else {
            let lastInfo : InfosRefresh = sharedInfos[sharedInfos.count - 1]
            
            if (lastInfo.timestamp == newInfo.timestamp) {
                sharedInfos[sharedInfos.count - 1] = newInfo
            }
            else {
                sharedInfos.append(newInfo)
            }
        }
        
        if (sharedInfos.count > 10) {
            sharedInfos.removeFirst()
        }

        let sharedContainer = UserDefaults(suiteName: "group.Series")
        sharedContainer?.set(try? PropertyListEncoder().encode(sharedInfos), forKey: "Refresh")
        
        print ("Shared last refresh with widget")
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
        
        for uneSerie in db.shows {
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
    
    func computeFairRates() {
        // Load Data
        for uneSerie in shows {
            print("Loading \(uneSerie.serie)")
            downloadGlobalInfo(serie: uneSerie)
            downloadDates(serie: uneSerie)
            downloadDetailInfo(serie: uneSerie)
        }

        saveDB()
        
        // Calcule moyenne et écart type pour les ssaisons
        var moyIMDB : Double = 0.0
        var moyTrakt : Double = 0.0
        var moyMovieDB : Double = 0.0
        var moyBetaSeries : Double = 0.0
        var moyTVMaze : Double = 0.0
        var moyRottenTom : Double = 0.0
        var moyMetaCritic : Double = 0.0
        var moyAlloCine : Double = 0.0

        var nbIMDB : Int = 0
        var nbTrakt : Int = 0
        var nbMovieDB : Int = 0
        var nbBetaSeries : Int = 0
        var nbTVMaze : Int = 0
        var nbRottenTom : Int = 0
        var nbMetaCritic : Int = 0
        var nbAlloCine : Int = 0

        var ecartIMDB : Double = 0.0
        var ecartTrakt : Double = 0.0
        var ecartMovieDB : Double = 0.0
        var ecartBetaSeries : Double = 0.0
        var ecartTVMaze : Double = 0.0
        var ecartRottenTom : Double = 0.0
        var ecartMetaCritic : Double = 0.0
        var ecartAlloCine : Double = 0.0


        for uneSerie in shows {
            if (uneSerie.ratingIMDB != 0) {  moyIMDB = moyIMDB + Double(uneSerie.ratingIMDB); nbIMDB = nbIMDB + 1; ecartIMDB = ecartIMDB + Double(uneSerie.ratingIMDB * uneSerie.ratingIMDB) }
            if (uneSerie.ratingTrakt != 0) {  moyTrakt = moyTrakt + Double(uneSerie.ratingTrakt); nbTrakt = nbTrakt + 1; ecartTrakt = ecartTrakt + Double(uneSerie.ratingTrakt * uneSerie.ratingTrakt) }
            if (uneSerie.ratingMovieDB != 0) {  moyMovieDB = moyMovieDB + Double(uneSerie.ratingMovieDB); nbMovieDB = nbMovieDB + 1; ecartMovieDB = ecartMovieDB + Double(uneSerie.ratingMovieDB * uneSerie.ratingMovieDB) }
            if (uneSerie.ratingBetaSeries != 0) {  moyBetaSeries = moyBetaSeries + Double(uneSerie.ratingBetaSeries); nbBetaSeries = nbBetaSeries + 1; ecartBetaSeries = ecartBetaSeries + Double(uneSerie.ratingBetaSeries * uneSerie.ratingBetaSeries) }
            if (uneSerie.ratingTVmaze != 0) {  moyTVMaze = moyTVMaze + Double(uneSerie.ratingTVmaze); nbTVMaze = nbTVMaze + 1; ecartTVMaze = ecartTVMaze + Double(uneSerie.ratingTVmaze * uneSerie.ratingTVmaze) }
            if (uneSerie.ratingRottenTomatoes != 0) {  moyRottenTom = moyRottenTom + Double(uneSerie.ratingRottenTomatoes); nbRottenTom = nbRottenTom + 1; ecartRottenTom = ecartRottenTom + Double(uneSerie.ratingRottenTomatoes * uneSerie.ratingRottenTomatoes) }
            if (uneSerie.ratingMetaCritic != 0) {  moyMetaCritic = moyMetaCritic + Double(uneSerie.ratingMetaCritic); nbMetaCritic = nbMetaCritic + 1; ecartMetaCritic = ecartMetaCritic + Double(uneSerie.ratingMetaCritic * uneSerie.ratingMetaCritic) }
            if (uneSerie.ratingAlloCine != 0) {  moyAlloCine = moyAlloCine + Double(uneSerie.ratingAlloCine); nbAlloCine = nbAlloCine + 1; ecartAlloCine = ecartAlloCine + Double(uneSerie.ratingAlloCine * uneSerie.ratingAlloCine) }
            if (uneSerie.ratingIMDB != 0) {  moyIMDB = moyIMDB + Double(uneSerie.ratingIMDB); nbIMDB = nbIMDB + 1; ecartIMDB = ecartIMDB + Double(uneSerie.ratingIMDB * uneSerie.ratingIMDB) }
        }
        moyIMDB = moyIMDB / Double(nbIMDB)
        moyTrakt = moyTrakt / Double(nbTrakt)
        moyMovieDB = moyMovieDB / Double(nbMovieDB)
        moyBetaSeries = moyBetaSeries / Double(nbBetaSeries)
        moyTVMaze = moyTVMaze / Double(nbTVMaze)
        moyRottenTom = moyRottenTom / Double(nbRottenTom)
        moyMetaCritic = moyMetaCritic / Double(nbMetaCritic)
        moyAlloCine = moyAlloCine / Double(nbAlloCine)

        ecartIMDB = sqrt( ( ecartIMDB / Double(nbIMDB) ) - (moyIMDB * moyIMDB) )
        ecartTrakt = sqrt( ( ecartTrakt / Double(nbTrakt) ) - (moyTrakt * moyTrakt) )
        ecartMovieDB = sqrt( ( ecartMovieDB / Double(nbMovieDB) ) - (moyMovieDB * moyMovieDB) )
        ecartBetaSeries = sqrt( ( ecartBetaSeries / Double(nbBetaSeries) ) - (moyBetaSeries * moyBetaSeries) )
        ecartTVMaze = sqrt( ( ecartTVMaze / Double(nbTVMaze) ) - (moyTVMaze * moyTVMaze) )
        ecartRottenTom = sqrt( ( ecartRottenTom / Double(nbRottenTom) ) - (moyRottenTom * moyRottenTom) )
        ecartMetaCritic = sqrt( ( ecartMetaCritic / Double(nbMetaCritic) ) - (moyMetaCritic * moyMetaCritic) )
        ecartAlloCine = sqrt( ( ecartAlloCine / Double(nbAlloCine) ) - (moyAlloCine * moyAlloCine) )

        print("Coefficients pour les séries ")
        print("-----------------------------")

        print("IMDB           Moyenne = \(moyIMDB) et Ecart = \(ecartIMDB)")
        print("Trakt          Moyenne = \(moyTrakt) et Ecart = \(ecartTrakt)")
        print("MovieDB        Moyenne = \(moyMovieDB) et Ecart = \(ecartMovieDB)")
        print("BetaSeries     Moyenne = \(moyBetaSeries) et Ecart = \(ecartBetaSeries)")
        print("TVMaze         Moyenne = \(moyTVMaze) et Ecart = \(ecartTVMaze)")
        print("RottenTom      Moyenne = \(moyRottenTom) et Ecart = \(ecartRottenTom)")
        print("MetaCritic     Moyenne = \(moyMetaCritic) et Ecart = \(ecartMetaCritic)")
        print("AlloCine       Moyenne = \(moyAlloCine) et Ecart = \(ecartAlloCine)")
        print()
        print()
        
        // Calcule moyenne et écart type pour les épisodes
        var moyIMDBEps : Double = 0.0
        var moyTraktEps : Double = 0.0
        var moyBetaSeriesEps : Double = 0.0

        var nbIMDBEps : Int = 0
        var nbTraktEps : Int = 0
        var nbBetaSeriesEps : Int = 0

        var ecartIMDBEps : Double = 0.0
        var ecartTraktEps : Double = 0.0
        var ecartBetaSeriesEps : Double = 0.0

        // Moyennes simples
//        for uneSerie in shows {
//            for uneSaison in uneSerie.saisons {
//                for unEpisode in uneSaison.episodes {
//                    if (unEpisode.ratingIMdb != 0) {  moyIMDBEps = moyIMDBEps + Double(unEpisode.ratingIMdb); nbIMDBEps = nbIMDBEps + 1; ecartIMDBEps = ecartIMDBEps + Double(unEpisode.ratingIMdb * unEpisode.ratingIMdb) }
//                    if (unEpisode.ratingTrakt != 0) {  moyTraktEps = moyTraktEps + Double(unEpisode.ratingTrakt); nbTraktEps = nbTraktEps + 1; ecartTraktEps = ecartTraktEps + Double(unEpisode.ratingTrakt * unEpisode.ratingTrakt) }
//                    if (unEpisode.ratingBetaSeries != 0) {  moyBetaSeriesEps = moyBetaSeriesEps + Double(unEpisode.ratingBetaSeries); nbBetaSeriesEps = nbBetaSeriesEps + 1; ecartBetaSeriesEps = ecartBetaSeriesEps + Double(unEpisode.ratingBetaSeries * unEpisode.ratingBetaSeries) }
//                }
//
//            }
//        }

        // Moyennes pondérées par nombre de votants
        for uneSerie in shows {
            for uneSaison in uneSerie.saisons {
                for unEpisode in uneSaison.episodes {
                    if (unEpisode.ratingIMdb != 0) {
                        moyIMDBEps = moyIMDBEps + Double(unEpisode.ratingIMdb * unEpisode.ratersIMdb)
                        nbIMDBEps = nbIMDBEps + unEpisode.ratersIMdb
                        ecartIMDBEps = ecartIMDBEps + Double(unEpisode.ratingIMdb * unEpisode.ratingIMdb * unEpisode.ratersIMdb)
                    }
                    
                    if (unEpisode.ratingTrakt != 0) {
                        moyTraktEps = moyTraktEps + Double(unEpisode.ratingTrakt * unEpisode.ratersTrakt)
                        nbTraktEps = nbTraktEps + unEpisode.ratersTrakt
                        ecartTraktEps = ecartTraktEps + Double(unEpisode.ratingTrakt * unEpisode.ratingTrakt * unEpisode.ratersTrakt)
                    }
                    
                    if (unEpisode.ratingBetaSeries != 0) {
                        moyBetaSeriesEps = moyBetaSeriesEps + Double(unEpisode.ratingBetaSeries * unEpisode.ratersBetaSeries)
                        nbBetaSeriesEps = nbBetaSeriesEps + unEpisode.ratersBetaSeries
                        ecartBetaSeriesEps = ecartBetaSeriesEps + Double(unEpisode.ratingBetaSeries * unEpisode.ratingBetaSeries * unEpisode.ratersBetaSeries)
                    }
                }
            }
        }
        
        moyIMDBEps = moyIMDBEps / Double(nbIMDBEps)
        moyTraktEps = moyTraktEps / Double(nbTraktEps)
        moyBetaSeriesEps = moyBetaSeriesEps / Double(nbBetaSeriesEps)

        ecartIMDBEps = sqrt( ( ecartIMDBEps / Double(nbIMDBEps) ) - (moyIMDBEps * moyIMDBEps) )
        ecartTraktEps = sqrt( ( ecartTraktEps / Double(nbTraktEps) ) - (moyTraktEps * moyTraktEps) )
        ecartBetaSeriesEps = sqrt( ( ecartBetaSeriesEps / Double(nbBetaSeriesEps) ) - (moyBetaSeriesEps * moyBetaSeriesEps) )

        print("Coefficients pour les épisodes ")
        print("-------------------------------")

        print("IMDB           Moyenne = \(moyIMDBEps) et Ecart = \(ecartIMDBEps)")
        print("Trakt          Moyenne = \(moyTraktEps) et Ecart = \(ecartTraktEps)")
        print("BetaSeries     Moyenne = \(moyBetaSeriesEps) et Ecart = \(ecartBetaSeriesEps)")
    }

}
