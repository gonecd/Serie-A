//
//  SerieFiche.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

class CellSaison: UITableViewCell {
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var debut: UILabel!
    @IBOutlet weak var fin: UILabel!
    @IBOutlet weak var episodes: UILabel!
    @IBOutlet weak var graphe: GraphMiniSaison!
}


class SerieFiche: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var allCritics : [Critique] = []
    var modeAffichage : Int = 0
    
    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: Graph!
    @IBOutlet weak var spiderGraph: GraphMiniSerie!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewResume: UIView!
    @IBOutlet weak var viewInfos: UIView!
    @IBOutlet weak var viewRatings: UIView!
    
    @IBOutlet weak var viewSaisons: UITableView!
    
    @IBOutlet weak var boutonMyRating: UIButton!
    
    @IBOutlet weak var boutonWatchlist: UIView!
    @IBOutlet weak var boutonDiffuseurs: UIView!
    @IBOutlet weak var boutonNoter: UIView!
    @IBOutlet weak var boutonAbandon: UIView!
    @IBOutlet weak var boutonCritiques: UIView!
    @IBOutlet weak var boutonCasting: UIView!
    @IBOutlet weak var boutonRatings: UIView!

    @IBOutlet weak var sousBoutonWatchlist: UIButton!
    @IBOutlet weak var sousBoutonAbandon: UIButton!
    
    @IBOutlet weak var bRate1: UIButton!
    @IBOutlet weak var bRate2: UIButton!
    @IBOutlet weak var bRate3: UIButton!
    @IBOutlet weak var bRate4: UIButton!
    @IBOutlet weak var bRate5: UIButton!
    @IBOutlet weak var bRate6: UIButton!
    @IBOutlet weak var bRate7: UIButton!
    @IBOutlet weak var bRate8: UIButton!
    @IBOutlet weak var bRate9: UIButton!
    
    @IBOutlet weak var network: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var duree: UILabel!
    @IBOutlet weak var certif: UILabel!
    @IBOutlet weak var langue: UILabel!
    @IBOutlet weak var drapeau: UIImageView!
    @IBOutlet weak var drapeauBgd: UILabel!
    @IBOutlet weak var annee: UILabel!
    @IBOutlet weak var note: UILabel!
    
    @IBOutlet weak var labelInfos: UILabel!
    @IBOutlet weak var labelResume: UILabel!
    @IBOutlet weak var labelNotes: UILabel!
    @IBOutlet weak var labelSaisons: UILabel!
    
    @IBOutlet weak var bWebSite: UIButton!
    @IBOutlet weak var bTrakt: UIButton!
    @IBOutlet weak var bTVMaze: UIButton!
    @IBOutlet weak var bRotTom: UIButton!
    @IBOutlet weak var bIMDB: UIButton!
    @IBOutlet weak var bBetaSeries: UIButton!
    @IBOutlet weak var bMetaCritic: UIButton!
    @IBOutlet weak var bAlloCine: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = serie.serie
        
        makeGradiant(carre: boutonDiffuseurs, couleur: "Gris")
        makeGradiant(carre: boutonCritiques, couleur: "Gris")
        makeGradiant(carre: boutonCasting, couleur: "Gris")
        makeGradiant(carre: boutonWatchlist, couleur: "Vert")

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            makeGradiant(carre: boutonNoter, couleur: "Bleu")
            makeGradiant(carre: boutonAbandon, couleur: "Rouge")
            
            modeSpecifique(mode: modeAffichage)
        }
        else {
            makeGradiant(carre: boutonRatings, couleur: "Gris")

            if (modeAffichage == modeRecherche) {
                boutonWatchlist.isHidden = false
            }
            else {
                boutonWatchlist.isHidden = true
            }
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
        
        arrondirLabel(texte: labelInfos, radius: 10)
        arrondirLabel(texte: labelResume, radius: 10)
        arrondirLabel(texte: labelNotes, radius: 10)
        arrondirLabel(texte: labelSaisons, radius: 10)
        
        annee.text = String(serie.year)
        resume.text = serie.resume
        banniere.image = image
        
        let noteGlobale : Double = Double(serie.getGlobalRating())/10.0
        note.text = "👍🏼 " + String(noteGlobale)
        note.layer.borderColor = UIColor.systemBlue.cgColor
        note.layer.borderWidth = 2
        note.layer.cornerRadius = 10
        note.layer.masksToBounds = true
        
        // Masquer les liens s'il n'y a pas de page derrière ...
        if (rottenTomatoes.getPath(serie: serie.serie) == "") { bRotTom.isHidden = true }
        if (metaCritic.getPath(serie: serie.serie) == "") { bMetaCritic.isHidden = true }
        if (serie.homepage == "") { bWebSite.isHidden = true }
        if (serie.idAlloCine == "") { bAlloCine.isHidden = true }
        if (serie.idTVmaze == "") { bTVMaze.isHidden = true }
        if (serie.idIMdb == "") { bIMDB.isHidden = true }
        if (serie.idTrakt == "") { bTrakt.isHidden = true }
        
        // Affichage des genres
        var allGenres : String = ""
        for unGenre in serie.genres {
            allGenres = allGenres + unGenre + " "
        }
        genre.text = allGenres
        
        // Arrondir les labels
        arrondirLabel(texte: status, radius: 10)
        arrondirLabel(texte: network, radius: 8)
        arrondirLabel(texte: duree, radius: 8)
        arrondirLabel(texte: certif, radius: 8)
        arrondirLabel(texte: langue, radius: 8)
        arrondirLabel(texte: drapeauBgd, radius: 8)
        arrondirLabel(texte: genre, radius: 8)
        arrondirLabel(texte: annee, radius: 8)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            arrondir(fenetre: viewRatings, radius: 10)
            
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
        
        // Affichage du status
        if (serie.status == "Ended") {
            status.text = "FINIE"
            status.textColor = .black
        }
        else {
            status.text = "EN COURS"
            status.textColor = .systemBlue
        }
        
        // Remplissage des labels
        network.text? = serie.network
        duree.text? = String(serie.runtime) + " min"
        certif.text? = serie.certification
        langue.text? = serie.language
        drapeau.image = getDrapeau(country: serie.country)
        
        trakt.getEpisodes(uneSerie: serie)
        
        //Affichage du spider graph
        spiderGraph.sendNotes(rateTrakt: serie.getFairGlobalRatingTrakt(),
                              rateBetaSeries: serie.getFairGlobalRatingBetaSeries(),
                              rateMoviedb: serie.getFairGlobalRatingMoviedb(),
                              rateIMdb: serie.getFairGlobalRatingIMdb(),
                              rateTVmaze: serie.getFairGlobalRatingTVmaze(),
                              rateRottenTomatoes: serie.getFairGlobalRatingRottenTomatoes(),
                              rateMetaCritic: serie.getFairGlobalRatingMetaCritic(),
                              rateAlloCine: serie.getFairGlobalRatingAlloCine(),
                              rateSensCritique: serie.getFairGlobalRatingSensCritique() )
        spiderGraph.setType(type: 3)
        spiderGraph.setNeedsDisplay()
        
        
        let queue : OperationQueue = OperationQueue()
        
        let opRates = BlockOperation(block: {
            imdb.getEpisodesRatings(self.serie)
            OperationQueue.main.addOperation({
                self.graphe.sendSerie(self.serie)
                self.graphe.setNeedsDisplay()
            } )
            
            if (self.serie.idTVdb != "") { betaSeries.getEpisodesRatings(self.serie) }
            OperationQueue.main.addOperation({
                self.graphe.sendSerie(self.serie)
                self.graphe.setNeedsDisplay()
            } )
        } )
        queue.addOperation(opRates)
        
        let opeFinalise = BlockOperation(block: {
            db.saveDB()
            
            OperationQueue.main.addOperation({
                self.viewSaisons.reloadData()
                self.viewSaisons.setNeedsLayout()
            } )
        } )
        opeFinalise.addDependency(opRates)
        //        opeFinalise.addDependency(opeCritics)
        queue.addOperation(opeFinalise)
        
    }
    
    
    func modeSpecifique(mode : Int){
        let attributes = [NSAttributedString.Key.strikethroughStyle : 1, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemBackground] as [NSAttributedString.Key : Any]
        let titleNoAbandon = NSAttributedString(string: "       Abandon", attributes: attributes)
        let titleNoWatchlist = NSAttributedString(string: "       Watchlist", attributes: attributes)
        
        boutonDiffuseurs.isHidden = false
        
        switch mode {
        case modeFinie:
            boutonNoter.isHidden = false
            boutonWatchlist.isHidden = true
            boutonAbandon.isHidden = true
            break
        case modeEnCours:
            boutonNoter.isHidden = false
            boutonWatchlist.isHidden = true
            boutonAbandon.isHidden = false
            break
        case modeAbandon:
            boutonNoter.isHidden = false
            boutonWatchlist.isHidden = true
            boutonAbandon.isHidden = false
            sousBoutonAbandon.setAttributedTitle(titleNoAbandon, for: .normal)
            break
        case modeWatchlist:
            boutonNoter.isHidden = true
            boutonWatchlist.isHidden = false
            boutonAbandon.isHidden = true
            sousBoutonWatchlist.setAttributedTitle(titleNoWatchlist, for: .normal)
            break
        case modeRecherche:
            boutonNoter.isHidden = true
            boutonWatchlist.isHidden = false
            boutonAbandon.isHidden = true
            break
        case modeParRate:
            boutonNoter.isHidden = true
            boutonWatchlist.isHidden = true
            boutonAbandon.isHidden = true
            break
            
        default:
            return
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serie.saisons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSaison", for: indexPath) as! CellSaison
        cell.saison.text = "Saison " + String(indexPath.row + 1)
        cell.episodes.text = String(serie.saisons[indexPath.row].nbEpisodes) + " épisodes"
        
        if (serie.saisons[indexPath.row].starts == ZeroDate) { cell.debut.text = "TBD" }
        else { cell.debut.text = dateFormShort.string(from: serie.saisons[indexPath.row].starts) }
        
        if (serie.saisons[indexPath.row].ends == ZeroDate) { cell.fin.text = "TBD" }
        else { cell.fin.text = dateFormShort.string(from: serie.saisons[indexPath.row].ends) }
        
        cell.graphe.setSerie(serie: serie, saison: indexPath.row + 1)
        cell.graphe.setType(type: 3)
        cell.graphe.setNeedsDisplay()
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowSaison") {
            let viewController = segue.destination as! SaisonFiche
            
            viewController.serie = serie
            viewController.saison = (viewSaisons.indexPathForSelectedRow?.row)! + 1
            viewController.image = getImage(serie.banner)
        }
        else if (segue.identifier == "ShowDetailsCritique") {
            let viewController = segue.destination as! SerieFicheDetails
            viewController.serie = serie
            viewController.detailType = viewController.detailTypeCritique
        }
        else if (segue.identifier == "ShowDetailsDiffuseur") {
            let viewController = segue.destination as! SerieFicheDetails
            viewController.serie = serie
            viewController.detailType = viewController.detailTypeDiffuseurs
        }
        else if (segue.identifier == "ShowDetailsCasting") {
            let viewController = segue.destination as! SerieFicheDetails
            viewController.serie = serie
            viewController.detailType = viewController.detailTypeCasting
        }
        else if (segue.identifier == "ShowDetailsRatings") {
            let viewController = segue.destination as! SerieFicheDetails
            viewController.serie = serie
            viewController.detailType = viewController.detailTypeRatings
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            if gesture.direction == UISwipeGestureRecognizer.Direction.right {
                pageControl.currentPage = pageControl.currentPage - 1
            }
            else {
                pageControl.currentPage = pageControl.currentPage + 1
            }
            
            self.changePage(sender: self)
        }
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        switch (pageControl.currentPage) {
        case 0:
            viewResume.isHidden = false
            viewInfos.isHidden = false
            viewSaisons.isHidden = true
            graphe.isHidden = true
            
        case 1:
            viewResume.isHidden = true
            viewInfos.isHidden = false
            viewSaisons.isHidden = true
            graphe.isHidden = false
            
        case 2:
            viewResume.isHidden = true
            viewInfos.isHidden = true
            viewSaisons.isHidden = false
            graphe.isHidden = true
                       
        default:
            viewResume.isHidden = false
            viewInfos.isHidden = true
            viewSaisons.isHidden = true
            graphe.isHidden = true
        }
    }
    
    
    @IBAction func webTrakt(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://trakt.tv/shows/\(serie.idTrakt)")!) }
    @IBAction func webTVMaze(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://www.tvmaze.com/shows/\(serie.idTVmaze)")!) }
    @IBAction func webMetaCritic(_ sender: AnyObject) { UIApplication.shared.open(URL(string: metaCritic.getPath(serie: serie.serie))!) }
    @IBAction func webHomepage(_ sender: Any) { UIApplication.shared.open(URL(string: serie.homepage)!)}
    @IBAction func webRottenTomatoes(_ sender: AnyObject) { UIApplication.shared.open(URL(string: rottenTomatoes.getPath(serie: serie.serie))!) }
    @IBAction func webIMdb(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "http://www.imdb.com/title/\(serie.idIMdb)")!) }
    @IBAction func webAlloCine(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "http://www.allocine.fr/series/ficheserie_gen_cserie=\(serie.idAlloCine).html")!) }
    
    @IBAction func webBetaSeries(_ sender: AnyObject) {
        let myURL : String = "https://www.betaseries.com/serie/\(serie.serie.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "-"))"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func addRemoveWatchlist(_ sender: AnyObject) {
        if (serie.idTVdb != "") {
            if (modeAffichage == modeWatchlist){
                if (trakt.removeFromWatchlist(theTVdbId: serie.idTVdb)) {
                    db.downloadGlobalInfo(serie: serie)
                    db.shows.remove(at: db.shows.firstIndex(of: serie)!)
                    boutonWatchlist.isHidden = true
                    db.saveDB()
                }
            }
            else {
                if (trakt.addToWatchlist(theTVdbId: serie.idTVdb)) {
                    db.downloadGlobalInfo(serie: serie)
                    serie.watchlist = true
                    db.shows.append(serie)
                    boutonWatchlist.isHidden = true
                    db.saveDB()
                }
            }
        }
    }
    
    
    @IBAction func addRemoveAbandon(_ sender: AnyObject) {
        if (serie.idTVdb != "") {
            if (modeAffichage == modeAbandon){
                if (trakt.removeFromAbandon(theTVdbId: serie.idTVdb)) {
                    db.downloadGlobalInfo(serie: serie)
                    serie.unfollowed = false
                    boutonAbandon.isHidden = true
                    db.saveDB()
                }
            }
            else {
                if (trakt.addToAbandon(theTVdbId: serie.idTVdb)) {
                    db.downloadGlobalInfo(serie: serie)
                    serie.unfollowed = true
                    boutonAbandon.isHidden = true
                    db.saveDB()
                }
            }
        }
    }
    
    
    @IBAction func setMyRating(_ sender: Any) {
        viewRatings.isHidden = false
    }
    
    @IBAction func setRate1(_ sender: Any) { setRate(rate : 1); viewRatings.isHidden = true }
    @IBAction func setRate2(_ sender: Any) { setRate(rate : 2); viewRatings.isHidden = true }
    @IBAction func setRate3(_ sender: Any) { setRate(rate : 3); viewRatings.isHidden = true }
    @IBAction func setRate4(_ sender: Any) { setRate(rate : 4); viewRatings.isHidden = true }
    @IBAction func setRate5(_ sender: Any) { setRate(rate : 5); viewRatings.isHidden = true }
    @IBAction func setRate6(_ sender: Any) { setRate(rate : 6); viewRatings.isHidden = true }
    @IBAction func setRate7(_ sender: Any) { setRate(rate : 7); viewRatings.isHidden = true }
    @IBAction func setRate8(_ sender: Any) { setRate(rate : 8); viewRatings.isHidden = true }
    @IBAction func setRate9(_ sender: Any) { setRate(rate : 9); viewRatings.isHidden = true }
    
    @IBAction func cancelRate(_ sender: Any) { viewRatings.isHidden = true }
    
    func setRate(rate : Int) {
        print("Rate = \(rate)")
        if (trakt.setMyRating(tvdbID : serie.idTVdb, rating: rate)) {
            boutonMyRating.setTitle(String(rate), for: .normal)
            boutonMyRating.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: CGFloat(rate))
            serie.myRating = rate
        }
    }
    
}
