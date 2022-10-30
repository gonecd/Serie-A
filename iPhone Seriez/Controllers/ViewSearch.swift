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
    @IBOutlet weak var poster: UIImageView!
    
    @IBOutlet weak var sourceTVMaze: UIImageView!
    @IBOutlet weak var sourceBetaSeries: UIImageView!
    @IBOutlet weak var sourceTrakt: UIImageView!
    @IBOutlet weak var sourceMovieDB: UIImageView!
    
    var index: Int = 0
}


struct SourceRecherche {
    var TVMaze      : Bool = false
    var BetaSeries  : Bool = false
    var Trakt       : Bool = false
    var MovieDB     : Bool = false
    
    public init(foundTVMaze : Bool, foundBetaSeries : Bool, foundTrakt : Bool, foundMovieDB : Bool) {
        self.TVMaze = foundTVMaze
        self.BetaSeries = foundBetaSeries
        self.Trakt = foundTrakt
        self.MovieDB = foundMovieDB
    }
}

class ViewSearch: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var quickSearch: UIView!
    @IBOutlet weak var traktSearch: UIView!
    @IBOutlet weak var moviedbSearch: UIView!
    @IBOutlet weak var betaSeriesSearch: UIView!
    
    // Entete
    @IBOutlet weak var cptResults: UITextField!
    @IBOutlet weak var cptResultsTotal: UITextField!
    @IBOutlet weak var descriptionTexte: UITextView!
    @IBOutlet weak var results: UITableView!

    // Quick Search
    @IBOutlet weak var quickTitre: UITextField!

    // Trakt Search
    @IBOutlet weak var titre: UITextField!
    @IBOutlet weak var inTitre: UISwitch!
    @IBOutlet weak var inResume: UISwitch!
    @IBOutlet weak var inCasting: UISwitch!
    
    // MovieDB Search
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
    
    // BetaSeries Search
    @IBOutlet weak var debutBetaSeries: UITextField!
    @IBOutlet weak var finBetaSeries: UITextField!

    @IBOutlet weak var duree0020: UIButton!
    @IBOutlet weak var duree2030: UIButton!
    @IBOutlet weak var duree3040: UIButton!
    @IBOutlet weak var duree4050: UIButton!
    @IBOutlet weak var duree5060: UIButton!
    @IBOutlet weak var duree60plus: UIButton!
    
    @IBOutlet weak var streamNetflix: UIButton!
    @IBOutlet weak var streamDisney: UIButton!
    @IBOutlet weak var streamCanal: UIButton!
    @IBOutlet weak var streamAmazon: UIButton!
    @IBOutlet weak var streamApple: UIButton!
    @IBOutlet weak var streamOCS: UIButton!
    
    @IBOutlet weak var genreBScomedy: UIButton!
    @IBOutlet weak var genreBSdrama: UIButton!
    @IBOutlet weak var genreBSsoap: UIButton!
    @IBOutlet weak var genreBScrime: UIButton!
    @IBOutlet weak var genreBShorror: UIButton!
    @IBOutlet weak var genreBSchild: UIButton!
    @IBOutlet weak var genreBSanime: UIButton!
    @IBOutlet weak var genreBSaction: UIButton!
    @IBOutlet weak var genreBSfamilly: UIButton!
    @IBOutlet weak var genreBSadventure: UIButton!
    @IBOutlet weak var genreBSfantasy: UIButton!
    @IBOutlet weak var genreBSmystery: UIButton!
    @IBOutlet weak var genreBSanimation: UIButton!
    @IBOutlet weak var genreBSscify: UIButton!
    @IBOutlet weak var genreBSsport: UIButton!
    @IBOutlet weak var genreBSminiserie: UIButton!
    @IBOutlet weak var genreBSromance: UIButton!
    @IBOutlet weak var genreBSsuspense: UIButton!
    @IBOutlet weak var genreBSwestern: UIButton!
    @IBOutlet weak var genreBSthriller: UIButton!
    @IBOutlet weak var genreBShistory: UIButton!
    
    
    let viewQuick       : Int = 0
    let viewTrakt       : Int = 1
    let viewMovieDB     : Int = 2
    let viewBetaSeries  : Int = 3

    let alphaFull  : CGFloat = 1.00
    let alphaLight : CGFloat = 0.20

    var seriesTrouvees  : [Serie] = []
    var sourcesTrouvees  : [SourceRecherche] = []
    var currentView     : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeGradiant(carre: traktSearch, couleur: "Blanc")
        makeGradiant(carre: quickSearch, couleur: "Blanc")
        makeGradiant(carre: moviedbSearch, couleur: "Blanc")
        makeGradiant(carre: betaSeriesSearch, couleur: "Blanc")
        makeGradiant(carre: results, couleur: "Blanc")

        arrondir(texte: cptResults, radius: 10.0)
        arrondir(texte: cptResultsTotal, radius: 10.0)
        cptResults.text = "0"
        cptResultsTotal.text = "+" + "\u{221E}"
        currentView = viewQuick
        
        descriptionTexte.text = ""
    }
    
    @IBAction func searchMode(_ sender: Any) {
        let toggle : Int = (sender as! UISegmentedControl).selectedSegmentIndex
        descriptionTexte.text = ""

        switch toggle {
        case 0:
            self.moviedbSearch.isHidden = true
            self.traktSearch.isHidden = true
            self.betaSeriesSearch.isHidden = true
            self.quickSearch.isHidden = false
            currentView = viewQuick
            updateRechercheQuick(sender)
            break
            
        case 1:
            self.moviedbSearch.isHidden = true
            self.traktSearch.isHidden = false
            self.betaSeriesSearch.isHidden = true
            self.quickSearch.isHidden = true
            currentView = viewTrakt
            updateRechercheTrakt(sender)
            break

        case 2:
            self.moviedbSearch.isHidden = false
            self.traktSearch.isHidden = true
            self.betaSeriesSearch.isHidden = true
            self.quickSearch.isHidden = true
            currentView = viewMovieDB
            updateRechercheCriteres(sender)
            break
            
        case 3:
            self.moviedbSearch.isHidden = true
            self.traktSearch.isHidden = true
            self.betaSeriesSearch.isHidden = false
            self.quickSearch.isHidden = true
            currentView = viewBetaSeries
            updateRechercheBetaSeries(sender)
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
        
        if (currentView == viewMovieDB) { updateRechercheCriteres(sender) }
        else if (currentView == viewBetaSeries) { updateRechercheBetaSeries(sender) }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        cell.poster.image = getImage(seriesTrouvees[indexPath.row].poster)
        cell.index = indexPath.row

        if (sourcesTrouvees[indexPath.row].TVMaze)      { cell.sourceTVMaze.alpha = alphaFull }      else { cell.sourceTVMaze.alpha = alphaLight }
        if (sourcesTrouvees[indexPath.row].BetaSeries)  { cell.sourceBetaSeries.alpha = alphaFull }  else { cell.sourceBetaSeries.alpha = alphaLight }
        if (sourcesTrouvees[indexPath.row].Trakt)       { cell.sourceTrakt.alpha = alphaFull }       else { cell.sourceTrakt.alpha = alphaLight }
        if (sourcesTrouvees[indexPath.row].MovieDB)     { cell.sourceMovieDB.alpha = alphaFull }     else { cell.sourceMovieDB.alpha = alphaLight }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellResult = sender as! CellResult
        
        if (self.currentView == viewBetaSeries) { seriesTrouvees[tableCell.index] = betaSeries.getSerieGlobalInfos(idTVDB: seriesTrouvees[tableCell.index].idTVdb, idIMDB: seriesTrouvees[tableCell.index].idIMdb, idBetaSeries: seriesTrouvees[tableCell.index].idBetaSeries) }
        
        db.downloadGlobalInfo(serie: seriesTrouvees[tableCell.index])
        
        viewController.serie = seriesTrouvees[tableCell.index]
        viewController.image = getImage(seriesTrouvees[tableCell.index].banner)
        viewController.modeAffichage = modeRecherche
    }
    
    
    
    
    // ===================================================
    //
    //      Recherche Quick
    //
    // ===================================================
    
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
            
            (seriesTrouvees, sourcesTrouvees) = mergeResults(dataTrakt: dataTrakt, dataBetaSeries: dataBetaSeries, dataTheMovieDB: dataTheMovieDB, dataTVMaze: dataTVMaze)
            
            cptResults.text = String(seriesTrouvees.count)
            cptResultsTotal.text = String(dataTrakt.count + dataBetaSeries.count + dataTheMovieDB.count + dataTVMaze.count)
        }
        else {
            seriesTrouvees = []
            cptResults.text = "0"
            cptResultsTotal.text = "+" + "\u{221E}"
        }
        
        results.reloadData()
        results.setNeedsLayout()
            
    }

    func mergeResults(dataTrakt :[Serie], dataBetaSeries :[Serie], dataTheMovieDB :[Serie], dataTVMaze :[Serie]) -> ([Serie], [SourceRecherche]) {
        var result : [Serie] = []
        var sources : [SourceRecherche] = []
        
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
            var source : SourceRecherche = SourceRecherche.init(foundTVMaze: false, foundBetaSeries: false, foundTrakt: true, foundMovieDB: false)
            
            for i in 0..<dataBetaSeries.count { if (uneSerieTrakt.idIMdb == dataBetaSeries[i].idIMdb) { uneSerieBetaSeries = dataBetaSeries[i]; source.BetaSeries = true; break; } }
            for i in 0..<dataTheMovieDB.count { if (uneSerieTrakt.idMoviedb == dataTheMovieDB[i].idMoviedb) { uneSerieMovieDB = dataTheMovieDB[i]; source.MovieDB = true; break; } }
            for i in 0..<dataTVMaze.count { if (uneSerieTrakt.idIMdb == dataTVMaze[i].idIMdb) { uneSerieTVMaze = dataTVMaze[i]; source.TVMaze = true; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: uneSerieTrakt, BetaSeries: uneSerieBetaSeries,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie, YAQCS: emptySerie)
            
            traitees.append(uneSerie.serie)
            result.append(uneSerie)
            sources.append(source)
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
            var source : SourceRecherche = SourceRecherche.init(foundTVMaze: false, foundBetaSeries: true, foundTrakt: false, foundMovieDB: false)

            for i in 0..<dataTheMovieDB.count { if (uneSerieBetaSeries.serie == dataTheMovieDB[i].serie) { uneSerieMovieDB = dataTheMovieDB[i]; source.MovieDB = true; break; } }
            for i in 0..<dataTVMaze.count { if (uneSerieBetaSeries.idIMdb == dataTVMaze[i].idIMdb) { uneSerieTVMaze = dataTVMaze[i]; source.TVMaze = true; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: emptySerie, BetaSeries: uneSerieBetaSeries,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie, YAQCS: emptySerie)
            
            traitees.append(uneSerie.serie)
            result.append(uneSerie)
            sources.append(source)
        }
        
        // Adding series from TVMaze
        for uneSerieTVMaze in dataTVMaze {
            if traitees.contains(uneSerieTVMaze.serie) { continue }
            
            let uneSerie : Serie = Serie(serie: "")
            
            let emptySerie :Serie = Serie(serie:uneSerieTVMaze.serie)
            var uneSerieMovieDB : Serie = emptySerie
            var uneSerieIMDB : Serie = emptySerie
            uneSerieIMDB = imdb.getSerieGlobalInfos(idIMDB: uneSerieTVMaze.idIMdb)
            var source : SourceRecherche = SourceRecherche.init(foundTVMaze: true, foundBetaSeries: false, foundTrakt: false, foundMovieDB: false)

            for i in 0..<dataTheMovieDB.count { if (uneSerieTVMaze.serie == dataTheMovieDB[i].serie) { uneSerieMovieDB = dataTheMovieDB[i]; source.MovieDB = true; break; } }
            
            uneSerie.cleverMerge(TVdb: emptySerie, Moviedb: uneSerieMovieDB, Trakt: emptySerie, BetaSeries: emptySerie,
                                 IMDB: uneSerieIMDB, RottenTomatoes: emptySerie, TVmaze: uneSerieTVMaze, MetaCritic: emptySerie, YAQCS: emptySerie)
            
            traitees.append(uneSerie.serie)
            result.append(uneSerie)
            sources.append(source)
        }
        
        // Adding series from MovieDB
        for uneSerieMovieDB in dataTheMovieDB {
            if traitees.contains(uneSerieMovieDB.serie) { continue }
            let source : SourceRecherche = SourceRecherche.init(foundTVMaze: false, foundBetaSeries: false, foundTrakt: false, foundMovieDB: true)
            result.append(uneSerieMovieDB)
            sources.append(source)
        }
        
        let arrays_combined = zip(result, sources).sorted(by: {($0.0.ratingTrakt + $0.0.ratingBetaSeries + $0.0.ratingMovieDB + $0.0.ratingTVmaze) > ($1.0.ratingTrakt + $1.0.ratingBetaSeries + $1.0.ratingMovieDB + $1.0.ratingTVmaze)})
        
        return (Array(arrays_combined.map {$0.0}.prefix(20)), Array(arrays_combined.map {$0.1}.prefix(20)))
    }

    
    // ===================================================
    //
    //      Recherche Trakt
    //
    // ===================================================

    @IBAction func updateRechercheTrakt(_ sender: Any) {
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
        sourcesTrouvees = []
        
        if ((titre.text != "") && (chercherDans != "")) {
            chercherDans.removeLast()
            seriesTrouvees = trakt.recherche(serieArechercher: titre.text!, aChercherDans : chercherDans)
        }
        
        let uneSourceTrakt : SourceRecherche = SourceRecherche.init(foundTVMaze: false, foundBetaSeries: false, foundTrakt: true, foundMovieDB: false)
        for _ in seriesTrouvees {
            sourcesTrouvees.append(uneSourceTrakt)
        }
        
        results.reloadData()
        results.setNeedsLayout()
            
        cptResults.text = String(seriesTrouvees.count)
        cptResultsTotal.text = String(seriesTrouvees.count)
    }

    
    
    
    // ===================================================
    //
    //      Recherche Movie DB
    //
    // ===================================================

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
        sourcesTrouvees = []
        
        (seriesTrouvees, nbSeriesTrouvees) = theMoviedb.chercher(genreIncl: tmpGenres.replacingOccurrences(of: ", ", with: ","),
                                                                 genreExcl: tmpGenres2.replacingOccurrences(of: ", ", with: ","),
                                                                 anneeBeg: debut.text!,
                                                                 anneeEnd: fin.text!,
                                                                 langue: tmpLangue,
                                                                 network: tmpNetworks.replacingOccurrences(of: ", ", with: ","))

        let uneSourceMovieDB : SourceRecherche = SourceRecherche.init(foundTVMaze: false, foundBetaSeries: false, foundTrakt: false, foundMovieDB: true)
        for _ in seriesTrouvees {
            sourcesTrouvees.append(uneSourceMovieDB)
        }
        
        results.reloadData()
        results.setNeedsLayout()

        cptResults.text = String(seriesTrouvees.count)
        cptResultsTotal.text = String(nbSeriesTrouvees)
    }
    
    
    // ===================================================
    //
    //      Recherche BetaSeries
    //
    // ===================================================

    @IBAction func buttonSelectDurees(_ sender: Any) {
        let button : UIButton = sender as! UIButton
        let tmpStatus : Bool = button.isSelected
        
        duree0020.isSelected = false
        duree2030.isSelected = false
        duree3040.isSelected = false
        duree4050.isSelected = false
        duree5060.isSelected = false
        duree60plus.isSelected = false

        button.isSelected = !tmpStatus
        
        updateRechercheBetaSeries(sender)
    }

    @IBAction func updateRechercheBetaSeries(_ sender: Any) {
        descriptionTexte.text = "Toutes les séries"
        
        // Choix de la periode
        if (debutBetaSeries.text == "") {
            if (finBetaSeries.text == "") { descriptionTexte.text = descriptionTexte.text + "\n\n" }
            else { descriptionTexte.text = descriptionTexte.text + "\n\ndiffusées avant " + finBetaSeries.text! }
        }
        else {
            if (finBetaSeries.text == "") { descriptionTexte.text = descriptionTexte.text + "\n\ndiffusées après " + debutBetaSeries.text! }
            else { descriptionTexte.text = descriptionTexte.text + "\n\ndiffusées entre " + debutBetaSeries.text! + " et " + finBetaSeries.text! }
        }
        
        // Choix des genres
        var tmpGenres : String = ""
        if (genreBScomedy.isSelected) { tmpGenres = tmpGenres + "Comédie, " }
        if (genreBSdrama.isSelected) { tmpGenres = tmpGenres + "Drame, " }
        if (genreBSsoap.isSelected) { tmpGenres = tmpGenres + "Soap, " }
        if (genreBScrime.isSelected) { tmpGenres = tmpGenres + "Crime, " }
        if (genreBShorror.isSelected) { tmpGenres = tmpGenres + "Horreur, " }
        if (genreBSchild.isSelected) { tmpGenres = tmpGenres + "Enfant, " }
        if (genreBSanime.isSelected) { tmpGenres = tmpGenres + "Anime, " }
        if (genreBSaction.isSelected) { tmpGenres = tmpGenres + "Action, " }
        if (genreBSfamilly.isSelected) { tmpGenres = tmpGenres + "Famille, " }
        if (genreBSadventure.isSelected) { tmpGenres = tmpGenres + "Aventure, " }
        if (genreBSfantasy.isSelected) { tmpGenres = tmpGenres + "Fantastique, " }
        if (genreBSmystery.isSelected) { tmpGenres = tmpGenres + "Mystère, " }
        if (genreBSanimation.isSelected) { tmpGenres = tmpGenres + "Animation, " }
        if (genreBSscify.isSelected) { tmpGenres = tmpGenres + "Science-fiction, " }
        if (genreBSsport.isSelected) { tmpGenres = tmpGenres + "Sport, " }
        if (genreBSminiserie.isSelected) { tmpGenres = tmpGenres + "Mini-Series, " }
        if (genreBSromance.isSelected) { tmpGenres = tmpGenres + "Romance, " }
        if (genreBSsuspense.isSelected) { tmpGenres = tmpGenres + "Suspense, " }
        if (genreBSwestern.isSelected) { tmpGenres = tmpGenres + "Western, " }
        if (genreBSthriller.isSelected) { tmpGenres = tmpGenres + "Thriller, " }
        if (genreBShistory.isSelected) { tmpGenres = tmpGenres + "Histoire, " }
        
        if (tmpGenres == "" ) { descriptionTexte.text = descriptionTexte.text + "\n\ntous genres confondus" }
        else {
            tmpGenres.removeLast()
            tmpGenres.removeLast()
            descriptionTexte.text = descriptionTexte.text + "\n\nde genre " + tmpGenres
        }

        
        // Choix de la durée d'épisode
        var tmpDuree : String = ""
        if (duree0020.isSelected)        { tmpDuree = "moins de 20 min" }
        else if (duree2030.isSelected)   { tmpDuree = "20 à 30 min" }
        else if (duree3040.isSelected)   { tmpDuree = "30 à 40 min" }
        else if (duree4050.isSelected)   { tmpDuree = "40 à 50 min" }
        else if (duree5060.isSelected)   { tmpDuree = "50 à 60 min" }
        else if (duree60plus.isSelected) { tmpDuree = "plus de 60 min" }
        
        if (tmpDuree == "") { descriptionTexte.text = descriptionTexte.text + "\n\nquelle que soit la durée des épisodes" }
        else                { descriptionTexte.text = descriptionTexte.text + "\n\navec des épisodes de " + tmpDuree }

        // Choix du service de Streaming
        var tmpStreamers : String = ""
        if (streamNetflix.isSelected) { tmpStreamers = tmpStreamers + "Netflix, " }
        if (streamDisney.isSelected) { tmpStreamers = tmpStreamers + "Disney+, " }
        if (streamCanal.isSelected) { tmpStreamers = tmpStreamers + "Canal+, " }
        if (streamAmazon.isSelected) { tmpStreamers = tmpStreamers + "Amazon Prime, " }
        if (streamApple.isSelected) { tmpStreamers = tmpStreamers + "Apple TV+, " }
        if (streamOCS.isSelected) { tmpStreamers = tmpStreamers + "OCS Go, " }
        if (tmpStreamers == "" ) { descriptionTexte.text = descriptionTexte.text + "\n\n" }
        else {
            tmpStreamers.removeLast()
            tmpStreamers.removeLast()
            descriptionTexte.text = descriptionTexte.text + "\n\nstreamées par " + tmpStreamers
        }
        
        
        // Recherche sur BetaSeries
        var nbSeriesTrouvees : Int = 0
        seriesTrouvees = []
        sourcesTrouvees = []
        
        (seriesTrouvees, nbSeriesTrouvees) = betaSeries.chercher(genres: tmpGenres.replacingOccurrences(of: ", ", with: ","),
                                                                 anneeBeg: debutBetaSeries.text!,
                                                                 anneeEnd: finBetaSeries.text!,
                                                                 duree: tmpDuree,
                                                                 streamers: tmpStreamers.replacingOccurrences(of: ", ", with: ","))

        let uneSourceBetaSeries : SourceRecherche = SourceRecherche.init(foundTVMaze: false, foundBetaSeries: true, foundTrakt: false, foundMovieDB: false)
        for _ in seriesTrouvees {
            sourcesTrouvees.append(uneSourceBetaSeries)
        }
        
        results.reloadData()
        results.setNeedsLayout()

        cptResults.text = String(seriesTrouvees.count)
        cptResultsTotal.text = String(nbSeriesTrouvees)
    }
    
}

