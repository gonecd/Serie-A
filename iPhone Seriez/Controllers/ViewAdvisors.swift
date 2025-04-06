//
//  ViewAdvisors.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 03/11/2024.
//  Copyright © 2024 Home. All rights reserved.
//

import UIKit
import ContactsUI

class CellAdvisorListe: UITableViewCell {
    
    @IBOutlet weak var banniereSerie: UIImageView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var miniGraphe: GraphMiniSerie!
    @IBOutlet weak var globalRating: UITextField!
    @IBOutlet weak var myRating: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var drapeau: UIImageView!
    
    var index: Int = 0
}

struct Advisors {
    var id      : String
    var prenom  : String
    var nom     : String
    var surnom  : String
    var image   : UIImage
}

class ViewAdvisors: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    var viewList        : [Serie] = [Serie]()
    var AdvisorsList    : [Advisors] = []
    
    @IBOutlet var liste: UITableView!
    @IBOutlet weak var cadreFiltre: UIView!
    @IBOutlet weak var cadreListe: UIView!
    @IBOutlet weak var cadrePie: UIView!
    @IBOutlet weak var cadreXY: UIView!
    
    @IBOutlet weak var labelWatchlist: UITextField!
    @IBOutlet weak var labelEnCours: UITextField!
    @IBOutlet weak var labelFinies: UITextField!
    @IBOutlet weak var labelAbandon: UITextField!
    
    @IBOutlet weak var NbSeries: UILabel!
    @IBOutlet weak var nbWatchlist: UILabel!
    @IBOutlet weak var nbEnCours: UILabel!
    @IBOutlet weak var nbFinies: UILabel!
    @IBOutlet weak var nbAbandon: UILabel!
    
    @IBOutlet weak var graphePie: GrapheAdvisorPie!
    @IBOutlet weak var grapheXY: GrapheAdvisorXY!
    
    @IBOutlet weak var bRate1: UIButton!
    @IBOutlet weak var bRate2: UIButton!
    @IBOutlet weak var bRate3: UIButton!
    @IBOutlet weak var bRate4: UIButton!
    @IBOutlet weak var bRate5: UIButton!
    @IBOutlet weak var bRate6: UIButton!
    @IBOutlet weak var bRate7: UIButton!
    @IBOutlet weak var bRate8: UIButton!
    @IBOutlet weak var bRate9: UIButton!
    @IBOutlet weak var bRateNone: UIButton!

    @IBOutlet weak var labelConsensus: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let advisorsFullList  : [String] = viewList.map({$0.nomConseil})
        let advisorsShortList : [String] = Array(Set(advisorsFullList))
        
        for idAdv in advisorsShortList {
            var unAdvisor : Advisors = Advisors(id: idAdv, prenom: "", nom: "", surnom: "", image: UIImage())
            
            if (idAdv == "Une Serie ?") {
                unAdvisor.nom = ""
                unAdvisor.prenom = "Une Serie ?"
                unAdvisor.surnom = "Une Serie ?"
                unAdvisor.image = #imageLiteral(resourceName: "2021_05_15_0u9_Kleki.png")
            }
            else if (idAdv == "Presse & média") {
                unAdvisor.nom = ""
                unAdvisor.prenom = "Presse & média"
                unAdvisor.surnom = "Presse & média"
                unAdvisor.image = UIImage(systemName: "newspaper") ?? UIImage()
            }
            else if (idAdv == "") {
                unAdvisor.nom = ""
                unAdvisor.prenom = "Personne"
                unAdvisor.surnom = "Personne"
                unAdvisor.image = UIImage(systemName: "person.circle") ?? UIImage()
            } else {
                let unContact : CNContact = getContactFromID(contactID: idAdv)
                
                if ((unContact.familyName != "") || (unContact.givenName != "") || (unContact.nickname != "")) {
                    unAdvisor.nom = unContact.familyName
                    unAdvisor.prenom = unContact.nickname
                    unAdvisor.surnom = unContact.givenName
                    if (unContact.thumbnailImageData == nil) { unAdvisor.image = UIImage(systemName: "book") ?? UIImage() }
                    else                                     { unAdvisor.image = UIImage(data: unContact.thumbnailImageData!) ?? UIImage() }
                }
                else {
                    unAdvisor.nom = ""
                    unAdvisor.prenom = idAdv
                    unAdvisor.surnom = idAdv
                    unAdvisor.image = UIImage(systemName: "person.circle.fill") ?? UIImage()
                }
            }
            
            AdvisorsList.append(unAdvisor)
        }
        AdvisorsList = AdvisorsList.sorted(by: {$0.surnom < $1.surnom } )
        
        arrondir(texte: labelWatchlist, radius: 6.0)
        arrondir(texte: labelEnCours, radius: 6.0)
        arrondir(texte: labelFinies, radius: 6.0)
        arrondir(texte: labelAbandon, radius: 6.0)
        
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            makeGradiant(carre: cadreFiltre, couleur: "Blanc")
            makeGradiant(carre: cadreListe, couleur: "Blanc")
            makeGradiant(carre: cadrePie, couleur: "Blanc")
            makeGradiant(carre: cadreXY, couleur: "Blanc")
            
            // Boutons des ratings
            arrondirButton(texte: bRate1, radius: 6.0)
            bRate1.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate1.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 1.0)
            
            arrondirButton(texte: bRate2, radius: 6.0)
            bRate2.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate2.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 2.0)
            
            arrondirButton(texte: bRate3, radius: 6.0)
            bRate3.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate3.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 3.0)
            
            arrondirButton(texte: bRate4, radius: 6.0)
            bRate4.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate4.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 4.0)
            
            arrondirButton(texte: bRate5, radius: 6.0)
            bRate5.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate5.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 5.0)
            
            arrondirButton(texte: bRate6, radius: 6.0)
            bRate6.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate6.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 6.0)
            
            arrondirButton(texte: bRate7, radius: 6.0)
            bRate7.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate7.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 7.0)
            
            arrondirButton(texte: bRate8, radius: 6.0)
            bRate8.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate8.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 8.0)
            
            arrondirButton(texte: bRate9, radius: 6.0)
            bRate9.setTitleColor(UIColor.systemBackground, for: .normal)
            bRate9.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 9.0)
            
            arrondirButton(texte: bRateNone, radius: 6.0)
            bRateNone.setTitleColor(UIColor.systemBackground, for: .normal)
            bRateNone.backgroundColor = .systemGray
            
            labelConsensus.text = " Consensus 👍🏼 "
            labelConsensus.layer.borderColor = UIColor.systemBlue.cgColor
            labelConsensus.layer.borderWidth = 2
            labelConsensus.layer.cornerRadius = 10
            labelConsensus.layer.masksToBounds = true
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func computeSerieListe(serie : Serie) -> (label: String, couleur: UIColor) {
        if (serie.watchlist) { return ("Watchlist", .systemGreen) }
        if (serie.unfollowed) { return ("Série abandonnée", .systemRed) }
        if (serie.enCours()) { return ("Série en cours", .systemBlue) }
        
        return ("Série finie", .systemGray2)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellAdvisorListe = sender as! CellAdvisorListe
        viewController.serie = viewList[tableCell.index]
        viewController.image = getImage(viewList[tableCell.index].banner)
    }
    
    
    
    
    
    // Fonctions de la table
    //
    // -------------------------------------

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellAdvisorListe", for: indexPath) as! CellAdvisorListe
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIcolor2 : UIcolor1
        
        cell.banniereSerie?.image = getImage(viewList[indexPath.row].poster)
        cell.index = indexPath.row
        cell.titre.text = viewList[indexPath.row].serie
        
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
        
        // Affichage du status
        arrondir(texte: cell.status, radius: 8.0)
        cell.status.text = computeSerieListe(serie : viewList[indexPath.row]).label
        cell.status.textColor = computeSerieListe(serie : viewList[indexPath.row]).couleur
        
        // Affichage du drapeau
        cell.drapeau.image = getDrapeau(country: viewList[indexPath.row].country)
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

    // Fonctions du picker
    //
    // -------------------------------------

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AdvisorsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewList = db.shows
        viewList = viewList.filter({ $0.nomConseil == AdvisorsList[row].id })
        
        refreshAfterFiler()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let advisorView = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 40))
        
        let advisorName  : UILabel     = UILabel(frame: CGRect(x: 100, y: 5, width: 240, height: 30))
        let advisorImage : UIImageView = UIImageView(frame: CGRect(x: 30, y: 5, width: 30, height: 30))
        
        advisorView.addSubview(advisorName)
        advisorView.addSubview(advisorImage)

        advisorName.text  = AdvisorsList[row].surnom
        advisorImage.image  = AdvisorsList[row].image

        return advisorView
    }
    
    
    
    
    // Fonctions de filtrage
    //
    // -------------------------------------
    
    func refreshAfterFiler() {
        
            let countWatchlist : Int = viewList.count(where: { $0.watchlist })
            let countEnCours : Int = viewList.count(where: { $0.enCours() })
            let countFinies : Int = viewList.count(where: { ( !($0.watchlist || $0.enCours() || $0.unfollowed) ) })
            let countAbandon : Int = viewList.count(where: { $0.unfollowed })
            
            NbSeries.text = String(viewList.count)
            nbWatchlist.text = String(countWatchlist)
            nbEnCours.text = String(countEnCours)
            nbFinies.text = String(countFinies)
            nbAbandon.text = String(countAbandon)
            
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            // Raffraichir le camembert
            graphePie.setValues(vAbandon: countAbandon, vFinies: countFinies, vWatchlist: countWatchlist, vEnCours: countEnCours)
            graphePie.setNeedsDisplay()
            
            // Raffraichir le graphe
            grapheXY.liste = viewList
            grapheXY.setNeedsDisplay()
        }
        
        // Raffraichir la liste
        liste.reloadData()
        liste.setNeedsDisplay()
    }
}




