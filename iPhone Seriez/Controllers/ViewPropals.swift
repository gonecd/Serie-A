//
//  ViewPropals.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 10/11/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import SeriesCommon


class SrcProposition {
    var serie   : String
    var id      : String
    var typeid  : Int
    var source  : Int
    var type    : Int
    
    public init(serie: String, id : String, typeid: Int, source: Int, type: Int) {
        self.serie = serie
        self.id = id
        self.typeid = typeid
        self.source = source
        self.type = type
    }
}

class Suggestion {
    var serie     : String = ""
    var category  : Int = categInconnues
    var IMDBid    : String = ""
    var MovieDBid : String = ""
    var AlloCineID: String = ""
    var TVMazeID  : String = ""
    
    var countTrending : Int = 0
    var countPopular  : Int = 0
    
    var IMDBtrending       : Bool = false
    var IMDBpopular        : Bool = false
    var RottenTomtrending  : Bool = false
    var RottenTomBpopular  : Bool = false
    var TVMazetrending     : Bool = false
    var TVMazepopular      : Bool = false
    var AlloCinetrending   : Bool = false
    var AlloCinepopular    : Bool = false
    var MetaCritictrending : Bool = false
    var MetaCriticpopular  : Bool = false
    var Trakttrending      : Bool = false
    var Traktpopular       : Bool = false
    var BetaSeriestrending : Bool = false
    var BetaSeriespopular  : Bool = false
    var MovieDBtrending    : Bool = false
    var MovieDBpopular     : Bool = false
}


class CellPropal : UICollectionViewCell {
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var iconeTrakt: UIImageView!
    @IBOutlet weak var iconeBetaSeries: UIImageView!
    @IBOutlet weak var iconeTVMaze: UIImageView!
    @IBOutlet weak var iconeAlloCine: UIImageView!
    @IBOutlet weak var iconeMovieDB: UIImageView!
    @IBOutlet weak var iconeRottenTom: UIImageView!
    @IBOutlet weak var iconeIMDB: UIImageView!
    @IBOutlet weak var iconeMetaCritic: UIImageView!
    
    @IBOutlet weak var popuTrakt: UILabel!
    @IBOutlet weak var popuBetaSeries: UILabel!
    @IBOutlet weak var popuTVMaze: UILabel!
    @IBOutlet weak var popuAlloCine: UILabel!
    @IBOutlet weak var popuMovieDB: UILabel!
    @IBOutlet weak var popuRottenTom: UILabel!
    @IBOutlet weak var popuIMDB: UILabel!
    @IBOutlet weak var popuMetaCritic: UILabel!
    
    @IBOutlet weak var trendTrakt: UILabel!
    @IBOutlet weak var trendBetaSeries: UILabel!
    @IBOutlet weak var trendTVMaze: UILabel!
    @IBOutlet weak var trendAlloCine: UILabel!
    @IBOutlet weak var trendMovieDB: UILabel!
    @IBOutlet weak var trendRottenTom: UILabel!
    @IBOutlet weak var trendIMDB: UILabel!
    @IBOutlet weak var trendMetaCritic: UILabel!
    
    var index: Int = 0
}


