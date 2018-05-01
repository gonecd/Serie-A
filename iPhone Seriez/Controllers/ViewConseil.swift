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
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var chooser: UISegmentedControl!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var roue: UIActivityIndicatorView!
    
    @IBOutlet weak var boutonSuivies: UIButton!
    @IBOutlet weak var boutonAbandons: UIButton!
    @IBOutlet weak var boutonInconnues: UIButton!
    @IBOutlet weak var boutonWatchlist: UIButton!
    
    var grapheType : Int = 0
    var accueil : ViewAccueil = ViewAccueil()
    var allShows : [Serie] = []
    var allConseils : [(serie : Serie, cpt : Int, category : Int)] = []
    var shortList : [Serie] = []
    var conseilsMinimum : Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graph.vue = self
        detail.isHidden = true

    }
    
    
    func selectTopConseils(minConseils : Int) -> [(serie : Serie, cpt : Int, category : Int)]
    {
        var selection : [(serie : Serie, cpt : Int, category : Int)] = []
        shortList = []

        for indexConseil in 0..<allConseils.count
        {
            if (allConseils[indexConseil].cpt > minConseils-1)
            {
                selection.append((serie: allConseils[indexConseil].serie, cpt: allConseils[indexConseil].cpt, category : allConseils[indexConseil].category))
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
        var categ : Int = 0
        
        // Si la série est-elle déjà dans la liste, on incrémente juste son compteur
        for indexConseil in 0..<allConseils.count
        {
            if (show == allConseils[indexConseil].serie.serie)
            {
                allConseils[indexConseil].cpt = allConseils[indexConseil].cpt + 1
                if ( (allConseils[indexConseil].category == categInconnues) && (allConseils[indexConseil].cpt == conseilsMinimum) )
                {
                    completeShowInfos(uneSerie: allConseils[indexConseil].serie)
                }
                return
            }
        }
        
        // Si la série est une série connue, on l'ajoute à la liste
        for uneSerie in allShows
        {
            if (uneSerie.serie == show)
            {
                if (uneSerie.unfollowed) { categ = categAbandonnees }
                else if (uneSerie.watchlist) { categ = categWatchlist }
                else { categ = categSuivies }
                
                allConseils.append((serie: uneSerie, cpt: 1, category : categ))

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
        categ = categInconnues
        
        if (conseilsMinimum == 1) { completeShowInfos(uneSerie: uneSerie) }
        allConseils.append((serie: uneSerie, cpt: 1, category : categ))
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

                self.poster.image = getImage(oneShow.poster)
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
        if (grapheType == 0)
        {
            grapheType = 1
            
            boutonSuivies.isHidden = false
            boutonWatchlist.isHidden = false
            boutonAbandons.isHidden = false
            boutonInconnues.isHidden = false
        }
        else
        {
            grapheType = 0

            boutonSuivies.isHidden = true
            boutonWatchlist.isHidden = true
            boutonAbandons.isHidden = true
            boutonInconnues.isHidden = true
        }
        
        self.graph.setType(type: grapheType)
        self.graph.setNeedsDisplay()
    }
    
    @IBAction func toggleCategory(_ sender: Any) {
        let myButton : UIButton = sender as! UIButton
        
        if (myButton == boutonSuivies) { self.graph.toggleCategory(category : categSuivies) }
        if (myButton == boutonWatchlist) { self.graph.toggleCategory(category : categWatchlist) }
        if (myButton == boutonAbandons) { self.graph.toggleCategory(category : categAbandonnees) }
        if (myButton == boutonInconnues) { self.graph.toggleCategory(category : categInconnues) }

        self.graph.setNeedsDisplay()
    }
    
    
    @IBAction func addToWatchList(_ sender: Any) {
        print("Adding to Watchlist")
    }
    
    @IBAction func closeDetails(_ sender: Any) {
        detail.isHidden = true
    }
    
    @IBAction func loadConseils(_ sender: Any)
    {
        self.roue.startAnimating()
        goButton.isHidden = true
        allConseils = []

        if (chooser.selectedSegmentIndex == 0)
        {
            // SIMILAR
            self.conseilsMinimum = 3
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
                    self.graph.sendSeries(liste : self.selectTopConseils(minConseils : self.conseilsMinimum), max : 10)
                    
                    DispatchQueue.main.async {
                        self.progressBar.setProgress(Float(numShow)/Float(nbShows), animated: true)
                        self.graph.setNeedsDisplay()
                    }
                }
                
                DispatchQueue.main.async {
                    self.progressBar.isHidden = true
                    self.goButton.isHidden = false
                    self.roue.stopAnimating()
                }
            }
        }
        else if (chooser.selectedSegmentIndex == 1)
        {
            // POPULAR
            self.conseilsMinimum = 1

            self.addShowsToListe(newShows : self.accueil.trakt.getPopularShows(), idType : "IMDB")
            self.addShowsToListe(newShows : self.accueil.theMoviedb.getPopularShows(), idType : "MovieDB")
            self.addShowsToListe(newShows : self.accueil.betaSeries.getPopularShows(), idType : "TVDB")

            self.graph.sendSeries(liste : self.selectTopConseils(minConseils : self.conseilsMinimum), max : 3)
            self.graph.setNeedsDisplay()
            self.goButton.isHidden = false
            self.roue.stopAnimating()
        }
        else
        {
            // TRENDING
            self.conseilsMinimum = 1

            self.addShowsToListe(newShows : self.accueil.trakt.getTrendingShows(), idType : "IMDB")
            self.addShowsToListe(newShows : self.accueil.theMoviedb.getTrendingShows(), idType : "MovieDB")
            self.addShowsToListe(newShows : self.accueil.betaSeries.getTrendingShows(), idType : "TVDB")
            
            self.graph.sendSeries(liste : self.selectTopConseils(minConseils : self.conseilsMinimum), max : 3)
            self.graph.setNeedsDisplay()
            self.goButton.isHidden = false
            self.roue.stopAnimating()
        }
    }
    
}
