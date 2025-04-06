//
//  SerieFiche.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import ContactsUI

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
//    var allCritics : [Critique] = []
    var modeAffichage : Int = 0
    var parentalGuide : NSMutableDictionary = [:]

    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: Graph!
    @IBOutlet weak var spiderGraph: GraphMiniSerie!
    
    @IBOutlet weak var viewResume: UIView!
    @IBOutlet weak var viewInfos: UIView!
    @IBOutlet weak var viewGraphes: UIView!
    @IBOutlet weak var viewSaisonsUp: UIView!
    @IBOutlet weak var viewSaisons: UITableView!
    
    @IBOutlet weak var boutonMyRating: UIButton!
    
    @IBOutlet weak var boutonWatchlist: UIView!
    @IBOutlet weak var boutonDiffuseurs: UIView!
    @IBOutlet weak var boutonNoter: UIView!
    @IBOutlet weak var boutonAbandon: UIView!
    @IBOutlet weak var boutonCritiques: UIView!
    @IBOutlet weak var boutonCasting: UIView!
    @IBOutlet weak var boutonRatings: UIView!
    @IBOutlet weak var boutonSaisons: UIView!
    @IBOutlet weak var boutonAdvisor: UIView!
    
    @IBOutlet weak var sousBoutonWatchlist: UIButton!
    @IBOutlet weak var sousBoutonAbandon: UIButton!
    
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
    
    @IBOutlet weak var labelConseil: UILabel!
    @IBOutlet weak var imageConseil: UIImageView!
    
    @IBOutlet weak var parentSex: UILabel!
    @IBOutlet weak var parentViolence: UILabel!
    @IBOutlet weak var parentDrugs: UILabel!
    @IBOutlet weak var parentProfanity: UILabel!
    @IBOutlet weak var parentFrightened: UILabel!
    
    @IBOutlet weak var langueFR: UIButton!
    @IBOutlet weak var langueGB: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = serie.serie
        
        if (appConfig.modeCouleurSerie) {
            let mainSerieColor : UIColor = extractDominantColor(from: image) ?? .systemRed
            SerieColor1 = mainSerieColor.withAlphaComponent(0.3)
            SerieColor2 = mainSerieColor.withAlphaComponent(0.1)
        }

        makeGradiant(carre: boutonDiffuseurs, couleur: "Gris")
        makeGradiant(carre: boutonCritiques, couleur: "Gris")
        makeGradiant(carre: boutonCasting, couleur: "Gris")
        makeGradiant(carre: boutonWatchlist, couleur: "Vert")
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            makeGradiant(carre: boutonNoter, couleur: "Bleu")
            makeGradiant(carre: boutonAdvisor, couleur: "Bleu")
            makeGradiant(carre: boutonAbandon, couleur: "Rouge")

            arrondirLabel(texte: parentSex, radius: 7)
            arrondirLabel(texte: parentViolence, radius: 7)
            arrondirLabel(texte: parentDrugs, radius: 7)
            arrondirLabel(texte: parentProfanity, radius: 7)
            arrondirLabel(texte: parentFrightened, radius: 7)

            arrondir(fenetre: imageConseil, radius: 30.0)
            refreshAdvisor(name: serie.nomConseil)
            modeSpecifique(mode: modeAffichage)
            
            seriesBackgrounds(carre: viewInfos)
            seriesBackgrounds(carre: viewResume)
            seriesBackgrounds(carre: viewGraphes)
            seriesBackgrounds(carre: viewSaisonsUp)
        }
        else {
            seriesBackgrounds(carre: view)
            
            makeGradiant(carre: boutonRatings, couleur: "Gris")
            makeGradiant(carre: boutonSaisons, couleur: "Gris")
            spiderGraph.isHidden = true
            
            if (modeAffichage == modeRecherche) {
                boutonWatchlist.isHidden = false
            }
            else {
                boutonWatchlist.isHidden = true
            }
        }
        
        
        arrondirLabel(texte: labelInfos, radius: 10)
        arrondirLabel(texte: labelResume, radius: 10)
        arrondirLabel(texte: labelNotes, radius: 10)
        arrondirLabel(texte: labelSaisons, radius: 10)
        
        annee.text = String(serie.year)
        resume.text = serie.resumeFR
        banniere.image = image
        
        let noteGlobale : Double = Double(serie.getGlobalRating())/10.0
        note.text = "👍🏼 " + String(noteGlobale)
        note.layer.borderColor = UIColor.systemBlue.cgColor
        note.layer.borderWidth = 2
        note.layer.cornerRadius = 10
        note.layer.masksToBounds = true
        
        // Masquer les liens s'il n'y a pas de page derrière ...
        if (rottenTomatoes.getPath(serie: serie.serie) == "") { bRotTom.isHidden = true }
        if (serie.slugMetaCritic == "") { bMetaCritic.isHidden = true }
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
        if ( (serie.status == "Ended") || (serie.status == "ended") || (serie.status == "canceled") ){
            status.text = serie.status
            status.textColor = .red
        }
        else {
            status.text = serie.status
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
                              rateSensCritique: serie.getFairGlobalRatingSensCritique(),
                              rateSIMKL: serie.getFairGlobalRatingSIMKL() )
        spiderGraph.setType(type: 3)
        spiderGraph.setNeedsDisplay()
        
        let queue : OperationQueue = OperationQueue()
        
        let opRates = BlockOperation(block: {
            imdb.getEpisodesRatings(self.serie)
            OperationQueue.main.addOperation({
                self.graphe.sendSerie(self.serie)
                self.graphe.setNeedsDisplay()
            } )
            
            if (self.serie.idMoviedb != "") { theMoviedb.getEpisodesRatings(self.serie) }
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

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let opParental = BlockOperation(block: {
                self.parentalGuide = imdb.getParentalGuide(IMDBid: self.serie.idIMdb)
                OperationQueue.main.addOperation({
                    self.parentSex.backgroundColor = parentguideColor(severity: self.parentalGuide["#nudity"] as? String ?? "None")
                    self.parentViolence.backgroundColor = parentguideColor(severity: self.parentalGuide["#violence"] as? String ?? "None")
                    self.parentProfanity.backgroundColor = parentguideColor(severity: self.parentalGuide["#profanity"] as? String ?? "None")
                    self.parentDrugs.backgroundColor = parentguideColor(severity: self.parentalGuide["#alcohol"] as? String ?? "None")
                    self.parentFrightened.backgroundColor = parentguideColor(severity: self.parentalGuide["#frightening"] as? String ?? "None")
                } )
            } )
            queue.addOperation(opParental)
        }
        
        let opeFinalise = BlockOperation(block: {
            db.saveDB()
            
            OperationQueue.main.addOperation({
                self.viewSaisons.reloadData()
                self.viewSaisons.setNeedsLayout()
            } )
        } )
        opeFinalise.addDependency(opRates)
        queue.addOperation(opeFinalise)
    }
    
    
    func refreshAdvisor(name: String) {
        labelConseil.text = name
        
        switch name {
        case "Une Serie ?": imageConseil.image = #imageLiteral(resourceName: "2021_05_15_0u9_Kleki.png")
        case "Presse & média": imageConseil.image = UIImage(systemName: "newspaper")
        case "": imageConseil.image = UIImage(systemName: "person.circle")
        default: imageConseil.image = UIImage(systemName: "person.circle.fill")
        }
        
        let contact : CNContact = getContactFromID(contactID: name)
        
        if (contact.familyName != "") {
            if (contact.nickname == "")     { labelConseil.text = contact.givenName }
            else                            { labelConseil.text = contact.nickname }
                
            if (contact.thumbnailImageData == nil)   { imageConseil.image = UIImage(systemName: "book") }
            else                                     { imageConseil.image = UIImage(data: contact.thumbnailImageData!) }
        }
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
        else if (segue.identifier == "ShowDetailsSaisons") {
            let viewController = segue.destination as! SerieFicheDetails
            viewController.serie = serie
            viewController.detailType = viewController.detailTypeSaisons
        }
        else if (segue.identifier == "ShowDetailsNotes") {
            let viewController = segue.destination as! SerieFicheDetails
            viewController.serie = serie
            viewController.detailType = viewController.detailTypeNotes
        }
        else if (segue.identifier == "ShowDetailsAdvisor") {
            let viewController = segue.destination as! SerieFicheDetails
            viewController.serie = serie
            viewController.detailType = viewController.detailTypeAdvisor
        }
    }
    
    @IBAction func unwindToSerieFiche(sender: UIStoryboardSegue) {
        boutonMyRating.setTitle(String(serie.myRating), for: .normal)
        boutonMyRating.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: CGFloat(serie.myRating))
        
        refreshAdvisor(name: serie.nomConseil)
        
        db.saveDB()
        db.saveAdvisors()
    }

    
    @IBAction func webTrakt(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://trakt.tv/shows/\(serie.idTrakt)")!) }
    @IBAction func webTVMaze(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://www.tvmaze.com/shows/\(serie.idTVmaze)")!) }
    @IBAction func webMetaCritic(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://www.metacritic.com/tv/" + serie.slugMetaCritic)!) }
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
                    db.fillIndex()
                    boutonWatchlist.isHidden = true
                    
                    journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcSerie, texte: "Suppression de la watchlist", type: newsListes)

                    db.saveDB()
                }
            }
            else {
                if (trakt.addToWatchlist(theTVdbId: serie.idTVdb)) {
                    db.downloadGlobalInfo(serie: serie)
                    serie.watchlist = true
                    db.shows.append(serie)
                    db.fillIndex()
                    boutonWatchlist.isHidden = true

                    journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcSerie, texte: "Série ajoutée en watchlist", type: newsListes)

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

                    journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcSerie, texte: "Reprise de la série abandonnée", type: newsListes)

                    db.saveDB()
                }
            }
            else {
                if (trakt.addToAbandon(theTVdbId: serie.idTVdb)) {
                    db.downloadGlobalInfo(serie: serie)
                    serie.unfollowed = true
                    boutonAbandon.isHidden = true

                    journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcSerie, texte: "Abandon de la série", type: newsListes)

                    db.saveDB()
                }
            }
        }
    }
    
    @IBAction func setFrancais(_ sender: Any) {
        resume.text = serie.resumeFR
        langueFR.isSelected = true
        langueGB.isSelected = false
    }
    
    @IBAction func setAnglais(_ sender: Any) {
        resume.text = serie.resume
        langueFR.isSelected = false
        langueGB.isSelected = true
    }
}
