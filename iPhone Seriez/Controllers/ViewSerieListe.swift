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
    @IBOutlet weak var status: UITextField!
    
    var index: Int = 0
}


class ViewSerieListe: UITableViewController {
    
    var viewList: [Serie] = [Serie]()
    var allSaisons: [Int] = [Int]()
    let dateFormatter = DateFormatter()
    var accueil : ViewAccueil = ViewAccueil()
    
    @IBOutlet var liste: UITableView!
    var isWatchlist : Bool = false
    
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
        
        // Affichage du status
        cell.status.layer.cornerRadius = 8
        cell.status.layer.masksToBounds = true
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

        
        // Affichage du mini graphe
        cell.miniGraphe.sendNotes(viewList[indexPath.row].getFairRatingTrakt(),
                                  rateTVdb: viewList[indexPath.row].getFairRatingTVdb(),
                                  rateBetaSeries: viewList[indexPath.row].getFairRatingBetaSeries(),
                                  rateMoviedb: viewList[indexPath.row].getFairRatingMoviedb())
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
    
    @IBAction func addSerie(_ sender: Any) {
        let alert = UIAlertController(title: "Série à rechercher", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.default, handler:doNothing))
        alert.addAction(UIAlertAction(title: "Valider", style: UIAlertActionStyle.default, handler:searchSerie))
        self.present(alert, animated: true, completion: { })
    }
    
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "Nom de la série"
        popupTextField = textField
    }
    
    var popupTextField : UITextField = UITextField()
    func doNothing(alertView: UIAlertAction!) {}
    
    func searchSerie(alertView: UIAlertAction!)
    {
        let seriesTrouvees : [Serie] = accueil.chercherUneSerieSurTrakt(nomSerie: self.popupTextField.text!)
        let actionSheetController: UIAlertController = UIAlertController(title: "Ajouter à ma watchlist", message: nil, preferredStyle: .actionSheet)
        
        for uneSerie in seriesTrouvees
        {
            let uneAction: UIAlertAction = UIAlertAction(title: uneSerie.serie+" ("+String(uneSerie.year)+")", style: UIAlertActionStyle.default) { action -> Void in
                if (self.accueil.ajouterUneSerieDansLaWatchlistTrakt(uneSerie: uneSerie))
                {
                    self.viewList.append(uneSerie)
                    self.liste.reloadData()
                    self.view.setNeedsDisplay()
                }
            }
            actionSheetController.addAction(uneAction)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.cancel, handler: doNothing)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let reload = UITableViewRowAction(style: .normal, title: "Reload") { action, index in
            self.accueil.downloadSerieDetails(serie: self.viewList[index.row])
            self.liste.reloadData()
            self.view.setNeedsDisplay()
        }
        reload.backgroundColor = .green
        
        let remove = UITableViewRowAction(style: .destructive, title: "Remove") { action, index in
            if (self.accueil.supprimerUneSerieDansLaWatchlistTrakt(uneSerie: self.viewList[index.row]))
            {
                self.viewList.remove(at: index.row)
                self.liste.reloadData()
                self.view.setNeedsDisplay()
            }
        }
        remove.backgroundColor = .red
        
        if (self.isWatchlist) { return [reload, remove] }
        else { return [reload] }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}




