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

// Code des source
let typeTrending : Int = 1
let typePopular  : Int = 2


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

let colorAxis       : UIColor = UIColor.systemGray2


// Categories pour les conseils
let categInconnues      : Int = 0
let categWatchlist      : Int = 1
let categAbandonnees    : Int = 2
let categSuivies        : Int = 3
let categFinies         : Int = 4

// Genres on MovieDB
let genresMovieDB: NSDictionary = [
    "Action" : 28,
    "Adventure" : 12,
    "Animation" : 16,
    "Comedy" : 35,
    "Crime" : 80,
    "Documentary" : 99,
    "Drama" : 18,
    "Family" : 10751,
    "Fantasy" : 14,
    "History" : 36,
    "Horror" : 27,
    "Music" : 10402,
    "Mystery" : 9648,
    "Romance" : 10749,
    "Science Fiction" : 878,
    "TV Movie" : 10770,
    "Thriller" : 53,
    "War" : 10752,
    "Western" : 37
]

let genreDocumentaire   : Int = 99
let genreAnimation      : Int = 16

// Années on MovieDB
let anneesMovieDB: NSDictionary = [
    "N/A" : 0,
    "2010" : 2010,
    "2011" : 2011,
    "2012" : 2012,
    "2013" : 2013,
    "2014" : 2014,
    "2015" : 2015,
    "2016" : 2016,
    "2017" : 2017,
    "2018" : 2018
]

// Networks on MovieDB
let networksMovieDB: NSDictionary = [
    "ABC" : 18,
    "CBS" : 16,
    "FOX" : 19,
    "FX" : 88,
    "HBO" : 49,
    "NBC" : 6,
    "Netflix" : 213,
    "Showtime" : 67,
    "Starz" : 318,
    "The CW" : 71,
    "TF1" : 290,
    "France 2" : 361,
    "France 3" : 249,
    "Canal+" : 285,
    "Arte" : 662,
    "M6" : 712,
    "Channel 4" : 21,
    "BBC One" : 4,
    "BBC Two" : 332,
    "BBC Three" : 3,
    "BBC Four" : 100
]

// Networks on MovieDB
let languesMovieDB: NSDictionary = [
    "French" : "fr",
    "English" : "en",
    "Danish" : "da",
    "German" : "de",
    "Italian" : "it",
    "Japanese" : "ja",
    "Dutch" : "nl",
    "Norwegian" : "no",
    "Russian" : "ru",
    "Spanish" : "es",
    "Swedish" : "sv"
]

// Modes d'affichage de la view Série
let modeFinie       : Int = 1
let modeEnCours     : Int = 2
let modeAbandon     : Int = 3
let modeWatchlist   : Int = 4
let modeRecherche   : Int = 5

