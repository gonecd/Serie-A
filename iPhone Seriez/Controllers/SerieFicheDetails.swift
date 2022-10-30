//
//  SerieFicheDetails.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 26/06/2022.
//  Copyright © 2022 Home. All rights reserved.
//

import UIKit



class CellCritique: UITableViewCell {
    @IBOutlet weak var critiqueComment: UITextView!
    @IBOutlet weak var critiqueLogo: UIImageView!
    @IBOutlet weak var critiqueDate: UILabel!
    @IBOutlet weak var critiqueJournal: UILabel!
    @IBOutlet weak var critiqueAuteur: UILabel!
}

class CellDiffuseur: UITableViewCell {
    @IBOutlet weak var diffuseurLogo: UIImageView!
    @IBOutlet weak var diffuseurName: UILabel!
    @IBOutlet weak var diffuseurQualite: UILabel!
    @IBOutlet weak var diffuseurType: UILabel!
    @IBOutlet weak var diffuseurPrix: UILabel!
    @IBOutlet weak var diffuseurContenu: UILabel!
}

class CellSerieCasting: UITableViewCell {
    @IBOutlet weak var castingPhoto: UIImageView!
    @IBOutlet weak var castingActeur: UILabel!
    @IBOutlet weak var castingRole: UILabel!
}



