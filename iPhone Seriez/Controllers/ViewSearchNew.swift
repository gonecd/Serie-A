

//
//  ViewSearchNew.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 05/05/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class ViewSearchNew: UIViewController
{
    
    @IBOutlet weak var recherche: UITextField!
//    @IBOutlet weak var advanced: UIView!
    
    var seriesTrouvees : [Serie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        makeGradiant(carre: advanced, couleur : "Gris")
    }
    
    
    @IBAction func chercher(_ sender: Any) {
        if (recherche.text!.count > 2) {
            let searchString : String = recherche.text!
            
            var dataTrakt       : [Serie] = []
            var dataBetaSeries  : [Serie] = []
            var dataTheMovieDB  : [Serie] = []
            var dataTVMaze      : [Serie] = []
            
            let queue : OperationQueue = OperationQueue()
            
            queue.addOperation(BlockOperation(block: { dataBetaSeries = betaSeries.rechercheParTitre(serieArechercher: searchString) } ))
            queue.addOperation(BlockOperation(block: { dataTheMovieDB = theMoviedb.rechercheParTitre(serieArechercher: searchString) } ))
            queue.addOperation(BlockOperation(block: { dataTVMaze = tvMaze.rechercheParTitre(serieArechercher: searchString) } ))
            queue.addOperation(BlockOperation(block: { dataTrakt = trakt.rechercheParTitre(serieArechercher: searchString) } ))
            
            queue.waitUntilAllOperationsAreFinished()
            
            seriesTrouvees = mergeResults(dataTrakt: dataTrakt, dataBetaSeries: dataBetaSeries, dataTheMovieDB: dataTheMovieDB, dataTVMaze: dataTVMaze)
            performSegue(withIdentifier: "showSearchResults", sender: nil)
        }
    }
    
    
    func mergeResults(dataTrakt :[Serie], dataBetaSeries :[Serie], dataTheMovieDB :[Serie], dataTVMaze :[Serie]) -> [Serie] {
        var result : [Serie] = []
        var traitees : [String] = []
        
        // Merge series found by Trakt
        for uneSerieTrakt in dataTrakt {
            let uneSerie : Serie = Serie(serie: "")
            
            let emptySerie :Serie = Serie(serie:uneSerieTrakt.serie)
            var uneSerieBetaSeries : Serie = emptySerie
            var uneSerieMovieDB : Serie = emptySerie
            var uneSerieTVMaze : Serie = emptySerie
            var uneSerieIMDB : Serie = emptySerie
            uneSerieIMDB = imdb.getSerieGlobalInfos(idIMDB: uneSerieTrakt.idIMdb)
            
            for i in 0..<dataBetaSeries.count { if (uneSerieTrakt.idIMdb == dataBetaSeries[i].idIMdb) { uneSerieBetaSeries = dataBetaSeries[i]; break; } }
            for i in 0..<dataTheMovieDB.count { if (uneSerieTrakt.idMoviedb == dataTheMovieDB[i].idMoviedb) { uneSerieMovieDB = dataTheMovieDB[i]; break; } }
            for i in 0..<dataTVMaze.count { if (uneSerieTrakt.idIMdb == dataTVMaze[i].idIMdb) { uneSerieTVMaze = dataTVMaze[i]; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: uneSerieTrakt, BetaSeries: uneSerieBetaSeries,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie,
                                 AlloCine: emptySerie, SensCritique: emptySerie, SIMKL: emptySerie)

            traitees.append(uneSerie.serie)
            result.append(uneSerie)
        }
        
        // Adding series from BetaSeries
        for uneSerieBetaSeries in dataBetaSeries {
            if traitees.contains(uneSerieBetaSeries.serie) { continue }
            
            let uneSerie : Serie = Serie(serie: "")
            
            let emptySerie :Serie = Serie(serie:uneSerieBetaSeries.serie)
            var uneSerieMovieDB : Serie = emptySerie
            var uneSerieTVMaze : Serie = emptySerie
            var uneSerieIMDB : Serie = emptySerie
            uneSerieIMDB = imdb.getSerieGlobalInfos(idIMDB: uneSerieBetaSeries.idIMdb)
            
            for i in 0..<dataTheMovieDB.count { if (uneSerieBetaSeries.serie == dataTheMovieDB[i].serie) { uneSerieMovieDB = dataTheMovieDB[i]; break; } }
            for i in 0..<dataTVMaze.count { if (uneSerieBetaSeries.idIMdb == dataTVMaze[i].idIMdb) { uneSerieTVMaze = dataTVMaze[i]; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: emptySerie, BetaSeries: uneSerieBetaSeries,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie,
                                 AlloCine: emptySerie, SensCritique: emptySerie, SIMKL: emptySerie)
            
            traitees.append(uneSerie.serie)
            result.append(uneSerie)
        }
        
        // Adding series from TVMaze
        for uneSerieTVMaze in dataTVMaze {
            if traitees.contains(uneSerieTVMaze.serie) { continue }
            
            let uneSerie : Serie = Serie(serie: "")
            
            let emptySerie :Serie = Serie(serie:uneSerieTVMaze.serie)
            var uneSerieMovieDB : Serie = emptySerie
            var uneSerieIMDB : Serie = emptySerie
            uneSerieIMDB = imdb.getSerieGlobalInfos(idIMDB: uneSerieTVMaze.idIMdb)
            
            for i in 0..<dataTheMovieDB.count { if (uneSerieTVMaze.serie == dataTheMovieDB[i].serie) { uneSerieMovieDB = dataTheMovieDB[i]; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: emptySerie, BetaSeries: emptySerie,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie,
                                 AlloCine: emptySerie, SensCritique: emptySerie, SIMKL: emptySerie)
            
            traitees.append(uneSerie.serie)
            result.append(uneSerie)
        }
        
        // Adding series from MovieDB
        for uneSerieMovieDB in dataTheMovieDB {
            if traitees.contains(uneSerieMovieDB.serie) { continue }
            result.append(uneSerieMovieDB)
        }
        
        return Array(result.sorted(by: { ($0.ratingTrakt + $0.ratingBetaSeries + $0.ratingMovieDB + $0.ratingTVmaze) > ($1.ratingTrakt + $1.ratingBetaSeries + $1.ratingMovieDB + $1.ratingTVmaze) }).prefix(12))
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (seriesTrouvees != [] && segue.identifier == "showSearchResults") {
            let viewController = segue.destination as! ViewSerieListe
            
            viewController.title = "Propositions de séries"
            viewController.viewList = seriesTrouvees
            viewController.modeAffichage = modeRecherche
        }
    }
    
}

