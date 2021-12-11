//
//  ViewSearch.swift
//  SerieA
//
//  Created by Cyril Delamare on 13/05/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit


class CellResult: UITableViewCell {
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var annee: UILabel!
    
    var index: Int = 0
}

class ViewSearch: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var entete: UIView!
    @IBOutlet weak var quickSearch: UIView!
    @IBOutlet weak var traktSearch: UIView!
    @IBOutlet weak var moviedbSearch: UIView!
    
    
    // Entete
    @IBOutlet weak var cptResults: UITextField!
    @IBOutlet weak var descriptionTexte: UITextView!
    @IBOutlet weak var results: UITableView!

    // Trakt Search
    @IBOutlet weak var quickTitre: UITextField!

    // Trakt Search
    @IBOutlet weak var titre: UITextField!
    @IBOutlet weak var inTitre: UISwitch!
    @IBOutlet weak var inResume: UISwitch!
    @IBOutlet weak var inCasting: UISwitch!
    
    // Movie DB Search
    @IBOutlet weak var debut: UITextField!
    @IBOutlet weak var fin: UITextField!
    
    @IBOutlet weak var FX: UIButton!
    @IBOutlet weak var HBO: UIButton!
    @IBOutlet weak var NBC: UIButton!
    @IBOutlet weak var Netflix: UIButton!
    @IBOutlet weak var Showtime: UIButton!
    @IBOutlet weak var Starz: UIButton!
    @IBOutlet weak var TheCW: UIButton!
    @IBOutlet weak var Canal: UIButton!
    
    @IBOutlet weak var actionadventure: UIButton!
    @IBOutlet weak var animation: UIButton!
    @IBOutlet weak var comedy: UIButton!
    @IBOutlet weak var crime: UIButton!
    @IBOutlet weak var drama: UIButton!
    @IBOutlet weak var mystery: UIButton!
    @IBOutlet weak var scififantasy: UIButton!
    @IBOutlet weak var warpolitics: UIButton!
    @IBOutlet weak var western: UIButton!
    
    @IBOutlet weak var francais: UIButton!
    @IBOutlet weak var anglais: UIButton!
    
    var seriesTrouvees : [Serie] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeGradiant(carre: entete, couleur: "Blanc")
        makeGradiant(carre: traktSearch, couleur: "Blanc")
        makeGradiant(carre: quickSearch, couleur: "Blanc")
        makeGradiant(carre: moviedbSearch, couleur: "Blanc")
        makeGradiant(carre: results, couleur: "Blanc")

        arrondir(texte: cptResults, radius: 10.0)
        cptResults.text = "+" + "\u{221E}"
        
        descriptionTexte.text = ""
    }
    
    
    @IBAction func searchMode(_ sender: Any) {
        let toggle : Int = (sender as! UISegmentedControl).selectedSegmentIndex
        descriptionTexte.text = ""

        switch toggle {
        case 0:
            self.moviedbSearch.isHidden = true
            self.traktSearch.isHidden = true
            self.quickSearch.isHidden = false
            updateRechercheQuick(sender)
            break
            
        case 1:
            self.moviedbSearch.isHidden = true
            self.traktSearch.isHidden = false
            self.quickSearch.isHidden = true
            updateRechercheTitre(sender)
            break

        case 2:
            self.moviedbSearch.isHidden = false
            self.traktSearch.isHidden = true
            self.quickSearch.isHidden = true
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
    
    
    @IBAction func updateRechercheQuick(_ sender: Any) {
        
        // Choix du titre
        if (quickTitre.text == "") { descriptionTexte.text = "Toutes les séries" }
        else { descriptionTexte.text = "Titres contenant : \n     " + quickTitre.text! }

        if (quickTitre.text!.count > 2) {
            let searchString : String = quickTitre.text!
            
            var dataTrakt       : [Serie] = []
            var dataBetaSeries  : [Serie] = []
            var dataTheMovieDB  : [Serie] = []
            var dataTVMaze      : [Serie] = []
            
            let queue : OperationQueue = OperationQueue()
            
            queue.addOperation(BlockOperation(block: { dataBetaSeries = betaSeries.rechercheParTitre(serieArechercher: searchString) } ))
            queue.addOperation(BlockOperation(block: { dataTheMovieDB = theMoviedb.rechercheParTitre(serieArechercher: searchString) } ))
            queue.addOperation(BlockOperation(block: { dataTVMaze = tvMaze.rechercheParTitre(serieArechercher: searchString) } ))
            queue.addOperation(BlockOperation(block: { dataTrakt = trakt.rechercheParTitre(serieArechercher: searchString) } ))
            
            queue.waitUntilAllOperationsAreFinished()
            
            seriesTrouvees = mergeResults(dataTrakt: dataTrakt, dataBetaSeries: dataBetaSeries, dataTheMovieDB: dataTheMovieDB, dataTVMaze: dataTVMaze)
            
            results.reloadData()
            results.setNeedsLayout()
                
            cptResults.text = String(seriesTrouvees.count)
        }
    }

    func mergeResults(dataTrakt :[Serie], dataBetaSeries :[Serie], dataTheMovieDB :[Serie], dataTVMaze :[Serie]) -> [Serie] {
        var result : [Serie] = []
        var traitees : [String] = []
        
        // Merge series found by Trakt
        for uneSerieTrakt in dataTrakt {
            let uneSerie : Serie = Serie(serie: "")
            
            let emptySerie :Serie = Serie(serie:uneSerieTrakt.serie)
            var uneSerieBetaSeries : Serie = emptySerie
            var uneSerieMovieDB : Serie = emptySerie
            var uneSerieTVMaze : Serie = emptySerie
            var uneSerieIMDB : Serie = emptySerie
            uneSerieIMDB = imdb.getSerieGlobalInfos(idIMDB: uneSerieTrakt.idIMdb)
            
            for i in 0..<dataBetaSeries.count { if (uneSerieTrakt.idIMdb == dataBetaSeries[i].idIMdb) { uneSerieBetaSeries = dataBetaSeries[i]; break; } }
            for i in 0..<dataTheMovieDB.count { if (uneSerieTrakt.idMoviedb == dataTheMovieDB[i].idMoviedb) { uneSerieMovieDB = dataTheMovieDB[i]; break; } }
            for i in 0..<dataTVMaze.count { if (uneSerieTrakt.idIMdb == dataTVMaze[i].idIMdb) { uneSerieTVMaze = dataTVMaze[i]; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: uneSerieTrakt, BetaSeries: uneSerieBetaSeries,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie, AlloCine: emptySerie)
            
            traitees.append(uneSerie.serie)
            result.append(uneSerie)
        }
        
        // Adding series from BetaSeries
        for uneSerieBetaSeries in dataBetaSeries {
            if traitees.contains(uneSerieBetaSeries.serie) { continue }
            
            let uneSerie : Serie = Serie(serie: "")
            
            let emptySerie :Serie = Serie(serie:uneSerieBetaSeries.serie)
            var uneSerieMovieDB : Serie = emptySerie
            var uneSerieTVMaze : Serie = emptySerie
            var uneSerieIMDB : Serie = emptySerie
            uneSerieIMDB = imdb.getSerieGlobalInfos(idIMDB: uneSerieBetaSeries.idIMdb)
            
            for i in 0..<dataTheMovieDB.count { if (uneSerieBetaSeries.serie == dataTheMovieDB[i].serie) { uneSerieMovieDB = dataTheMovieDB[i]; break; } }
            for i in 0..<dataTVMaze.count { if (uneSerieBetaSeries.idIMdb == dataTVMaze[i].idIMdb) { uneSerieTVMaze = dataTVMaze[i]; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: emptySerie, BetaSeries: uneSerieBetaSeries,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie, AlloCine: emptySerie)
            
            traitees.append(uneSerie.serie)
            result.append(uneSerie)
        }
        
        // Adding series from TVMaze
        for uneSerieTVMaze in dataTVMaze {
            if traitees.contains(uneSerieTVMaze.serie) { continue }
            
            let uneSerie : Serie = Serie(serie: "")
            
            let emptySerie :Serie = Serie(serie:uneSerieTVMaze.serie)
            var uneSerieMovieDB : Serie = emptySerie
            var uneSerieIMDB : Serie = emptySerie
            uneSerieIMDB = imdb.getSerieGlobalInfos(idIMDB: uneSerieTVMaze.idIMdb)
            
            for i in 0..<dataTheMovieDB.count { if (uneSerieTVMaze.serie == dataTheMovieDB[i].serie) { uneSerieMovieDB = dataTheMovieDB[i]; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: emptySerie, BetaSeries: emptySerie,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie, AlloCine: emptySerie)
            
            traitees.append(uneSerie.serie)
            result.append(uneSerie)
        }
        
        // Adding series from MovieDB
        for uneSerieMovieDB in dataTheMovieDB {
            if traitees.contains(uneSerieMovieDB.serie) { continue }
            result.append(uneSerieMovieDB)
        }
        
        return Array(result.sorted(by: { ($0.ratingTrakt + $0.ratingBetaSeries + $0.ratingMovieDB + $0.ratingTVmaze) > ($1.ratingTrakt + $1.ratingBetaSeries + $1.ratingMovieDB + $1.ratingTVmaze) }).prefix(12))
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
        
        results.reloadData()
        results.setNeedsLayout()
            
        cptResults.text = String(seriesTrouvees.count)
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
        if (actionadventure.isSelected && (actionadventure.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Action & Adventure, " }
        if (animation.isSelected && (animation.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Animation, " }
        if (comedy.isSelected && (comedy.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Comedy, " }
        if (crime.isSelected && (crime.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Crime, " }
        if (drama.isSelected && (drama.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Drama, " }
        if (mystery.isSelected && (mystery.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Mystery, " }
        if (scififantasy.isSelected && (scififantasy.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Sci-Fi & Fantasy, " }
        if (warpolitics.isSelected && (warpolitics.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "War & Politics, " }
        if (western.isSelected && (western.titleColor(for: .selected) == .systemGreen)) { tmpGenres = tmpGenres + "Western, " }
        
        if (tmpGenres == "" ) { descriptionTexte.text = descriptionTexte.text + "\n\ntous genres confondus" }
        else {
            tmpGenres.removeLast()
            tmpGenres.removeLast()
            descriptionTexte.text = descriptionTexte.text + "\n\nde genre " + tmpGenres
        }
        
        // exclusions de genres
        var tmpGenres2 : String = ""
        if (actionadventure.isSelected && (actionadventure.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Action & Adventure, " }
        if (animation.isSelected && (animation.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Animation, " }
        if (comedy.isSelected && (comedy.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Comedy, " }
        if (crime.isSelected && (crime.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Crime, " }
        if (drama.isSelected && (drama.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Drama, " }
        if (mystery.isSelected && (mystery.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Mystery, " }
        if (scififantasy.isSelected && (scififantasy.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Sci-Fi & Fantasy, " }
        if (warpolitics.isSelected && (warpolitics.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "War & Politics, " }
        if (western.isSelected && (western.titleColor(for: .selected) == .systemRed)) { tmpGenres2 = tmpGenres2 + "Western, " }

        if (tmpGenres2 == "" ) { descriptionTexte.text = descriptionTexte.text + "" }
        else {
            tmpGenres2.removeLast()
            tmpGenres2.removeLast()
            descriptionTexte.text = descriptionTexte.text + "\nmais pas de genre " + tmpGenres2
        }
        
        
        // Choix du network de diffusion
        var tmpNetworks : String = ""
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

        results.reloadData()
        results.setNeedsLayout()

        cptResults.text = String(nbSeriesTrouvees)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(seriesTrouvees.count, 20)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellResult", for: indexPath) as! CellResult
        
        cell.titre.text = seriesTrouvees[indexPath.row].serie
        if (seriesTrouvees[indexPath.row].year == 0) { cell.annee.text = "-" }
        else { cell.annee.text = String(seriesTrouvees[indexPath.row].year) }
        cell.index = indexPath.row

        return cell
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellResult = sender as! CellResult
        
        db.downloadGlobalInfo(serie: seriesTrouvees[tableCell.index])
        
        viewController.serie = seriesTrouvees[tableCell.index]
        viewController.image = getImage(seriesTrouvees[tableCell.index].banner)
        viewController.modeAffichage = modeRecherche

    }
    
}

