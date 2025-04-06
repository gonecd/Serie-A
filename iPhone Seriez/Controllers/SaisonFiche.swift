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
}



class SaisonFiche: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var saison : Int = 0
    var allStreamers : [String] = []
    
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
    
    @IBOutlet weak var viewSaison: UIView!
    @IBOutlet weak var viewSaisons: UIView!
    @IBOutlet weak var viewEpisodes: UIView!
    @IBOutlet weak var viewDiffuseurs: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let queue : OperationQueue = OperationQueue()

        title = "\(serie.serie) - Saison " + String(saison)
        
        if (appConfig.modeCouleurSerie) {
            let mainSerieColor : UIColor = extractDominantColor(from: image) ?? .systemRed
            SerieColor1 = mainSerieColor.withAlphaComponent(0.3)
            SerieColor2 = mainSerieColor.withAlphaComponent(0.1)
        }

        seriesBackgrounds(carre: viewSaison)
        seriesBackgrounds(carre: viewSaisons)
        seriesBackgrounds(carre: viewEpisodes)
        seriesBackgrounds(carre: viewDiffuseurs)

        banniere.image = image
        self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
        graphe.setNeedsDisplay()
        
        graphSaisons.setSerie(serie: self.serie, saison: self.saison)
        graphSaisons.setType(type: 1)
        graphSaisons.setNeedsDisplay()

        trakt.getEpisodes(uneSerie: serie)
        
        var manqueTVdbID = false
        var manqueIMdbID = false

        for unEpisode in serie.saisons[saison-1].episodes {
            if ((unEpisode.idIMdb) == "" && (unEpisode.date.compare(Date()) == .orderedAscending)) {
                manqueIMdbID = true
            }
            
            if ((unEpisode.idTVdb == 0) && (unEpisode.date.compare(Date()) == .orderedAscending)) {
                manqueTVdbID = true
            }
        }
        
        if (manqueTVdbID) { theTVdb.getEpisodesDetailsAndRating(uneSerie: serie)}
        
        if (manqueIMdbID) {
            let opeIMDBids = BlockOperation(block: {
                imdb.getSerieIDs(uneSerie: self.serie)
                imdb.getEpisodesRatings(self.serie)
                
                OperationQueue.main.addOperation({
                    self.graphe.sendSaison(self.serie.saisons[self.saison - 1])
                    self.graphSaisons.setSerie(serie: self.serie, saison: self.saison)
                    self.episodesList.reloadData()
                    
                    self.graphe.setNeedsDisplay()
                    self.graphSaisons.setNeedsDisplay()
                    self.episodesList.setNeedsLayout()
                    
                    db.saveDB()
                } )
            } )
            queue.addOperation(opeIMDBids)
        }
        
        arrondirLabel(texte: labelEpisodes, radius: 10)
        arrondirLabel(texte: labelDiffuseurs, radius: 10)
        arrondirLabel(texte: labelSaison, radius: 10)
        arrondirLabel(texte: labelSaisons, radius: 10)

        arrondir(fenetre: diffuseur1, radius: 4)
        arrondir(fenetre: diffuseur2, radius: 4)
        arrondir(fenetre: diffuseur3, radius: 4)
        
        // Récupération des diffuseurs en mode streaming
        
        let opeStreamers = BlockOperation(block: {
            self.allStreamers = getStreamers(serie: self.serie.serie, idTVDB: self.serie.idTVdb, idIMDB: self.serie.idIMdb, saison: self.saison)

            OperationQueue.main.addOperation({
                if (self.allStreamers.count > 0) { self.diffuseur1.image = getImage(self.allStreamers[0]) }
                if (self.allStreamers.count > 1) { self.diffuseur2.image = getImage(self.allStreamers[1]) }
                if (self.allStreamers.count > 2) { self.diffuseur3.image = getImage(self.allStreamers[2]) }
            } )
        } )
        queue.addOperation(opeStreamers)

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
        
        let opeLoadSensCritique = BlockOperation(block: {
            sensCritique.getEpisodesRatings(serie: self.serie)
        } )
        queue.addOperation(opeLoadSensCritique)
        
        let opeFinalise = BlockOperation(block: {
            db.saveDB()
        } )
        opeFinalise.addDependency(opeLoadBetaSeries)
        opeFinalise.addDependency(opeLoadMovieDB)
        opeFinalise.addDependency(opeLoadIMDB)
        opeFinalise.addDependency(opeLoadTVmaze)
        opeFinalise.addDependency(opeLoadSensCritique)
        queue.addOperation(opeFinalise)
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        episodesList.reloadData()
        episodesList.setNeedsLayout()
    }

        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! EpisodeFiche
        let ficheEpisode : CellEpisode = sender as! CellEpisode
        
        viewController.serie = serie
        viewController.saison = saison
        viewController.image = image
        viewController.episode = Int(ficheEpisode.numero.text!)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serie.saisons[saison - 1].episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellEpisode", for: indexPath) as! CellEpisode
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1

        cell.numero.text = String(indexPath.row + 1)
        cell.titre.text = serie.saisons[saison - 1].episodes[indexPath.row].titre
        
        if (serie.saisons[saison - 1].episodes[indexPath.row].date == ZeroDate) { cell.date.text = "TBD" }
        else { cell.date.text = dateFormShort.string(from: serie.saisons[saison - 1].episodes[indexPath.row].date) }
        
        if ( (indexPath.row + 1) > serie.saisons[saison - 1].nbWatchedEps) { cell.titre.textColor = .darkText }
        else { cell.titre.textColor = .systemGray }
        
        cell.duree.text = String(serie.saisons[saison - 1].episodes[indexPath.row].duration) + " min"
        
        return cell
    }
    
}

