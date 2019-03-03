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
    let dateFormatter = DateFormatter()
    var grapheType : Int = 0
    
    @IBOutlet var liste: UITableView!
    var isWatchlist : Bool = false
    var isPropositions : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yyyy"
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
        for unGenre in viewList[indexPath.row].genres
        {
            allGenres = allGenres + unGenre + " "
        }
        cell.genres.text = allGenres
        
        // Affichage du status
        arrondir(texte: cell.status, radius: 8.0)
        if (viewList[indexPath.row].status == "Ended")
        {
            cell.status.text = "FINIE"
            cell.status.textColor = UIColor.black
        }
        else
        {
            cell.status.text = "EN COURS"
            cell.status.textColor = UIColor.blue
        }
        
        // Affichage du drapeau
        cell.drapeau.image = getDrapeau(country: viewList[indexPath.row].country)
        
        // Affichage du mini graphe
        cell.miniGraphe.sendNotes(rateTrakt: viewList[indexPath.row].getFairGlobalRatingTrakt(),
                                  rateTVdb: viewList[indexPath.row].getFairGlobalRatingTVdb(),
                                  rateBetaSeries: viewList[indexPath.row].getFairGlobalRatingBetaSeries(),
                                  rateMoviedb: viewList[indexPath.row].getFairGlobalRatingMoviedb(),
                                  rateIMdb: viewList[indexPath.row].getFairGlobalRatingIMdb(),
                                  rateTVmaze: viewList[indexPath.row].getFairGlobalRatingTVmaze(),
                                  rateRottenTomatoes: viewList[indexPath.row].getFairGlobalRatingRottenTomatoes() )
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
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        // Function Reload Data
        let reload = UITableViewRowAction(style: .normal, title: "Reload") { action, index in

            db.downloadGlobalInfo(serie: self.viewList[index.row])
            db.saveDB()
            self.liste.reloadData()
            self.view.setNeedsDisplay()
        }
        reload.backgroundColor = .green
        
        // Function Remove from watchlist
        let remove = UITableViewRowAction(style: .destructive, title: "Remove") { action, index in
            if (self.supprimerUneSerieDansLaWatchlistTrakt(uneSerie: self.viewList[index.row]))
            {
                self.viewList.remove(at: index.row)
                self.liste.reloadData()
                self.view.setNeedsDisplay()
            }
        }
        remove.backgroundColor = .red
        
        // Function Add to watclist
        let addWatchlist = UITableViewRowAction(style: .destructive, title: "Add to watchlist") { action, index in
            if (trakt.addToWatchlist(theTVdbId: self.viewList[index.row].idTVdb))
            {
                db.downloadGlobalInfo(serie: self.viewList[index.row])
                self.viewList[index.row].watchlist = true
                db.shows.append(self.viewList[index.row])
                db.saveDB()
            }
        }
        addWatchlist.backgroundColor = .purple
        
        if (self.isWatchlist) { return [reload, remove] }
        else if (self.isPropositions) { return [addWatchlist] }
        else { return [reload] }
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
    
    func supprimerUneSerieDansLaWatchlistTrakt(uneSerie: Serie) -> Bool
    {
        if (trakt.removeFromWatchlist(theTVdbId: uneSerie.idTVdb))
        {
            db.shows.remove(at: db.shows.index(of: uneSerie)!)
            db.saveDB()
            //TODO : updateCompteurs()
            
            return true
        }
        return false
    }
    
    
}




