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

    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: GraphSaison!
    @IBOutlet weak var episodesList: UITableView!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saison " + String(saison)
        
        banniere.image = image
        self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
        graphe.setNeedsDisplay()
        theTVdb.getEpisodesDetailsAndRating(uneSerie: self.serie)

        
        let queue : OperationQueue = OperationQueue()

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

        let opeLoadTrakt = BlockOperation(block: {
            if (self.serie.idTrakt != "") { trakt.getEpisodesRatings(self.serie) }
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            OperationQueue.main.addOperation({ self.graphe.setNeedsDisplay() } )
        } )
        queue.addOperation(opeLoadTrakt)
        
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
        opeFinalise.addDependency(opeLoadTrakt)
        opeFinalise.addDependency(opeLoadTVmaze)
        opeFinalise.addDependency(opeLoadRottenT)
        opeFinalise.addDependency(opeLoadMetaCritic)
        queue.addOperation(opeFinalise)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "showEpisode") {
            let viewController = segue.destination as! EpisodeFiche
            let collectionCell : CellEpisode = sender as! CellEpisode
            viewController.serie = serie
            viewController.saison = saison
            viewController.image = image
            viewController.episode = Int(collectionCell.numero.text!)!
        }
        else {
            let viewController = segue.destination as! SerieFiche
            viewController.serie = serie
            viewController.image = image
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serie.saisons[saison - 1].episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellEpisode", for: indexPath) as! CellEpisode
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"
        
        cell.numero.text = String(indexPath.row + 1)
        cell.titre.text = serie.saisons[saison - 1].episodes[indexPath.row].titre
        
        if (serie.saisons[saison - 1].episodes[indexPath.row].date == ZeroDate) { cell.date.text = "TBD" }
        else { cell.date.text = dateFormatter.string(from: serie.saisons[saison - 1].episodes[indexPath.row].date) }
        
        if ( (indexPath.row + 1) > serie.saisons[saison - 1].nbWatchedEps) { cell.vu.isHidden = true }
        else { cell.vu.isHidden = false }

        return cell
    }
    
}

