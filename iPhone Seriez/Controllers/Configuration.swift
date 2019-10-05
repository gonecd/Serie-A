//
//  Configuration.swift
//  SerieA
//
//  Created by Cyril Delamare on 17/06/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import SeriesCommon

class Configuration: UIViewController
{
    @IBOutlet weak var progresData: UIProgressView!
    @IBOutlet weak var boutonIMDB: UIButton!
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

    @IBOutlet weak var chronoTrakt: UILabel!
    @IBOutlet weak var chronoTVdb: UILabel!
    @IBOutlet weak var chronoBetaSeries: UILabel!
    @IBOutlet weak var chronoMovieDB: UILabel!
    @IBOutlet weak var chronoIMdb: UILabel!
    @IBOutlet weak var chronoRottenTom: UILabel!
    @IBOutlet weak var chronoTVmaze: UILabel!
    @IBOutlet weak var chronoMetaCritic: UILabel!
    @IBOutlet weak var chronoAlloCine: UILabel!
    
    @IBOutlet weak var viewReload: UIView!
    @IBOutlet weak var viewConnect: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progresData.isHidden = true
        loadingIMDB.isHidden = true
        boutonIMDB.layer.cornerRadius = 8.0
        boutonIMDB.layer.masksToBounds = true
        updateChronos()
        
        makeGradiant(carre: viewReload, couleur : "Gris")
        makeGradiant(carre: viewConnect, couleur : "Gris")
        
        makePrettyColorViews(view: colTrakt, couleur: colorTrakt)
        makePrettyColorViews(view: colTVdb, couleur: colorTVdb)
        makePrettyColorViews(view: colBetaSeries, couleur: colorBetaSeries)
        makePrettyColorViews(view: colMovieDB, couleur: colorMoviedb)
        makePrettyColorViews(view: colIMDB, couleur: colorIMDB)
        makePrettyColorViews(view: colRottenTom, couleur: colorRottenTomatoes)
        makePrettyColorViews(view: colTVmaze, couleur: colorTVmaze)
        makePrettyColorViews(view: colMetaCritic, couleur: colorMetaCritic)
        makePrettyColorViews(view: colAlloCine, couleur: colorAlloCine)
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
        
        // RAZ des compteurs
        timerTrakt = 0
        timerTheTVdb = 0
        timerBetaSeries = 0
        timerTheMovieDB = 0
        timerIMdb = 0
        timerRottenTom = 0
        timerTVmaze = 0
        timerMetaCritic = 0

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
            var timeStamp : Date = Date()
            imdb.downloadData()
            imdb.loadDataFile()
            timerIMdb = timerIMdb + Date().timeIntervalSince(timeStamp)
            
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
                
                timeStamp = Date()
                db.downloadDates(serie: uneSerie)
                timerTVmaze = timerTVmaze + Date().timeIntervalSince(timeStamp)
                
                if (uneSerie.saisons[uneSerie.saisons.count - 1].watched() == false) {
                    db.downloadDetailInfo(serie: uneSerie)
                }

//                if ( (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
//                    if (uneSerie.saisons[uneSerie.saisons.count - 1].watched() == false) {
//                        db.downloadDetailInfo(serie: uneSerie)
//                    }
//                }
            }
            
            DispatchQueue.main.async {
                self.updateChronos()

                db.finaliseDB()
                db.saveDB()
                
                self.progresData.isHidden = true
                self.encours.isHidden = true
            }
        }
    }
    
    
    func updateChronos() {
        chronoTrakt.text = String(format: "%0.3f sec", timerTrakt)
        chronoTVdb.text = String(format: "%0.3f sec", timerTheTVdb)
        chronoBetaSeries.text = String(format: "%0.3f sec", timerBetaSeries)
        chronoMovieDB.text = String(format: "%0.3f sec", timerTheMovieDB)
        chronoIMdb.text = String(format: "%0.3f sec", timerIMdb)
        chronoRottenTom.text = String(format: "%0.3f sec", timerRottenTom)
        chronoTVmaze.text = String(format: "%0.3f sec", timerTVmaze)
        chronoMetaCritic.text = String(format: "%0.3f sec", timerMetaCritic)
        chronoAlloCine.text = String(format: "%0.3f sec", timerAlloCine)
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
                db.saveDB()
            }
        }
    }
}

