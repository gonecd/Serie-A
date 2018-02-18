//
//  ViewAdecouvrir.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit


class CellAdecouvrir: UITableViewCell {
    
    @IBOutlet weak var banniereSerie: UIImageView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var debut: UILabel!
    @IBOutlet weak var fin: UILabel!
    @IBOutlet weak var ratingBetaSeries: UILabel!
    @IBOutlet weak var ratingTVdb: UILabel!
    @IBOutlet weak var ratingTrakt: UILabel!
    
    @IBOutlet weak var miniGraphe: GraphMiniSaison!
    
    var index: Int = 0
}


class ViewAdecouvrir: UITableViewController {
    
    var viewList: [Serie] = [Serie]()
    var allSaisons: [Int] = [Int]()
    let dateFormatter = DateFormatter()
    var accueil : ViewAccueil = ViewAccueil()
    
    // Correctiond es notes pour homogénéisation
    var correctionTVdb : Double = 1.0
    var correctionBetaSeries : Double = 1.0
    var correctionTrakt : Double = 1.0
   
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellAdecouvrir", for: indexPath) as! CellAdecouvrir
        
        cell.banniereSerie?.image = accueil.getImage(viewList[indexPath.row].poster)
        cell.index = indexPath.row
        cell.titre.text = viewList[indexPath.row].serie
        
        let uneSaison = viewList[indexPath.row].saisons[allSaisons[indexPath.row] - 1]
        let today = Date()
        var totBetaSeries : Double = 0.0
        var totTrakt : Double = 0.0
        var totTVdb : Double = 0.0
        var nbEps = 0
        
        for eps in uneSaison.episodes
        {
            if (eps.date.compare(today) == .orderedAscending)
            {
                totBetaSeries = totBetaSeries + eps.ratingBetaSeries
                totTrakt = totTrakt + eps.ratingTrakt
                totTVdb = totTVdb + eps.ratingTVdb
                nbEps = nbEps + 1
            }
        }

        var totBetaSeriesMoy : Double = 0.0
        var totTraktMoy : Double = 0.0
        var totTVdbMoy : Double = 0.0
        var nbEpsMoy = 0

        for loopSaison in viewList[indexPath.row].saisons
        {
            if (loopSaison.saison < allSaisons[indexPath.row])
            {
                for eps in loopSaison.episodes
                {
                    totBetaSeriesMoy = totBetaSeriesMoy + eps.ratingBetaSeries
                    totTraktMoy = totTraktMoy + eps.ratingTrakt
                    totTVdbMoy = totTVdbMoy + eps.ratingTVdb
                    nbEpsMoy = nbEpsMoy + 1
                }
            }
        }
        
        cell.ratingBetaSeries.text = String(format: "%.1f", totBetaSeries/Double(nbEps))
        cell.ratingTrakt.text = String(format: "%.1f", totTrakt/Double(nbEps))
        cell.ratingTVdb.text = String(format: "%.1f", totTVdb/Double(nbEps))
        cell.saison.text = "Saison " + String(allSaisons[indexPath.row]) + " - ( " + String(nbEps) + " / " + String(uneSaison.episodes.count) + " )"
        cell.debut.text = dateFormatter.string(from: uneSaison.episodes[0].date)
        cell.fin.text = dateFormatter.string(from: uneSaison.episodes[uneSaison.episodes.count - 1].date)
        
        cell.miniGraphe.theSaison = uneSaison
        cell.miniGraphe.sendNotes(totTrakt/Double(nbEps), rateTVdb: totTVdb/Double(nbEps), rateBetaSeries: totBetaSeries/Double(nbEps),
                                  averageTrakt: totTraktMoy/Double(nbEpsMoy), averageTVdb: totTVdbMoy/Double(nbEpsMoy), averageBetaSeries: totBetaSeriesMoy/Double(nbEpsMoy))
        cell.miniGraphe.setNeedsDisplay()

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SaisonFiche
        let tableCell : CellAdecouvrir = sender as! CellAdecouvrir
        viewController.serie = viewList[tableCell.index]
        viewController.saison = allSaisons[tableCell.index]
        viewController.image = accueil.getImage(viewList[tableCell.index].banner)
        viewController.accueil = accueil
    }
    
    @IBAction func refreshData(_ sender: Any) {
        
        for uneSerie in viewList
        {
            accueil.downloadSerieDetails(serie: uneSerie)
        }
        
        self.view.setNeedsDisplay()
    }

}



