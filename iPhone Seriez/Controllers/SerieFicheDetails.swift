//
//  SerieFicheDetails.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 26/06/2022.
//  Copyright © 2022 Home. All rights reserved.
//

import UIKit
import ContactsUI


class CellCritique: UITableViewCell {
    @IBOutlet weak var critiqueComment: UITextView!
    @IBOutlet weak var critiqueLogo: UIImageView!
    @IBOutlet weak var critiqueDate: UILabel!
    @IBOutlet weak var critiqueJournal: UILabel!
    @IBOutlet weak var critiqueAuteur: UILabel!
    @IBOutlet weak var critiqueNote: UILabel!
    
}

class CellDiffuseur: UITableViewCell {
    @IBOutlet weak var diffuseurLogo: UIImageView!
    @IBOutlet weak var diffuseurName: UILabel!
    @IBOutlet weak var diffuseurQualite: UILabel!
    @IBOutlet weak var diffuseurType: UILabel!
    @IBOutlet weak var diffuseurContenu: UILabel!
    @IBOutlet weak var source: UIImageView!
}

class CellSerieCasting: UITableViewCell {
    @IBOutlet weak var castingPhoto: UIImageView!
    @IBOutlet weak var castingActeur: UILabel!
    @IBOutlet weak var castingRole: UILabel!
}



class SerieFicheDetails: UIViewController, UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate {
    
    var serie : Serie = Serie(serie: "")
    
    var allCritics : [Critique] = []
    var allDiffuseurs : [Diffuseur] = []
    var allCasting : [Casting] = []
    
    var parentalGuide : NSMutableDictionary = [:]
    
    var detailType : Int = 2
    
    let detailTypeCritique = 0
    let detailTypeCasting = 1
    let detailTypeDiffuseurs = 2
    let detailTypeSaisons = 3
    let detailTypeRatings = 4
    let detailTypeNotes = 5
    let detailTypeAdvisor = 6
    
    @IBOutlet weak var tableDetailCritique: UITableView!
    @IBOutlet weak var tableDetailDiffuseur: UITableView!
    @IBOutlet weak var tableDetailCasting: UITableView!
    @IBOutlet weak var tableDetailSaisons: UITableView!
    @IBOutlet weak var noteSelect: UIView!
    @IBOutlet weak var advisorSelect: UIView!
    
    @IBOutlet weak var viewDetailRatings: UIView!
    @IBOutlet weak var graphe: Graph!
    @IBOutlet weak var spiderGraph: GraphMiniSerie!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var boutonMyRating: UIButton!
    
    @IBOutlet weak var bRate1: UIButton!
    @IBOutlet weak var bRate2: UIButton!
    @IBOutlet weak var bRate3: UIButton!
    @IBOutlet weak var bRate4: UIButton!
    @IBOutlet weak var bRate5: UIButton!
    @IBOutlet weak var bRate6: UIButton!
    @IBOutlet weak var bRate7: UIButton!
    @IBOutlet weak var bRate8: UIButton!
    @IBOutlet weak var bRate9: UIButton!
    
    @IBOutlet weak var autre: UITextField!
    @IBOutlet weak var advisorName: UILabel!
    @IBOutlet weak var advisorImage: UIImageView!
    @IBOutlet weak var viewAdvisorChoice: UIView!
    @IBOutlet weak var viewAdvisorChange: UIView!
    @IBOutlet weak var boutonValiderAdvisor: UIView!
    
    var newRate : Int = 0
    var newConseil : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newRate = serie.myRating
        newConseil = serie.nomConseil
        
        tableDetailCritique.isHidden = true
        tableDetailDiffuseur.isHidden = true
        tableDetailCasting.isHidden = true
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            tableDetailSaisons.isHidden = true
            viewDetailRatings.isHidden = true
            