class ViewPropals: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var viewCollection: UICollectionView!
    
    @IBOutlet weak var viewFinies: UIView!
    @IBOutlet weak var viewEnCours: UIView!
    @IBOutlet weak var viewAbandonnees: UIView!
    @IBOutlet weak var viewWatchList: UIView!
    @IBOutlet weak var viewGetShows: UIView!
    @IBOutlet weak var viewStatuses: UIView!
    
    @IBOutlet weak var boutonTrakt: UIButton!
    @IBOutlet weak var boutonBetaSeries: UIButton!
    @IBOutlet weak var boutonTVMaze: UIButton!
    @IBOutlet weak var boutonAlloCine: UIButton!
    @IBOutlet weak var boutonMovieDB: UIButton!
    @IBOutlet weak var boutonRottenTom: UIButton!
    @IBOutlet weak var boutonIMDB: UIButton!
    @IBOutlet weak var boutonMetaCritic: UIButton!
    @IBOutlet weak var boutonTrendy: UIButton!
    @IBOutlet weak var boutonPopular: UIButton!
    
    // New structures
    var allPropositions : [SrcProposition] = []
    var allSuggestions : [Suggestion] = []
    var allSuggestedSeries : [Serie] = []
    
    let alphaNull  : CGFloat = 0.00
    let alphaFull  : CGFloat = 1.00
    let alphaLight : CGFloat = 0.20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeMiniGradiant(carre: viewFinies, couleur : "Gris")
        makeMiniGradiant(carre: viewEnCours, couleur : "Bleu")
        makeMiniGradiant(carre: viewAbandonnees, couleur : "Rouge")
        makeMiniGradiant(carre: viewWatchList, couleur : "Vert")
        
        makeGradiant(carre: viewGetShows, couleur : "Gris")
        
        viewStatuses.isHidden = true
        viewGetShows.isHidden = false
    }
    
    
    @IBAction func searchForPropositions(_ sender: Any) {
        allPropositions.removeAll()
        allSuggestions.removeAll()
        allSuggestedSeries.removeAll()
        
        loadPropals()
        mergePropals()
        
        loadDetailsRT(nbSeries: 24)
    }

    
    func loadDetailsRT(nbSeries : Int) {
        allSuggestedSeries.removeAll()

        DispatchQueue.global(qos: .utility).async {
            
            DispatchQueue.main.async { self.viewGetShows.isHidden = true }
            
            for i in 0..<nbSeries {
                if (i > self.allSuggestions.count) { return }
                
                var uneSerie : Serie = Serie(serie: self.allSuggestions[i].serie)
                
                if (self.allSuggestions[i].category == categInconnues) {
                    uneSerie.idIMdb = self.allSuggestions[i].IMDBid
                    uneSerie.idMoviedb = self.allSuggestions[i].MovieDBid
                    
                    var found : Bool = false
                    found = trakt.getIDs(serie: uneSerie)
                    
                    if (!found && self.allSuggestions[i].MovieDBid != "" ) { theMoviedb.getIDs(serie: uneSerie) }
                    
                    db.downloadGlobalInfo(serie: uneSerie)
                }
                else {
                    uneSerie = db.shows[db.index[self.allSuggestions[i].serie]!]
                }
                
                self.allSuggestedSeries.append(uneSerie)
                
                DispatchQueue.main.async {
                    self.viewCollection.reloadData()
                    self.viewCollection.setNeedsDisplay()
                }
            }
                        
            DispatchQueue.main.async { self.viewStatuses.isHidden = false }
        }
    }
    
    func loadDetails(nbSeries : Int) {
        allSuggestedSeries.removeAll()
        
        for i in 0..<nbSeries {
            if (i > allSuggestions.count) { return }
            
            var uneSerie : Serie = Serie(serie: allSuggestions[i].serie)
            
            if (allSuggestions[i].category == categInconnues) {
                uneSerie.idIMdb = allSuggestions[i].IMDBid
                uneSerie.idMoviedb = allSuggestions[i].MovieDBid
                
                var found : Bool = false
                found = trakt.getIDs(serie: uneSerie)
                
                if (!found && allSuggestions[i].MovieDBid != "" ) { theMoviedb.getIDs(serie: uneSerie) }
                
                db.downloadGlobalInfo(serie: uneSerie)
            }
            else {
                uneSerie = db.shows[db.index[allSuggestions[i].serie]!]
            }
            
            allSuggestedSeries.append(uneSerie)
        }
        
        viewCollection.reloadData()
        viewCollection.setNeedsDisplay()

        viewStatuses.isHidden = false
        viewGetShows.isHidden = true
    }
    
    
    func loadPropals() {
        let queue : OperationQueue = OperationQueue()
        var flagTrending : Bool = false
        var flagPopular : Bool = false
        
        if (boutonTrendy.alpha  == alphaFull) { flagTrending = true }
        if (boutonPopular.alpha == alphaFull) { flagPopular = true }
        
        if (boutonBetaSeries.alpha  == alphaFull) {
            let opeLoadBetaSeries = BlockOperation(block: {
                var dataBetaSeries : (names : [String], ids : [String]) = ([], [])
                
                if (flagTrending) {
                    dataBetaSeries = betaSeries.getTrendingShows()
                    for i in 0..<dataBetaSeries.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataBetaSeries.names[i], id: dataBetaSeries.ids[i], typeid: srcIMdb, source: srcBetaSeries, type: typeTrending)
                        self.allPropositions.append(uneProposition)
                    }
                }
                
                if (flagPopular) {
                    dataBetaSeries = betaSeries.getPopularShows()
                    for i in 0..<dataBetaSeries.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataBetaSeries.names[i], id: dataBetaSeries.ids[i], typeid: srcIMdb, source: srcBetaSeries, type: typePopular)
                        self.allPropositions.append(uneProposition)
                    }
                }
            } )
            queue.addOperation(opeLoadBetaSeries)
        }
        
        if (boutonMovieDB.alpha  == alphaFull) {
            let opeLoadMovieDB = BlockOperation(block: {
                var dataMoviedb : (names : [String], ids : [String]) = ([], [])
                
                if (flagTrending) {
                    dataMoviedb = theMoviedb.getTrendingShows()
                    for i in 0..<dataMoviedb.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataMoviedb.names[i], id: dataMoviedb.ids[i], typeid: srcMovieDB, source: srcMovieDB, type: typeTrending)
                        self.allPropositions.append(uneProposition)
                    }
                }
                
                if (flagPopular) {
                    dataMoviedb = theMoviedb.getPopularShows()
                    for i in 0..<dataMoviedb.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataMoviedb.names[i], id: dataMoviedb.ids[i], typeid: srcMovieDB, source: srcMovieDB, type: typePopular)
                        self.allPropositions.append(uneProposition)
                    }
                }
            } )
            queue.addOperation(opeLoadMovieDB)
        }
        
        if (boutonIMDB.alpha  == alphaFull) {
            let opeLoadIMDB = BlockOperation(block: {
                var dataIMDB : (names : [String], ids : [String]) = ([], [])
                
                if (flagTrending) {
                    dataIMDB = imdb.getTrendingShows()
                    for i in 0..<dataIMDB.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataIMDB.names[i], id: dataIMDB.ids[i], typeid: srcIMdb, source: srcIMdb, type: typeTrending)
                        self.allPropositions.append(uneProposition)
                    }
                }
                
                if (flagPopular) {
                    dataIMDB = imdb.getPopularShows()
                    for i in 0..<dataIMDB.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataIMDB.names[i], id: dataIMDB.ids[i], typeid: srcIMdb, source: srcIMdb, type: typePopular)
                        self.allPropositions.append(uneProposition)
                    }
                }
            } )
            queue.addOperation(opeLoadIMDB)
        }
        
        if (boutonTrakt.alpha  == alphaFull) {
            let opeLoadTrakt = BlockOperation(block: {
                var dataTrakt : (names : [String], ids : [String]) = ([], [])
                
                if (flagTrending) {
                    dataTrakt = trakt.getTrendingShows()
                    for i in 0..<dataTrakt.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataTrakt.names[i], id: dataTrakt.ids[i], typeid: srcIMdb, source: srcTrakt, type: typeTrending)
                        self.allPropositions.append(uneProposition)
                    }
                }
                
                if (flagPopular) {
                    dataTrakt = trakt.getPopularShows()
                    for i in 0..<dataTrakt.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataTrakt.names[i], id: dataTrakt.ids[i], typeid: srcIMdb, source: srcTrakt, type: typePopular)
                        self.allPropositions.append(uneProposition)
                    }
                }
            } )
            queue.addOperation(opeLoadTrakt)
        }
        
        if (boutonTVMaze.alpha  == alphaFull) {
            let opeLoadTVmaze = BlockOperation(block: {
                var dataTVMaze : (names : [String], ids : [String]) = ([], [])
                
                if (flagTrending) {
                    dataTVMaze = tvMaze.getTrendingShows()
                    for i in 0..<dataTVMaze.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataTVMaze.names[i], id: dataTVMaze.ids[i], typeid: srcTVMaze, source: srcTVMaze, type: typeTrending)
                        self.allPropositions.append(uneProposition)
                    }
                }
                
                if (flagPopular) {
                    dataTVMaze = tvMaze.getPopularShows()
                    for i in 0..<dataTVMaze.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataTVMaze.names[i], id: dataTVMaze.ids[i], typeid: srcTVMaze, source: srcTVMaze, type: typePopular)
                        self.allPropositions.append(uneProposition)
                    }
                }
            } )
            queue.addOperation(opeLoadTVmaze)
        }
        
        if (boutonRottenTom.alpha  == alphaFull) {
            let opeLoadRottenT = BlockOperation(block: {
                var dataRottenT : (names : [String], ids : [String]) = ([], [])
                
                if (flagTrending) {
                    dataRottenT = rottenTomatoes.getTrendingShows()
                    for i in 0..<dataRottenT.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataRottenT.names[i], id: dataRottenT.ids[i], typeid: 0, source: srcRottenTom, type: typeTrending)
                        self.allPropositions.append(uneProposition)
                    }
                }
                
                if (flagPopular) {
                    dataRottenT = rottenTomatoes.getPopularShows()
                    for i in 0..<dataRottenT.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataRottenT.names[i], id: dataRottenT.ids[i], typeid: 0, source: srcRottenTom, type: typePopular)
                        self.allPropositions.append(uneProposition)
                    }
                }
            } )
            queue.addOperation(opeLoadRottenT)
        }
        
        if (boutonMetaCritic.alpha  == alphaFull) {
            let opeLoadMetaCritic = BlockOperation(block: {
                var dataMetaCritic : (names : [String], ids : [String]) = ([], [])
                
                if (flagTrending) {
                    dataMetaCritic = metaCritic.getTrendingShows()
                    for i in 0..<dataMetaCritic.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataMetaCritic.names[i], id: dataMetaCritic.ids[i], typeid: 0, source: srcMetaCritic, type: typeTrending)
                        self.allPropositions.append(uneProposition)
                    }
                }
                
                if (flagPopular) {
                    dataMetaCritic = metaCritic.getPopularShows()
                    for i in 0..<dataMetaCritic.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataMetaCritic.names[i], id: dataMetaCritic.ids[i], typeid: 0, source: srcMetaCritic, type: typePopular)
                        self.allPropositions.append(uneProposition)
                    }
                }
            } )
            queue.addOperation(opeLoadMetaCritic)
        }
        
        if (boutonAlloCine.alpha  == alphaFull) {
            let opeLoadAlloCine = BlockOperation(block: {
                var dataAlloCine : (names : [String], ids : [String]) = ([], [])
                
                if (flagTrending) {
                    dataAlloCine = alloCine.getTrendingShows()
                    for i in 0..<dataAlloCine.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataAlloCine.names[i], id: dataAlloCine.ids[i], typeid: srcAlloCine, source: srcAlloCine, type: typeTrending)
                        self.allPropositions.append(uneProposition)
                    }
                }
                
                if (flagPopular) {
                    dataAlloCine = alloCine.getPopularShows()
                    for i in 0..<dataAlloCine.names.count {
                        let uneProposition : SrcProposition = SrcProposition(serie: dataAlloCine.names[i], id: dataAlloCine.ids[i], typeid: srcAlloCine, source: srcAlloCine, type: typePopular)
                        self.allPropositions.append(uneProposition)
                    }
                }
            } )
            queue.addOperation(opeLoadAlloCine)
        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    func mergePropals() {
        var pleaseAdd : Bool = false
        
        for unePropale in allPropositions {
            pleaseAdd = false
            var uneSuggestion : Suggestion? = findInPrevious(serie: unePropale.serie)
            
            if (uneSuggestion == nil) {
                uneSuggestion = Suggestion()
                uneSuggestion!.serie = unePropale.serie
                uneSuggestion!.category = knownShowCateg(serie: unePropale.serie)
                
                pleaseAdd = true
            }
            
            if ((unePropale.source == srcIMdb) && (unePropale.type == typeTrending))       { uneSuggestion!.IMDBtrending = true }
            if ((unePropale.source == srcIMdb) && (unePropale.type == typePopular))        { uneSuggestion!.IMDBpopular = true }
            if ((unePropale.source == srcTVMaze) && (unePropale.type == typeTrending))     { uneSuggestion!.TVMazetrending = true }
            if ((unePropale.source == srcTVMaze) && (unePropale.type == typePopular))      { uneSuggestion!.TVMazepopular = true }
            if ((unePropale.source == srcAlloCine) && (unePropale.type == typeTrending))   { uneSuggestion!.AlloCinetrending = true }
            if ((unePropale.source == srcAlloCine) && (unePropale.type == typePopular))    { uneSuggestion!.AlloCinepopular = true }
            if ((unePropale.source == srcRottenTom) && (unePropale.type == typeTrending))  { uneSuggestion!.RottenTomtrending = true }
            if ((unePropale.source == srcRottenTom) && (unePropale.type == typePopular))   { uneSuggestion!.RottenTomBpopular = true }
            if ((unePropale.source == srcMetaCritic) && (unePropale.type == typeTrending)) { uneSuggestion!.MetaCritictrending = true }
            if ((unePropale.source == srcMetaCritic) && (unePropale.type == typePopular))  { uneSuggestion!.MetaCriticpopular = true }
            if ((unePropale.source == srcTrakt) && (unePropale.type == typeTrending))      { uneSuggestion!.Trakttrending = true }
            if ((unePropale.source == srcTrakt) && (unePropale.type == typePopular))       { uneSuggestion!.Traktpopular = true }
            if ((unePropale.source == srcBetaSeries) && (unePropale.type == typeTrending)) { uneSuggestion!.BetaSeriestrending = true }
            if ((unePropale.source == srcBetaSeries) && (unePropale.type == typePopular))  { uneSuggestion!.BetaSeriespopular = true }
            if ((unePropale.source == srcMovieDB) && (unePropale.type == typeTrending))    { uneSuggestion!.MovieDBtrending = true }
            if ((unePropale.source == srcMovieDB) && (unePropale.type == typePopular))     { uneSuggestion!.MovieDBtrending = true }
            
            if (unePropale.typeid == srcIMdb)     { uneSuggestion!.IMDBid = unePropale.id }
            if (unePropale.typeid == srcTVMaze)   { uneSuggestion!.TVMazeID = unePropale.id }
            if (unePropale.typeid == srcAlloCine) { uneSuggestion!.AlloCineID = unePropale.id }
            if (unePropale.typeid == srcMovieDB)  { uneSuggestion!.MovieDBid = unePropale.id }
            
            if (unePropale.type == typeTrending)  { uneSuggestion!.countTrending = uneSuggestion!.countTrending + 1 }
            if (unePropale.type == typePopular)   { uneSuggestion!.countPopular = uneSuggestion!.countPopular + 1 }
            
            if (pleaseAdd) { allSuggestions.append(uneSuggestion!) }
        }
        
        allSuggestions = allSuggestions.sorted(by: { $0.countPopular+$0.countTrending > $1.countPopular+$1.countTrending })
    }
    
    func findInPrevious(serie: String) -> Suggestion? {
        for uneSuggestion in allSuggestions {
            if (uneSuggestion.serie == serie) { return uneSuggestion }
        }
        return nil
    }
    
    func knownShowCateg(serie: String) -> Int {
        let indexDB : Int = db.index[serie] ?? -1
        
        if (indexDB != -1) {
            if (db.shows[indexDB].watchlist) { return categWatchlist }
            else if (db.shows[indexDB].unfollowed) { return categAbandonnees }
            else if (db.shows[indexDB].watching()) { return categSuivies }
            else { return categFinies }
        }
        
        return categInconnues
    }
    
    
    @IBAction func flipFlop(_ sender: Any) {
        var bouton : UIButton = sender as! UIButton
        
        if (bouton.alpha == alphaFull) {
            bouton.alpha = alphaLight
        }
        else {
            bouton.alpha = alphaFull
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allSuggestedSeries.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellPropal", for: indexPath as IndexPath) as! CellPropal
        
        // Reinitialisation des icones et couleurs de la Cell
        cell.iconeIMDB.alpha = alphaLight
        cell.trendIMDB.alpha = alphaNull
        cell.popuIMDB.alpha = alphaNull
        cell.iconeRottenTom.alpha = alphaLight
        cell.trendRottenTom.alpha = alphaNull
        cell.popuRottenTom.alpha = alphaNull
        cell.iconeTVMaze.alpha = alphaLight
        cell.trendTVMaze.alpha = alphaNull
        cell.popuTVMaze.alpha = alphaNull
        cell.iconeAlloCine.alpha = alphaLight
        cell.trendAlloCine.alpha = alphaNull
        cell.popuAlloCine.alpha = alphaNull
        cell.iconeMetaCritic.alpha = alphaLight
        cell.trendMetaCritic.alpha = alphaNull
        cell.popuMetaCritic.alpha = alphaNull
        cell.iconeTrakt.alpha = alphaLight
        cell.trendTrakt.alpha = alphaNull
        cell.popuTrakt.alpha = alphaNull
        cell.iconeBetaSeries.alpha = alphaLight
        cell.trendBetaSeries.alpha = alphaNull
        cell.popuBetaSeries.alpha = alphaNull
        cell.iconeMovieDB.alpha = alphaLight
        cell.trendMovieDB.alpha = alphaNull
        cell.popuMovieDB.alpha = alphaNull

        let sugg : Suggestion = allSuggestions[indexPath.row]
        
        if (sugg.IMDBtrending || sugg.IMDBpopular) {
            cell.iconeIMDB.alpha = alphaFull
            if (sugg.IMDBtrending) { cell.trendIMDB.alpha = alphaFull }
            if (sugg.IMDBpopular) { cell.popuIMDB.alpha = alphaFull }
        }
        
        if (sugg.RottenTomtrending || sugg.RottenTomBpopular) {
            cell.iconeRottenTom.alpha = alphaFull
            if (sugg.RottenTomtrending) { cell.trendRottenTom.alpha = alphaFull }
            if (sugg.RottenTomBpopular) { cell.popuRottenTom.alpha = alphaFull }
        }
        
        if (sugg.TVMazetrending || sugg.TVMazepopular) {
            cell.iconeTVMaze.alpha = alphaFull
            if (sugg.TVMazetrending) { cell.trendTVMaze.alpha = alphaFull }
            if (sugg.TVMazepopular) { cell.popuTVMaze.alpha = alphaFull }
        }
        
        if (sugg.AlloCinetrending || sugg.AlloCinepopular) {
            cell.iconeAlloCine.alpha = alphaFull
            if (sugg.AlloCinetrending) { cell.trendAlloCine.alpha = alphaFull }
            if (sugg.AlloCinepopular) { cell.popuAlloCine.alpha = alphaFull }
        }
        
        if (sugg.MetaCritictrending || sugg.MetaCriticpopular) {
            cell.iconeMetaCritic.alpha = alphaFull
            if (sugg.MetaCritictrending) { cell.trendMetaCritic.alpha = alphaFull }
            if (sugg.MetaCriticpopular) { cell.popuMetaCritic.alpha = alphaFull }
        }
        
        if (sugg.Trakttrending || sugg.Traktpopular) {
            cell.iconeTrakt.alpha = alphaFull
            if (sugg.Trakttrending) { cell.trendTrakt.alpha = alphaFull }
            if (sugg.Traktpopular) { cell.popuTrakt.alpha = alphaFull }
        }
        
        if (sugg.BetaSeriestrending || sugg.BetaSeriespopular) {
            cell.iconeBetaSeries.alpha = alphaFull
            if (sugg.BetaSeriestrending) { cell.trendBetaSeries.alpha = alphaFull }
            if (sugg.BetaSeriespopular) { cell.popuBetaSeries.alpha = alphaFull }
        }
        
        if (sugg.MovieDBtrending || sugg.MovieDBpopular) {
            cell.iconeMovieDB.alpha = alphaFull
            if (sugg.MovieDBtrending) { cell.trendMovieDB.alpha = alphaFull }
            if (sugg.MovieDBpopular) { cell.popuMovieDB.alpha = alphaFull }
        }
        
        cell.poster.image = getImage(allSuggestedSeries[indexPath.row].poster)
        cell.note.text = String(allSuggestedSeries[indexPath.row].getGlobalRating()) + " %"
        arrondir(texte: cell.note, radius: 8.0)
        cell.index = indexPath.row
        
        switch sugg.category {
        case categInconnues:
            cell.status.image = #imageLiteral(resourceName: "Idea-icon.png")
            cell.statusView.backgroundColor = UIColor(red: 0.0, green: 143.0/255.0, blue: 0.0, alpha: 1.0)
            break
            
        case categWatchlist:
            cell.status.image = #imageLiteral(resourceName: "List-icon.png")
            cell.statusView.backgroundColor = UIColor(red: 0.0, green: 143.0/255.0, blue: 0.0, alpha: 1.0)
            break
            
        case categAbandonnees:
            cell.status.image = #imageLiteral(resourceName: "Trash-icon.png")
            cell.statusView.backgroundColor = .systemRed
            break
            
        case categSuivies:
            cell.status.image = #imageLiteral(resourceName: "Play-icon.png")
            cell.statusView.backgroundColor = .systemBlue
            break
            
        case categFinies:
            cell.status.image = #imageLiteral(resourceName: "Stop-icon.png")
            cell.statusView.backgroundColor = .systemGray
            break
            
        default:
            cell.status.image = #imageLiteral(resourceName: "Bio-Hazard-icon.png")
            cell.statusView.backgroundColor = .systemGray4
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellPropal = sender as! CellPropal
        
        viewController.serie = allSuggestedSeries[tableCell.index]
        viewController.image = getImage(allSuggestedSeries[tableCell.index].banner)
    }
}
