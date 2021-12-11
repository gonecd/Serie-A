//
//  SaisonFiche.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

class CellEpisode: UITableViewCell {
    @IBOutlet weak var numero: UILabel!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var duree: UILabel!
    @IBOutlet weak var graphe: GraphMiniEpisode!
}



class SaisonFiche: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var saison : Int = 0
    var durees : [Int] = []
    
    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: GraphSaison!
    @IBOutlet weak var graphSaisons: GraphMiniSaison!
    @IBOutlet weak var episodesList: UITableView!
    
    @IBOutlet weak var labelEpisodes: UILabel!
    @IBOutlet weak var labelDiffuseurs: UILabel!
    @IBOutlet weak var labelSaison: UILabel!
    @IBOutlet weak var labelSaisons: UILabel!

    @IBOutlet weak var diffuseur1: UIImageView!
    @IBOutlet weak var diffuseur2: UIImageView!
    @IBOutlet weak var diffuseur3: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saison " + String(saison)
        
        banniere.image = image
        self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
        graphe.setNeedsDisplay()
        
        graphSaisons.setSerie(serie: self.serie, saison: self.saison)
        graphSaisons.setType(type: 1)
        graphSaisons.setNeedsDisplay()

        trakt.getEpisodes(uneSerie: serie)
        
        var manqueTVdbID = false
        
        for unEpisode in serie.saisons[saison-1].episodes {
            if ((unEpisode.idIMdb) == "" && (unEpisode.date.compare(Date()) == .orderedAscending)) {
                unEpisode.idIMdb = imdb.getEpisodeID(serieID: serie.idIMdb, saison: saison, episode: unEpisode.episode)
                if (unEpisode.idIMdb == "") { print("No IMDB id for \(serie.serie) saison: \(saison) episode: \(unEpisode.episode)") }
            }
            
            if ((unEpisode.idTVdb == 0) && (unEpisode.date.compare(Date()) == .orderedAscending)) {
                manqueTVdbID = true
            }
        }
        
        if (manqueTVdbID) { theTVdb.getEpisodesDetailsAndRating(uneSerie: serie)}
        
        arrondirLabel(texte: labelEpisodes, radius: 10)
        arrondirLabel(texte: labelDiffuseurs, radius: 10)
        arrondirLabel(texte: labelSaison, radius: 10)
        arrondirLabel(texte: labelSaisons, radius: 10)

        arrondir(fenetre: diffuseur1, radius: 4)
        arrondir(fenetre: diffuseur2, radius: 4)
        arrondir(fenetre: diffuseur3, radius: 4)
        
        // Récupération des diffuseurs en mode streaming
        let allStreamers : [String] = getStreamers(serie: self.serie.serie, idTVDB: self.serie.idTVdb, idIMDB: self.serie.idIMdb, saison: self.saison)
        if (allStreamers.count > 0) { self.diffuseur1.image = loadImage(allStreamers[0]) }
        if (allStreamers.count > 1) { self.diffuseur2.image = loadImage(allStreamers[1]) }
        if (allStreamers.count > 2) { self.diffuseur3.image = loadImage(allStreamers[2]) }
        
        
        let queue : OperationQueue = OperationQueue()
        
        let opeLoadBetaSeries = BlockOperation(block: {
            if (self.serie.idTVdb != "") { betaSeries.getEpisodesRatings(self.serie) }

            OperationQueue.main.addOperation({
                self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
                self.graphSaisons.setSerie(serie: self.serie, saison: self.saison)
                self.episodesList.reloadData()
                self.graphe.setNeedsDisplay()
                self.graphSaisons.setNeedsDisplay()
                self.episodesList.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeLoadBetaSeries)
        
        let opeLoadMovieDB = BlockOperation(block: {
            if (self.serie.idMoviedb != "") { theMoviedb.getEpisodesRatings(self.serie) }
        } )
        queue.addOperation(opeLoadMovieDB)
        
        let opeLoadIMDB = BlockOperation(block: {
            imdb.getEpisodesRatings(self.serie)
            
            OperationQueue.main.addOperation({
                self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
                self.graphSaisons.setSerie(serie: self.serie, saison: self.saison)
                self.episodesList.reloadData()
                self.graphe.setNeedsDisplay()
                self.graphSaisons.setNeedsDisplay()
                self.episodesList.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeLoadIMDB)
        
        let opeLoadTVmaze = BlockOperation(block: {
            tvMaze.getEpisodesRatings(self.serie)
        } )
        queue.addOperation(opeLoadTVmaze)
        
        let opeLoadEpisodeDurations = BlockOperation(block: {
            self.durees = tvMaze.getEpisodesDurations(idTVMaze: self.serie.idTVmaze, saison: self.saison)
            
            OperationQueue.main.addOperation({
                self.episodesList.reloadData()
                self.episodesList.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeLoadEpisodeDurations)
        
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
        return serie.saisons[saison - 1].episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellEpisode", for: indexPath) as! CellEpisode
        
        cell.numero.text = String(indexPath.row + 1)
        cell.titre.text = serie.saisons[saison - 1].episodes[indexPath.row].titre
        
        if (serie.saisons[saison - 1].episodes[indexPath.row].date == ZeroDate) { cell.date.text = "TBD" }
        else { cell.date.text = dateFormShort.string(from: serie.saisons[saison - 1].episodes[indexPath.row].date) }
        
        if ( (indexPath.row + 1) > serie.saisons[saison - 1].nbWatchedEps) { cell.titre.textColor = .darkText }
        else { cell.titre.textColor = .systemGray }
        
        if (durees.count > indexPath.row) { cell.duree.text = String(durees[indexPath.row]) + " min" }
        else { cell.duree.text = "" }
        
        cell.graphe.setEpisode(eps: serie.saisons[saison - 1].episodes[indexPath.row])
        cell.graphe.setNeedsDisplay()

        return cell
    }
    
}

