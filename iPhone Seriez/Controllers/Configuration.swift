//
//  Configuration.swift
//  SerieA
//
//  Created by Cyril Delamare on 17/06/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class Configuration: UIViewController
{
    @IBOutlet weak var progresData: UIProgressView!
    @IBOutlet weak var encours: UILabel!
    @IBOutlet weak var loadingIMDB: UIActivityIndicatorView!
    
    @IBOutlet weak var colTrakt: UIView!
    @IBOutlet weak var colTVdb: UIView!
    @IBOutlet weak var colBetaSeries: UIView!
    @IBOutlet weak var colMovieDB: UIView!
    @IBOutlet weak var colIMDB: UIView!
    @IBOutlet weak var colRottenTom: UIView!
    @IBOutlet weak var colTVmaze: UIView!
    @IBOutlet weak var colMetaCritic: UIView!
    @IBOutlet weak var colAlloCine: UIView!
    @IBOutlet weak var colSensCritique: UIView!
    @IBOutlet weak var colSIMKL: UIView!
    
    @IBOutlet weak var chronoTrakt: UILabel!
    @IBOutlet weak var chronoTVdb: UILabel!
    @IBOutlet weak var chronoBetaSeries: UILabel!
    @IBOutlet weak var chronoMovieDB: UILabel!
    @IBOutlet weak var chronoIMdb: UILabel!
    @IBOutlet weak var chronoRottenTom: UILabel!
    @IBOutlet weak var chronoTVmaze: UILabel!
    @IBOutlet weak var chronoMetaCritic: UILabel!
    @IBOutlet weak var chronoAlloCine: UILabel!
    @IBOutlet weak var chronoSensCritique: UILabel!
    @IBOutlet weak var chronoSIMKL: UILabel!
    
    @IBOutlet weak var viewReload: UIView!
    @IBOutlet weak var viewConnect: UIView!
    @IBOutlet weak var viewMyRates: UIView!
    @IBOutlet weak var viewIMDBids: UIView!
    @IBOutlet weak var viewIMDBratings: UIView!
    @IBOutlet weak var ViewFairRates: UIView!
    @IBOutlet weak var viewAdvisors: UIView!
    @IBOutlet weak var viewVideCache: UIView!

    @IBOutlet weak var viewData: UIView!
    @IBOutlet weak var viewSources: UIView!
    @IBOutlet weak var viewUpdates: UIView!
    @IBOutlet weak var viewThemes: UIView!
    @IBOutlet weak var viewDivers: UIView!
    
    @IBOutlet weak var updateTrakt: UILabel!
    @IBOutlet weak var updateIMDB: UILabel!
    @IBOutlet weak var updateTVMaze: UILabel!
    
    @IBOutlet weak var SerieColorSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progresData.isHidden = true
        loadingIMDB.isHidden = true
        updateChronos()
        
        title = "Configuration"
        

        makeGradiant(carre: viewReload, couleur : "Gris")
        makeGradiant(carre: viewConnect, couleur : "Gris")
        makeGradiant(carre: viewMyRates, couleur : "Gris")
        makeGradiant(carre: viewIMDBids, couleur : "Gris")
        makeGradiant(carre: viewIMDBratings, couleur : "Gris")
        makeGradiant(carre: ViewFairRates, couleur : "Gris")

        // iPad spécific
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            SerieColorSwitch.setOn(appConfig.modeCouleurSerie, animated: false)
            SerieColorSwitch.onTintColor = mainUIcolor

            makeGradiant(carre: viewData, couleur: "Blanc")
            makeGradiant(carre: viewSources, couleur: "Blanc")
            makeGradiant(carre: viewUpdates, couleur: "Blanc")
            makeGradiant(carre: viewThemes, couleur: "Blanc")
            makeGradiant(carre: viewDivers, couleur: "Blanc")
            makeGradiant(carre: viewAdvisors, couleur : "Gris")
            makeGradiant(carre: viewVideCache, couleur : "Gris")

            let dataUpdates : DataUpdatesEntry = db.loadDataUpdates()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM à HH:mm"

            updateTrakt.text = dateFormatter.string(from: dataUpdates.Trakt_Viewed)
            updateIMDB.text = dateFormatter.string(from: dataUpdates.IMDB_Rates)
            updateTVMaze.text = dateFormatter.string(from: dataUpdates.TVMaze_Dates)
        }
        
        makePrettyColorViews(view: colTrakt, couleur: colorTrakt)
        makePrettyColorViews(view: colTVdb, couleur: colorTVdb)
        makePrettyColorViews(view: colBetaSeries, couleur: colorBetaSeries)
        makePrettyColorViews(view: colMovieDB, couleur: colorMoviedb)
        makePrettyColorViews(view: colIMDB, couleur: colorIMDB)
        makePrettyColorViews(view: colRottenTom, couleur: colorRottenTomatoes)
        makePrettyColorViews(view: colTVmaze, couleur: colorTVmaze)
        makePrettyColorViews(view: colMetaCritic, couleur: colorMetaCritic)
        makePrettyColorViews(view: colAlloCine, couleur: colorAlloCine)
        makePrettyColorViews(view: colSensCritique, couleur: colorSensCritique)
        makePrettyColorViews(view: colSIMKL, couleur: colorSIMKL)
    }

    func makePrettyColorViews(view : UIView, couleur : UIColor) {
        view.layer.borderColor = couleur.cgColor
        view.layer.borderWidth = 2.0
        view.layer.backgroundColor = couleur.withAlphaComponent(0.5).cgColor
        view.layer.cornerRadius = 8;
    }
    
     
    @IBAction func loadAll(_ sender: Any) {
        progresData.setProgress(0.0, animated: false)
        progresData.isHidden = false
        encours.isHidden = false
        
        var oldDB : [Serie] = []
        var oldIndex : Dictionary = [String:Int]()
        var i : Int  = 0

        for oneShow in db.shows {
            oldDB.append(oneShow.partialCopy())
            oldIndex[oneShow.serie] = i
            i = i + 1
        }

        
        DispatchQueue.global(qos: .utility).async {
            
            DispatchQueue.main.async {
                self.encours.text = "Loading Watched list..."
                self.updateChronos()
            }
            db.shows = trakt.getWatched()
            
            DispatchQueue.main.async { self.encours.text = "Loading Stopped list ..." }
            db.shows = db.merge(db.shows, adds: trakt.getStopped())

            DispatchQueue.main.async { self.encours.text = "Loading Watchlist ..." }
            db.shows = db.merge(db.shows, adds: trakt.getWatchlist())

            DispatchQueue.main.async { self.encours.text = "Loading IMDB rates ..." }
            imdb.downloadData()
            imdb.loadDataFile()
            
            let nbShows : Float = Float(db.shows.count)
            var showNum : Int = 0
            
            for uneSerie in db.shows {
                showNum = showNum + 1
                DispatchQueue.main.async {
                    self.progresData.setProgress(Float(showNum)/nbShows, animated: true)
                    self.encours.text = "Loading " + uneSerie.serie
                    self.updateChronos()
                }
                
                db.downloadGlobalInfo(serie: uneSerie)
                
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    if ( (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
                        if (uneSerie.saisons[uneSerie.saisons.count - 1].watched() == false) {
                            db.downloadDetailInfo(serie: uneSerie)
                        }
                    }
                }
                
                let indexOldDB : Int = oldIndex[uneSerie.serie] ?? -1
                if (indexOldDB == -1) {
                    if (uneSerie.watchlist) { journal.addInfo(serie: uneSerie.serie, source: srcTrakt, methode: funcFullRefresh, texte: "Série ajoutée en watchlist", type: newsListes) }
                    else if (uneSerie.unfollowed) { journal.addInfo(serie: uneSerie.serie, source: srcTrakt, methode: funcFullRefresh, texte: "Abandon de la série", type: newsListes) }
                    else { journal.addInfo(serie: uneSerie.serie, source: srcTrakt, methode: funcFullRefresh, texte: "Visionnage d'un nouvelle série", type: newsListes) }
                } else {
                    db.checkForUpdates(newSerie: uneSerie, oldSerie: oldDB[indexOldDB], methode: funcFullRefresh)
                }

            }
            
            DispatchQueue.main.async {
                self.updateChronos()

                var dataUpdates : DataUpdatesEntry = db.loadDataUpdates()
                dataUpdates.UneSerieReload = Date()
                db.saveDataUpdates(dataUpdates: dataUpdates)

                db.finaliseDB()
                db.saveDB()
                
                self.progresData.isHidden = true
                self.encours.isHidden = true
            }
        }
        
    }
    
    @IBAction func connectToTrakt(_ sender: Any) {
        trakt.webAutenth()
    }
    
    
    func updateChronos() {
        chronoTrakt.text = String(format: "%0.3f sec", trakt.chrono)
        chronoTVdb.text = String(format: "%0.3f sec", theTVdb.chrono)
        chronoBetaSeries.text = String(format: "%0.3f sec", betaSeries.chrono)
        chronoMovieDB.text = String(format: "%0.3f sec", theMoviedb.chrono)
        chronoIMdb.text = String(format: "%0.3f sec", imdb.chrono)
        chronoRottenTom.text = String(format: "%0.3f sec", rottenTomatoes.chrono)
        chronoTVmaze.text = String(format: "%0.3f sec", tvMaze.chrono)
        chronoMetaCritic.text = String(format: "%0.3f sec", metaCritic.chrono)
        chronoAlloCine.text = String(format: "%0.3f sec", alloCine.chrono)
        chronoSensCritique.text = String(format: "%0.3f sec", sensCritique.chrono)
        chronoSIMKL.text = String(format: "%0.3f sec", simkl.chrono)
    }
    
    
    @IBAction func LoadIMDB(_ sender: Any) {
        loadingIMDB.isHidden = false
        loadingIMDB.startAnimating()
        
        DispatchQueue.global(qos: .utility).async {
            
            imdb.downloadData()
            imdb.loadDataFile()
            
            var tmpSerie : Serie
            
            for uneSerie in db.shows {
                tmpSerie = imdb.getSerieGlobalInfos(idIMDB: uneSerie.idIMdb)
                uneSerie.ratersIMDB = tmpSerie.ratersIMDB
                uneSerie.ratingIMDB = tmpSerie.ratingIMDB
            }
            
            DispatchQueue.main.async {
                self.loadingIMDB.stopAnimating()
                self.loadingIMDB.isHidden = true

                var dataUpdates : DataUpdatesEntry = db.loadDataUpdates()
                dataUpdates.IMDB_Rates = Date()
                db.saveDataUpdates(dataUpdates: dataUpdates)

                db.saveDB()
            }
        }
    }
    
    @IBAction func getMyRates(_ sender: Any) {
        let myRates : Dictionary = trakt.getMyRatings()
        
        for uneSerie in db.shows {
            uneSerie.myRating = myRates[uneSerie.serie] ?? -1
        }
        
        db.saveDB()
    }

    
    @IBAction func LoadIMDBids(_ sender: Any) {
        loadingIMDB.isHidden = false
        loadingIMDB.startAnimating()
        
        DispatchQueue.global(qos: .utility).async {
            
            imdb.downloadEpisodes()
                       
            DispatchQueue.main.async {
                self.loadingIMDB.stopAnimating()
                self.loadingIMDB.isHidden = true
                
                var dataUpdates : DataUpdatesEntry = db.loadDataUpdates()
                dataUpdates.IMDB_Episodes = Date()
                db.saveDataUpdates(dataUpdates: dataUpdates)

                db.saveDB()
            }
        }
    }
    
    @IBAction func ComputeFairRates(_ sender: Any) {
        db.computeFairRates()
    }

    @IBAction func themeGris(_ sender: Any)     { setColors(couleur: .systemGray) }
    @IBAction func themeBlanc(_ sender: Any)    { setColors(couleur: .systemBackground) }
    @IBAction func themeBleu(_ sender: Any)     { setColors(couleur: .systemBlue) }
    @IBAction func themeRouge(_ sender: Any)    { setColors(couleur: .systemRed) }
    @IBAction func themeOrange(_ sender: Any)   { setColors(couleur: .systemOrange) }
    @IBAction func themeVert(_ sender: Any)     { setColors(couleur: .systemGreen) }
    @IBAction func themeJaune(_ sender: Any)    { setColors(couleur: .systemYellow) }
    @IBAction func themeMenthe(_ sender: Any)   { setColors(couleur: .systemMint) }

    func setColors(couleur: UIColor){
        mainUIcolor = couleur
        UIcolor1 = mainUIcolor.withAlphaComponent(0.3)
        UIcolor2 = mainUIcolor.withAlphaComponent(0.1)
        SerieColor1 = mainUIcolor.withAlphaComponent(0.3)
        SerieColor2 = mainUIcolor.withAlphaComponent(0.1)

        switch couleur {
        case .systemGray        : appConfig.couleur = "Gris"
        case .systemBackground  : appConfig.couleur = "Blanc"
        case .systemRed         : appConfig.couleur = "Rouge"
        case .systemGreen       : appConfig.couleur = "Vert"
        case .systemBlue        : appConfig.couleur = "Bleu"
        case .systemOrange      : appConfig.couleur = "Orange"
        case .systemYellow      : appConfig.couleur = "Jaune"
        case .systemMint        : appConfig.couleur = "Menthe"
        default                 : appConfig.couleur = "Gris"
        }

        appConfig.save()

        //        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: couleur, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)]
      
        makeGradiant(carre: viewData, couleur: "Blanc")
        makeGradiant(carre: viewSources, couleur: "Blanc")
        makeGradiant(carre: viewUpdates, couleur: "Blanc")
        makeGradiant(carre: viewThemes, couleur: "Blanc")
        makeGradiant(carre: viewDivers, couleur: "Blanc")
    }
    
    @IBAction func switchUseSerieColor(_ sender: Any) {
        appConfig.modeCouleurSerie = SerieColorSwitch.isOn
        SerieColor1 = UIcolor1
        SerieColor2 = UIcolor2
        
        appConfig.save()
        
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: mainUIcolor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)]
    }
    
    @IBAction func AdvisorsReload(_ sender: Any) {
        db.loadAdvisors()
        db.saveDB()
    }
    
    @IBAction func ViderLeCacheImages(_ sender: Any) {
        emptyCache()
    }
    
}
