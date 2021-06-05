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
    
    public init(serie: String, id : String, typeid: Int, source: Int) {
        self.serie = serie
        self.id = id
        self.typeid = typeid
        self.source = source
    }
}


class Suggestion {
    var serie     : String = ""
    var IMDBid    : String = ""
    var MovieDBid : String = ""
    var AlloCineID: String = ""
    var TVMazeID  : String = ""
    
    var sources        : [Int] = []
}


class CellPropal : UICollectionViewCell {
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var annee: UILabel!
    @IBOutlet weak var nbSaisons: UILabel!
    @IBOutlet weak var nbEpidodes: UILabel!
    @IBOutlet weak var drapeau: UIImageView!
    
    @IBOutlet weak var iconeTrakt: UIImageView!
    @IBOutlet weak var iconeBetaSeries: UIImageView!
    @IBOutlet weak var iconeTVMaze: UIImageView!
    @IBOutlet weak var iconeAlloCine: UIImageView!
    @IBOutlet weak var iconeMovieDB: UIImageView!
    @IBOutlet weak var iconeRottenTom: UIImageView!
    @IBOutlet weak var iconeIMDB: UIImageView!
    @IBOutlet weak var iconeMetaCritic: UIImageView!
    
    @IBOutlet weak var graph: GraphMiniSerie!
    
    var index: Int = 0
}


