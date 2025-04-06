//
//  Constantes.swift
//  SerieA
//
//  Created by Cyril Delamare on 24/02/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

let ZeroDate : Date = Date.init(timeIntervalSince1970: 0)
let AppDir : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let PosterDir : URL = AppDir.appendingPathComponent("poster")
let IMdbDir : URL = AppDir.appendingPathComponent("imdb")
let appConfig : AppConfig = AppConfig.init()

let dateFormShort   = DateFormatter()
let dateFormLong    = DateFormatter()
let dateFormSource  = DateFormatter()

// Structures globales
var trakt          : Trakt          = Trakt.init()
var theTVdb        : TheTVdb        = TheTVdb.init()
var betaSeries     : BetaSeries     = BetaSeries.init()
var theMoviedb     : TheMoviedb     = TheMoviedb.init()
var imdb           : IMdb           = IMdb.init()
var tvMaze         : TVmaze         = TVmaze.init()
var simkl          : SIMKL          = SIMKL.init()
var rottenTomatoes : RottenTomatoes = RottenTomatoes.init()
var metaCritic     : MetaCritic     = MetaCritic.init()
var alloCine       : AlloCine       = AlloCine.init()
var justWatch      : JustWatch      = JustWatch.init()
var sensCritique   : SensCritique   = SensCritique.init()
var yaqcs          : YaQuoiCommeSerie = YaQuoiCommeSerie()



var db      : Database  = Database.init()
var journal : Journal   = Journal.init()


// Code des source
let srcTrakt        : Int = 1
let srcTVdb         : Int = 2
let srcBetaSeries   : Int = 3
let srcMovieDB      : Int = 4
let srcIMdb         : Int = 5
let srcTVMaze       : Int = 6
let srcMetaCritic   : Int = 7
let srcRottenTom    : Int = 8
let srcAlloCine     : Int = 9
let srcJustWatch    : Int = 10
let srcSensCritique : Int = 11
let srcSIMKL        : Int = 12
let srcUneSerie     : Int = 13


// Méthodos de refresh des infos de la base
let funcBackgroundFetch : Int = 0
let funcQuickRefresh    : Int = 1
let funcFullRefresh     : Int = 2
let funcEpisodeVu       : Int = 3
let funcSerie           : Int = 4

// Types de news
let newsDates     : Int = 0
let newsVision    : Int = 1
let newsArrets    : Int = 2
let newsDiffusion : Int = 3
let newsListes    : Int = 4


// Limitations de chargement
let similarShowsPerSource : Int = 8
let popularShowsPerSource : Int = 25


// Couleurs de remplissage des sources
let colorTrakt          : UIColor = .systemRed
let colorTVdb           : UIColor = .systemGray
let colorBetaSeries     : UIColor = .systemBlue
let colorIMDB           : UIColor = .systemOrange
let colorMoviedb        : UIColor = .systemGreen
let colorTVmaze         : UIColor = .systemCyan
let colorRottenTomatoes : UIColor = .systemPurple
let colorMetaCritic     : UIColor = .systemIndigo
let colorAlloCine       : UIColor = .systemYellow
let colorSensCritique   : UIColor = .systemGray2
let colorSIMKL          : UIColor = .systemBrown

let colorAxis       : UIColor = UIColor.systemGray


// Categories pour les conseils
let categInconnues      : Int = 0
let categWatchlist      : Int = 1
let categAbandonnees    : Int = 2
let categSuivies        : Int = 3
let categFinies         : Int = 4


// Modes d'affichage de la view Série
let modeExplore     : Int = 0
let modeFinie       : Int = 1
let modeEnCours     : Int = 2
let modeAbandon     : Int = 3
let modeWatchlist   : Int = 4
let modeRecherche   : Int = 5


// Corrections statistiques pour les séries
var moyenneIMDB             : Int       = 80
var ecartTypeIMDB           : Double    = 6.476
var moyenneTrakt            : Int       = 78
var ecartTypeTrakt          : Double    = 6.096
var moyenneMovieDB          : Int       = 77
var ecartTypeMovieDB        : Double    = 6.026
var moyenneBetaSeries       : Int       = 83
var ecartTypeBetaSeries     : Double    = 7.059
var moyenneTVmaze           : Int       = 78
var ecartTypeTVmaze         : Double    = 5.716
var moyenneRottenTomatoes   : Int       = 82
var ecartTypeRottenTomatoes : Double    = 11.597
var moyenneMetaCritic       : Int       = 72
var ecartTypeMetaCritic     : Double    = 9.934
var moyenneAlloCine         : Int       = 79
var ecartTypeAlloCine       : Double    = 7.842
var moyenneSensCritique     : Int       = 70
var ecartTypeSensCritique   : Double    = 7.374
var moyenneSIMKL            : Int       = 77
var ecartTypeSIMKL          : Double    = 7.796


// Corrections statistiques pour les épisodes NEW ONES
var moyenneIMDBeps           : Int       = 84
var ecartTypeIMDBeps         : Double    = 9.155
var moyenneTrakteps          : Int       = 78
var ecartTypeTrakteps        : Double    = 3.162
var moyenneBetaSerieseps     : Int       = 85
var ecartTypeBetaSerieseps   : Double    = 3.602
var moyenneMoviedbeps        : Int       = 79
var ecartTypeMoviedbeps      : Double    = 6.816
var moyenneTVMazeeps         : Int       = 77
var ecartTypeTVMazeeps       : Double    = 7.074
var moyenneSensCritiqueeps   : Int       = 72
var ecartTypeSensCritiqueeps : Double    = 6.232


let notesMid    : Double = 64.0
let notesRange  : Double = 16.0


// Couleurs de l'interface
var mainUIcolor : UIColor = .systemGray
var UIcolor1 : UIColor = mainUIcolor.withAlphaComponent(0.3)
var UIcolor2 : UIColor = mainUIcolor.withAlphaComponent(0.1)

var SerieColor1 : UIColor = .systemGray.withAlphaComponent(0.3)
var SerieColor2 : UIColor = .systemGray.withAlphaComponent(0.1)
