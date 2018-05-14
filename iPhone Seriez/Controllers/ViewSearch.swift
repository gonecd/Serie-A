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
    @IBOutlet weak var subViewGenre: UIView!
    @IBOutlet weak var subViewNetwork: UIView!
    @IBOutlet weak var subViewLangue: UIView!
    
    @IBOutlet weak var carreResults: UIView!
    @IBOutlet weak var cptResults: UITextField!
    @IBOutlet weak var roueResults: UIActivityIndicatorView!
    
    @IBOutlet weak var labelTitre: UILabel!
    @IBOutlet weak var labelAnnee: UILabel!
    @IBOutlet weak var labelGenre: UILabel!
    @IBOutlet weak var labelNetwork: UILabel!
    @IBOutlet weak var labelLangue: UILabel!
    
    @IBOutlet weak var texteTitre: UITextView!
    @IBOutlet weak var texteAnnees: UILabel!
    @IBOutlet weak var texteGenresInclus: UITextView!
    @IBOutlet weak var texteGenresExclus: UILabel!
    @IBOutlet weak var texteLangues: UILabel!
    @IBOutlet weak var texteNetwork: UITextView!
    
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
        labelAnnee.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelGenre.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelNetwork.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelLangue.transform = CGAffineTransform.init(rotationAngle: ( 3.1415926535/2.0))
        labelTitre.frame.origin = CGPoint(x: 300.0, y: 10.0)
        labelAnnee.frame.origin = CGPoint(x: 10.0, y: 10.0)
        labelGenre.frame.origin = CGPoint(x: 10.0, y: 10.0)
        labelNetwork.frame.origin = CGPoint(x: 10.0, y: 10.0)
        labelLangue.frame.origin = CGPoint(x: 10.0, y: 10.0)

        makeGradiant(carre: subViewTitre, couleur: "Rouge")
        makeGradiant(carre: subViewAnnee, couleur: "Vert")
        makeGradiant(carre: subViewGenre, couleur: "Bleu")
        makeGradiant(carre: subViewNetwork, couleur: "Rouge")
        makeGradiant(carre: subViewLangue, couleur: "Vert")
        makeGradiant(carre: carreResults, couleur: "Vert")

        subViewTitre.frame.origin.x = -333
        subViewAnnee.frame.origin.x = 373
        subViewGenre.frame.origin.x = 373
        subViewNetwork.frame.origin.x = 373
        subViewLangue.frame.origin.x = 373

        activeSubView = nil

        arrondir(texte: cptResults, radius: 10.0)
        cptResults.text = "+" + "\u{221E}"
        
        texteTitre.text = ""
        texteAnnees.text = ""
        texteGenresInclus.text = ""
        texteGenresExclus.text = ""
        texteLangues.text = ""
        texteNetwork.text = ""
    }
    
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        // Mode "Par Titre"
        if (mode == 0)
        {
            if gesture.direction == UISwipeGestureRecognizerDirection.right {
                if (self.activeSubView == nil) {
                    UIView.animate(withDuration: 0.7, animations: { self.subViewTitre.frame.origin.x = 0 } )
                    self.activeSubView = subViewTitre
                }
            }
            else if gesture.direction == UISwipeGestureRecognizerDirection.left {
                if (self.activeSubView != nil) {
                    UIView.animate(withDuration: 0.7, animations: { self.subViewTitre.frame.origin.x = -300 } )
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
        
        texteTitre.text = ""
        texteAnnees.text = ""
        texteGenresInclus.text = ""
        texteGenresExclus.text = ""
        texteLangues.text = ""
        texteNetwork.text = ""

        updateRechercheTitre()
    }
    

    @IBAction func parCriteres(_ sender: Any) {
        mode = 1
        
        UIView.animate(withDuration: 0.7, animations: { self.subViewAnnee.frame.origin.x = 340 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewGenre.frame.origin.x = 340 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewNetwork.frame.origin.x = 340 } )
        UIView.animate(withDuration: 0.7, animations: { self.subViewLangue.frame.origin.x = 340 } )
        
        UIView.animate(withDuration: 0.7, animations: { self.subViewTitre.frame.origin.x = -333 } )
        
        texteTitre.text = ""
        texteAnnees.text = ""
        texteGenresInclus.text = ""
        texteGenresExclus.text = ""
        texteLangues.text = ""
        texteNetwork.text = ""

        updateRecherche()
    }
    
    
    @IBAction func buttonSelect(_ sender: Any) {
        let button : UIButton = sender as! UIButton
        button.isSelected = !button.isSelected
    }

    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func updateRechercheTitre()
    {
        // Choix du titre
        if (titre.text == "") { texteTitre.text = "Toutes les séries" }
        else { texteTitre.text = "Séries où l'on peut trouver : " + titre.text! }
        
        // Recherche sur Trakt
        seriesTrouvees = []

        if (titre.text != "") {
            seriesTrouvees = trakt.recherche(serieArechercher: titre.text!)
        }
        
        cptResults.text = String(seriesTrouvees.count)
        
    }
    
    func updateRecherche ()
    {
        texteTitre.text = "Toutes les séries"
        
        // Choix de la periode
        if (debut.text == "") {
            if (fin.text == "") { texteAnnees.text = "" }
            else { texteAnnees.text = "diffusées avant " + fin.text! }
        }
        else {
            if (fin.text == "") { texteAnnees.text = "diffusées après " + debut.text! }
            else { texteAnnees.text = "diffusées entre " + debut.text! + " et " + fin.text! }
        }
        
        // Choix des genres
        var tmpGenres : String = ""
        if (action.isSelected) { tmpGenres = tmpGenres + "Action, " }
        if (adventure.isSelected) { tmpGenres = tmpGenres + "Adventure, " }
        if (animation.isSelected) { tmpGenres = tmpGenres + "Animation, " }
        if (comedy.isSelected) { tmpGenres = tmpGenres + "Comedy, " }
        if (crime.isSelected) { tmpGenres = tmpGenres + "Crime, " }
        if (documentary.isSelected) { tmpGenres = tmpGenres + "Documentary, " }
        if (family.isSelected) { tmpGenres = tmpGenres + "Family, " }
        if (fantasy.isSelected) { tmpGenres = tmpGenres + "Fantasy, " }
        if (history.isSelected) { tmpGenres = tmpGenres + "History, " }
        if (horror.isSelected) { tmpGenres = tmpGenres + "Horror, " }
        if (music.isSelected) { tmpGenres = tmpGenres + "Music, " }
        if (mystery.isSelected) { tmpGenres = tmpGenres + "Mystery, " }
        if (romance.isSelected) { tmpGenres = tmpGenres + "Romance, " }
        if (scienceFiction.isSelected) { tmpGenres = tmpGenres + "Science Fiction, " }
        if (tvMovie.isSelected) { tmpGenres = tmpGenres + "TV Movie, " }
        if (thriller.isSelected) { tmpGenres = tmpGenres + "Thriller, " }
        if (war.isSelected) { tmpGenres = tmpGenres + "War, " }
        if (western.isSelected) { tmpGenres = tmpGenres + "Western, " }
        if (tmpGenres == "" ) { texteGenresInclus.text = "Tous genres confondus" }
        else {
            tmpGenres.removeLast()
            tmpGenres.removeLast()
            texteGenresInclus.text = "de genre " + tmpGenres
        }

        // TODO : exclusions de genres
        texteGenresExclus.text = ""
        
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
        if (tmpNetworks == "" ) { texteNetwork.text = "" }
        else {
            tmpNetworks.removeLast()
            tmpNetworks.removeLast()
            texteNetwork.text = "vues sur " + tmpNetworks
        }
        
        
        // Choix de la langue
        var tmpLangue : String = ""
        if (francais.isSelected) {
            if (anglais.isSelected) {
                texteLangues.text = "en français ou en anglais"
                tmpLangue = "en|fr"
            }
            else {
                texteLangues.text = "en français uniquement"
                tmpLangue = "fr"
            }
        }
        else {
            if (anglais.isSelected) {
                texteLangues.text = "en anglais uniquement"
                tmpLangue = "en"
            }
            else { texteLangues.text = "quelle que soit la langue" }
        }
        
        // Recherche sur TheMovieDB
        var nbSeriesTrouvees : Int = 0
        seriesTrouvees = []

        (seriesTrouvees, nbSeriesTrouvees) = theMoviedb.chercher(genreIncl: tmpGenres.replacingOccurrences(of: ", ", with: ","),
                                             genreExcl: "",
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
