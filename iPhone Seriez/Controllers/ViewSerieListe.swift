//
//  ViewSerieListe.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import TagListView


class CellSerieListe: UITableViewCell {
    
    @IBOutlet weak var banniereSerie: UIImageView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var miniGraphe: GraphMiniSerie!
    @IBOutlet weak var globalRating: UITextField!
    @IBOutlet weak var myRating: UITextField!
    @IBOutlet weak var drapeau: UIImageView!
    @IBOutlet weak var network: UIImageView!
    @IBOutlet weak var genresTags: TagListView!
    
    var index: Int = 0
}


class ViewSerieListe: UITableViewController {
    
    var viewList: [Serie] = [Serie]()
    var grapheType : Int = 0
    
    @IBOutlet var liste: UITableView!
    var modeAffichage : Int = 0
    
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
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1

        cell.banniereSerie?.image = getImage(viewList[indexPath.row].poster)
        arrondir(fenetre: cell.banniereSerie, radius: 6)

        cell.index = indexPath.row
        cell.titre.text = viewList[indexPath.row].serie
        cell.saison.text =  String(viewList[indexPath.row].nbSaisons) + " saisons - " + String(viewList[indexPath.row].nbEpisodes) + " épiosdes - " + String(viewList[indexPath.row].runtime) + " min"
        
        let note : Double = Double(viewList[indexPath.row].getGlobalRating())/10.0
        cell.globalRating.text = "👍🏼 " + String(note)
        cell.globalRating.layer.borderColor = UIColor.systemBlue.cgColor
        cell.globalRating.layer.borderWidth = 2
        cell.globalRating.layer.cornerRadius = 12
        cell.globalRating.layer.masksToBounds = true
        
        cell.myRating.textColor = UIColor.init(red: 1.0, green: 153.0/255.0, blue: 1.0, alpha: 1.0)

        if (viewList[indexPath.row].myRating < 1) {
            cell.myRating.text = "-"
            cell.myRating.backgroundColor = UIColor.systemGray
        }
        else {
            cell.myRating.text = String(viewList[indexPath.row].myRating)
            cell.myRating.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: CGFloat(viewList[indexPath.row].myRating))
        }
        arrondir(texte: cell.myRating, radius: 12.0)
        cell.myRating.textColor = UIColor.systemBackground
        
        // Affichage des genres
        cell.genresTags.removeAllTags()
        cell.genresTags.textFont = UIFont.systemFont(ofSize: 10)
        cell.genresTags.alignment = .leading
        cell.genresTags.addTags(viewList[indexPath.row].genres)

        // Affichage du drapeau
        cell.drapeau.image = getDrapeau(country: viewList[indexPath.row].country)
        
        // Affichage du network
        cell.network.image = getLogoDiffuseur(diffuseur: viewList[indexPath.row].diffuseur)
        arrondir(fenetre: cell.network, radius: 4)

        // Affichage du mini graphe
        cell.miniGraphe.sendNotes(rateTrakt: viewList[indexPath.row].getFairGlobalRatingTrakt(),
                                  rateBetaSeries: viewList[indexPath.row].getFairGlobalRatingBetaSeries(),
                                  rateMoviedb: viewList[indexPath.row].getFairGlobalRatingMoviedb(),
                                  rateIMdb: viewList[indexPath.row].getFairGlobalRatingIMdb(),
                                  rateTVmaze: viewList[indexPath.row].getFairGlobalRatingTVmaze(),
                                  rateRottenTomatoes: viewList[indexPath.row].getFairGlobalRatingRottenTomatoes(),
                                  rateMetaCritic: viewList[indexPath.row].getFairGlobalRatingMetaCritic(),
                                  rateAlloCine: viewList[indexPath.row].getFairGlobalRatingAlloCine(),
                                  rateSensCritique: viewList[indexPath.row].getFairGlobalRatingSensCritique(),
                                  rateSIMKL: viewList[indexPath.row].getFairGlobalRatingSIMKL() )

        cell.miniGraphe.setType(type: grapheType)
        cell.miniGraphe.setNeedsDisplay()
        
        return cell
    }
    
    
    func computeSerieListe(serie : Serie) -> (label: String, couleur: UIColor) {
        if (serie.watchlist) { return ("Watchlist", .systemGreen) }
        if (serie.unfollowed) { return ("Série abandonnée", .systemRed) }
        if (serie.enCours()) { return ("Série en cours", .systemBlue) }

        return ("Série finie", .systemGray2)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellSerieListe = sender as! CellSerieListe
        viewController.serie = viewList[tableCell.index]
        viewController.image = getImage(viewList[tableCell.index].banner)
        viewController.modeAffichage = self.modeAffichage
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reload = UIContextualAction(style: .destructive, title: "Refresh") {  (contextualAction, view, boolValue) in

            let oldSerie : Serie = self.viewList[indexPath.row].partialCopy()
            
            db.downloadGlobalInfo(serie: self.viewList[indexPath.row])
            db.downloadDates(serie: self.viewList[indexPath.row])
            db.downloadDetailInfo(serie: self.viewList[indexPath.row])

            db.checkForUpdates(newSerie: self.viewList[indexPath.row], oldSerie: oldSerie, methode: funcSerie)

            db.saveDB()
            self.liste.reloadData()
            self.view.setNeedsDisplay()
        }
        reload.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [reload])
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    @IBAction func changeGraphe(_ sender: Any) {
        if (grapheType == 0) { grapheType = 3 }
        else if (grapheType == 3) { grapheType = 0 }
        
        self.liste.reloadData()
        self.view.setNeedsDisplay()
    }
}