            spiderGraph.sendNotes(rateTrakt: serie.getFairGlobalRatingTrakt(),
                                  rateBetaSeries: serie.getFairGlobalRatingBetaSeries(),
                                  rateMoviedb: serie.getFairGlobalRatingMoviedb(),
                                  rateIMdb: serie.getFairGlobalRatingIMdb(),
                                  rateTVmaze: serie.getFairGlobalRatingTVmaze(),
                                  rateRottenTomatoes: serie.getFairGlobalRatingRottenTomatoes(),
                                  rateMetaCritic: serie.getFairGlobalRatingMetaCritic(),
                                  rateAlloCine: serie.getFairGlobalRatingAlloCine(),
                                  rateSensCritique: serie.getFairGlobalRatingSensCritique(),
                                  rateSIMKL: serie.getFairGlobalRatingSIMKL() )
        }
        else {
            noteSelect.isHidden = true
            advisorSelect.isHidden = true
        }
        
        if (detailType == detailTypeCritique) {
            let queue : OperationQueue = OperationQueue()
            
            queue.addOperation(BlockOperation(block: { self.allCritics.append(contentsOf: alloCine.getCritics(serie: self.serie.serie, saison: 1)) } ) )
//            queue.addOperation(BlockOperation(block: { self.allCritics.append(contentsOf: metaCritic.getCritics(slug: self.serie.slugMetaCritic, saison: 1)) } ) )
            queue.addOperation(BlockOperation(block: { self.allCritics.append(contentsOf: rottenTomatoes.getCritics(serie: self.serie.serie, saison: 1)) } ) )
            queue.addOperation(BlockOperation(block: { self.allCritics.append(contentsOf: imdb.getCritics(IMDBid: self.serie.idIMdb, saison: 1)) } ) )

            queue.waitUntilAllOperationsAreFinished()
            tableDetailCritique.isHidden = false
        }
        else if (detailType == detailTypeDiffuseurs) {
            allDiffuseurs = justWatch.getDiffuseurs(serie: serie.serie, saison: 0)
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
        else if (detailType == detailTypeSaisons) {
            tableDetailSaisons.isHidden = false
        }
        else if (detailType == detailTypeNotes) {
            noteSelect.isHidden = false
            
            // Boutons de choix des ratings
            arrondirButton(texte: bRate1, radius: 20.0)
            bRate1.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate1.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 1.0)
            
            arrondirButton(texte: bRate2, radius: 20.0)
            bRate2.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate2.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 2.0)
            
            arrondirButton(texte: bRate3, radius: 20.0)
            bRate3.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate3.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 3.0)
            
            arrondirButton(texte: bRate4, radius: 20.0)
            bRate4.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate4.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 4.0)
            
            arrondirButton(texte: bRate5, radius: 20.0)
            bRate5.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate5.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 5.0)
            
            arrondirButton(texte: bRate6, radius: 20.0)
            bRate6.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate6.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 6.0)
            
            arrondirButton(texte: bRate7, radius: 20.0)
            bRate7.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate7.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 7.0)
            
            arrondirButton(texte: bRate8, radius: 20.0)
            bRate8.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate8.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 8.0)
            
            arrondirButton(texte: bRate9, radius: 20.0)
            bRate9.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate9.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 9.0)
            
        }
        else if (detailType == detailTypeAdvisor) {
            
            makeGradiant(carre: viewAdvisorChange, couleur: "Blanc")
            makeGradiant(carre: viewAdvisorChoice, couleur: "Blanc")
            makeGradiant(carre: boutonValiderAdvisor, couleur: "Rouge")
            
            advisorName.text = serie.nomConseil
            
            switch serie.nomConseil {
            case "Une Serie ?": advisorImage.image = #imageLiteral(resourceName: "2021_05_15_0u9_Kleki.png")
            case "Presse & média": advisorImage.image = UIImage(systemName: "newspaper")
            case "": advisorImage.image = UIImage(systemName: "person.circle")
            default: advisorImage.image = UIImage(systemName: "person.circle.fill")
            }
            
            let contact : CNContact = getContactFromID(contactID: serie.nomConseil)
            
            if (contact.givenName != "") {
                if (contact.nickname == "")     { advisorName.text = contact.givenName }
                else                            { advisorName.text = contact.nickname }
                    
                if (contact.thumbnailImageData == nil) { advisorImage.image = UIImage(systemName: "book") }
                else                                   { advisorImage.image = UIImage(data: contact.thumbnailImageData!) }
            }

            advisorSelect.isHidden = false
        }
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tableDetailCritique) { return allCritics.count }
        else if (tableView == tableDetailDiffuseur) { return allDiffuseurs.count }
        else if (tableView == tableDetailCasting) { return allCasting.count }
        else if (tableView == tableDetailSaisons) { return serie.saisons.count }
        else { return 0 }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tableDetailCritique) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailCritique", for: indexPath) as! CellCritique
            
            cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1
            
            cell.critiqueComment.text = allCritics[indexPath.row].texte
            cell.critiqueDate.text = allCritics[indexPath.row].date
            cell.critiqueJournal.text = allCritics[indexPath.row].journal
            cell.critiqueAuteur.text = allCritics[indexPath.row].auteur
            cell.critiqueNote.text = allCritics[indexPath.row].note

            if (allCritics[indexPath.row].source == srcMetaCritic) { cell.critiqueLogo.image = #imageLiteral(resourceName: "metacritic.png") }
            if (allCritics[indexPath.row].source == srcRottenTom) { cell.critiqueLogo.image = #imageLiteral(resourceName: "rottentomatoes.ico") }
            if (allCritics[indexPath.row].source == srcAlloCine) { cell.critiqueLogo.image = #imageLiteral(resourceName: "allocine.ico") }
            if (allCritics[indexPath.row].source == srcIMdb) { cell.critiqueLogo.image =  #imageLiteral(resourceName: "imdb.ico") }

            return cell
        }
        else if (tableView == tableDetailDiffuseur) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailDiffuseur", for: indexPath) as! CellDiffuseur
            
            cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1
            
            cell.diffuseurName.text = allDiffuseurs[indexPath.row].name
            arrondirLabel(texte: cell.diffuseurType, radius: 10)
            
            cell.diffuseurLogo.image = getImage(allDiffuseurs[indexPath.row].logo)
            cell.diffuseurQualite.text = allDiffuseurs[indexPath.row].qualite
            cell.diffuseurContenu.text = allDiffuseurs[indexPath.row].contenu
            
            switch allDiffuseurs[indexPath.row].mode {
            case "Streaming":
                cell.diffuseurType.text = "Streaming"
                cell.diffuseurType.backgroundColor = .systemPink
                break
            case "Achat":
                cell.diffuseurType.text = "Achat"
                cell.diffuseurType.backgroundColor = .systemBlue
                break
            case "Location":
                cell.diffuseurType.text = "Location"
                cell.diffuseurType.backgroundColor = .systemBrown
                break
            case "forced":
                cell.diffuseurType.text = "Forcé"
                cell.diffuseurType.backgroundColor = .systemOrange
                break
            default:
                cell.diffuseurType.text = allDiffuseurs[indexPath.row].mode
                cell.diffuseurType.backgroundColor = .systemGray
            }
            
            switch allDiffuseurs[indexPath.row].sourceDiffuseur {
            case srcBetaSeries:
                cell.source.image = #imageLiteral(resourceName: "betaseries.png")
                break
            case srcJustWatch:
                cell.source.image = #imageLiteral(resourceName: "justwatch.ico")
                break
            default:
                cell.source.image = UIImage()
            }
            
            
            return cell
        }
        else if (tableView == tableDetailCasting) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailCasting", for: indexPath) as! CellSerieCasting
            
            cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1
            
            cell.castingPhoto.image = getImage(allCasting[indexPath.row].photo)
            cell.castingActeur.text = allCasting[indexPath.row].name
            cell.castingRole.text = allCasting[indexPath.row].personnage
            
            return cell
        }
        else if (tableView == tableDetailSaisons) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellDetailSaison", for: indexPath) as! CellSaison
            cell.saison.text = "Saison " + String(indexPath.row + 1)
            cell.episodes.text = String(serie.saisons[indexPath.row].nbEpisodes) + " épisodes"
            
            cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1
            
            if (serie.saisons[indexPath.row].starts == ZeroDate) { cell.debut.text = "TBD" }
            else { cell.debut.text = dateFormShort.string(from: serie.saisons[indexPath.row].starts) }
            
            if (serie.saisons[indexPath.row].ends == ZeroDate) { cell.fin.text = "TBD" }
            else { cell.fin.text = dateFormShort.string(from: serie.saisons[indexPath.row].ends) }
            
            cell.graphe.setSerie(serie: serie, saison: indexPath.row + 1)
            cell.graphe.setType(type: 3)
            cell.graphe.setNeedsDisplay()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pressedButton = sender as! UIButton
        
        if (pressedButton == bRate1) { newRate = 1 }
        else if (pressedButton == bRate2) { newRate = 2 }
        else if (pressedButton == bRate3) { newRate = 3 }
        else if (pressedButton == bRate4) { newRate = 4 }
        else if (pressedButton == bRate5) { newRate = 5 }
        else if (pressedButton == bRate6) { newRate = 6 }
        else if (pressedButton == bRate7) { newRate = 7 }
        else if (pressedButton == bRate8) { newRate = 8 }
        else if (pressedButton == bRate9) { newRate = 9 }
        
        let viewController = segue.destination as! SerieFiche
        viewController.serie.myRating = newRate
        viewController.serie.nomConseil = newConseil
    }
    
    
    @IBAction func chooseFromContacts(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if (contact.nickname == "") {
            advisorName.text = contact.givenName
        }
        else {
            advisorName.text = contact.nickname
        }
            
        if (contact.thumbnailImageData == nil) {
            advisorImage.image = UIImage(systemName: "book")
        }
        else {
            advisorImage.image = UIImage(data: contact.thumbnailImageData!)
        }
        
        newConseil = contact.identifier
    }

    
    @IBAction func chooseOther(_ sender: Any) {
        if (autre.text == "") {
            advisorImage.image = UIImage(systemName: "person.circle")
            advisorName.text = "Personne"
        }
        else {
            advisorImage.image = UIImage(systemName: "person.circle.fill")
            advisorName.text = autre.text
        }
        newConseil = autre.text ?? ""
    }
    
    
    @IBAction func chooseUneSerie(_ sender: Any) {
        advisorName.text = "Une Série ?"
        advisorImage.image = #imageLiteral(resourceName: "2021_05_15_0u9_Kleki.png")
        newConseil = "Une Serie ?"
    }
    
    
    @IBAction func choosePress(_ sender: Any) {
        advisorName.text = "Presse & média"
        advisorImage.image = UIImage(systemName: "newspaper")
        newConseil = "Presse & média"
    }
    
    
    @IBAction func chooseNoOne(_ sender: Any) {
        advisorName.text = "Personne"
        advisorImage.image = UIImage(systemName: "person.circle")
        newConseil = ""
    }
    
    
//    func retrieveContactsWithStore(store: CNContactStore)
//    {
//        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey,CNContactImageDataKey, CNContactEmailAddressesKey] as [Any]
//        let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
//        var cnContacts = [CNContact]()
//        do {
//            try store.enumerateContacts(with: request){
//                (contact, cursor) -> Void in
//                if (!contact.phoneNumbers.isEmpty) {
//                }
//                
//                if contact.isKeyAvailable(CNContactImageDataKey) {
//                    if let contactImageData = contact.imageData {
//                        print(UIImage(data: contactImageData)) // Print the image set on the contact
//                    }
//                } else { // No Image available }
//                
//                if (!contact.emailAddresses.isEmpty) {  }
//                
//                cnContacts.append(contact)
//            }
//        } catch let error {
//            NSLog("Fetch contact error: \(error)")
//        }
//        
//        NSLog(">>>> Contact list:")
//        for contact in cnContacts {
//            let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
//            NSLog("\(fullName): \(contact.phoneNumbers.description)")
//        }
//    }
    
    
}

