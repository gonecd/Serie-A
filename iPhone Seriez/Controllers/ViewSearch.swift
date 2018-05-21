//
//  ViewSearch.swift
//  SerieA
//
//  Created by Cyril Delamare on 13/05/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class ViewSearch: UIViewController
{
    
    @IBOutlet weak var subViewAnnee: UIView!
    @IBOutlet weak var subViewTitre: UIView!
    @IBOutlet weak var subViewTexteLoc: UIView!
    @IBOutlet weak var subViewGenre: UIView!
    @IBOutlet weak var subViewNetwork: UIView!
    @IBOutlet weak var subViewLangue: UIView!
    
    @IBOutlet weak var carreResults: UIView!
    @IBOutlet weak var cptResults: UITextField!
    @IBOutlet weak var roueResults: UIActivityIndicatorView!
    
    @IBOutlet weak var labelTitre: UILabel!
    @IBOutlet weak var labelTexteLoc: UILabel!
    @IBOutlet weak var labelAnnee: UILabel!
    @IBOutlet weak var labelGenre: UILabel!
    @IBOutlet weak var labelNetwork: UILabel!
    @IBOutlet weak var labelLangue: UILabel!
    
    @IBOutlet weak var descriptionTexte: UITextView!
    
    @IBOutlet weak var inTitre: UISwitch!
    @IBOutlet weak var inResume: UISwitch!
    @IBOutlet weak var inCasting: UISwitch!
    
    @IBOutlet weak var titre: UITextField!
    @IBOutlet weak var debut: UITextField!
    @IBOutlet weak var fin: UITextField!
    
    @IBOutlet weak var ABC: UIButton!
    @IBOutlet weak var CBS: UIButton!
    @IBOutlet weak var FOX: UIButton!
    @IBOutlet weak var FX: UIButton!
    @IBOutlet weak var HBO: UIButton!
    @IBOutlet weak var NBC: UIButton!
    @IBOutlet weak var Netflix: UIButton!
    @IBOutlet weak var Showtime: UIButton!
    @IBOutlet weak var Starz: UIButton!
    @IBOutlet weak var TheCW: UIButton!
    @IBOutlet weak var Canal: UIButton!
    
    @IBOutlet weak var action: UIButton!
    @IBOutlet weak var adventure: UIButton!
    @IBOutlet weak var animation: UIButton!
    @IBOutlet weak var comedy: UIButton!
    @IBOutlet weak var crime: UIButton!
    @IBOutlet weak var documentary: UIButton!
    @IBOutlet weak var drama: UIButton!
    @IBOutlet weak var family: UIButton!
    @IBOutlet weak var fantasy: UIButton!
    @IBOutlet weak var history: UIButton!
    @IBOutlet weak var horror: UIButton!
    @IBOutlet weak var music: UIButton!
    @IBOutlet weak var mystery: UIButton!
    @IBOutlet weak var romance: UIButton!
    @IBOutlet weak var scienceFiction: UIButton!
    @IBOutlet weak var tvMovie: UIButton!
    @IBOutlet weak var thriller: UIButton!
    @IBOutlet weak var war: UIButton!
    @IBOutlet weak var western: UIButton!
    
    @IBOutlet weak var francais: UIButton!
    @IBOutlet weak var anglais: UIButton!
    
    var activeSubView : UIView!
    var seriesTrouvees : [Serie] = []
    var mode : Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)

        labelTitre.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelTexteLoc.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelAnnee.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelGenre.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelNetwork.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelLangue.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelTitre.frame.origin = CGPoint(x: 300.0, y: 10.0)
        labelTexteLoc.frame.origin = CGPoint(x: 300.0, y: 10.0)
        labelAnnee.frame.origin = CGPoint(x: 10.0, y: 10.0)
        labelGenre.frame.origin = CGPoint(x: 10.0, y: 10.0)
        labelNetwork.frame.origin = CGPoint(x: 10.0, y: 10.0)
        labelLangue.frame.origin = CGPoint(x: 10.0, y: 10.0)

        makeGradiant(carre: subViewTitre, couleur: "Rouge")
        makeGradiant(carre: subViewTexteLoc, couleur: "Vert")
        makeGradiant(carre: subViewAnnee, couleur: "Vert")
        makeGradiant(carre: subViewGenre, couleur: "Bleu")
        makeGradiant(carre: subViewNetwork, couleur: "Rouge")
        makeGradiant(carre: subViewLangue, couleur: "Vert")
        makeGradiant(carre: carreResults, couleur: "Vert")

        subViewTitre.frame.origin.x = -333
        subViewTexteLoc.frame.origin.x = -333
        subViewAnnee.frame.origin.x = 373
        subViewGenre.frame.origin.x = 373
        subViewNetwork.frame.origin.x = 373
        subViewLangue.frame.origin.x = 373

        activeSubView = nil

        arrondir(texte: cptResults, radius: 10.0)
        cptResults.text = "+" + "\u{221E}"
        
        descriptionTexte.text = ""
    }
    
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        // Mode "Par Titre"
        if (mode == 0)
        {
            if gesture.direction == UISwipeGestureRecognizerDirection.right {
                if (self.activeSubView == nil) {
                    if ( (gesture.location(in: self.view).y > 100.0) && (gesture.location(in: self.view).y < 200.0) )
                    {
                        UIView.animate(withDuration: 0.7, animations: { self.subViewTitre.frame.origin.x = 0 } )
                        self.activeSubView = subViewTitre
                    }
                    else if ( (gesture.location(in: self.view).y > 200.0) && (gesture.location(in: self.view).y < 350.0) )
                    {
                        UIView.animate(withDuration: 0.7, animations: { self.subViewTexteLoc.frame.origin.x = 0 } )
                        self.activeSubView = subViewTexteLoc
                    }
                }
            }
            else if gesture.direction == UISwipeGestureRecognizerDirection.left {
                if (self.activeSubView != nil) {
                    UIView.animate(withDuration: 0.7, animations: { self.activeSubView.frame.origin.x = -300 } )
                    self.activeSubView = nil
                    self.updateRechercheTitre()
                }
            }
        }
        
        
        // Mode "Par Critères"
        if (mode == 1)
        {
            if gesture.direction == UISwipeGestureRecognizerDirection.right {
                if (self.activeSubView != nil) {
                    UIView.animate(withDuration: 0.7, animations: { self.activeSubView.frame.origin.x = 340 } )
                    self.activeSubView = nil
                    self.updateRecherche()
                }
            }
            else if gesture.direction == UISwipeGestureRecognizerDirection.left {
                if (self.activeSubView == nil) {
                    if ( (gesture.location(in: self.view).y > 100.0) && (gesture.location(in: self.view).y < 200.0) )
                    {
                        UIView.animate(withDuration: 0.7, animations: { self.subViewAnnee.frame.origin.x = 45 } )
                        self.activeSubView = subViewAnnee
                    }
                    else if ( (gesture.location(in: self.view).y > 200.0) && (gesture.location(in: self.view).y < 300.0) )
                    {
                        UIView.animate(withDuration: 0.7, animations: { self.subViewGenre.frame.origin.x = 45 } )
                        self.activeSubView = subViewGenre
                    }
                    else if ( (gesture.location(in: self.view).y > 300.0) && (gesture.location(in: self.view).y < 400.0) )
                    {
                        UIView.animate(withDuration: 0.7, animations: { self.subViewNetwork.frame.origin.x = 45 } )
                        self.activeSubView = subViewNetwork
                    }
                    else if ( (gesture.location(in: self.view).y > 400.0) && (gesture.location(in: self.view).y < 500.0) )
                    {
                        UIView.animate(withDuration: 0.7, animations: { self.subViewLangue.frame.origin.x = 45 } )
                        self.activeSubView = subViewLangue
                    }
                }
            }
        }
    }
    
    @IBAction func parTitre(_ sender: Any) {
        mode = 0
        
        UIView.animate(withDuration: 0.7, animations: { self.subViewAnnee.frame.origin.x = 373 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewGenre.frame.origin.x = 373 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewNetwork.frame.origin.x = 373 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewLangue.frame.origin.x = 373 } )
        
        UIView.animate(withDuration: 0.7, animations: { self.subViewTitre.frame.origin.x = -300 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewTexteLoc.frame.origin.x = -300 } )

        descriptionTexte.text = ""
        updateRechercheTitre()
    }
    

    @IBAction func parCriteres(_ sender: Any) {
        mode = 1
        
        UIView.animate(withDuration: 0.7, animations: { self.subViewAnnee.frame.origin.x = 340 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewGenre.frame.origin.x = 340 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewNetwork.frame.origin.x = 340 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewLangue.frame.origin.x = 340 } )
        
        UIView.animate(withDuration: 0.7, animations: { self.subViewTitre.frame.origin.x = -333 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewTexteLoc.frame.origin.x = -333 } )

        descriptionTexte.text = ""
        updateRecherche()
    }
    
    
    @IBAction func buttonSelect3States(_ sender: Any) {
        let button : UIButton = sender as! UIButton
        
        if (button.isSelected == false) {
            button.setTitleColor(UIColor.green, for: .selected)
            button.isSelected = true
        }
        else if ((button.isSelected == true) && (button.titleColor(for: .selected) == UIColor.green )) {
            button.setTitleColor(UIColor.red, for: .selected)
            button.isSelected = true
        }
        else if ((button.isSelected == true) && (button.titleColor(for: .selected) == UIColor.red )) {
            button.setTitleColor(UIColor.green, for: .selected)
            button.isSelected = false
        }
    }

    @IBAction func buttonSelect2States(_ sender: Any) {
        let button : UIButton = sender as! UIButton
        button.isSelected = !button.isSelected
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func updateRechercheTitre()
    {
        var chercherDans : String = ""
        
        // Choix du titre
        if (titre.text == "") { descriptionTexte.text = "Toutes les séries" }
        else
        {
            descriptionTexte.text = "Séries où l'on peut trouver : \n     " + titre.text!
            if (inTitre.isOn) {
                descriptionTexte.text = descriptionTexte.text + "\n\n  dans le titre"
                chercherDans = "title,"
            }
            
            if (inResume.isOn) {
                descriptionTexte.text = descriptionTexte.text + "\n\n  dans le résumé"
                chercherDans = chercherDans + "overview,"
            }
            if (inCasting.isOn) {
                descriptionTexte.text = descriptionTexte.text + "\n\n  dans le casting"
                chercherDans = chercherDans + "people,"
            }
        }
        
        // Recherche sur Trakt
        seriesTrouvees = []

        if ((titre.text != "") && (chercherDans != "")) {
            chercherDans.removeLast()
            seriesTrouvees = trakt.recherche(serieArechercher: titre.text!, aChercherDans : chercherDans)
        }
        
        cptResults.text = String(seriesTrouvees.count)
        
    }
    
    func updateRecherche ()
    {
        descriptionTexte.text = "Toutes les séries"
        
        // Choix de la periode
        if (debut.text == "") {
            if (fin.text == "") { descriptionTexte.text = descriptionTexte.text + "\n\n" }
            else { descriptionTexte.text = descriptionTexte.text + "\n\ndiffusées avant " + fin.text! }
        }
        else {
            if (fin.text == "") { descriptionTexte.text = descriptionTexte.text + "\n\ndiffusées après " + debut.text! }
            else { descriptionTexte.text = descriptionTexte.text + "\n\ndiffusées entre " + debut.text! + " et " + fin.text! }
        }
        


        // Choix des genres
        var tmpGenres : String = ""
        if (action.isSelected && (action.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Action, " }
        if (adventure.isSelected && (adventure.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Adventure, " }
        if (animation.isSelected && (animation.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Animation, " }
        if (comedy.isSelected && (comedy.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Comedy, " }
        if (crime.isSelected && (crime.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Crime, " }
        if (documentary.isSelected && (documentary.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Documentary, " }
        if (family.isSelected && (family.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Family, " }
        if (fantasy.isSelected && (fantasy.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Fantasy, " }
        if (history.isSelected && (history.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "History, " }
        if (horror.isSelected && (horror.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Horror, " }
        if (music.isSelected && (music.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Music, " }
        if (mystery.isSelected && (mystery.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Mystery, " }
        if (romance.isSelected && (romance.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Romance, " }
        if (scienceFiction.isSelected && (scienceFiction.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Science Fiction, " }
        if (tvMovie.isSelected && (tvMovie.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "TV Movie, " }
        if (thriller.isSelected && (thriller.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Thriller, " }
        if (war.isSelected && (war.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "War, " }
        if (western.isSelected && (western.titleColor(for: .selected) == UIColor.green)) { tmpGenres = tmpGenres + "Western, " }
        if (tmpGenres == "" ) { descriptionTexte.text = descriptionTexte.text + "\n\ntous genres confondus" }
        else {
            tmpGenres.removeLast()
            tmpGenres.removeLast()
            descriptionTexte.text = descriptionTexte.text + "\n\nde genre " + tmpGenres
        }

        // TODO : exclusions de genres
        var tmpGenres2 : String = ""
        if (action.isSelected && (action.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Action, " }
        if (adventure.isSelected && (adventure.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Adventure, " }
        if (animation.isSelected && (animation.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Animation, " }
        if (comedy.isSelected && (comedy.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Comedy, " }
        if (crime.isSelected && (crime.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Crime, " }
        if (documentary.isSelected && (documentary.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Documentary, " }
        if (family.isSelected && (family.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Family, " }
        if (fantasy.isSelected && (fantasy.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Fantasy, " }
        if (history.isSelected && (history.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "History, " }
        if (horror.isSelected && (horror.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Horror, " }
        if (music.isSelected && (music.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Music, " }
        if (mystery.isSelected && (mystery.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Mystery, " }
        if (romance.isSelected && (romance.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Romance, " }
        if (scienceFiction.isSelected && (scienceFiction.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Science Fiction, " }
        if (tvMovie.isSelected && (tvMovie.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "TV Movie, " }
        if (thriller.isSelected && (thriller.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Thriller, " }
        if (war.isSelected && (war.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "War, " }
        if (western.isSelected && (western.titleColor(for: .selected) == UIColor.red)) { tmpGenres2 = tmpGenres2 + "Western, " }
        if (tmpGenres2 == "" ) { descriptionTexte.text = descriptionTexte.text + "" }
        else {
            tmpGenres2.removeLast()
            tmpGenres2.removeLast()
            descriptionTexte.text = descriptionTexte.text + "\nmais pas de genre " + tmpGenres2
        }
        

        // Choix du network de diffusion
        var tmpNetworks : String = ""
        if (ABC.isSelected) { tmpNetworks = tmpNetworks + "ABC, " }
        if (CBS.isSelected) { tmpNetworks = tmpNetworks + "CBS, " }
        if (FOX.isSelected) { tmpNetworks = tmpNetworks + "FOX, " }
        if (FX.isSelected) { tmpNetworks = tmpNetworks + "FX, " }
        if (HBO.isSelected) { tmpNetworks = tmpNetworks + "HBO, " }
        if (NBC.isSelected) { tmpNetworks = tmpNetworks + "NBC, " }
        if (Netflix.isSelected) { tmpNetworks = tmpNetworks + "Netflix, " }
        if (Showtime.isSelected) { tmpNetworks = tmpNetworks + "Showtime, " }
        if (Starz.isSelected) { tmpNetworks = tmpNetworks + "Starz, " }
        if (TheCW.isSelected) { tmpNetworks = tmpNetworks + "The CW, " }
        if (Canal.isSelected) { tmpNetworks = tmpNetworks + "Canal+, " }
        if (tmpNetworks == "" ) { descriptionTexte.text = descriptionTexte.text + "\n\n" }
        else {
            tmpNetworks.removeLast()
            tmpNetworks.removeLast()
            descriptionTexte.text = descriptionTexte.text + "\n\nvues sur " + tmpNetworks
        }
        
        
        // Choix de la langue
        var tmpLangue : String = ""
        if (francais.isSelected) {
            if (anglais.isSelected) {
                descriptionTexte.text = descriptionTexte.text + "\n\nen français ou en anglais"
                tmpLangue = "en|fr"
            }
            else {
                descriptionTexte.text = descriptionTexte.text + "\n\nen français uniquement"
                tmpLangue = "fr"
            }
        }
        else {
            if (anglais.isSelected) {
                descriptionTexte.text = descriptionTexte.text + "\n\nen anglais uniquement"
                tmpLangue = "en"
            }
            else { descriptionTexte.text = descriptionTexte.text + "\n\nquelle que soit la langue" }
        }
        
        // Recherche sur TheMovieDB
        var nbSeriesTrouvees : Int = 0
        seriesTrouvees = []

        (seriesTrouvees, nbSeriesTrouvees) = theMoviedb.chercher(genreIncl: tmpGenres.replacingOccurrences(of: ", ", with: ","),
                                                                 genreExcl: tmpGenres2.replacingOccurrences(of: ", ", with: ","),
                                                                 anneeBeg: debut.text!,
                                                                 anneeEnd: fin.text!,
                                                                 langue: tmpLangue,
                                                                 network: tmpNetworks.replacingOccurrences(of: ", ", with: ","))

        cptResults.text = String(nbSeriesTrouvees)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! ViewSerieListe
        
        if (seriesTrouvees != [])
        {
            for uneSerie in seriesTrouvees
            {
                print("Enrichissement de \(uneSerie.serie)")
                theMoviedb.getIDs(serie: uneSerie)
                db.downloadGlobalInfo(serie: uneSerie)
            }
            
            viewController.title = "Propositions de séries"
            viewController.viewList = seriesTrouvees
            viewController.isPropositions = true
        }
    }
    
}
