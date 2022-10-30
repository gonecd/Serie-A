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
var rottenTomatoes : RottenTomatoes = RottenTomatoes.init()
var metaCritic     : MetaCritic     = MetaCritic.init()
var alloCine       : AlloCine       = AlloCine.init()
var justWatch      : JustWatch      = JustWatch.init()
var sensCritique   : SensCritique   = SensCritique.init()
var yaqcs          : YaQuoiCommeSerie = YaQuoiCommeSerie()



var db : Database   = Database.init()

// Code des source
let srcTrakt      : Int = 1
let srcTVdb       : Int = 2
let srcBetaSeries : Int = 3
let srcMovieDB    : Int = 4
let srcIMdb       : Int = 5
let srcTVMaze     : Int = 6
let srcMetaCritic : Int = 7
let srcRottenTom  : Int = 8
let srcAlloCine   : Int = 9


// Limitations de chargement
let similarShowsPerSource : Int = 8
let popularShowsPerSource : Int = 20


// Couleurs de remplissage des sources
let colorTrakt          : UIColor = .systemRed
let colorTVdb           : UIColor = .systemGray
let colorBetaSeries     : UIColor = .systemBlue
let colorIMDB           : UIColor = .systemOrange
let colorMoviedb        : UIColor = .systemGreen
let colorTVmaze         : UIColor = .systemTeal
let colorRottenTomatoes : UIColor = .systemPurple
let colorMetaCritic     : UIColor = .systemIndigo
let colorAlloCine       : UIColor = .systemYellow
let colorSensCritique   : UIColor = .systemGray2

let colorAxis       : UIColor = UIColor.systemGray2


// Categories pour les conseils
let categInconnues      : Int = 0
let categWatchlist      : Int = 1
let categAbandonnees    : Int = 2
let categSuivies        : Int = 3
let categFinies         : Int = 4


// Modes d'affichage de la view Série
let modeFinie       : Int = 1
let modeEnCours     : Int = 2
let modeAbandon     : Int = 3
let modeWatchlist   : Int = 4
let modeRecherche   : Int = 5
let modeParRate     : Int = 6


// Corrections statistiques pour les séries
var moyenneIMDB             : Int       = 80
var ecartTypeIMDB           : Double    = 6.743
var moyenneTrakt            : Int       = 80
var ecartTypeTrakt          : Double    = 6.005
var moyenneMovieDB          : Int       = 77
var ecartTypeMovieDB        : Double    = 5.981
var moyenneBetaSeries       : Int       = 83
var ecartTypeBetaSeries     : Double    = 7.627
var moyenneTVmaze           : Int       = 79
var ecartTypeTVmaze         : Double    = 6.285
var moyenneRottenTomatoes   : Int       = 85
var ecartTypeRottenTomatoes : Double    = 12.284
var moyenneMetaCritic       : Int       = 74
var ecartTypeMetaCritic     : Double    = 8.127
var moyenneAlloCine         : Int       = 79
var ecartTypeAlloCine       : Double    = 8.516
var moyenneSensCritique     : Int       = 69
var ecartTypeSensCritique   : Double    = 8.370


// Corrections statistiques pour les épisodes NEW ONES
var moyenneIMDBeps         : Int       = 84
var ecartTypeIMDBeps       : Double    = 9.331
var moyenneTrakteps        : Int       = 78
var ecartTypeTrakteps      : Double    = 2.971
var moyenneBetaSerieseps   : Int       = 86
var ecartTypeBetaSerieseps : Double    = 3.723


let notesMid    : Double = 64.0
let notesRange  : Double = 16.0
