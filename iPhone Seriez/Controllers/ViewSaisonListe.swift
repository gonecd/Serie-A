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
        switch viewList[indexPath.row].country {
        case "US":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_the_United_States.png")
            
        case "GB":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_the_United_Kingdom.png")
            
        case "UK":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_the_United_Kingdom.png")
            
        case "FR":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_France.png")
            
        case "ES":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_Spain.png")
            
        case "DE":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_Germany.png")
            
        case "CA":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_Canada.png")
            
        case "CZ":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_the_Czech_Republic.png")
            
        case "NO":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_Norway.png")
            
        case "SE":
            cell.drapeau.image = #imageLiteral(resourceName: "Flag_of_Sweden.png")
            
        default:
            print("Pays sans drapeau : \(viewList[indexPath.row].country) pour la serie \(viewList[indexPath.row].serie)")
        }
        
        let uneSaison = viewList[indexPath.row].saisons[allSaisons[indexPath.row] - 1]

        var totBetaSeriesMoy : Int = 0
        var totTraktMoy : Int = 0
        var totTVdbMoy : Int = 0
        var totMoviedbMoy : Int = 0
        var totIMdbMoy : Int = 0
        var nbEpsMoy = 0
        
        for loopSaison in viewList[indexPath.row].saisons
        {
            if (loopSaison.saison < allSaisons[indexPath.row])
            {
                totBetaSeriesMoy = totBetaSeriesMoy + loopSaison.getFairRatingBetaSeries()
                totTraktMoy = totTraktMoy + loopSaison.getFairRatingTrakt()
                totTVdbMoy = totTVdbMoy + loopSaison.getFairRatingTVdb()
                totMoviedbMoy = totMoviedbMoy + loopSaison.getFairRatingMoviedb()
                totIMdbMoy = totIMdbMoy + loopSaison.getFairRatingIMdb()
                nbEpsMoy = nbEpsMoy + 1
            }
        }
        
        cell.saison.text = "Saison " + String(allSaisons[indexPath.row]) + " - ( ?? / " + String(uneSaison.nbEpisodes) + " )"
        
        if (uneSaison.starts == ZeroDate) { cell.debut.text = "?" }
        else { cell.debut.text = dateFormatter.string(from: uneSaison.starts) }
        
        if (uneSaison.ends == ZeroDate) { cell.fin.text = "?" }
        else { cell.fin.text = dateFormatter.string(from: uneSaison.ends) }
        
        cell.globalRating.text = String(viewList[indexPath.row].getGlobalRating()) + " %"
        cell.globalRating.layer.cornerRadius = 12
        cell.globalRating.layer.masksToBounds = true
        

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
                                  rateIMdb: uneSaison.getFairRatingIMdb(),
                                  seasonsAverageTrakt: Double(totTraktMoy)/Double(nbEpsMoy),
                                  seasonsAverageTVdb: Double(totTVdbMoy)/Double(nbEpsMoy),
                                  seasonsAverageBetaSeries: Double(totBetaSeriesMoy)/Double(nbEpsMoy),
                                  seasonsAverageMoviedb: Double(totMoviedbMoy)/Double(nbEpsMoy),
                                  seasonsAverageIMdb: Double(totIMdbMoy)/Double(nbEpsMoy))
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
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let reload = UITableViewRowAction(style: .normal, title: "Reload") { action, index in
            self.accueil.downloadSerieDetails(serie: self.viewList[index.row])
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




