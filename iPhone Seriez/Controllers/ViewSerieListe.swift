//
//  ViewSerieListe.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit


class CellSerieListe: UITableViewCell {
    
    @IBOutlet weak var banniereSerie: UIImageView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var miniGraphe: GraphMiniSerie!
    @IBOutlet weak var genres: UITextView!
    @IBOutlet weak var globalRating: UITextField!
    
    var index: Int = 0
}


class ViewSerieListe: UITableViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSerieListe", for: indexPath) as! CellSerieListe
        
        cell.banniereSerie?.image = accueil.getImage(viewList[indexPath.row].poster)
        cell.index = indexPath.row
        cell.titre.text = viewList[indexPath.row].serie
        cell.saison.text =  String(viewList[indexPath.row].saisons.count) + " Saison(s)"
        cell.globalRating.text = String(viewList[indexPath.row].getGlobalRating())

        // Affichage des genres
        var allGenres : String = ""
        for unGenre in viewList[indexPath.row].genres
        {
            allGenres = allGenres + unGenre + " "
        }
        cell.genres.text = allGenres
        
        // Affichage du mini graphe
        cell.miniGraphe.sendNotes(viewList[indexPath.row].getFairRatingTrakt(), rateTVdb: viewList[indexPath.row].getFairRatingTVdb(), rateBetaSeries: viewList[indexPath.row].getFairRatingBetaSeries())
        cell.miniGraphe.setNeedsDisplay()
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellSerieListe = sender as! CellSerieListe
        viewController.serie = viewList[tableCell.index]
        viewController.image = accueil.getImage(viewList[tableCell.index].banner)
    }
    
    @IBAction func refreshData(_ sender: Any) {
        
        for uneSerie in viewList
        {
            accueil.downloadSerieDetails(serie: uneSerie)
        }
        
        self.view.setNeedsDisplay()
    }
    
}




