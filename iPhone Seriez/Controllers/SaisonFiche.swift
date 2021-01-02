//
//  SaisonFiche.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import SeriesCommon

class CellEpisode: UITableViewCell {
    @IBOutlet weak var numero: UILabel!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var vu: UIImageView!
}



class SaisonFiche: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var saison : Int = 0
    var allCritics : [Critique] = []

    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: GraphSaison!
    @IBOutlet weak var episodesList: UITableView!
    @IBOutlet weak var criticList: UITableView!

    @IBOutlet weak var labelEpisodes: UILabel!
    @IBOutlet weak var labelCritiques: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saison " + String(saison)
        
        banniere.image = image
        self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
        graphe.setNeedsDisplay()
        
        //killtvdb theTVdb.getEpisodesDetailsAndRating(uneSerie: serie)
        trakt.getEpisodes(uneSerie: serie)

        for unEpisode in serie.saisons[saison-1].episodes {
            if ((unEpisode.idIMdb) == "" && (unEpisode.date.compare(Date()) == .orderedAscending)) {
                unEpisode.idIMdb = imdb.getEpisodeID(serieID: serie.idIMdb, saison: saison, episode: unEpisode.episode)
                if (unEpisode.idIMdb == "") { print("No IMDB id for \(serie.serie) saison: \(saison) episode: \(unEpisode.episode)") }
            }
        }
        
        arrondirLabel(texte: labelEpisodes, radius: 10)
        arrondirLabel(texte: labelCritiques, radius: 10)

        let queue : OperationQueue = OperationQueue()

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let opeCritics = BlockOperation(block: {
                self.allCritics.append(contentsOf: rottenTomatoes.getCritics(serie: self.serie.serie, saison: self.saison))
                OperationQueue.main.addOperation({
                    self.criticList.reloadData()
                    self.criticList.setNeedsLayout()
                } )
                
                self.allCritics.append(contentsOf: metaCritic.getCritics(serie: self.serie.serie, saison: self.saison))
                OperationQueue.main.addOperation({
                    self.criticList.reloadData()
                    self.criticList.setNeedsLayout()
                } )
            } )
            queue.addOperation(opeCritics)
        }
        
        let opeLoadBetaSeries = BlockOperation(block: {
            if (self.serie.idTVdb != "") { betaSeries.getEpisodesRatings(self.serie) }
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            OperationQueue.main.addOperation({ self.graphe.setNeedsDisplay() } )
        } )
        queue.addOperation(opeLoadBetaSeries)

        let opeLoadMovieDB = BlockOperation(block: {
            if (self.serie.idMoviedb != "") { theMoviedb.getEpisodesRatings(self.serie) }
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            OperationQueue.main.addOperation({ self.graphe.setNeedsDisplay() } )
        } )
        queue.addOperation(opeLoadMovieDB)

        let opeLoadIMDB = BlockOperation(block: {
            imdb.getEpisodesRatings(self.serie)
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            OperationQueue.main.addOperation({ self.graphe.setNeedsDisplay() } )
        } )
        queue.addOperation(opeLoadIMDB)

// killtvdb       let opeLoadTrakt = BlockOperation(block: {
//            if (self.serie.idTrakt != "") { trakt.getEpisodesRatings(self.serie) }
//            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
//            OperationQueue.main.addOperation({ self.graphe.setNeedsDisplay() } )
//        } )
//        queue.addOperation(opeLoadTrakt)
        
        let opeLoadTVmaze = BlockOperation(block: {
            tvMaze.getEpisodesRatings(self.serie)
        } )
        queue.addOperation(opeLoadTVmaze)
        
        let opeLoadRottenT = BlockOperation(block: {
            rottenTomatoes.getEpisodesRatings(self.serie)
        } )
        queue.addOperation(opeLoadRottenT)

        let opeLoadMetaCritic = BlockOperation(block: {
            metaCritic.getEpisodesRatings(self.serie)
        } )
        queue.addOperation(opeLoadMetaCritic)

        let opeFinalise = BlockOperation(block: {
            db.saveDB()
        } )
        opeFinalise.addDependency(opeLoadBetaSeries)
        opeFinalise.addDependency(opeLoadMovieDB)
        opeFinalise.addDependency(opeLoadIMDB)
// killtvdb       opeFinalise.addDependency(opeLoadTrakt)
        opeFinalise.addDependency(opeLoadTVmaze)
        opeFinalise.addDependency(opeLoadRottenT)
        opeFinalise.addDependency(opeLoadMetaCritic)
        queue.addOperation(opeFinalise)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! EpisodeFiche
        let collectionCell : CellEpisode = sender as! CellEpisode
        viewController.serie = serie
        viewController.saison = saison
        viewController.image = image
        viewController.episode = Int(collectionCell.numero.text!)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == episodesList) { return serie.saisons[saison - 1].episodes.count }
        else { return allCritics.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == episodesList) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellEpisode", for: indexPath) as! CellEpisode
            
            cell.numero.text = String(indexPath.row + 1)
            cell.titre.text = serie.saisons[saison - 1].episodes[indexPath.row].titre
            
            if (serie.saisons[saison - 1].episodes[indexPath.row].date == ZeroDate) { cell.date.text = "TBD" }
            else { cell.date.text = dateFormShort.string(from: serie.saisons[saison - 1].episodes[indexPath.row].date) }
            
            if ( (indexPath.row + 1) > serie.saisons[saison - 1].nbWatchedEps) { cell.vu.isHidden = true }
            else { cell.vu.isHidden = false }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellComment", for: indexPath) as! CellComment

            cell.comment.text = allCritics[indexPath.row].texte
            cell.date.text = allCritics[indexPath.row].date
            cell.journal.text = allCritics[indexPath.row].journal
            cell.auteur.text = allCritics[indexPath.row].auteur

            if (allCritics[indexPath.row].source == srcMetaCritic) { cell.logo.image = #imageLiteral(resourceName: "metacritic.png") }
            if (allCritics[indexPath.row].source == srcRottenTom) { cell.logo.image = #imageLiteral(resourceName: "rottentomatoes.ico") }
            if (allCritics[indexPath.row].source == srcAlloCine) { cell.logo.image = #imageLiteral(resourceName: "allocine.ico") }

            return cell
        }
    }
    
}

