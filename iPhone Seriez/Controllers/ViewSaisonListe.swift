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
        
        let uneSaison = viewList[indexPath.row].saisons[allSaisons[indexPath.row] - 1]
        var nbEps = 0
        
        for eps in uneSaison.episodes
        {
            let today = Date()
            if (eps.date.compare(today) == .orderedAscending)
            {
                nbEps = nbEps + 1
            }
        }
        
        var totBetaSeriesMoy : Int = 0
        var totTraktMoy : Int = 0
        var totTVdbMoy : Int = 0
        var totMoviedbMoy : Int = 0
        var nbEpsMoy = 0
        
        for loopSaison in viewList[indexPath.row].saisons
        {
            if (loopSaison.saison < allSaisons[indexPath.row])
            {
                totBetaSeriesMoy = totBetaSeriesMoy + loopSaison.getFairRatingBetaSeries()
                totTraktMoy = totTraktMoy + loopSaison.getFairRatingTrakt()
                totTVdbMoy = totTVdbMoy + loopSaison.getFairRatingTVdb()
                totMoviedbMoy = totMoviedbMoy + loopSaison.getFairRatingMoviedb()
                nbEpsMoy = nbEpsMoy + 1
            }
        }
        
        cell.saison.text = "Saison " + String(allSaisons[indexPath.row]) + " - ( " + String(nbEps) + " / " + String(uneSaison.episodes.count) + " )"
        cell.debut.text = dateFormatter.string(from: uneSaison.episodes[0].date)
        cell.fin.text = dateFormatter.string(from: uneSaison.episodes[uneSaison.episodes.count - 1].date)
        cell.globalRating.text = String(viewList[indexPath.row].getGlobalRating())
        
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
        
        
        cell.miniGraphe.theSaison = uneSaison
        cell.miniGraphe.sendNotes(uneSaison.getFairRatingTrakt(),
                                  rateTVdb: uneSaison.getFairRatingTVdb(),
                                  rateBetaSeries: uneSaison.getFairRatingBetaSeries(),
                                  rateMoviedb: uneSaison.getFairRatingMoviedb(),
                                  seasonsAverageTrakt: Double(totTraktMoy)/Double(nbEpsMoy),
                                  seasonsAverageTVdb: Double(totTVdbMoy)/Double(nbEpsMoy),
                                  seasonsAverageBetaSeries: Double(totBetaSeriesMoy)/Double(nbEpsMoy),
                                  seasonsAverageMoviedb: Double(totMoviedbMoy)/Double(nbEpsMoy))
        cell.miniGraphe.setNeedsDisplay()
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SaisonFiche
        let tableCell : CellSaisonListe = sender as! CellSaisonListe
        viewController.serie = viewList[tableCell.index]
        viewController.saison = allSaisons[tableCell.index]
        viewController.image = accueil.getImage(viewList[tableCell.index].banner)
        viewController.accueil = accueil
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let reload = UITableViewRowAction(style: .normal, title: "Reload") { action, index in
            self.accueil.downloadSerieDetails(serie: self.viewList[index.row])
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




