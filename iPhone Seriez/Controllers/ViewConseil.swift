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
    
    var grapheType : Int = 0
    var accueil : ViewAccueil = ViewAccueil()
    var allShows : [Serie] = []
    var allConseils : [Serie] = []
    var shortList : [Serie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        graph.accueil = accueil
        graph.vue = self
        detail.isHidden = true

        for oneShow in allShows
        {
            if(oneShow.unfollowed)
            {
                addShowsToListe(newShows : self.accueil.trakt.getSimilarShows(IMDBid: oneShow.idIMdb), idType : "IMDB")
                addShowsToListe(newShows : self.accueil.theMoviedb.getSimilarShows(movieDBid: oneShow.idMoviedb), idType : "MovieDB")
                addShowsToListe(newShows : self.accueil.betaSeries.getSimilarShows(TVDBid: oneShow.idTVdb), idType : "TVDB")
            }
        }
        
        graph.sendSeries(liste : selectTopConseils(minConseils : 3))
        
    }
    
    
    func selectTopConseils(minConseils : Int) -> [(serie : Serie, cpt : Int)]
    {
        var aggListe : [(serie : Serie, cpt : Int)] = []
        var returnListe : [(serie : Serie, cpt : Int)] = []
        shortList = []
        var found : Bool = false
        
        for oneShow in allConseils
        {
            found = false
            
            for index in 0..<aggListe.count
            {
                if (oneShow.serie == aggListe[index].serie.serie)
                {
                    aggListe[index].cpt = aggListe[index].cpt + 1
                    found = true
                    continue
                }
            }
            
            if (found == false)
            {
                aggListe.append((serie: oneShow, cpt: 1))
            }
        }
        
        
        for index in 0..<aggListe.count
        {
            if (aggListe[index].cpt > minConseils-1)
            {
                print(" ==> \(aggListe[index].cpt) propositions for \(aggListe[index].serie.serie)")
                found = false
                for uneSerie in allShows
                {
                    if (uneSerie.serie == aggListe[index].serie.serie)
                    {
                        aggListe[index].serie = uneSerie
                        found = true
                        continue
                    }
                }
                
                if (found == false)
                {
                    print("Il faut loader \(aggListe[index].serie.serie)")

                    var dataTVdb : Serie = Serie(serie: "")
                    var dataMoviedb : Serie = Serie(serie: "")
                    var dataBetaSeries : Serie = Serie(serie: "")
                    var dataTrakt : Serie = Serie(serie: "")
                    var dataIMDB : Serie = Serie(serie: "")

                    if (aggListe[index].serie.idIMdb != "")
                    {
                        print("Completing info using idIMdb")
                        dataTrakt = self.accueil.trakt.getSerieGlobalInfos(idTraktOrIMDB: aggListe[index].serie.idIMdb)
                        dataMoviedb = self.accueil.theMoviedb.getSerieGlobalInfos(idMovieDB: dataTrakt.idMoviedb)
                        dataBetaSeries = self.accueil.betaSeries.getSerieGlobalInfos(idTVDB : dataTrakt.idTVdb, idIMDB : aggListe[index].serie.idIMdb)
                        dataTVdb = self.accueil.theTVdb.getSerieGlobalInfos(idTVdb : dataTrakt.idTVdb)
                        dataIMDB = self.accueil.imdb.getSerieGlobalInfos(idIMDB: dataTrakt.idMoviedb)

                    } else if (aggListe[index].serie.idMoviedb != "")
                    {
                        print("Completing info using idMoviedb")
                        dataMoviedb = self.accueil.theMoviedb.getSerieGlobalInfos(idMovieDB: aggListe[index].serie.idMoviedb)
                        dataTrakt = self.accueil.trakt.getSerieGlobalInfos(idTraktOrIMDB: dataMoviedb.idIMdb)
                        dataBetaSeries = self.accueil.betaSeries.getSerieGlobalInfos(idTVDB : dataMoviedb.idTVdb, idIMDB : dataMoviedb.idIMdb)
                        dataTVdb = self.accueil.theTVdb.getSerieGlobalInfos(idTVdb : dataMoviedb.idTVdb)
                        dataIMDB = self.accueil.imdb.getSerieGlobalInfos(idIMDB: dataMoviedb.idIMdb)

                    } else if (aggListe[index].serie.idTVdb != "")
                    {
                        print("Completing info using idTVdb")
                        dataTVdb = self.accueil.theTVdb.getSerieGlobalInfos(idTVdb : aggListe[index].serie.idTVdb)
                        dataBetaSeries = self.accueil.betaSeries.getSerieGlobalInfos(idTVDB : aggListe[index].serie.idTVdb, idIMDB : dataTVdb.idIMdb)
                        dataTrakt = self.accueil.trakt.getSerieGlobalInfos(idTraktOrIMDB: dataTVdb.idIMdb)
                        aggListe[index].serie.idMoviedb = dataTrakt.idMoviedb
                        dataMoviedb = self.accueil.theMoviedb.getSerieGlobalInfos(idMovieDB: dataTrakt.idMoviedb)
                        dataIMDB = self.accueil.imdb.getSerieGlobalInfos(idIMDB: dataTVdb.idIMdb)

                    }

                    aggListe[index].serie.cleverMerge(TVdb: dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB)
                    
                    // On ne prend que les séries inconnues
                    returnListe.append((serie: aggListe[index].serie, cpt: aggListe[index].cpt))
                    shortList.append(aggListe[index].serie)
                }
            }
        }
        
        print("Coucou")
        return returnListe
    }
    
    func addShowsToListe(newShows : (names : [String], ids : [String]), idType : String)
    {
        for index in 0..<newShows.names.count
        {
            let uneSerie : Serie = Serie(serie: newShows.names[index])
            switch (idType)
            {
            case "IMDB":
                uneSerie.idIMdb = newShows.ids[index]
                uneSerie.idTrakt = newShows.ids[index]

            case "TVDB":
                uneSerie.idTVdb = newShows.ids[index]

            case "MovieDB":
                uneSerie.idMoviedb = newShows.ids[index]

            default:
                print("ViewConseil::addShowsToListe Type inconnu : \(idType)")
            }
            allConseils.append(uneSerie)
        }
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
                
                continue
            }
        }
        
        detail.isHidden = false

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
