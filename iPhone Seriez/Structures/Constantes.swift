//
//  Constantes.swift
//  SerieA
//
//  Created by Cyril Delamare on 24/02/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

// Correction des notes pour homogénéisation
let correctionTVdb          : Int = 77
let correctionBetaSeries    : Int = 86
let correctionTrakt         : Int = 79
let correctionMoviedb       : Int = 75
let correctionIMdb          : Int = 86

var moyenneIMDB : Int = 0
var ecartTypeIMDB : Double = 0.0
var moyenneTVdb : Int = 0
var ecartTypeTVdb : Double = 0.0
var moyenneTrakt : Int = 0
var ecartTypeTrakt : Double = 0.0
var moyenneMovieDB : Int = 0
var ecartTypeMovieDB : Double = 0.0
var moyenneBetaSeries : Int = 0
var ecartTypeBetaSeries : Double = 0.0

// Couleurs de remplissage des sources
let fillColorTrakt          : UIColor = UIColor.red
let fillColorTVdb           : UIColor = UIColor.black
let fillColorBetaSeries     : UIColor = UIColor.blue
let fillColorIMDB           : UIColor = UIColor.yellow
let fillColorRottenTomatoes : UIColor = UIColor.red
let fillColorMoviedb        : UIColor = UIColor.black

// Couleurs de détourage des sources
let borderColorTrakt          : UIColor = UIColor.white
let borderColorTVdb           : UIColor = UIColor.white
let borderColorBetaSeries     : UIColor = UIColor.white
let borderColorIMDB           : UIColor = UIColor.black
let borderColorRottenTomatoes : UIColor = UIColor.green
let borderColorMoviedb        : UIColor = UIColor.green

// Couleurs des sources
let colorTrakt          : UIColor = UIColor.red
let colorTVdb           : UIColor = UIColor.green
let colorBetaSeries     : UIColor = UIColor.blue
let colorIMDB           : UIColor = UIColor.yellow
let colorRottenTomatoes : UIColor = UIColor.purple
let colorMoviedb        : UIColor = UIColor.black


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
    "Ths CW" : 71,
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







