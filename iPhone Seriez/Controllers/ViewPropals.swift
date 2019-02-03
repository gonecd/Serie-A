//
//  ViewPropals.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 10/11/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit


class CellPropal : UICollectionViewCell {
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var statusView: UIView!

    var index: Int = 0
}


class ViewPropals: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var boutonStop: UIView!
    @IBOutlet weak var boutonEncours: UIView!
    @IBOutlet weak var boutonWatchlist: UIView!
    @IBOutlet weak var boutonAbandon: UIView!
    
    @IBOutlet weak var viewChooser: UIView!
    @IBOutlet weak var viewBandeau: UIView!
    @IBOutlet weak var viewCollection: UICollectionView!
    
    @IBOutlet weak var sourceTrakt: UIImageView!
    @IBOutlet weak var sourceBetaSeries: UIImageView!
    @IBOutlet weak var sourceMovieDB: UIImageView!
    @IBOutlet weak var critere: UILabel!
    
    @IBOutlet weak var toggleTrakt: UISwitch!
    @IBOutlet weak var toggleBetaSeries: UISwitch!
    @IBOutlet weak var toggleMovieDB: UISwitch!
    @IBOutlet weak var critereChooser: UISegmentedControl!
    
    
    var allConseils : [(serie : Serie, category : Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBandeau.isHidden = true
        viewCollection.isHidden = true
        viewChooser.isHidden = false
        
        makeMiniGradiant(carre: boutonStop, couleur : "Gris")
        makeMiniGradiant(carre: boutonEncours, couleur : "Bleu")
        makeMiniGradiant(carre: boutonWatchlist, couleur : "Vert")
        makeMiniGradiant(carre: boutonAbandon, couleur : "Rouge")
    }
    
    
    @IBAction func searchForPropositions(_ sender: Any) {
        switch (critereChooser.selectedSegmentIndex)
        {
        case 0: critere.text = "les meilleures notes"
        case 1: critere.text = "les plus actives"
        case 2: critere.text = "proches de mes séries"
        default: critere.text = "aucun"
        }
        
        if (toggleTrakt.isOn) {
            sourceTrakt.isHidden = false
            
            switch (critereChooser.selectedSegmentIndex) {
            case 0: self.addShowsToListe(newShows : trakt.getPopularShows(), idType : "IMDB")
            case 1: self.addShowsToListe(newShows : trakt.getTrendingShows(), idType : "IMDB")
            case 2: print("Error")
            default: print("Error")
            }
        }
        else {
            sourceTrakt.isHidden = true
        }
        
        if (toggleMovieDB.isOn) {
            sourceMovieDB.isHidden = false
            
            switch (critereChooser.selectedSegmentIndex) {
            case 0: self.addShowsToListe(newShows : theMoviedb.getPopularShows(), idType : "MovieDB")
            case 1: self.addShowsToListe(newShows : theMoviedb.getTrendingShows(), idType : "MovieDB")
            case 2: print("Error")
            default: print("Error")
            }
        }
        else {
            sourceMovieDB.isHidden = true
        }
        
        if (toggleBetaSeries.isOn) {
            sourceBetaSeries.isHidden = false
            
            switch (critereChooser.selectedSegmentIndex) {
            case 0: self.addShowsToListe(newShows : betaSeries.getPopularShows(), idType : "TVDB")
            case 1: self.addShowsToListe(newShows : betaSeries.getTrendingShows(), idType : "TVDB")
            case 2: print("Error")
            default: print("Error")
            }
        }
        else {
            sourceBetaSeries.isHidden = true
        }
        
        viewBandeau.isHidden = false
        viewCollection.isHidden = false
        viewChooser.isHidden = true
        
        allConseils = allConseils.sorted(by: { $0.serie.getGlobalRating() > $1.serie.getGlobalRating() })
        
        viewCollection.reloadData()
        viewCollection.setNeedsDisplay()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allConseils.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellPropal", for: indexPath as IndexPath) as! CellPropal
        
        cell.poster.image = getImage(allConseils[indexPath.row].serie.poster)
        cell.note.text = String(allConseils[indexPath.row].serie.getGlobalRating()) + " %"
        arrondir(texte: cell.note, radius: 6.0)
        cell.index = indexPath.row
        
        if (allConseils[indexPath.row].category == categSuivies) {
            if (allConseils[indexPath.row].serie.saisons.count > 0) {
                if ( (allConseils[indexPath.row].serie.saisons[allConseils[indexPath.row].serie.saisons.count - 1].watched() == true) && (allConseils[indexPath.row].serie.status == "Ended") ) {
                    cell.status.image = #imageLiteral(resourceName: "Stop-icon.png")
                    makeMiniGradiant(carre: cell.statusView, couleur : "Gris")
                }
                else {
                    cell.status.image = #imageLiteral(resourceName: "Play-icon.png")
                    makeMiniGradiant(carre: cell.statusView, couleur : "Bleu")
                }
            }
        }
        else if (allConseils[indexPath.row].category == categAbandonnees) {
            cell.status.image = #imageLiteral(resourceName: "Trash-icon.png")
            makeMiniGradiant(carre: cell.statusView, couleur : "Rouge")
        }
        else if (allConseils[indexPath.row].category == categWatchlist) {
            cell.status.image = #imageLiteral(resourceName: "List-icon.png")
            makeMiniGradiant(carre: cell.statusView, couleur : "Vert")
        }
        else {
            cell.statusView.isHidden = true
        }
        
        cell.statusView.setNeedsLayout()
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    func addShowsToListe(newShows : (names : [String], ids : [String]), idType : String) {
        for index in 0..<newShows.names.count {
            addOneShow(show: newShows.names[index], id: newShows.ids[index], idType: idType)
        }
    }
    
    func addOneShow(show : String, id : String, idType : String) {
        var categ : Int = 0
        
        // Si la série est-elle déjà dans la liste, on fait rien
        for indexConseil in 0..<allConseils.count {
            if (show == allConseils[indexConseil].serie.serie) {
                return
            }
        }
        
        // Si la série est une série connue, on l'ajoute à la liste
        for uneSerie in db.shows {
            if (uneSerie.serie == show) {
                if (uneSerie.unfollowed) { categ = categAbandonnees }
                else if (uneSerie.watchlist) { categ = categWatchlist }
                else { categ = categSuivies }
                
                allConseils.append((serie: uneSerie, category : categ))
                
                return
            }
        }
        
        // Sinon on l'ajoute à la liste
        let uneSerie : Serie = Serie(serie: show)
        switch (idType) {
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
        
        completeShowInfos(uneSerie: uneSerie)
        
        if (!uneSerie.genres.contains("Documentary") && !uneSerie.genres.contains("Animation")) {
            allConseils.append((serie: uneSerie, category : categ))
        }
        else {
            print("FILTRAGE DE \(uneSerie.serie) : \(uneSerie.genres)")
        }
    }
    
    
    func completeShowInfos(uneSerie : Serie) {
        var dataTVdb : Serie = Serie(serie: "")
        var dataMoviedb : Serie = Serie(serie: "")
        var dataBetaSeries : Serie = Serie(serie: "")
        var dataTrakt : Serie = Serie(serie: "")
        var dataIMDB : Serie = Serie(serie: "")
        var dataRotten : Serie = Serie(serie: "")
        var dataTVmaze : Serie = Serie(serie: "")

        if (uneSerie.idIMdb != "") {
            dataTrakt = trakt.getSerieGlobalInfos(idTraktOrIMDB: uneSerie.idIMdb)
            dataMoviedb = theMoviedb.getSerieGlobalInfos(idMovieDB: dataTrakt.idMoviedb)
            dataBetaSeries = betaSeries.getSerieGlobalInfos(idTVDB : dataTrakt.idTVdb, idIMDB : uneSerie.idIMdb)
            dataTVdb = theTVdb.getSerieGlobalInfos(idTVdb : dataTrakt.idTVdb)
            dataIMDB = imdb.getSerieGlobalInfos(idIMDB: uneSerie.idIMdb)
            dataTVmaze = tvMaze.getSerieGlobalInfos(idTVDB : dataTrakt.idTVdb, idIMDB : uneSerie.idIMdb)
            dataRotten = rottenTomatoes.getSerieGlobalInfos(serie : uneSerie.serie)
        }
        else if (uneSerie.idMoviedb != "") {
            dataMoviedb = theMoviedb.getSerieGlobalInfos(idMovieDB: uneSerie.idMoviedb)
            dataTrakt = trakt.getSerieGlobalInfos(idTraktOrIMDB: dataMoviedb.idIMdb)
            dataBetaSeries = betaSeries.getSerieGlobalInfos(idTVDB : dataMoviedb.idTVdb, idIMDB : dataMoviedb.idIMdb)
            dataTVdb = theTVdb.getSerieGlobalInfos(idTVdb : dataMoviedb.idTVdb)
            dataIMDB = imdb.getSerieGlobalInfos(idIMDB: dataMoviedb.idIMdb)
            dataTVmaze = tvMaze.getSerieGlobalInfos(idTVDB : dataMoviedb.idTVdb, idIMDB : dataMoviedb.idIMdb)
            dataRotten = rottenTomatoes.getSerieGlobalInfos(serie : uneSerie.serie)
        }
        else if (uneSerie.idTVdb != "") {
            dataTVdb = theTVdb.getSerieGlobalInfos(idTVdb : uneSerie.idTVdb)
            dataBetaSeries = betaSeries.getSerieGlobalInfos(idTVDB : uneSerie.idTVdb, idIMDB : dataTVdb.idIMdb)
            dataTrakt = trakt.getSerieGlobalInfos(idTraktOrIMDB: dataTVdb.idIMdb)
            uneSerie.idMoviedb = dataTrakt.idMoviedb
            dataMoviedb = theMoviedb.getSerieGlobalInfos(idMovieDB: dataTrakt.idMoviedb)
            dataIMDB = imdb.getSerieGlobalInfos(idIMDB: dataTVdb.idIMdb)
            dataTVmaze = tvMaze.getSerieGlobalInfos(idTVDB : uneSerie.idTVdb, idIMDB : dataTVdb.idIMdb)
            dataRotten = rottenTomatoes.getSerieGlobalInfos(serie : uneSerie.serie)
        }
        
        uneSerie.cleverMerge(TVdb: dataTVdb, Moviedb: dataMoviedb, Trakt: dataTrakt, BetaSeries: dataBetaSeries, IMDB: dataIMDB, RottenTomatoes: dataRotten, TVmaze: dataTVmaze)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellPropal = sender as! CellPropal
        viewController.serie = allConseils[tableCell.index].serie
        viewController.image = getImage(allConseils[tableCell.index].serie.banner)
    }
}