class ViewPropals: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var viewCollection: UICollectionView!
    
    @IBOutlet weak var boutonTrakt: UIButton!
    @IBOutlet weak var boutonBetaSeries: UIButton!
    @IBOutlet weak var boutonTVMaze: UIButton!
    @IBOutlet weak var boutonAlloCine: UIButton!
    @IBOutlet weak var boutonMovieDB: UIButton!
    @IBOutlet weak var boutonRottenTom: UIButton!
    @IBOutlet weak var boutonIMDB: UIButton!
    @IBOutlet weak var boutonMetaCritic: UIButton!
    
    // New structures
    var allPropositions : [SrcProposition] = []
    var allSuggestions : [Suggestion] = []
    var displayedSeries : [Serie] = []
    
    let alphaNull  : CGFloat = 0.00
    let alphaFull  : CGFloat = 1.00
    let alphaLight : CGFloat = 0.20
    
    var affficheGraphe : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchForPropositions(self)
    }
    
    
    @IBAction func searchForPropositions(_ sender: Any) {
        allPropositions.removeAll()
        allSuggestions.removeAll()
        displayedSeries.removeAll()
        
        loadPropals()
        mergePropals()
        
        loadDetailsRT()
    }

    
    func loadDetailsRT() {
        DispatchQueue.global(qos: .utility).async {
            
            for i in 0..<self.allSuggestions.count {
                let uneSerie : Serie = Serie(serie: self.allSuggestions[i].serie)
                uneSerie.idIMdb = self.allSuggestions[i].IMDBid
                uneSerie.idMoviedb = self.allSuggestions[i].MovieDBid
                
                var found : Bool = false
                found = trakt.getIDs(serie: uneSerie)
                
                if (!found && self.allSuggestions[i].MovieDBid != "" ) { _ = theMoviedb.getIDs(serie: uneSerie) }
                
                db.downloadGlobalInfo(serie: uneSerie)
                
                self.displayedSeries.append(uneSerie)
                
                DispatchQueue.main.async {
                    self.viewCollection.reloadData()
                    self.viewCollection.setNeedsDisplay()
                }
            }
        }
    }
    
    
    func loadPropals() {
        let queue : OperationQueue = OperationQueue()
        
        let opeLoadBetaSeries = BlockOperation(block: {
            let dataBetaSeries : (names : [String], ids : [String]) = betaSeries.getTrendingShows()
            for i in 0..<dataBetaSeries.names.count {
                let uneProposition : SrcProposition = SrcProposition(serie: dataBetaSeries.names[i], id: dataBetaSeries.ids[i], typeid: srcIMdb, source: srcBetaSeries)
                self.allPropositions.append(uneProposition)
            }
        } )
        queue.addOperation(opeLoadBetaSeries)
        
        let opeLoadMovieDB = BlockOperation(block: {
            let dataMoviedb : (names : [String], ids : [String]) = theMoviedb.getPopularShows()
            for i in 0..<dataMoviedb.names.count {
                let uneProposition : SrcProposition = SrcProposition(serie: dataMoviedb.names[i], id: dataMoviedb.ids[i], typeid: srcMovieDB, source: srcMovieDB)
                self.allPropositions.append(uneProposition)
            }
        } )
        queue.addOperation(opeLoadMovieDB)
        
        let opeLoadIMDB = BlockOperation(block: {
            let dataIMDB : (names : [String], ids : [String]) = imdb.getTrendingShows()
            for i in 0..<dataIMDB.names.count {
                let uneProposition : SrcProposition = SrcProposition(serie: dataIMDB.names[i], id: dataIMDB.ids[i], typeid: srcIMdb, source: srcIMdb)
                self.allPropositions.append(uneProposition)
            }
        } )
        queue.addOperation(opeLoadIMDB)
        
        let opeLoadTrakt = BlockOperation(block: {
            let dataTrakt : (names : [String], ids : [String]) = trakt.getTrendingShows()
            for i in 0..<dataTrakt.names.count {
                let uneProposition : SrcProposition = SrcProposition(serie: dataTrakt.names[i], id: dataTrakt.ids[i], typeid: srcIMdb, source: srcTrakt)
                self.allPropositions.append(uneProposition)
            }
        } )
        queue.addOperation(opeLoadTrakt)
        
        let opeLoadTVmaze = BlockOperation(block: {
            let dataTVMaze : (names : [String], ids : [String]) = tvMaze.getTrendingShows()
            for i in 0..<dataTVMaze.names.count {
                let uneProposition : SrcProposition = SrcProposition(serie: dataTVMaze.names[i], id: dataTVMaze.ids[i], typeid: srcTVMaze, source: srcTVMaze)
                self.allPropositions.append(uneProposition)
            }
        } )
        queue.addOperation(opeLoadTVmaze)
        
        let opeLoadRottenT = BlockOperation(block: {
            let dataRottenT : (names : [String], ids : [String]) = rottenTomatoes.getTrendingShows()
            print("===> dataRottenT : " + String(dataRottenT.names.count))
            for i in 0..<dataRottenT.names.count {
                let uneProposition : SrcProposition = SrcProposition(serie: dataRottenT.names[i], id: dataRottenT.ids[i], typeid: 0, source: srcRottenTom)
                self.allPropositions.append(uneProposition)
            }
        } )
        queue.addOperation(opeLoadRottenT)
        
        let opeLoadMetaCritic = BlockOperation(block: {
            let dataMetaCritic : (names : [String], ids : [String]) = metaCritic.getTrendingShows()
            for i in 0..<dataMetaCritic.names.count {
                let uneProposition : SrcProposition = SrcProposition(serie: dataMetaCritic.names[i], id: dataMetaCritic.ids[i], typeid: 0, source: srcMetaCritic)
                self.allPropositions.append(uneProposition)
            }
        } )
        queue.addOperation(opeLoadMetaCritic)
        
        let opeLoadAlloCine = BlockOperation(block: {
            let dataAlloCine : (names : [String], ids : [String]) = alloCine.getTrendingShows()
            for i in 0..<dataAlloCine.names.count {
                let uneProposition : SrcProposition = SrcProposition(serie: dataAlloCine.names[i], id: dataAlloCine.ids[i], typeid: srcAlloCine, source: srcAlloCine)
                self.allPropositions.append(uneProposition)
            }
        } )
        queue.addOperation(opeLoadAlloCine)
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    func mergePropals() {
        var toBeAdded : Bool = false
        
        for unePropale in allPropositions {
            let indexDB : Int = db.index[unePropale.serie] ?? -1
            if (indexDB == -1) { // On ne prend que les séries inconnues (ie: ni vues, ni abandonnées, ni en cours, ni en watchlist)
                toBeAdded = false
                var uneSuggestion : Suggestion? = findInPrevious(serie: unePropale.serie)
                
                if (uneSuggestion == nil) {
                    uneSuggestion = Suggestion()
                    uneSuggestion!.serie = unePropale.serie
                    
                    toBeAdded = true
                }
                
                if (unePropale.typeid == srcIMdb)     { uneSuggestion!.IMDBid = unePropale.id }
                if (unePropale.typeid == srcTVMaze)   { uneSuggestion!.TVMazeID = unePropale.id }
                if (unePropale.typeid == srcAlloCine) { uneSuggestion!.AlloCineID = unePropale.id }
                if (unePropale.typeid == srcMovieDB)  { uneSuggestion!.MovieDBid = unePropale.id }
                
                uneSuggestion!.sources.append(unePropale.source)
                
                if (toBeAdded) { allSuggestions.append(uneSuggestion!) }
            }
        }
        
        allSuggestions.removeAll(where: { $0.sources.count == 1  })
        allSuggestions = allSuggestions.sorted(by: { $0.sources.count > $1.sources.count })
    }
    
    func findInPrevious(serie: String) -> Suggestion? {
        for uneSuggestion in allSuggestions {
            if (uneSuggestion.serie.uppercased() == serie.uppercased()) { return uneSuggestion }
        }
        return nil
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedSeries.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellPropal", for: indexPath as IndexPath) as! CellPropal
                
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        
        cell.titre.text = displayedSeries[indexPath.row].serie
        cell.poster.image = getImage(displayedSeries[indexPath.row].poster)
        cell.drapeau.image = getDrapeau(country: displayedSeries[indexPath.row].country)
        cell.note.text = String(displayedSeries[indexPath.row].getGlobalRating()) + " %"
        arrondir(texte: cell.note, radius: 8.0)
        
        cell.graph.sendNotes(rateTrakt: displayedSeries[indexPath.row].getFairGlobalRatingTrakt(),
                             rateBetaSeries: displayedSeries[indexPath.row].getFairGlobalRatingBetaSeries(),
                             rateMoviedb: displayedSeries[indexPath.row].getFairGlobalRatingMoviedb(),
                             rateIMdb: displayedSeries[indexPath.row].getFairGlobalRatingIMdb(),
                             rateTVmaze: displayedSeries[indexPath.row].getFairGlobalRatingTVmaze(),
                             rateRottenTomatoes: displayedSeries[indexPath.row].getFairGlobalRatingRottenTomatoes(),
                             rateMetaCritic: displayedSeries[indexPath.row].getFairGlobalRatingMetaCritic(),
                             rateAlloCine: displayedSeries[indexPath.row].getFairGlobalRatingAlloCine() )
        cell.graph.setType(type: 0)
        cell.graph.setNeedsDisplay()
        
        let sugg : Suggestion = findSuggestion(serie: displayedSeries[indexPath.row].serie)
        
        cell.annee.text = String(displayedSeries[indexPath.row].year)
        cell.nbSaisons.text = String(displayedSeries[indexPath.row].nbSaisons)
        cell.nbEpidodes.text = String(displayedSeries[indexPath.row].nbEpisodes)
        cell.index = indexPath.row
        
        if (sugg.sources.contains(srcIMdb))        { cell.iconeIMDB.alpha = alphaFull }        else { cell.iconeIMDB.alpha = alphaLight }
        if (sugg.sources.contains(srcRottenTom))   { cell.iconeRottenTom.alpha = alphaFull }   else { cell.iconeRottenTom.alpha = alphaLight }
        if (sugg.sources.contains(srcTVMaze))      { cell.iconeTVMaze.alpha = alphaFull }      else { cell.iconeTVMaze.alpha = alphaLight }
        if (sugg.sources.contains(srcAlloCine))    { cell.iconeAlloCine.alpha = alphaFull }    else { cell.iconeAlloCine.alpha = alphaLight }
        if (sugg.sources.contains(srcMetaCritic))  { cell.iconeMetaCritic.alpha = alphaFull }  else { cell.iconeMetaCritic.alpha = alphaLight }
        if (sugg.sources.contains(srcTrakt))       { cell.iconeTrakt.alpha = alphaFull }       else { cell.iconeTrakt.alpha = alphaLight }
        if (sugg.sources.contains(srcBetaSeries))  { cell.iconeBetaSeries.alpha = alphaFull }  else { cell.iconeBetaSeries.alpha = alphaLight }
        if (sugg.sources.contains(srcMovieDB))     { cell.iconeMovieDB.alpha = alphaFull }     else { cell.iconeMovieDB.alpha = alphaLight }
        
        if (affficheGraphe) {
            cell.graph.isHidden = false
        } else {
            cell.graph.isHidden = true
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    @IBAction func showGraphe(_ sender: Any) {
        affficheGraphe = !affficheGraphe
        
        viewCollection.reloadData()
        viewCollection.setNeedsDisplay()
    }
    
    
    @IBAction func trier(_ sender: Any) {
        let index : Int = (sender as! UISegmentedControl).selectedSegmentIndex
        
        switch index {
        case 0:
            displayedSeries = displayedSeries.sorted(by: { findSuggestion(serie: $0.serie).sources.count > findSuggestion(serie: $1.serie).sources.count })
            break
            
        case 1:
            displayedSeries = displayedSeries.sorted(by: { $0.getGlobalRating() > $1.getGlobalRating() })
            break

        case 2:
            displayedSeries = displayedSeries.sorted(by: { $0.year > $1.year })
            break
            
        case 3:
            displayedSeries = displayedSeries.sorted(by: { $0.serie < $1.serie })
            break
            
        default:
            return
        }
        
        viewCollection.reloadData()
        viewCollection.setNeedsDisplay()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellPropal = sender as! CellPropal
        
        viewController.serie = displayedSeries[tableCell.index]
        viewController.image = getImage(displayedSeries[tableCell.index].banner)
        viewController.modeAffichage = modeRecherche
    }
    
    
    func findSuggestion(serie: String) -> Suggestion {
        for uneSugg in allSuggestions {
            if (uneSugg.serie.uppercased() == serie.uppercased()) { return uneSugg}
        }
        
        return Suggestion()
    }
}
