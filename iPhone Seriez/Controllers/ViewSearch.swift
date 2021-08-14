//
//  ViewSearch.swift
//  SerieA
//
//  Created by Cyril Delamare on 13/05/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import SeriesCommon

class ViewSearch: UIViewController {
    @IBOutlet weak var entete: UIView!
    @IBOutlet weak var traktSearch: UIView!
    @IBOutlet weak var moviedbSearch: UIView!
    
    
    // Entete
    @IBOutlet weak var cptResults: UITextField!
    @IBOutlet weak var cptDetails: UITextField!
    @IBOutlet weak var descriptionTexte: UITextView!
    @IBOutlet weak var resultats: UITextView!
    
    // Trakt Search
    @IBOutlet weak var titre: UITextField!
    @IBOutlet weak var inTitre: UISwitch!
    @IBOutlet weak var inResume: UISwitch!
    @IBOutlet weak var inCasting: UISwitch!
    
    // Movie DB Search
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
    
    var seriesTrouvees : [Serie] = []
    var detailsLoaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeGradiant(carre: entete, couleur: "Blanc")
        makeGradiant(carre: traktSearch, couleur: "Blanc")
        makeGradiant(carre: moviedbSearch, couleur: "Blanc")

        arrondir(texte: cptResults, radius: 10.0)
        arrondir(texte: cptDetails, radius: 10.0)
        cptResults.text = "+" + "\u{221E}"
        cptDetails.text = "+" + "\u{221E}"
        
