//
//  ViewSerieListe.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import SeriesCommon


class CellSerieListe: UITableViewCell {
    
    @IBOutlet weak var banniereSerie: UIImageView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var miniGraphe: GraphMiniSerie!
    @IBOutlet weak var genres: UITextView!
    @IBOutlet weak var globalRating: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var drapeau: UIImageView!
    
    var index: Int = 0
}


class ViewSerieListe: UITableViewController {
    
    var viewList: [Serie] = [Serie]()
    var allSaisons: [Int] = [Int]()
    var grapheType : Int = 0

    @IBOutlet var liste: UITableView!
    var isWatchlist : Bool = false
    var isPropositions : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSerieListe", for: indexPath) as! CellSerieListe
        
        cell.banniereSerie?.image = getImage(viewList[indexPath.row].poster)
        cell.index = indexPath.row
        cell.titre.text = viewList[indexPath.row].serie
        cell.saison.text =  String(viewList[indexPath.row].nbSaisons) + " Saisons - " + String(viewList[indexPath.row].nbEpisodes) + " Epiosdes - " + String(viewList[indexPath.row].runtime) + " min"
        
        cell.globalRating.text = String(viewList[indexPath.row].getGlobalRating()) + " %"
        arrondir(texte: cell.globalRating, radius: 12.0)
        
        // Affichage des genres
        var allGenres : String = ""
        for unGenre in viewList[indexPath.row].genres {
            allGenres = allGenres + unGenre + " "
        }
        cell.genres.text = allGenres
        
        // Affichage du status
        arrondir(texte: cell.status, radius: 8.0)
        if (viewList[indexPath.row].status == "Ended") {
            cell.status.text = "FINIE"
            cell.status.textColor = UIColor.black
        }
        else {
            cell.status.text = "EN COURS"
            cell.status.textColor = .systemBlue
        }
        
        // Affichage du drapeau
        cell.drapeau.image = getDrapeau(country: viewList[indexPath.row].country)
        
        // Affichage du mini graphe
        cell.miniGraphe.sendNotes(rateTrakt: viewList[indexPath.row].getFairGlobalRatingTrakt(),
                                  rateBetaSeries: viewList[indexPath.row].getFairGlobalRatingBetaSeries(),
                                  rateMoviedb: viewList[indexPath.row].getFairGlobalRatingMoviedb(),
                                  rateIMdb: viewList[indexPath.row].getFairGlobalRatingIMdb(),
                                  rateTVmaze: viewList[indexPath.row].getFairGlobalRatingTVmaze(),
                                  rateRottenTomatoes: viewList[indexPath.row].getFairGlobalRatingRottenTomatoes(),
                                  rateMetaCritic: viewList[indexPath.row].getFairGlobalRatingMetaCritic(),
                                  rateAlloCine: viewList[indexPath.row].getFairGlobalRatingAlloCine() )
        cell.miniGraphe.setType(type: grapheType)
        cell.miniGraphe.setNeedsDisplay()
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellSerieListe = sender as! CellSerieListe
        viewController.serie = viewList[tableCell.index]
        viewController.image = getImage(viewList[tableCell.index].banner)
        viewController.modeRecherche = isPropositions
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reload = UIContextualAction(style: .destructive, title: "Reload") {  (contextualAction, view, boolValue) in
            db.downloadGlobalInfo(serie: self.viewList[indexPath.row])
            db.saveDB()
            self.liste.reloadData()
            self.view.setNeedsDisplay()
        }
        reload.backgroundColor = .systemGreen
        
        let remove = UIContextualAction(style: .destructive, title: "Remove") {  (contextualAction, view, boolValue) in
            if (self.supprimerUneSerieDansLaWatchlistTrakt(uneSerie: self.viewList[indexPath.row])) {
                self.viewList.remove(at: indexPath.row)
                self.liste.reloadData()
                self.view.setNeedsDisplay()
            }
        }
        remove.backgroundColor = .systemRed

        let addWatchlist = UIContextualAction(style: .destructive, title: "Add to watchlist") {  (contextualAction, view, boolValue) in
            if (trakt.addToWatchlist(theTVdbId: self.viewList[indexPath.row].idTVdb)) {
                db.downloadGlobalInfo(serie: self.viewList[indexPath.row])
                self.viewList[indexPath.row].watchlist = true
                db.shows.append(self.viewList[indexPath.row])
                db.saveDB()
            }
        }
        addWatchlist.backgroundColor = .systemPurple

        if (self.isWatchlist) { return UISwipeActionsConfiguration(actions: [reload, remove]) }
        else if (self.isPropositions) { return UISwipeActionsConfiguration(actions: [addWatchlist]) }
        else { return UISwipeActionsConfiguration(actions: [reload]) }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    @IBAction func changeGraphe(_ sender: Any) {
        if (grapheType == 0) { grapheType = 1 }
        else { grapheType = 0 }
        
        self.liste.reloadData()
        self.view.setNeedsDisplay()
    }
    
    func supprimerUneSerieDansLaWatchlistTrakt(uneSerie: Serie) -> Bool {
        if (trakt.removeFromWatchlist(theTVdbId: uneSerie.idTVdb)) {
            db.shows.remove(at: db.shows.firstIndex(of: uneSerie)!)
            db.saveDB()
            //TODO : updateCompteurs()
            
            return true
        }
        return false
    }
    
}
