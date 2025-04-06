//
//  Database.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/05/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import Mon_activitéExtension
import WidgetKit

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
        
        // Mise à jour des séries arrêtées
        for uneSerie in trakt.getStopped() {
            let indexDB : Int = index[uneSerie.serie] ?? -1
            
            if (indexDB == -1) {
                // Nouvelle série on l'ajoute telle que
                index[uneSerie.serie] = shows.count
                downloadGlobalInfo(serie: uneSerie)
                uneSerie.unfollowed = true
                shows.append(uneSerie)
            }
            else {
                if (shows[indexDB].unfollowed == false)  {
                    shows[indexDB].unfollowed = true
                    journal.addInfo(serie: uneSerie.serie, source: srcTrakt, methode: funcQuickRefresh, texte: "Abandon de la série", type: newsListes)
                }
            }
        }
        
        // Mise à jour de la watchlist
        for uneSerie in trakt.getWatchlist() {
            let indexDB : Int = index[uneSerie.serie] ?? -1
            
            if (indexDB == -1) {
                // Nouvelle série on l'ajoute telle que
                index[uneSerie.serie] = shows.count
                downloadGlobalInfo(serie: uneSerie)
                uneSerie.watchlist = true
                shows.append(uneSerie)
                journal.addInfo(serie: uneSerie.serie, source: srcTrakt, methode: funcQuickRefresh, texte: "Série ajoutée en watchlist", type: newsListes)
            }
            else {
                if (shows[indexDB].watchlist == false) {
                    shows[indexDB].watchlist = true
                    journal.addInfo(serie: uneSerie.serie, source: srcTrakt, methode: funcQuickRefresh, texte: "Série ajoutée en watchlist", type: newsListes)
                }
            }
        }
        
        fillIndex()
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
        var dataIMDB        : Serie = Serie(serie: "")
        var dataAlloCine    : Serie = Serie(serie: "")
        var dataSensCritique: Serie = Serie(serie: "")
        var dataSIMKL       : Serie = Serie(serie: "")

        queue.addOperation(BlockOperation(block: {
            if (serie.idIMdb != "") { dataTrakt = trakt.getSerieGlobalInfos(idTraktOrIMDB: serie.idIMdb) }
            else { dataTrakt = trakt.getSerieGlobalInfos(idTraktOrIMDB: serie.idTrakt) }
        } ) )

        queue.addOperation(BlockOperation(block: { dataTVdb = theTVdb.getSerieGlobalInfos(idTVdb: serie.idTVdb) } ) )
        queue.addOperation(BlockOperation(block: { dataBetaSeries = betaSeries.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb, idBetaSeries: serie.idBetaSeries) } ) )
        queue.addOperation(BlockOperation(block: { dataMoviedb = theMoviedb.getSerieGlobalInfos(idMovieDB: serie.idMoviedb) } ) )
        queue.addOperation(BlockOperation(block: { dataIMDB = imdb.getSerieGlobalInfos(idIMDB: serie.idIMdb) } ) )
        queue.addOperation(BlockOperation(block: { dataTVmaze = tvMaze.getSerieGlobalInfos(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb) } ) )
        queue.addOperation(BlockOperation(block: { dataRotten = rottenTomatoes.getSerieGlobalInfos(serie : serie.serie) } ) )
        queue.addOperation(BlockOperation(block: { dataMetaCritic = metaCritic.getSerieGlobalInfos(serie: serie.serie) } ) )
        queue.addOperation(BlockOperation(block: { dataAlloCine = alloCine.getSerieGlobalInfos(serie: serie.serie) } ) )
        queue.addOperation(BlockOperation(block: { dataSensCritique = sensCritique.getSerieGlobalInfos(serie: serie.serie) } ) )
        queue.addOperation(BlockOperation(block: { dataSIMKL = simkl.getSerieGlobalInfos(idSIMKLOrIMDB: serie.idIMdb) } ) )

        queue.waitUntilAllOperationsAreFinished()
        
        serie.cleverMerge(TVdb : dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB, RottenTomatoes: dataRotten, TVmaze: dataTVmaze, MetaCritic: dataMetaCritic, AlloCine: dataAlloCine, SensCritique: dataSensCritique, SIMKL: dataSIMKL)
    }
    
    
    func downloadDetailInfo(serie : Serie) {
        trakt.getEpisodes(uneSerie: serie)
        
//        var needIMDBids : Bool = false
        
        for uneSaison in serie.saisons {
//            for unEpisode in uneSaison.episodes {
//                if ((unEpisode.idIMdb) == "" && (unEpisode.date.compare(Date()) == .orderedAscending) && (unEpisode.date != ZeroDate) ) {
//                    needIMDBids = true
//                }
//            }
            
            if (uneSaison.ends == ZeroDate) {
                if (uneSaison.episodes.count > 0) {
                    uneSaison.ends = uneSaison.episodes[uneSaison.episodes.count - 1].date
                }
            }
        }

//        if (needIMDBids) { imdb.getSerieIDs(uneSerie: serie) }
        
        let queue : OperationQueue = OperationQueue()
        
        queue.addOperation(BlockOperation(block: { if (serie.idTVdb != "") { betaSeries.getEpisodesRatings(serie) } } ) )
        queue.addOperation(BlockOperation(block: { imdb.getEpisodesRatings(serie) } ) )
        queue.addOperation(BlockOperation(block: { if (serie.idMoviedb != "") { theMoviedb.getEpisodesRatings(serie) } } ) )
        queue.addOperation(BlockOperation(block: { tvMaze.getEpisodesRatings(serie) } ))
        queue.addOperation(BlockOperation(block: { sensCritique.getEpisodesRatings(serie: serie) } ))
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    func downloadDates(serie : Serie) {
        // TV Maze est buggué pour Death Note & Lupin
//        if (serie.serie == "Death Note") { return }
//        if (serie.serie == "Lupin") { return }
//        if (serie.serie == "Money Heist") { return }

        let tvMazeResults : (saisons : [Int], debuts : [Date], fins : [Date]) = tvMaze.getSeasonsDates(idTVmaze: serie.idTVmaze)
        
        for i:Int in 0..<tvMazeResults.saisons.count {
            let seasonIdx : Int = tvMazeResults.saisons[i]-1

            if (seasonIdx < serie.saisons.count) {
                let prevSaisonStart : Date = serie.saisons[seasonIdx].starts
                let prevSaisonEnd : Date = serie.saisons[seasonIdx].ends

                if (tvMazeResults.debuts[i] != ZeroDate) { serie.saisons[seasonIdx].starts = tvMazeResults.debuts[i] }
                if (tvMazeResults.fins[i] != ZeroDate) { serie.saisons[seasonIdx].ends = tvMazeResults.fins[i] }

                if (serie.saisons[seasonIdx].watched() == false) {
                    if ( (prevSaisonStart != tvMazeResults.debuts[i]) &&
                         (tvMazeResults.debuts[i] != ZeroDate) &&
                         (abs(tvMazeResults.debuts[i].timeIntervalSince(prevSaisonStart)/3600) > 36) ) {
                        print("<<<<< NEWS >>>>> Nouveau début de saison (\(seasonIdx+1)) pour \(serie.serie) : \(dateFormSource.string(from: tvMazeResults.debuts[i])) (was \(dateFormSource.string(from: prevSaisonStart)))")
                    }
                    
                    if ( (prevSaisonEnd != tvMazeResults.fins[i]) &&
                         (tvMazeResults.debuts[i] != ZeroDate) &&
                         (abs(tvMazeResults.fins[i].timeIntervalSince(prevSaisonEnd)/3600) > 36) ) {
                        print("<<<<< NEWS >>>>> Nouvelle fin de saison (\(seasonIdx+1)) pour \(serie.serie) : \(dateFormSource.string(from: tvMazeResults.fins[i])) (was \(dateFormSource.string(from: prevSaisonEnd)))")
                    }
                }
            }
            else {
                if (tvMazeResults.debuts[i] != ZeroDate) {
                    // Ajout de la saison et de ses informations
                    let newSaison : Saison = Saison(serie: serie.serie, saison: seasonIdx+1)
                    newSaison.starts = tvMazeResults.debuts[i]
                    newSaison.ends = tvMazeResults.fins[i]
                    
                    serie.saisons.append(newSaison)
                    
                    print("<<<<< NEWS >>>>> Nouvelle saison (\(seasonIdx+1)) pour \(serie.serie) : de \(dateFormSource.string(from: newSaison.starts)) à \(dateFormSource.string(from: newSaison.ends))")
                }
            }
        }
    }
    
    
    func finaliseDB() {
        db.shows = db.shows.sorted(by: { $0.serie < $1.serie })
        db.fillIndex()
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
//                shows = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: Serie, from: data)!
                //unarchivedObject(ofClass: [Serie], from: data) as! [Serie]
                shows = shows.sorted(by: { $0.serie < $1.serie })
                fillIndex()
            } catch {
                print("Echec de la lecture de la DB")
            }
        }
    }
    
    func saveAdvisors() {
        var advisorsDico : Dictionary = [String:String]()
        for uneSerie in db.shows where uneSerie.nomConseil != "" { advisorsDico[uneSerie.serie] = uneSerie.nomConseil }
        
        if (advisorsDico.count > 0) {
            let pathToSVG = AppDir.appendingPathComponent("Advisors.db")
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: advisorsDico, requiringSecureCoding: false)
                try data.write(to: pathToSVG)
            } catch {
                print ("Echec de la sauvegarde des advisors")
            }
        }
    }
    
    
    func loadAdvisors() {
        let pathToSVG = AppDir.appendingPathComponent("Advisors.db")
        var advisorsDico : Dictionary = [String:String]()

        if let nsData = NSData(contentsOf: pathToSVG) {
            do {
                let data = Data(referencing:nsData)
                advisorsDico = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary)!
            } catch {
                print("Echec de la lecture de la DB")
            }
        }
        
        // Mise à jour de la DB
        for unAdvisor in advisorsDico {
            let indexDB : Int = index[unAdvisor.key] ?? -1
            if (indexDB == -1)  { print("ADVISOR : \(unAdvisor.key) non trouvé dans la databse") }
            else                { shows[indexDB].nomConseil = unAdvisor.value }
        }
    }

    
    func checkForUpdates(newSerie: Serie, oldSerie : Serie, methode: Int) {
        if (newSerie.status != oldSerie.status) {
            journal.addInfo(serie: newSerie.serie, source: srcTrakt, methode: methode, texte: "Changement de status de la série : \(newSerie.status) -> \(oldSerie.status)", type: newsArrets)
        }
        
        let news : [String] = newSerie.findUpdates(versus: oldSerie)
        for uneNews in news {
            journal.addInfo(serie: newSerie.serie, source: srcTrakt, methode: methode, texte: uneNews, type: newsDates)
        }
    }
    
    
    func fillIndex() {
        index = [String:Int]()
        
        for i:Int in 0..<shows.count {
            index[shows[i].serie] = i
        }
    }
    
    
    func shareWithWidget() {
        var monActivite : [Data4MonActivite] = []

        for uneSerie in db.shows {
            if (uneSerie.watching()) {
                for uneSaison in uneSerie.saisons {
                    if(uneSaison.nbWatchedEps > 0) && (uneSaison.nbWatchedEps < uneSaison.nbEpisodes) {
                        let infoActivite : Data4MonActivite = Data4MonActivite(serie: uneSerie.serie,
                                                                   channel: uneSerie.diffuseur,
                                                                   saison: uneSaison.saison,
                                                                   nbEps: uneSaison.nbEpisodes,
                                                                   nbWatched: uneSaison.nbWatchedEps,
                                                                   poster: uneSerie.poster)
                        
                        monActivite.append(infoActivite)
                    }
                }
            }
        }
        
        let sharedContainer = UserDefaults(suiteName: "group.Series")
        sharedContainer?.set(try? PropertyListEncoder().encode(monActivite), forKey: "MonActivite")
        
        WidgetCenter.shared.reloadTimelines(ofKind: "Mon_activite_")
    }
    
    
    func loadDataUpdates() -> DataUpdatesEntry {
        var dataUpdates : DataUpdatesEntry = DataUpdatesEntry(date: .now, TVMaze_Dates: ZeroDate, Trakt_Viewed: ZeroDate, IMDB_Rates: ZeroDate, IMDB_Episodes: ZeroDate, UneSerieReload: ZeroDate, UneSerieWatchedEps: ZeroDate)
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"DataUpdates") as? Data {
            dataUpdates = try! PropertyListDecoder().decode(DataUpdatesEntry.self, from: data)
        }

        return dataUpdates
    }
    
    
    func saveDataUpdates(dataUpdates : DataUpdatesEntry) {
        let sharedContainer = UserDefaults(suiteName: "group.Series")
        sharedContainer?.set(try? PropertyListEncoder().encode(dataUpdates), forKey: "DataUpdates")
        WidgetCenter.shared.reloadTimelines(ofKind: "DataUpdates")
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
                
                if ( (lastSaison.watched() == true) && ( (uneSerie.status == "ended") || (uneSerie.status == "Ended") || (uneSerie.status == "canceled") ) ) { valSeriesFinies = valSeriesFinies + 1 }
                if ( ((lastSaison.watched() == false) || ( (uneSerie.status != "ended") && (uneSerie.status != "Ended") && (uneSerie.status != "canceled") ) ) && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) ) { valSeriesEnCours = valSeriesEnCours + 1 }
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
    
    
    func computeStatsPerRate() -> ([Int], [Int], [Int], [Int]) {
        var statsAbandonnees : [Int] = [Int](0...9)
        var statsWatchList : [Int] = [Int](0...9)
        var statsFinies : [Int] = [Int](0...9)
        var statsEnCours : [Int] = [Int](0...9)

        for i in 0 ... 9 {
            statsAbandonnees[i] = 0
            statsWatchList[i] = 0
            statsFinies[i] = 0
            statsEnCours[i] = 0
        }
        
        for uneSerie in db.shows {
            var rating : Int = uneSerie.myRating
            
            if (uneSerie.myRating < 0) { rating = 0 }
            
            if (uneSerie.unfollowed) { statsAbandonnees[rating] = statsAbandonnees[rating] + 1 }
            if (uneSerie.watchlist) { statsWatchList[rating] = statsWatchList[rating] + 1 }
            if (uneSerie.saisons.count > 0) {
                let lastSaison : Saison = uneSerie.saisons[uneSerie.saisons.count - 1]
                
                if ( (lastSaison.watched() == true) && (uneSerie.status == "Ended") ) { statsFinies[rating] = statsFinies[rating] + 1 }
                if ( ((lastSaison.watched() == false) || (uneSerie.status != "Ended")) && (uneSerie.unfollowed == false) && (uneSerie.watchlist == false) ) { statsEnCours[rating] = statsEnCours[rating] + 1 }
            }
        }
        
        return (statsAbandonnees, statsWatchList, statsFinies, statsEnCours)
    }
    
    func checkSeasonDates() {
        var jump : Bool = false
        
        for uneSerie in shows {
            for uneSaison in uneSerie.saisons {
                if (uneSaison.episodes.count > 0) {
                    
                    let delta : TimeInterval = uneSaison.episodes[uneSaison.episodes.count-1].date.timeIntervalSince(uneSaison.ends)
                    
                    print("  \(delta) sec ==> \(uneSerie.serie) saison \(uneSaison.saison) finit le \(uneSaison.ends), et le dernier épisode est diffusé le \(uneSaison.episodes[uneSaison.episodes.count-1].date)")
                    jump = true
                }
            }
            if (jump) {
                print("")
                jump = false
            }
        }
    }
    
    func computeFairRates() {
        // Load Data
//        for uneSerie in shows {
//            print("Loading \(uneSerie.serie)")
//            downloadGlobalInfo(serie: uneSerie)
//            //downloadDates(serie: uneSerie)
//            //downloadDetailInfo(serie: uneSerie)
//            
//            sleep(1)
//        }

        //saveDB()
        
        // Calcule moyenne et écart type pour les ssaisons
        var moyIMDB : Double = 0.0
        var moyTrakt : Double = 0.0
        var moyMovieDB : Double = 0.0
        var moyBetaSeries : Double = 0.0
        var moyTVMaze : Double = 0.0
        var moyRottenTom : Double = 0.0
        var moyMetaCritic : Double = 0.0
        var moyAlloCine : Double = 0.0
        var moySensCritique : Double = 0.0
        var moySIMKL : Double = 0.0

        var nbIMDB : Int = 0
        var nbTrakt : Int = 0
        var nbMovieDB : Int = 0
        var nbBetaSeries : Int = 0
        var nbTVMaze : Int = 0
        var nbRottenTom : Int = 0
        var nbMetaCritic : Int = 0
        var nbAlloCine : Int = 0
        var nbSensCritique : Int = 0
        var nbSIMKL : Int = 0

        var ecartIMDB : Double = 0.0
        var ecartTrakt : Double = 0.0
        var ecartMovieDB : Double = 0.0
        var ecartBetaSeries : Double = 0.0
        var ecartTVMaze : Double = 0.0
        var ecartRottenTom : Double = 0.0
        var ecartMetaCritic : Double = 0.0
        var ecartAlloCine : Double = 0.0
        var ecartSensCritique : Double = 0.0
        var ecartSIMKL : Double = 0.0


        for uneSerie in shows {
            if (uneSerie.ratingIMDB != 0) {  moyIMDB = moyIMDB + Double(uneSerie.ratingIMDB); nbIMDB = nbIMDB + 1; ecartIMDB = ecartIMDB + Double(uneSerie.ratingIMDB * uneSerie.ratingIMDB) }
            if (uneSerie.ratingTrakt != 0) {  moyTrakt = moyTrakt + Double(uneSerie.ratingTrakt); nbTrakt = nbTrakt + 1; ecartTrakt = ecartTrakt + Double(uneSerie.ratingTrakt * uneSerie.ratingTrakt) }
            if (uneSerie.ratingMovieDB != 0) {  moyMovieDB = moyMovieDB + Double(uneSerie.ratingMovieDB); nbMovieDB = nbMovieDB + 1; ecartMovieDB = ecartMovieDB + Double(uneSerie.ratingMovieDB * uneSerie.ratingMovieDB) }
            if (uneSerie.ratingBetaSeries != 0) {  moyBetaSeries = moyBetaSeries + Double(uneSerie.ratingBetaSeries); nbBetaSeries = nbBetaSeries + 1; ecartBetaSeries = ecartBetaSeries + Double(uneSerie.ratingBetaSeries * uneSerie.ratingBetaSeries) }
            if (uneSerie.ratingTVmaze != 0) {  moyTVMaze = moyTVMaze + Double(uneSerie.ratingTVmaze); nbTVMaze = nbTVMaze + 1; ecartTVMaze = ecartTVMaze + Double(uneSerie.ratingTVmaze * uneSerie.ratingTVmaze) }
            if (uneSerie.ratingRottenTomatoes != 0) {  moyRottenTom = moyRottenTom + Double(uneSerie.ratingRottenTomatoes); nbRottenTom = nbRottenTom + 1; ecartRottenTom = ecartRottenTom + Double(uneSerie.ratingRottenTomatoes * uneSerie.ratingRottenTomatoes) }
            if (uneSerie.ratingMetaCritic != 0) {  moyMetaCritic = moyMetaCritic + Double(uneSerie.ratingMetaCritic); nbMetaCritic = nbMetaCritic + 1; ecartMetaCritic = ecartMetaCritic + Double(uneSerie.ratingMetaCritic * uneSerie.ratingMetaCritic) }
            if (uneSerie.ratingAlloCine != 0) {  moyAlloCine = moyAlloCine + Double(uneSerie.ratingAlloCine); nbAlloCine = nbAlloCine + 1; ecartAlloCine = ecartAlloCine + Double(uneSerie.ratingAlloCine * uneSerie.ratingAlloCine) }
            if (uneSerie.ratingSensCritique != 0) {  moySensCritique = moySensCritique + Double(uneSerie.ratingSensCritique); nbSensCritique = nbSensCritique + 1; ecartSensCritique = ecartSensCritique + Double(uneSerie.ratingSensCritique * uneSerie.ratingSensCritique) }
            if (uneSerie.ratingSIMKL != 0) {  moySIMKL = moySIMKL + Double(uneSerie.ratingSIMKL); nbSIMKL = nbSIMKL + 1; ecartSIMKL = ecartSIMKL + Double(uneSerie.ratingSIMKL * uneSerie.ratingSIMKL) }
        }
        moyIMDB = moyIMDB / Double(nbIMDB)
        moyTrakt = moyTrakt / Double(nbTrakt)
        moyMovieDB = moyMovieDB / Double(nbMovieDB)
        moyBetaSeries = moyBetaSeries / Double(nbBetaSeries)
        moyTVMaze = moyTVMaze / Double(nbTVMaze)
        moyRottenTom = moyRottenTom / Double(nbRottenTom)
        moyMetaCritic = moyMetaCritic / Double(nbMetaCritic)
        moyAlloCine = moyAlloCine / Double(nbAlloCine)
        moySensCritique = moySensCritique / Double(nbSensCritique)
        moySIMKL = moySIMKL / Double(nbSIMKL)

        ecartIMDB = sqrt( ( ecartIMDB / Double(nbIMDB) ) - (moyIMDB * moyIMDB) )
        ecartTrakt = sqrt( ( ecartTrakt / Double(nbTrakt) ) - (moyTrakt * moyTrakt) )
        ecartMovieDB = sqrt( ( ecartMovieDB / Double(nbMovieDB) ) - (moyMovieDB * moyMovieDB) )
        ecartBetaSeries = sqrt( ( ecartBetaSeries / Double(nbBetaSeries) ) - (moyBetaSeries * moyBetaSeries) )
        ecartTVMaze = sqrt( ( ecartTVMaze / Double(nbTVMaze) ) - (moyTVMaze * moyTVMaze) )
        ecartRottenTom = sqrt( ( ecartRottenTom / Double(nbRottenTom) ) - (moyRottenTom * moyRottenTom) )
        ecartMetaCritic = sqrt( ( ecartMetaCritic / Double(nbMetaCritic) ) - (moyMetaCritic * moyMetaCritic) )
        ecartAlloCine = sqrt( ( ecartAlloCine / Double(nbAlloCine) ) - (moyAlloCine * moyAlloCine) )
        ecartSensCritique = sqrt( ( ecartSensCritique / Double(nbSensCritique) ) - (moySensCritique * moySensCritique) )
        ecartSIMKL = sqrt( ( ecartSIMKL / Double(nbSIMKL) ) - (moySIMKL * moySIMKL) )

        print("Coefficients pour les séries ")
        print("-----------------------------")

        print("IMDB           Moyenne = \(moyIMDB) et Ecart = \(ecartIMDB) pour \(nbIMDB) séries")
        print("Trakt          Moyenne = \(moyTrakt) et Ecart = \(ecartTrakt) pour \(nbTrakt) séries")
        print("MovieDB        Moyenne = \(moyMovieDB) et Ecart = \(ecartMovieDB) pour \(nbMovieDB) séries")
        print("BetaSeries     Moyenne = \(moyBetaSeries) et Ecart = \(ecartBetaSeries) pour \(nbBetaSeries) séries")
        print("TVMaze         Moyenne = \(moyTVMaze) et Ecart = \(ecartTVMaze) pour \(nbTVMaze) séries")
        print("RottenTom      Moyenne = \(moyRottenTom) et Ecart = \(ecartRottenTom) pour \(nbRottenTom) séries")
        print("MetaCritic     Moyenne = \(moyMetaCritic) et Ecart = \(ecartMetaCritic) pour \(nbMetaCritic) séries")
        print("AlloCine       Moyenne = \(moyAlloCine) et Ecart = \(ecartAlloCine) pour \(nbAlloCine) séries")
        print("SensCritique   Moyenne = \(moySensCritique) et Ecart = \(ecartSensCritique) pour \(nbSensCritique) séries")
        print("SIMKL          Moyenne = \(moySIMKL) et Ecart = \(ecartSIMKL) pour \(nbSIMKL) séries")
        print()
        print()
        
        //return
        
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

        var moyMoviedbEps : Double = 0.0
        var moyTVmazeEps : Double = 0.0
        var moySensCritiqueEps : Double = 0.0

        var nbMoviedbEps : Int = 0
        var nbTVmazeEps : Int = 0
        var nbSensCritiqueEps : Int = 0

        var ecartMoviedbEps : Double = 0.0
        var ecartTVmazeEps : Double = 0.0
        var ecartSensCritiqueEps : Double = 0.0

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

                    if (unEpisode.ratingMoviedb != 0) {
                        moyMoviedbEps = moyMoviedbEps + Double(unEpisode.ratingMoviedb * unEpisode.ratersMoviedb)
                        nbMoviedbEps = nbMoviedbEps + unEpisode.ratersMoviedb
                        ecartMoviedbEps = ecartMoviedbEps + Double(unEpisode.ratingMoviedb * unEpisode.ratingMoviedb * unEpisode.ratersMoviedb)
                    }
                    
                    if (unEpisode.ratingTVMaze != 0) {
                        moyTVmazeEps = moyTVmazeEps + Double(unEpisode.ratingTVMaze * unEpisode.ratersTVMaze)
                        nbTVmazeEps = nbTVmazeEps + unEpisode.ratersTVMaze
                        ecartTVmazeEps = ecartTVmazeEps + Double(unEpisode.ratingTVMaze * unEpisode.ratingTVMaze * unEpisode.ratersTVMaze)
                    }
                    
                    if (unEpisode.ratingSensCritique != 0) {
                        moySensCritiqueEps = moySensCritiqueEps + Double(unEpisode.ratingSensCritique * 11)
                        nbSensCritiqueEps = nbSensCritiqueEps + 11
                        ecartSensCritiqueEps = ecartSensCritiqueEps + Double(unEpisode.ratingSensCritique * unEpisode.ratingSensCritique * 11)
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

        moyMoviedbEps = moyMoviedbEps / Double(nbMoviedbEps)
        moyTVmazeEps = moyTVmazeEps / Double(nbTVmazeEps)
        moySensCritiqueEps = moySensCritiqueEps / Double(nbSensCritiqueEps)

        ecartMoviedbEps = sqrt( ( ecartMoviedbEps / Double(nbMoviedbEps) ) - (moyMoviedbEps * moyMoviedbEps) )
        ecartTVmazeEps = sqrt( ( ecartTVmazeEps / Double(nbTVmazeEps) ) - (moyTVmazeEps * moyTVmazeEps) )
        ecartSensCritiqueEps = sqrt( ( ecartSensCritiqueEps / Double(nbSensCritiqueEps) ) - (moySensCritiqueEps * moySensCritiqueEps) )

        print("Coefficients pour les épisodes ")
        print("-------------------------------")

        print("IMDB           Moyenne = \(moyIMDBEps) et Ecart = \(ecartIMDBEps)")
        print("Trakt          Moyenne = \(moyTraktEps) et Ecart = \(ecartTraktEps)")
        print("BetaSeries     Moyenne = \(moyBetaSeriesEps) et Ecart = \(ecartBetaSeriesEps)")
        
        print("Moviedb        Moyenne = \(moyMoviedbEps) et Ecart = \(ecartMoviedbEps)")
        print("TVmaze         Moyenne = \(moyTVmazeEps) et Ecart = \(ecartTVmazeEps)")
        print("SensCritique   Moyenne = \(moySensCritiqueEps) et Ecart = \(ecartSensCritiqueEps)")
    }

}