// Graphes
//
// -------------------------------------

class GrapheAdvisorPie: UIView  {
    var valAbandon   : Int = 10
    var valFinies    : Int = 10
    var valWatchlist : Int = 10
    var valEnCours   : Int = 10
    
    func setValues(vAbandon: Int, vFinies: Int, vWatchlist: Int, vEnCours: Int) {
        valAbandon = vAbandon
        valFinies = vFinies
        valWatchlist = vWatchlist
        valEnCours = vEnCours
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        let total : Int = valAbandon + valFinies + valWatchlist + valEnCours
        
        traceUnArc(color: .systemGray, debut: 0.0, fin: CGFloat(valFinies)/CGFloat(total))
        traceUnArc(color: .systemBlue, debut: CGFloat(valFinies)/CGFloat(total), fin: CGFloat(valFinies + valEnCours)/CGFloat(total))
        traceUnArc(color: .systemRed, debut: CGFloat(valFinies + valEnCours)/CGFloat(total), fin: CGFloat(valFinies + valEnCours + valAbandon)/CGFloat(total))
        traceUnArc(color: .systemGreen, debut: CGFloat(valFinies + valEnCours + valAbandon)/CGFloat(total), fin: 1.0)
    }
    
    func traceUnArc(color: UIColor, debut: CGFloat, fin: CGFloat) {
        let centreX : CGFloat = 80.0
        let centreY : CGFloat = 80.0
        let rayon   : CGFloat = 75.0
        
        UIColor.systemBackground.setStroke()
        color.withAlphaComponent(0.70).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 2.0
        path.move(to: CGPoint(x: centreX, y: centreY))
        path.addArc(withCenter: CGPoint(x: centreX, y: centreY), radius: rayon, startAngle: 2 * .pi * debut, endAngle: 2 * .pi * fin, clockwise: true)
        path.fill()
        path.stroke()
    }
}


