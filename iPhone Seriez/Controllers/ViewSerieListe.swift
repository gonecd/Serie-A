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
    @IBOutlet weak var drapeau: UIImageView!
    
    var index: Int = 0
}


class ViewSerieListe: UITableViewController {
    
    var viewList: [Serie] = [Serie]()
    var allSaisons: [Int] = [Int]()
    let dateFormatter = DateFormatter()
    var accueil : ViewAccueil = ViewAccueil()
    var grapheType : Int = 0
    
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
        cell.saison.text =  String(viewList[indexPath.row].nbSaisons) + " Saisons - " + String(viewList[indexPath.row].nbEpisodes) + " Epiosdes - " + String(viewList[indexPath.row].runtime) + " min"
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
        
        // Affichage du mini graphe
        cell.miniGraphe.sendNotes(rateTrakt: viewList[indexPath.row].getFairGlobalRatingTrakt(),
                                  rateTVdb: viewList[indexPath.row].getFairGlobalRatingTVdb(),
                                  rateBetaSeries: viewList[indexPath.row].getFairGlobalRatingBetaSeries(),
                                  rateMoviedb: viewList[indexPath.row].getFairGlobalRatingMoviedb(),
                                  rateIMdb: viewList[indexPath.row].getFairGlobalRatingIMdb())
        cell.miniGraphe.setType(type: grapheType)
        cell.miniGraphe.setNeedsDisplay()
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSerie")
        {
            let viewController = segue.destination as! SerieFiche
            let tableCell : CellSerieListe = sender as! CellSerieListe
            viewController.serie = viewList[tableCell.index]
            viewController.image = accueil.getImage(viewList[tableCell.index].banner)
        }
        else if (segue.identifier == "showChercher")
        {
            let viewController = segue.destination as! Chercher
            viewController.accueil = accueil
        }
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
            self.accueil.saveDB()
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


    @IBAction func changeGraphe(_ sender: Any) {
        if (grapheType == 0) { grapheType = 1 }
        else { grapheType = 0 }
        
        self.liste.reloadData()
        self.view.setNeedsDisplay()
    }
    
}