        descriptionTexte.text = ""
    }
    
    
    @IBAction func searchMode(_ sender: Any) {
        let toggle : Int = (sender as! UISegmentedControl).selectedSegmentIndex
        descriptionTexte.text = ""

        switch toggle {
        case 0:
            self.moviedbSearch.isHidden = true
            self.traktSearch.isHidden = true
            break
            
        case 1:
            self.moviedbSearch.isHidden = true
            self.traktSearch.isHidden = false
            updateRechercheTitre(sender)
            break

        case 2:
            self.moviedbSearch.isHidden = false
            self.traktSearch.isHidden = true
            updateRechercheCriteres(sender)
            break
            
        default:
            return
        }
    }
    

    @IBAction func buttonSelect3States(_ sender: Any) {
        let button : UIButton = sender as! UIButton
        
        if (button.isSelected == false) {
            button.setTitleColor(.systemGreen, for: .selected)
            button.isSelected = true
        }
        else if ((button.isSelected == true) && (button.titleColor(for: .selected) == .systemGreen )) {
            button.setTitleColor(.systemRed, for: .selected)
            button.isSelected = true
        }
        else if ((button.isSelected == true) && (button.titleColor(for: .selected) == .systemRed )) {
            button.setTitleColor(.systemGreen, for: .selected)
            button.isSelected = false
        }

        updateRechercheCriteres(sender)
    }
    
    @IBAction func buttonSelect2States(_ sender: Any) {
        let button : UIButton = sender as! UIButton
        button.isSelected = !button.isSelected
        
        updateRechercheCriteres(sender)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func updateRechercheTitre(_ sender: Any) {
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
        
        var seriesResultat : String = ""
            for i in 0..<min(seriesTrouvees.count,10) {
                seriesResultat = seriesResultat + "(" + String(seriesTrouvees[i].year) + ") " + seriesTrouvees[i].serie + "\n"
            }
        resultats.text = seriesResultat

        cptResults.text = String(seriesTrouvees.count)
        cptDetails.text = "-"
        detailsLoaded = false
    }
    
    @IBAction func updateRechercheCriteres (_ sender: Any) {
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
        if (action.isSelected && (action.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Action, " }
        if (adventure.isSelected && (adventure.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Adventure, " }
        if (animation.isSelected && (animation.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Animation, " }
        if (comedy.isSelected && (comedy.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Comedy, " }
        if (crime.isSelected && (crime.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Crime, " }
        if (documentary.isSelected && (documentary.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Documentary, " }
        if (drama.isSelected && (drama.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Drama, " }
        if (family.isSelected && (family.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Family, " }
        if (fantasy.isSelected && (fantasy.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Fantasy, " }
        if (history.isSelected && (history.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "History, " }
        if (horror.isSelected && (horror.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Horror, " }
        if (music.isSelected && (music.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Music, " }
        if (mystery.isSelected && (mystery.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Mystery, " }
        if (romance.isSelected && (romance.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Romance, " }
        if (scienceFiction.isSelected && (scienceFiction.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Science Fiction, " }
        if (tvMovie.isSelected && (tvMovie.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "TV Movie, " }
        if (thriller.isSelected && (thriller.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Thriller, " }
        if (war.isSelected && (war.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "War, " }
        if (western.isSelected && (western.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Western, " }
        if (tmpGenres == "" ) { descriptionTexte.text = descriptionTexte.text + "\n\ntous genres confondus" }
        else {
            tmpGenres.removeLast()
            tmpGenres.removeLast()
            descriptionTexte.text = descriptionTexte.text + "\n\nde genre " + tmpGenres
        }
        
        // exclusions de genres
        var tmpGenres2 : String = ""
        if (action.isSelected && (action.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Action, " }
        if (adventure.isSelected && (adventure.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Adventure, " }
        if (animation.isSelected && (animation.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Animation, " }
        if (comedy.isSelected && (comedy.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Comedy, " }
        if (crime.isSelected && (crime.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Crime, " }
        if (documentary.isSelected && (documentary.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Documentary, " }
        if (drama.isSelected && (drama.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Drama, " }
        if (family.isSelected && (family.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Family, " }
        if (fantasy.isSelected && (fantasy.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Fantasy, " }
        if (history.isSelected && (history.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "History, " }
        if (horror.isSelected && (horror.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Horror, " }
        if (music.isSelected && (music.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Music, " }
        if (mystery.isSelected && (mystery.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Mystery, " }
        if (romance.isSelected && (romance.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Romance, " }
        if (scienceFiction.isSelected && (scienceFiction.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Science Fiction, " }
        if (tvMovie.isSelected && (tvMovie.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "TV Movie, " }
        if (thriller.isSelected && (thriller.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Thriller, " }
        if (war.isSelected && (war.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "War, " }
        if (western.isSelected && (western.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Western, " }
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
        
        var seriesResultat : String = ""
        for i in 0..<min(seriesTrouvees.count,10) {
            seriesResultat = seriesResultat + "(" + String(seriesTrouvees[i].year) + ") " + seriesTrouvees[i].serie + "\n"
        }
        resultats.text = seriesResultat

        cptResults.text = String(nbSeriesTrouvees)
        cptDetails.text = "-"
        detailsLoaded = false
    }
    
    
    @IBAction func afficheDetails(_ sender: Any) {
        var compteur : Int = 0
        
        if ((seriesTrouvees != []) && (detailsLoaded == false)) {
            DispatchQueue.global(qos: .utility).async {
                for uneSerie in self.seriesTrouvees {
                    _ = theMoviedb.getIDs(serie: uneSerie)
                    db.downloadGlobalInfo(serie: uneSerie)
                    compteur = compteur + 1
                    DispatchQueue.main.async { self.cptDetails.text = String(compteur) }
                }
                
                self.detailsLoaded = true
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return detailsLoaded
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! ViewSerieListe
        
        if (seriesTrouvees != []) {
            viewController.title = "Propositions de séries"
            viewController.viewList = self.seriesTrouvees
            viewController.modeAffichage = modeRecherche
        }
    }
}




/*
 
 From MovieDB :
 https://image.tmdb.org/t/p/w154/xUtOM1QO4r8w8yeE00QvBdq58N5.jpg
 https://image.tmdb.org/t/p/w780/wu444tM9YBllq9UcBv5TeidO3j3.jpg
 
 {
   "page": 1,
   "results": [
     {
       "backdrop_path": "/wu444tM9YBllq9UcBv5TeidO3j3.jpg",
       "first_air_date": "2020-01-31",
       "genre_ids": [
         18,
         10765,
         9648
       ],
       "id": 91557,
       "name": "Ragnarok",
       "origin_country": [
         "NO"
       ],
       "original_language": "no",
       "original_name": "Ragnarok",
       "overview": "A small Norwegian town experiencing warm winters and violent downpours seems to be headed for another Ragnarök -- unless someone intervenes in time.",
       "popularity": 1232.156,
       "poster_path": "/xUtOM1QO4r8w8yeE00QvBdq58N5.jpg",
       "vote_average": 8,
       "vote_count": 441
     },
     {
       "backdrop_path": "/b0WmHGc8LHTdGCVzxRb3IBMur57.jpg",
       "first_air_date": "2021-03-19",
       "genre_ids": [
         10765,
         10759,
         18,
         10768
       ],
       "id": 88396,
       "name": "The Falcon and the Winter Soldier",
       "origin_country": [
         "US"
       ],
       "original_language": "en",
       "original_name": "The Falcon and the Winter Soldier",
       "overview": "Following the events of “Avengers: Endgame”, the Falcon, Sam Wilson and the Winter Soldier, Bucky Barnes team up in a global adventure that tests their abilities, and their patience.",
       "popularity": 774.954,
       "poster_path": "/6kbAMLteGO8yyewYau6bJ683sw7.jpg",
       "vote_average": 7.9,
       "vote_count": 5750
     },
     {
       "backdrop_path": "/dYvIUzdh6TUv4IFRq8UBkX7bNNu.jpg",
       "first_air_date": "2021-03-24",
       "genre_ids": [
         18,
         80,
         9648
       ],
       "id": 120168,
       "name": "Who Killed Sara?",
       "origin_country": [
         "MX"
       ],
       "original_language": "es",
       "original_name": "¿Quién mató a Sara?",
       "overview": "Hell-bent on exacting revenge and proving he was framed for his sister's murder, Álex sets out to unearth much more than the crime's real culprit.",
       "popularity": 725.655,
       "poster_path": "/o7uk5ChRt3quPIv8PcvPfzyXdMw.jpg",
       "vote_average": 7.8,
       "vote_count": 769
     },
 
 
 
 
 
 
 
 
 Dans Trakt
 
 [
   {
     "type": "show",
     "score": 624.5253,
     "show": {
       "title": "CSI: Miami",
       "year": 2002,
       "ids": {
         "trakt": 1609,
         "slug": "csi-miami",
         "tvdb": 78310,
         "imdb": "tt0313043",
         "tmdb": 1620,
         "tvrage": 3184
       }
     }
   },
   {
     "type": "show",
     "score": 527.9726,
     "show": {
       "title": "Miami Vice",
       "year": 1984,
       "ids": {
         "trakt": 1895,
         "slug": "miami-vice",
         "tvdb": 77098,
         "imdb": "tt0086759",
         "tmdb": 1908,
         "tvrage": 4461
       }
     }
   },
   {
     "type": "show",
     "score": 413.6213,
     "show": {
       "title": "Miami Medical",
       "year": 2010,
       "ids": {
         "trakt": 18575,
         "slug": "miami-medical",
         "tvdb": 142561,
         "imdb": "tt1406662",
         "tmdb": 18660,
         "tvrage": {}
       }
     }
   },
   {
     "type": "show",
     "score": 384.74634,
     "show": {
       "title": "Miami Ink",
       "year": 2005,
       "ids": {
         "trakt": 10931,
         "slug": "miami-ink",
         "tvdb": 78816,
         "imdb": "tt0472014",
         "tmdb": 10982,
         "tvrage": 7177
       }
     }
   },
   {
     "type": "show",
     "score": 369.27158,
     "show": {
       "title": "WAGS: Miami",
       "year": 2016,
       "ids": {
         "trakt": 112063,
         "slug": "wags-miami",
         "tvdb": 317892,
         "imdb": "tt6316862",
         "tmdb": 67787,
         "tvrage": {}
       }
     }
   },
 
 
 
 */
