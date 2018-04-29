//
//  ViewConseil.swift
//  SerieA
//
//  Created by Cyril Delamare on 21/04/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class ViewConseil: UIViewController {
    
    @IBOutlet weak var graph: GraphConseil!
    
    @IBOutlet weak var detail: UIView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var minigraphe: GraphMiniSerie!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var globalRating: UITextField!
    @IBOutlet weak var genres: UITextView!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var drapeau: UIImageView!
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var resume: UITextView!
    
    @IBOutlet weak var boutonWatchlist: UIButton!
    @IBOutlet weak var boutonClose: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var grapheType : Int = 0
    var accueil : ViewAccueil = ViewAccueil()
    var allShows : [Serie] = []
    var allConseils : [(serie : Serie, cpt : Int)] = []
    var shortList : [Serie] = []
    var conseilsMinimum : Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graph.accueil = accueil
        graph.vue = self
        detail.isHidden = true

        progressBar.setProgress(0.0, animated: false)
        progressBar.isHidden = false
        

        DispatchQueue.global(qos: .utility).async {
            
            let nbShows: Int = self.allShows.count
            //let nbShows: Int = 25
            var numShow : Int = 0
            
            //for oneShow in self.allShows
            for index in 0..<nbShows
            {
                if ( (self.allShows[index].unfollowed == false) &&
                    (self.allShows[index].watchlist == false) &&
                    ((self.allShows[index].saisons[self.allShows[index].saisons.count - 1].watched == false) || (self.allShows[index].status != "Ended")))
                {
                    self.addShowsToListe(newShows : self.accueil.trakt.getSimilarShows(IMDBid: self.allShows[index].idIMdb), idType : "IMDB")
                    self.addShowsToListe(newShows : self.accueil.theMoviedb.getSimilarShows(movieDBid: self.allShows[index].idMoviedb), idType : "MovieDB")
                    self.addShowsToListe(newShows : self.accueil.betaSeries.getSimilarShows(TVDBid: self.allShows[index].idTVdb), idType : "TVDB")
                }
                
                numShow = numShow + 1
                self.graph.sendSeries(liste : self.selectTopConseils(minConseils : self.conseilsMinimum))

                DispatchQueue.main.async {
                        self.progressBar.setProgress(Float(numShow)/Float(nbShows), animated: true)
                        self.graph.setNeedsDisplay()
                }
            }
            
            DispatchQueue.main.async { self.progressBar.isHidden = true }
        }
    }
    
    
    func selectTopConseils(minConseils : Int) -> [(serie : Serie, cpt : Int)]
    {
        var selection : [(serie : Serie, cpt : Int)] = []
        shortList = []

        for indexConseil in 0..<allConseils.count
        {
            if (allConseils[indexConseil].cpt > minConseils-1)
            {
                selection.append((serie: allConseils[indexConseil].serie, cpt: allConseils[indexConseil].cpt))
                shortList.append(allConseils[indexConseil].serie)
            }
        }
        
        return selection
    }
    
    
    func completeShowInfos(uneSerie : Serie)
    {
        var dataTVdb : Serie = Serie(serie: "")
        var dataMoviedb : Serie = Serie(serie: "")
        var dataBetaSeries : Serie = Serie(serie: "")
        var dataTrakt : Serie = Serie(serie: "")
        var dataIMDB : Serie = Serie(serie: "")
        
        print("Loading infos for \(uneSerie.serie)")
        
        if (uneSerie.idIMdb != "")
        {
            dataTrakt = self.accueil.trakt.getSerieGlobalInfos(idTraktOrIMDB: uneSerie.idIMdb)
            dataMoviedb = self.accueil.theMoviedb.getSerieGlobalInfos(idMovieDB: dataTrakt.idMoviedb)
            dataBetaSeries = self.accueil.betaSeries.getSerieGlobalInfos(idTVDB : dataTrakt.idTVdb, idIMDB : uneSerie.idIMdb)
            dataTVdb = self.accueil.theTVdb.getSerieGlobalInfos(idTVdb : dataTrakt.idTVdb)
            dataIMDB = self.accueil.imdb.getSerieGlobalInfos(idIMDB: uneSerie.idIMdb)
            
        } else if (uneSerie.idMoviedb != "")
        {
            dataMoviedb = self.accueil.theMoviedb.getSerieGlobalInfos(idMovieDB: uneSerie.idMoviedb)
            dataTrakt = self.accueil.trakt.getSerieGlobalInfos(idTraktOrIMDB: dataMoviedb.idIMdb)
            dataBetaSeries = self.accueil.betaSeries.getSerieGlobalInfos(idTVDB : dataMoviedb.idTVdb, idIMDB : dataMoviedb.idIMdb)
            dataTVdb = self.accueil.theTVdb.getSerieGlobalInfos(idTVdb : dataMoviedb.idTVdb)
            dataIMDB = self.accueil.imdb.getSerieGlobalInfos(idIMDB: dataMoviedb.idIMdb)
            
        } else if (uneSerie.idTVdb != "")
        {
            dataTVdb = self.accueil.theTVdb.getSerieGlobalInfos(idTVdb : uneSerie.idTVdb)
            dataBetaSeries = self.accueil.betaSeries.getSerieGlobalInfos(idTVDB : uneSerie.idTVdb, idIMDB : dataTVdb.idIMdb)
            dataTrakt = self.accueil.trakt.getSerieGlobalInfos(idTraktOrIMDB: dataTVdb.idIMdb)
            uneSerie.idMoviedb = dataTrakt.idMoviedb
            dataMoviedb = self.accueil.theMoviedb.getSerieGlobalInfos(idMovieDB: dataTrakt.idMoviedb)
            dataIMDB = self.accueil.imdb.getSerieGlobalInfos(idIMDB: dataTVdb.idIMdb)
            
        }
        
        uneSerie.cleverMerge(TVdb: dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB)
    }
    
    
    func addShowsToListe(newShows : (names : [String], ids : [String]), idType : String)
    {
        for index in 0..<newShows.names.count
        {
            addOneShow(show: newShows.names[index], id: newShows.ids[index], idType: idType)
        }
    }
    
    func addOneShow(show : String, id : String, idType : String)
    {
        // Si la série est une série connue, on l'ignore
        for uneSerie in allShows { if (uneSerie.serie == show) { return } }
        
        // Si la série est-elle déjà dans la liste, on incrémente juste son compteur
        for indexConseil in 0..<allConseils.count
        {
            if (show == allConseils[indexConseil].serie.serie)
            {
                allConseils[indexConseil].cpt = allConseils[indexConseil].cpt + 1
                if (allConseils[indexConseil].cpt == conseilsMinimum)
                {
                    completeShowInfos(uneSerie: allConseils[indexConseil].serie)
                }
                return
            }
        }
        
        // Sinon on l'ajoute à la liste
        let uneSerie : Serie = Serie(serie: show)
        switch (idType)
        {
        case "IMDB":
            uneSerie.idIMdb = id
            uneSerie.idTrakt = id
            
        case "TVDB":
            uneSerie.idTVdb = id
            
        case "MovieDB":
            uneSerie.idMoviedb = id
            
        default:
            print("ViewConseil::addShowsToListe Type inconnu : \(idType)")
        }
        
        allConseils.append((serie: uneSerie, cpt: 1))
    }
    
    func showDetails(serie : String)
    {
        for oneShow in shortList
        {
            if (oneShow.serie == serie)
            {
                self.titre.text = oneShow.serie
                self.saison.text =  String(oneShow.nbSaisons) + " Saisons - " + String(oneShow.nbEpisodes) + " Epiosdes - " + String(oneShow.runtime) + " min"
                self.resume.text = oneShow.resume

                self.poster.image = self.accueil.getImage(oneShow.poster)
                self.globalRating.text = String(oneShow.getGlobalRating()) + " %"
                arrondir(texte: self.globalRating, radius: 12.0)

                // Affichage des genres
                var allGenres : String = ""
                for unGenre in oneShow.genres
                {
                    allGenres = allGenres + unGenre + " "
                }
                self.genres.text = allGenres
                
                // Affichage du status
                arrondir(texte: self.status, radius: 8.0)
                if (oneShow.status == "Ended")
                {
                    self.status.text = "FINIE"
                    self.status.textColor = UIColor.black
                }
                else
                {
                    self.status.text = "EN COURS"
                    self.status.textColor = UIColor.blue
                }
                
                // Affichage du drapeau
                self.drapeau.image = getDrapeau(country: oneShow.country)
                
                // Affichage du mini graphe
                self.minigraphe.sendNotes(rateTrakt: oneShow.getFairGlobalRatingTrakt(),
                                          rateTVdb: oneShow.getFairGlobalRatingTVdb(),
                                          rateBetaSeries: oneShow.getFairGlobalRatingBetaSeries(),
                                          rateMoviedb: oneShow.getFairGlobalRatingMoviedb(),
                                          rateIMdb: oneShow.getFairGlobalRatingIMdb())
                self.minigraphe.setType(type: 0)
                self.minigraphe.setNeedsDisplay()
                
                detail.isHidden = false

                return
            }
        }
    }
    
    
    @IBAction func changeType(_ sender: Any) {
        if (grapheType == 0) { grapheType = 1 }
        else { grapheType = 0 }
        
        self.graph.setType(type: grapheType)
        self.graph.setNeedsDisplay()
    }
    
    @IBAction func addToWatchList(_ sender: Any) {
        print("Adding to Watchlist")
    }
    
    @IBAction func closeDetails(_ sender: Any) {
        detail.isHidden = true
    }
    
    
}