class SerieFicheDetails: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var serie : Serie = Serie(serie: "")
    
    var allCritics : [Critique] = []
    var allDiffuseurs : [Diffuseur] = []
    var allCasting : [Casting] = []

    
    var detailType : Int = 2
    
    let detailTypeCritique = 0
    let detailTypeCasting = 1
    let detailTypeDiffuseurs = 2
    let detailTypeSaisons = 3
    let detailTypeRatings = 4

    @IBOutlet weak var tableDetailCritique: UITableView!
    @IBOutlet weak var tableDetailDiffuseur: UITableView!
    @IBOutlet weak var tableDetailCasting: UITableView!

    @IBOutlet weak var viewDetailRatings: UIView!
    @IBOutlet weak var graphe: Graph!
    @IBOutlet weak var spiderGraph: GraphMiniSerie!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var boutonMyRating: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableDetailCritique.isHidden = true
        tableDetailDiffuseur.isHidden = true
        tableDetailCasting.isHidden = true
        viewDetailRatings.isHidden = true

        print("Details de la serie : \(serie.serie)")
        spiderGraph.sendNotes(rateTrakt: serie.getFairGlobalRatingTrakt(),
                              rateBetaSeries: serie.getFairGlobalRatingBetaSeries(),
                              rateMoviedb: serie.getFairGlobalRatingMoviedb(),
                              rateIMdb: serie.getFairGlobalRatingIMdb(),
                              rateTVmaze: serie.getFairGlobalRatingTVmaze(),
                              rateRottenTomatoes: serie.getFairGlobalRatingRottenTomatoes(),
                              rateMetaCritic: serie.getFairGlobalRatingMetaCritic(),
                              rateAlloCine: serie.getFairGlobalRatingAlloCine(),
                              rateSensCritique: serie.getFairGlobalRatingSensCritique() )

        if (detailType == detailTypeCritique) {
            let queue : OperationQueue = OperationQueue()

            queue.addOperation(BlockOperation(block: { self.allCritics.append(contentsOf: alloCine.getCritics(serie: self.serie.serie, saison: 1)) } ) )
            queue.addOperation(BlockOperation(block: { self.allCritics.append(contentsOf: metaCritic.getCritics(serie: self.serie.serie, saison: 1)) } ) )
            queue.addOperation(BlockOperation(block: { self.allCritics.append(contentsOf: rottenTomatoes.getCritics(serie: self.serie.serie, saison: 1)) } ) )

            queue.waitUntilAllOperationsAreFinished()
            tableDetailCritique.isHidden = false
        }
        else if (detailType == detailTypeDiffuseurs) {
            allDiffuseurs = justWatch.getDiffuseurs(serie: serie.serie)
            allDiffuseurs.append(contentsOf: betaSeries.getDiffuseurs(idTVDB : serie.idTVdb, idIMDB : serie.idIMdb))
            tableDetailDiffuseur.isHidden = false
        }
        else if (detailType == detailTypeCasting) {
            allCasting = theMoviedb.getCasting(idMovieDB: serie.idMoviedb, saison: 0, episode: 0)
            tableDetailCasting.isHidden = false
        }
        else if (detailType == detailTypeRatings) {
            //Affichage du spider graph
            spiderGraph.setType(type: 3)
            spiderGraph.setNeedsDisplay()

            graphe.sendSerie(self.serie)
            graphe.setNeedsDisplay()
            
            let noteGlobale : Double = Double(serie.getGlobalRating())/10.0
            note.text = "👍🏼 " + String(noteGlobale)
            note.layer.borderColor = UIColor.systemBlue.cgColor
            note.layer.borderWidth = 2
            note.layer.cornerRadius = 10
            note.layer.masksToBounds = true
            
            // MyRating de la série
            if (serie.myRating < 1) {
                boutonMyRating.setTitle("-", for: .normal)
                boutonMyRating.backgroundColor = UIColor.systemGray
            }
            else {
                boutonMyRating.setTitle(String(serie.myRating), for: .normal)
                boutonMyRating.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: CGFloat(serie.myRating))
            }
            arrondirButton(texte: boutonMyRating, radius: 12.0)
            boutonMyRating.setTitleColor(UIColor.systemBackground, for: .normal)

            viewDetailRatings.isHidden = false
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tableDetailCritique) { return allCritics.count }
        else if (tableView == tableDetailDiffuseur) { return allDiffuseurs.count }
        else if (tableView == tableDetailCasting) { return allCasting.count }
        else { return 0 }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tableDetailCritique) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailCritique", for: indexPath) as! CellCritique
            
            cell.critiqueComment.text = allCritics[indexPath.row].texte
            cell.critiqueDate.text = allCritics[indexPath.row].date
            cell.critiqueJournal.text = allCritics[indexPath.row].journal
            cell.critiqueAuteur.text = allCritics[indexPath.row].auteur

            if (allCritics[indexPath.row].source == srcMetaCritic) { cell.critiqueLogo.image = #imageLiteral(resourceName: "metacritic.png") }
            if (allCritics[indexPath.row].source == srcRottenTom) { cell.critiqueLogo.image = #imageLiteral(resourceName: "rottentomatoes.ico") }
            if (allCritics[indexPath.row].source == srcAlloCine) { cell.critiqueLogo.image = #imageLiteral(resourceName: "allocine.ico") }
            
            return cell
        }
        else if (tableView == tableDetailDiffuseur) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailDiffuseur", for: indexPath) as! CellDiffuseur

            cell.diffuseurName.text = allDiffuseurs[indexPath.row].name
            arrondirLabel(texte: cell.diffuseurType, radius: 10)

            cell.diffuseurLogo.image = loadImage(allDiffuseurs[indexPath.row].logo)
            cell.diffuseurQualite.text = allDiffuseurs[indexPath.row].qualite
            cell.diffuseurPrix.text = allDiffuseurs[indexPath.row].prix
            cell.diffuseurContenu.text = allDiffuseurs[indexPath.row].contenu

            switch allDiffuseurs[indexPath.row].mode {
            case "rent":
                cell.diffuseurType.text = "Location"
                cell.diffuseurType.backgroundColor = .systemIndigo
                break
            case "buy":
                cell.diffuseurType.text = "Achat"
                cell.diffuseurType.backgroundColor = .systemBlue
                break
            case "flatrate":
                cell.diffuseurType.text = "Abonnement"
                cell.diffuseurType.backgroundColor = .systemTeal
                break
            case "VOD":
                cell.diffuseurType.text = "VOD"
                cell.diffuseurType.backgroundColor = .systemPink
                break
            case "SVOD":
                cell.diffuseurType.text = "S-VOD"
                cell.diffuseurType.backgroundColor = .systemPurple
                break
            default:
                cell.diffuseurType.text = allDiffuseurs[indexPath.row].mode
                cell.diffuseurType.backgroundColor = .systemGray
            }

            return cell
        }
        else if (tableView == tableDetailCasting) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailCasting", for: indexPath) as! CellSerieCasting

            cell.castingPhoto.image = loadImage(allCasting[indexPath.row].photo)
            cell.castingActeur.text = allCasting[indexPath.row].name
            cell.castingRole.text = allCasting[indexPath.row].personnage


            return cell
        }

        return UITableViewCell()
    }
    
}

