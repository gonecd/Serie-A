//
//  ViewSaisonListe.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

class CellSaisonListe: UITableViewCell {
    
    @IBOutlet weak var banniereSerie: UIImageView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var debut: UILabel!
    @IBOutlet weak var fin: UILabel!
    @IBOutlet weak var miniGraphe: GraphMiniSaison!
    @IBOutlet weak var globalRating: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var drapeau: UIImageView!
    @IBOutlet weak var viewBgd: UIView!
    @IBOutlet weak var jours: UILabel!
    @IBOutlet weak var avantapres: UILabel!
    @IBOutlet weak var diffusion: UILabel!
    
    @IBOutlet weak var graphBis: GraphMiniSaison!
    
    var index: Int = 0
}


class ViewSaisonListe: UITableViewController {
    
    var viewList: [Serie] = [Serie]()
    var allSaisons: [Int] = [Int]()
    var grapheType : Int = 0

    @IBOutlet var liste: UITableView!
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSaisonListe", for: indexPath) as! CellSaisonListe
        
        cell.banniereSerie?.image = getImage(viewList[indexPath.row].poster)
        cell.index = indexPath.row
        cell.titre.text = viewList[indexPath.row].serie
        
        // Affichage du drapeau
        cell.drapeau.image = getDrapeau(country: viewList[indexPath.row].country)
        
        let uneSaison = viewList[indexPath.row].saisons[allSaisons[indexPath.row] - 1]
        cell.saison.text = "Saison " + String(uneSaison.saison) + " - " + String(uneSaison.nbEpisodes) + " épisodes"
        
        if (uneSaison.starts == ZeroDate) { cell.debut.text = "TBD" }
        else { cell.debut.text = dateFormLong.string(from: uneSaison.starts) }
        
        if (uneSaison.ends == ZeroDate) { cell.fin.text = "TBD" }
        else { cell.fin.text = dateFormLong.string(from: uneSaison.ends) }
        
        let note : Double = Double(viewList[indexPath.row].getGlobalRating())/10.0
        cell.globalRating.text = "👍🏼 " + String(note)
        cell.globalRating.layer.borderColor = UIColor.systemBlue.cgColor
        cell.globalRating.layer.borderWidth = 2
        cell.globalRating.layer.cornerRadius = 12
        cell.globalRating.layer.masksToBounds = true
        
        // Affichage du status
        cell.status.layer.cornerRadius = 8
        cell.status.layer.masksToBounds = true
        if ( (viewList[indexPath.row].status == "Ended") && (allSaisons[indexPath.row] == viewList[indexPath.row].saisons.count) ) {
            cell.status.text = "FINAL"
            cell.status.isHidden = false
        }
        else {
            cell.status.isHidden = true
        }
        
        if  (self.title == "Saisons prêtes à voir") {
            cell.viewBgd.isHidden = true
            cell.avantapres.isHidden = true
            cell.diffusion.isHidden = true
            cell.jours.isHidden = true
            
            cell.saison.text = "Saison " + String(uneSaison.saison) + " - " + String(uneSaison.nbWatchedEps) + " / " + String(uneSaison.nbEpisodes) + " épisodes"
            cell.miniGraphe.setSerie(serie: viewList[indexPath.row], saison: allSaisons[indexPath.row])
            cell.miniGraphe.setType(type: grapheType)
            cell.miniGraphe.setNeedsDisplay()

            if (UIDevice.current.userInterfaceIdiom == .pad) {
                cell.graphBis.setSerie(serie: viewList[indexPath.row], saison: allSaisons[indexPath.row])
                cell.graphBis.setType(type: 3)
                cell.graphBis.setNeedsDisplay()
            }
        }
        else {
            
            if (self.title == "Saisons en diffusion") {
                if (grapheType == 0) {
                    cell.miniGraphe.isHidden = true
                    cell.viewBgd.isHidden = false
                    cell.avantapres.isHidden = false
                    cell.diffusion.isHidden = false
                    cell.jours.isHidden = false

                    cell.avantapres.text = "à"
                    cell.diffusion.text = "venir"
                    let nbEps : Int = uneSaison.nbEpisodes - uneSaison.nbEpisodesDiffuses()
                    cell.jours.text = "\(nbEps) eps"
                    let alpha : CGFloat = 1.0 - CGFloat(min(20, nbEps)) / CGFloat(20)
                    cell.viewBgd.layer.borderColor = UIColor.systemBlue.withAlphaComponent(alpha).cgColor
                }
                else {
                    cell.miniGraphe.isHidden = false
                    cell.viewBgd.isHidden = true
                    cell.avantapres.isHidden = true
                    cell.diffusion.isHidden = true
                    cell.jours.isHidden = true

                        cell.miniGraphe.setSerie(serie: viewList[indexPath.row], saison: allSaisons[indexPath.row])
                        cell.miniGraphe.setType(type: grapheType)
                        cell.miniGraphe.setNeedsDisplay()
                }

                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    cell.graphBis.setSerie(serie: viewList[indexPath.row], saison: allSaisons[indexPath.row])
                    cell.graphBis.setType(type: 3)
                    cell.graphBis.setNeedsDisplay()
                }
            }
            else {
                cell.miniGraphe.isHidden = true
                if (UIDevice.current.userInterfaceIdiom == .pad) { cell.graphBis.isHidden = true }
                cell.avantapres.text = "avant la"
                cell.diffusion.text = "première"
                let nbJours : Int = daysBetweenDates(startDate: Date(), endDate: uneSaison.starts)
                cell.jours.text = "J - \(nbJours)"
                let alpha : CGFloat = CGFloat(max(0, 180 - nbJours)) / CGFloat(180)
                cell.viewBgd.layer.borderColor = UIColor.systemRed.withAlphaComponent(alpha).cgColor
            }
            
            cell.viewBgd.layer.cornerRadius = 10.0
            cell.viewBgd.layer.borderWidth = 5.0
            cell.layer.masksToBounds = true
        }
        
        return cell
    }
    
    
    @IBAction func changeGraphe(_ sender: Any) {
        if (grapheType == 0) { grapheType = 1 }
        else if (grapheType == 1) { grapheType = 2 }
        else if (grapheType == 2) { grapheType = 3 }
        else { grapheType = 0 }
        
        self.liste.reloadData()
        self.view.setNeedsDisplay()
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SaisonFiche
        let tableCell : CellSaisonListe = sender as! CellSaisonListe
        viewController.serie = viewList[tableCell.index]
        viewController.saison = allSaisons[tableCell.index]
        viewController.image = getImage(viewList[tableCell.index].banner)
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reload = UIContextualAction(style: .destructive, title: "Reload") {  (contextualAction, view, boolValue) in
            db.downloadGlobalInfo(serie: self.viewList[indexPath.row])
            db.downloadDates(serie: self.viewList[indexPath.row])
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
    
}
