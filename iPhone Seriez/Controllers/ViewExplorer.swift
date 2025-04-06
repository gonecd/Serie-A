//
//  ViewExplorer.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 03/11/2024.
//  Copyright © 2024 Home. All rights reserved.
//

import UIKit

class CellExplorerListe: UITableViewCell {
    
    @IBOutlet weak var banniereSerie: UIImageView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var miniGraphe: GraphMiniSerie!
    @IBOutlet weak var genres: UITextView!
    @IBOutlet weak var globalRating: UITextField!
    @IBOutlet weak var myRating: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var drapeau: UIImageView!
    @IBOutlet weak var network: UIImageView!
    @IBOutlet weak var diffuseur: UIImageView!
    
    var index: Int = 0
}



class ViewExplorer: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewList: [Serie] = [Serie]()
    var up : Bool = false
    var tri : String = "titre"
    var typeAffichage : Int = modeExplore

    @IBOutlet var liste: UITableView!
    @IBOutlet weak var cadreFiltre: UIView!
    @IBOutlet weak var cadreTri: UIView!
    @IBOutlet weak var cadreListe: UIView!
    @IBOutlet weak var cadreCompteur: UIView!
    
    @IBOutlet weak var NbSeries: UILabel!
    
    @IBOutlet weak var bRate1: UIButton!
    @IBOutlet weak var bRate2: UIButton!
    @IBOutlet weak var bRate3: UIButton!
    @IBOutlet weak var bRate4: UIButton!
    @IBOutlet weak var bRate5: UIButton!
    @IBOutlet weak var bRate6: UIButton!
    @IBOutlet weak var bRate7: UIButton!
    @IBOutlet weak var bRate8: UIButton!
    @IBOutlet weak var bRate9: UIButton!
    
    @IBOutlet weak var filtreFinies: UIButton!
    @IBOutlet weak var filtreEnCours: UIButton!
    @IBOutlet weak var filtreAbandonnees: UIButton!
    @IBOutlet weak var filtreWatchlist: UIButton!
    
    @IBOutlet weak var filtreAppleTV: UIButton!
    @IBOutlet weak var filtreCanalPlus: UIButton!
    @IBOutlet weak var filtrePrimeVideo: UIButton!
    @IBOutlet weak var filtreDisney: UIButton!
    @IBOutlet weak var filtreNetflix: UIButton!
    @IBOutlet weak var filtreParamount: UIButton!
    @IBOutlet weak var filtreMax: UIButton!
    @IBOutlet weak var filtreOCS: UIButton!

    @IBOutlet weak var filtreDates00: UIButton!
    @IBOutlet weak var filtreDates0010: UIButton!
    @IBOutlet weak var filtreDates1020: UIButton!
    @IBOutlet weak var filtreDates20: UIButton!
    
    @IBOutlet weak var filtreFrancais: UIButton!
    @IBOutlet weak var filtreUS: UIButton!
    @IBOutlet weak var filtreUK: UIButton!
    @IBOutlet weak var filtreEspagnol: UIButton!
    @IBOutlet weak var filtreCoreen: UIButton!
    @IBOutlet weak var filtreNorvegien: UIButton!
    @IBOutlet weak var filtreAllemand: UIButton!
    @IBOutlet weak var filtreIsraelien: UIButton!
    
    
    
    @IBOutlet weak var triTitre: UIButton!
    @IBOutlet weak var triNote: UIButton!
    @IBOutlet weak var triAnnee: UIButton!
    @IBOutlet weak var triConsensus: UIButton!
    
    @IBOutlet weak var triAsc: UIButton!
    @IBOutlet weak var triDesc: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch typeAffichage {
        case modeExplore : break
            
        case modeWatchlist :
            viewList = viewList.filter({ $0.watchlist })
            filtreFinies.isHidden = true
            filtreEnCours.isHidden = true
            filtreAbandonnees.isHidden = true
            filtreWatchlist.configuration?.background.strokeColor = .systemGreen
            filtreWatchlist.isEnabled = false
            break
            
        case modeAbandon :
            viewList = viewList.filter({ $0.unfollowed })
            filtreFinies.isHidden = true
            filtreEnCours.isHidden = true
            filtreWatchlist.isHidden = true
            filtreAbandonnees.configuration?.background.strokeColor = .systemGreen
            filtreAbandonnees.isEnabled = false
            break
            
        case modeEnCours :
            viewList = viewList.filter({ $0.enCours() })
            filtreFinies.isHidden = true
            filtreWatchlist.isHidden = true
            filtreAbandonnees.isHidden = true
            filtreEnCours.configuration?.background.strokeColor = .systemGreen
            filtreEnCours.isEnabled = false
            break
            
        case modeFinie :
            viewList = viewList.filter({ ( ($0.watchlist == false) && ($0.enCours() == false) && ($0.unfollowed == false) ) })
            filtreAbandonnees.isHidden = true
            filtreEnCours.isHidden = true
            filtreWatchlist.isHidden = true
            filtreFinies.configuration?.background.strokeColor = .systemGreen
            filtreFinies.isEnabled = false
            break
                        
        default: break
        }
        
        bRate1.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 1.0)
        bRate2.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 2.0)
        bRate3.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 3.0)
        bRate4.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 4.0)
        bRate5.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 5.0)
        bRate6.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 6.0)
        bRate7.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 7.0)
        bRate8.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 8.0)
        bRate9.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 9.0)
        
        bRate1.layer.cornerRadius = 12.0
        bRate2.layer.cornerRadius = 12.0
        bRate3.layer.cornerRadius = 12.0
        bRate4.layer.cornerRadius = 12.0
        bRate5.layer.cornerRadius = 12.0
        bRate6.layer.cornerRadius = 12.0
        bRate7.layer.cornerRadius = 12.0
        bRate8.layer.cornerRadius = 12.0
        bRate9.layer.cornerRadius = 12.0

        makeGradiant(carre: cadreFiltre, couleur: "Blanc")
        makeGradiant(carre: cadreTri, couleur: "Blanc")
        makeGradiant(carre: cadreListe, couleur: "Blanc")
        makeGradiant(carre: cadreCompteur, couleur: "Blanc")
        
        NbSeries.text = String(viewList.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellExplorerListe", for: indexPath) as! CellExplorerListe
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIcolor2 : UIcolor1

        cell.banniereSerie?.image = getImage(viewList[indexPath.row].poster)
        cell.index = indexPath.row
        cell.titre.text = viewList[indexPath.row].serie
        cell.saison.text =  String(viewList[indexPath.row].nbSaisons) + " saisons - " + String(viewList[indexPath.row].nbEpisodes) + " épisodes - " + String(viewList[indexPath.row].runtime) + " min"
        
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
        var allGenres : String = ""
        for unGenre in viewList[indexPath.row].genres {
            allGenres = allGenres + unGenre + " "
        }
        cell.genres.text = allGenres
        
        // Affichage du status
        arrondir(texte: cell.status, radius: 8.0)
        cell.status.text = computeSerieListe(serie : viewList[indexPath.row]).label
        cell.status.textColor = computeSerieListe(serie : viewList[indexPath.row]).couleur
        
        // Affichage du drapeau
        cell.drapeau.image = getDrapeau(country: viewList[indexPath.row].country)
        
        // Affichage du network
        cell.network.image = getImage(viewList[indexPath.row].networkLogo)
        //arrondir(fenetre: cell.network, radius: 4)
        cell.diffuseur.image = getLogoDiffuseur(diffuseur: viewList[indexPath.row].diffuseur)
        arrondir(fenetre: cell.diffuseur, radius: 4)

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

        cell.miniGraphe.setType(type: 0)
        cell.miniGraphe.setNeedsDisplay()
        
        return cell
    }
    
    
    func computeSerieListe(serie : Serie) -> (label: String, couleur: UIColor) {
        
        if (serie.watchlist) { return ("Watchlist", .systemGreen) }
        if (serie.unfollowed) { return ("Série abandonnée", .systemRed) }
        if (serie.enCours()) { return ("Série en cours", .systemBlue) }

        return ("Série finie", .systemGray2)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellExplorerListe = sender as! CellExplorerListe
        viewController.serie = viewList[tableCell.index]
        viewController.image = getImage(viewList[tableCell.index].banner)
        viewController.modeAffichage = self.typeAffichage
    }
    
    
    
    
    // Fonctions de filtrage
    //
    // -------------------------------------
    
    @IBAction func filtrer(_ sender: Any) {
        let bouton : UIButton = sender as! UIButton
        
        if (bouton.configuration?.background.strokeColor == .systemRed) {
            bouton.configuration?.background.strokeColor = .clear
        }
        else if (bouton.configuration?.background.strokeColor == .systemGreen) {
            bouton.configuration?.background.strokeColor = .systemRed
        }
        else {
            bouton.configuration?.background.strokeColor = .systemGreen
        }

        
        
        viewList = db.shows
        
        if (filtreFinies.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ ( ($0.watchlist == false) && ($0.enCours() == false) && ($0.unfollowed == false) ) }) }
        if (filtreFinies.configuration?.background.strokeColor == .systemRed ) { viewList = viewList.filter({ ( ($0.watchlist) || ($0.enCours()) || ($0.unfollowed) ) }) }
        if (filtreWatchlist.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.watchlist }) }
        if (filtreWatchlist.configuration?.background.strokeColor == .systemRed ) { viewList = viewList.filter({ $0.watchlist == false }) }
        if (filtreAbandonnees.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.unfollowed }) }
        if (filtreAbandonnees.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.unfollowed == false }) }
        if (filtreEnCours.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.enCours() }) }
        if (filtreEnCours.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.enCours() == false }) }

        if (filtreFrancais.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.country == "FR" }) }
        if (filtreFrancais.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.country != "FR" }) }
        if (filtreUS.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.country == "US" }) }
        if (filtreUS.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.country != "US" }) }
        if (filtreUK.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ (($0.country == "GB") || ($0.country == "UK") ) }) }
        if (filtreUK.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ (($0.country != "GB") && ($0.country != "UK") ) }) }
        if (filtreEspagnol.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.country == "ES" }) }
        if (filtreEspagnol.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.country != "ES" }) }
        if (filtreAllemand.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.country == "DE" }) }
        if (filtreAllemand.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.country != "DE" }) }
        if (filtreNorvegien.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.country == "NO" }) }
        if (filtreNorvegien.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.country != "NO" }) }
        if (filtreIsraelien.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.country == "IL" }) }
        if (filtreIsraelien.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.country != "IL" }) }
        if (filtreCoreen.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.country == "KR" }) }
        if (filtreCoreen.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.country != "KR" }) }

        if (filtreAppleTV.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.diffuseur == "Apple TV+" }) }
        if (filtreAppleTV.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.diffuseur != "Apple TV+" }) }
        if (filtreCanalPlus.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.diffuseur == "Canal+" }) }
        if (filtreCanalPlus.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.diffuseur != "Canal+" }) }
        if (filtrePrimeVideo.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.diffuseur == "Prime Video" }) }
        if (filtrePrimeVideo.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.diffuseur != "Prime Video" }) }
        if (filtreDisney.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.diffuseur == "Disney+" }) }
        if (filtreDisney.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.diffuseur != "Disney+" }) }
        if (filtreNetflix.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.diffuseur == "Netflix" }) }
        if (filtreNetflix.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.diffuseur != "Netflix" }) }
        if (filtreOCS.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.diffuseur == "OCS" }) }
        if (filtreOCS.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.diffuseur != "OCS" }) }
        if (filtreParamount.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.diffuseur == "Paramount+" }) }
        if (filtreParamount.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.diffuseur != "Paramount+" }) }
        if (filtreMax.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.diffuseur == "Max" }) }
        if (filtreMax.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.diffuseur != "Max" }) }

        if (filtreDates00.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.year < 2001 }) }
        if (filtreDates00.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.year > 2000 }) }
        if (filtreDates20.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.year > 2020 }) }
        if (filtreDates20.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.year < 2020 }) }
        if (filtreDates0010.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ (($0.year > 2000) && ($0.year < 2010)) }) }
        if (filtreDates0010.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ (($0.year < 2001) || ($0.year > 2009)) }) }
        if (filtreDates1020.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ (($0.year > 2009) && ($0.year < 2020)) }) }
        if (filtreDates1020.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ (($0.year < 2010) || ($0.year > 2019)) }) }

        if (bRate1.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 1 }) }
        if (bRate1.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 1 }) }
        if (bRate2.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 2 }) }
        if (bRate2.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 2 }) }
        if (bRate3.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 3 }) }
        if (bRate3.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 3 }) }
        if (bRate4.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 4 }) }
        if (bRate4.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 4 }) }
        if (bRate5.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 5 }) }
        if (bRate5.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 5 }) }
        if (bRate6.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 6 }) }
        if (bRate6.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 6 }) }
        if (bRate7.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 7 }) }
        if (bRate7.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 7 }) }
        if (bRate8.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 8 }) }
        if (bRate8.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 8 }) }
        if (bRate9.configuration?.background.strokeColor == .systemGreen) { viewList = viewList.filter({ $0.myRating == 9 }) }
        if (bRate9.configuration?.background.strokeColor == .systemRed) { viewList = viewList.filter({ $0.myRating != 9 }) }

        Trier()
        NbSeries.text = String(viewList.count)
    }
    
    
    
    
    
    // Fonctions de tri
    //
    // -------------------------------------
    
    func Trier() {
        if up {
            switch(tri) {
            case "titre":  viewList = viewList.sorted(by: { $0.serie > $1.serie })
            case "note":  viewList = viewList.sorted(by: { $0.myRating > $1.myRating })
            case "annee":  viewList = viewList.sorted(by: { $0.year > $1.year })
            case "consensus":  viewList = viewList.sorted(by: { $0.getGlobalRating() > $1.getGlobalRating() })

            default: viewList = viewList.sorted(by: { $0.serie > $1.serie })
            }
        }
        else {
            switch(tri) {
            case "titre":  viewList = viewList.sorted(by: { $0.serie < $1.serie })
            case "note":  viewList = viewList.sorted(by: { $0.myRating < $1.myRating })
            case "annee":  viewList = viewList.sorted(by: { $0.year < $1.year })
            case "consensus":  viewList = viewList.sorted(by: { $0.getGlobalRating() < $1.getGlobalRating() })

            default: viewList = viewList.sorted(by: { $0.serie < $1.serie })
            }
        }
            
        self.liste.reloadData()
        self.view.setNeedsDisplay()
    }
    
    @IBAction func TriTitre(_ sender: Any) {
        cleanTri()
        triTitre.configuration?.background.strokeColor = .systemGreen
        tri = "titre"
        Trier()
    }

    @IBAction func TriNote(_ sender: Any) {
        cleanTri()
        triNote.configuration?.background.strokeColor = .systemGreen
        tri = "note"
        Trier()
    }

    @IBAction func TriAnnee(_ sender: Any) {
        cleanTri()
        triAnnee.configuration?.background.strokeColor = .systemGreen
        tri = "annee"
        Trier()
    }

    @IBAction func TriConsensus(_ sender: Any) {
        cleanTri()
        triConsensus.configuration?.background.strokeColor = .systemGreen
        tri = "consensus"
        Trier()
    }

    @IBAction func TriUp(_ sender: Any) {
        cleanTriSens()
        triAsc.configuration?.background.strokeColor = .systemGreen
        up = false
        Trier()
    }
    
    @IBAction func TriDown(_ sender: Any) {
        cleanTriSens()
        triDesc.configuration?.background.strokeColor = .systemGreen
        up = true
        Trier()
    }

    func cleanTriSens() {
        triAsc.configuration?.background.strokeColor = .clear
        triDesc.configuration?.background.strokeColor = .clear
    }

    func cleanTri() {
        triTitre.configuration?.background.strokeColor = .clear
        triNote.configuration?.background.strokeColor = .clear
        triAnnee.configuration?.background.strokeColor = .clear
        triConsensus.configuration?.background.strokeColor = .clear
    }
}