class GrapheAdvisorXY: UIView  {
    var liste: [Serie] = [Serie]()
    
    let origineX : CGFloat = 30.0
    var origineY : CGFloat = 0.0
    var hauteur : CGFloat = 0.0
    var largeur : CGFloat = 0.0

    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineY = self.frame.height - origineX
        hauteur  = self.frame.height - origineX - 30.0
        largeur  = self.frame.width - origineX - 10.0

        traceFond()
        
        for uneSerie in liste {
            var color : UIColor = .systemGray
            
            if (uneSerie.unfollowed) { color = .systemRed }
            else if (uneSerie.enCours()) { color = .systemBlue }
            else if (uneSerie.watchlist) { color = .systemGreen }
            else { color = .black }
            
            traceUnPoint(consensus: uneSerie.getGlobalRating(), myRate: 10*uneSerie.myRating, serie: uneSerie.serie, color: color)
        }
    }
    
    func traceFond() {
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: colorAxis]
        
        // Lignes
        colorAxis.setStroke()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()
        
        // Lignes achurées horizontales & verticales
        for i:Int in 1 ..< 5 {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i)/5)))
            pathLine.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i)/5)))
            pathLine.stroke()
        }
        
        for i:Int in 1 ..< 10 {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            
            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / 10), y: origineY))
            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / 10), y: origineY - hauteur))
            pathLine.stroke()
        }
        
        // Légende en Y
        for i:Int in 0 ..< 6 {
            let legendeY : NSString = String(i*2) as NSString
            legendeY.draw(in: CGRect(x: 7, y: origineY - (hauteur * CGFloat(i)/5) - 7, width: 20, height: 10), withAttributes: textAttributes)
            
        }
    }
    
    func traceUnPoint(consensus: Int, myRate: Int, serie: String, color: UIColor) {
        let diametre : CGFloat = 8.0
        let offset : CGFloat = 15.0
        var myRateCorrected : Int = myRate
        
        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        if (myRate == -10) { myRateCorrected = 0 }
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + (largeur * CGFloat(myRateCorrected) / 100) + offset, y: origineY - (hauteur * CGFloat(consensus) / 100 ) ),
                    radius: diametre / 2, startAngle: 2 * .pi, endAngle: 0, clockwise: false)
        
        path.stroke()
        path.fill()
        
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                              NSAttributedString.Key.foregroundColor: color]

        serie.draw(in: CGRect(x: origineX + (largeur * CGFloat(myRateCorrected) / 100) + 8 + offset, y: origineY - (hauteur * CGFloat(consensus) / 100 ) - 10, width: 160, height: 12), withAttributes: textAttributes)
    }
}
