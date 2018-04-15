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
    
    var index: Int = 0
}


class ViewSaisonListe: UITableViewController {
    
    var viewList: [Serie] = [Serie]()
    var allSaisons: [Int] = [Int]()
    let dateFormatter = DateFormatter()
    var accueil : ViewAccueil = ViewAccueil()
    
    @IBOutlet var liste: UITableView!
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSaisonListe", for: indexPath) as! CellSaisonListe
        
        cell.banniereSerie?.image = accueil.getImage(viewList[indexPath.row].poster)
        cell.index = indexPath.row
        cell.titre.text = viewList[indexPath.row].serie
        
        // Affichage du drapeau
        cell.drapeau.image = getDrapeau(country: viewList[indexPath.row].country)
        
        let uneSaison = viewList[indexPath.row].saisons[allSaisons[indexPath.row] - 1]
        cell.saison.text = "Saison " + String(uneSaison.saison) + " - " + String(uneSaison.nbEpisodes) + " épisodes"
        
        if (uneSaison.starts == ZeroDate) { cell.debut.text = "?" }
        else { cell.debut.text = dateFormatter.string(from: uneSaison.starts) }
        
        if (uneSaison.ends == ZeroDate) { cell.fin.text = "?" }
        else { cell.fin.text = dateFormatter.string(from: uneSaison.ends) }
        
        cell.globalRating.text = String(viewList[indexPath.row].getGlobalRating()) + " %"
        arrondir(texte: cell.globalRating, radius: 12.0)
        
        // Affichage du status
        cell.status.layer.cornerRadius = 8
        cell.status.layer.masksToBounds = true
        if ( (viewList[indexPath.row].status == "Ended") && (allSaisons[indexPath.row] == viewList[indexPath.row].saisons.count) )
        {
            cell.status.text = "FINAL"
            cell.status.isHidden = false
        }
        else
        {
            cell.status.isHidden = true
        }
        
        if  (self.title == "Saisons prêtes à voir")
        {
            cell.viewBgd.isHidden = true
            cell.avantapres.isHidden = true
            cell.diffusion.isHidden = true
            cell.jours.isHidden = true
           
//            var totBetaSeriesMoy : Int = 0
//            var totTraktMoy : Int = 0
//            var totTVdbMoy : Int = 0
//            var totMoviedbMoy : Int = 0
//            var totIMdbMoy : Int = 0
//            var nbEpsMoy = 0
//
//            for loopSaison in viewList[indexPath.row].saisons
//            {
//                if (loopSaison.saison < allSaisons[indexPath.row])
//                {
//                    totBetaSeriesMoy = totBetaSeriesMoy + loopSaison.getFairRatingBetaSeries()
//                    totTraktMoy = totTraktMoy + loopSaison.getFairRatingTrakt()
//                    totTVdbMoy = totTVdbMoy + loopSaison.getFairRatingTVdb()
//                    totMoviedbMoy = totMoviedbMoy + loopSaison.getFairRatingMoviedb()
//                    totIMdbMoy = totIMdbMoy + loopSaison.getFairRatingIMdb()
//                    nbEpsMoy = nbEpsMoy + 1
//                }
//            }
            
            cell.miniGraphe.sendNotes(rateTrakt : viewList[indexPath.row].getFairGlobalRatingTrakt(),
                                      rateTVdb: viewList[indexPath.row].getFairGlobalRatingTVdb(),
                                      rateBetaSeries: viewList[indexPath.row].getFairGlobalRatingBetaSeries(),
                                      rateMoviedb: viewList[indexPath.row].getFairGlobalRatingMoviedb(),
                                      rateIMdb: viewList[indexPath.row].getFairGlobalRatingIMdb(),
                                      seasonsAverageTrakt: 0.0,
                                      seasonsAverageTVdb: 0.0,
                                      seasonsAverageBetaSeries: 0.0,
                                      seasonsAverageMoviedb: 0.0,
                                      seasonsAverageIMdb: 0.0)
//            cell.miniGraphe.sendNotes(rateTrakt : uneSaison.getFairRatingTrakt(),
//                                      rateTVdb: uneSaison.getFairRatingTVdb(),
//                                      rateBetaSeries: uneSaison.getFairRatingBetaSeries(),
//                                      rateMoviedb: uneSaison.getFairRatingMoviedb(),
//                                      rateIMdb: uneSaison.getFairRatingIMdb(),
//                                      seasonsAverageTrakt: Double(totTraktMoy)/Double(nbEpsMoy),
//                                      seasonsAverageTVdb: Double(totTVdbMoy)/Double(nbEpsMoy),
//                                      seasonsAverageBetaSeries: Double(totBetaSeriesMoy)/Double(nbEpsMoy),
//                                      seasonsAverageMoviedb: Double(totMoviedbMoy)/Double(nbEpsMoy),
//                                      seasonsAverageIMdb: Double(totIMdbMoy)/Double(nbEpsMoy))
            cell.miniGraphe.setNeedsDisplay()
        }
        else
        {
            cell.miniGraphe.isHidden = true
            
            if (self.title == "Saisons en diffusion")
            {
                cell.avantapres.text = "till"
                cell.diffusion.text = "completion"
                let nbJours : Int = daysBetweenDates(startDate: Date(), endDate: uneSaison.ends)
                cell.jours.text = "J - \(nbJours)"
                cell.viewBgd.layer.borderColor = UIColor.lightGray.cgColor
            }
            else
            {
                cell.avantapres.text = "before"
                cell.diffusion.text = "return"
                let nbJours : Int = daysBetweenDates(startDate: Date(), endDate: uneSaison.starts)
                cell.jours.text = "J - \(nbJours)"
                cell.viewBgd.layer.borderColor = UIColor.darkGray.cgColor
            }
            
            cell.viewBgd.layer.cornerRadius = 10.0
            cell.viewBgd.layer.borderWidth = 10.0
            cell.layer.masksToBounds = true
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SaisonFiche
        let tableCell : CellSaisonListe = sender as! CellSaisonListe
        self.accueil.downloadSerieDetails(serie: self.viewList[tableCell.index])
        viewController.serie = viewList[tableCell.index]
        viewController.saison = allSaisons[tableCell.index]
        viewController.image = accueil.getImage(viewList[tableCell.index].banner)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let reload = UITableViewRowAction(style: .normal, title: "Reload") { action, index in
            self.accueil.downloadGlobalInfo(serie: self.viewList[index.row])
            self.accueil.saveDB()
            self.liste.reloadData()
            self.view.setNeedsDisplay()
        }
        reload.backgroundColor = .green
        
        return [reload]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}




