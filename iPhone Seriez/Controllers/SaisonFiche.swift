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
    @IBOutlet weak var roue: UIActivityIndicatorView!
    @IBOutlet weak var labelSerie: UILabel!
    @IBOutlet weak var labelSaison: UILabel!
    @IBOutlet weak var episodesList: UITableView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var boutonVuUnEp: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        banniere.image = image
        labelSerie.text = serie.serie
        labelSaison.text = "Saison " + String(saison)
        graphe.setNeedsDisplay()
        makeGradiant(carre: boutonVuUnEp, couleur: "Gris")
        
        DispatchQueue.global(qos: .utility).async {
            
            DispatchQueue.main.async { self.roue.startAnimating() }

            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }

            theTVdb.getSerieInfosLight(uneSerie: self.serie)
            DispatchQueue.main.async { self.episodesList.reloadData() }

            if (self.serie.idTVdb != "") { theTVdb.getEpisodesRatings(self.serie) }
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }
            
            if (self.serie.idTVdb != "") { betaSeries.getEpisodesRatings(self.serie) }
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }
            
            if (self.serie.idMoviedb != "") { theMoviedb.getEpisodesRatings(self.serie) }
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }
            
            imdb.getEpisodesRatings(self.serie)
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }

            if (self.serie.idTrakt != "") { trakt.getEpisodesRatings(self.serie) }
            self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }
            
            db.saveDB()
            
            DispatchQueue.main.async { self.roue.stopAnimating() }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "showEpisode")
        {
            let viewController = segue.destination as! EpisodeFiche
            let collectionCell : CellEpisode = sender as! CellEpisode
            viewController.serie = serie
            viewController.saison = saison
            viewController.image = image
            viewController.episode = Int(collectionCell.numero.text!)!
        }
        else
        {
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
        cell.date.text = dateFormatter.string(from: serie.saisons[saison - 1].episodes[indexPath.row].date)
        
        if ( (indexPath.row + 1) > serie.saisons[saison - 1].nbWatchedEps) {
            cell.vu.isHidden = true
        }
        else {
            cell.vu.isHidden = false
        }

        return cell
    }
    
    
    @IBAction func vuUnEpisode(_ sender: Any) {
        if (serie.saisons[saison - 1].nbWatchedEps < serie.saisons[saison - 1].nbEpisodes) {
            
            if (trakt.addToHistory(tvdbID: serie.saisons[saison - 1].episodes[serie.saisons[saison - 1].nbWatchedEps].idTVdb)) {
                serie.saisons[saison - 1].nbWatchedEps = serie.saisons[saison - 1].nbWatchedEps + 1
                if (serie.unfollowed) { serie.unfollowed = false }
                if (serie.watchlist) { serie.watchlist = false }

                table.reloadData()
                table.setNeedsDisplay()
                
                db.updateCompteurs()
                db.saveDB()
            }
        }
    }
    
}

