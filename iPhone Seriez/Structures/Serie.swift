//
//  Serie.swift
//  Seriez
//
//  Created by Cyril Delamare on 02/01/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation



public class Serie : NSObject, NSCoding {
    // Source Trakt
    public var serie : String
    public var saisons : [Saison] = [Saison]()
    
    public var idIMdb         : String = String()
    public var idTrakt        : String = String()
    public var idTVdb         : String = String()
    public var idSIMKL        : String = String()
    public var idMoviedb      : String = String()
    public var idTVmaze       : String = String()
    public var idAlloCine     : String = String()
    public var idBetaSeries   : String = String()
    public var idSensCritique : String = String()
    public var slugMetaCritic : String = String()

    
    public var unfollowed : Bool = false
    public var watchlist : Bool = false
    
    // Source TheTVdb
    public var network : String = String()
    public var networkLogo : String = String()
    public var diffuseur : String = String()
    public var banner : String = String()
    public var poster : String = String()
    public var status : String = String()
    public var resume : String = String()
    public var resumeFR : String = String()
    public var genres : [String] = []
    public var year : Int = 0
    
    // General infos
    public var ratingIMDB : Int = 0
    public var ratersIMDB : Int = 0
    public var ratingTrakt : Int = 0
    public var ratersTrakt: Int = 0
    public var ratingBetaSeries : Int = 0
    public var ratersBetaSeries : Int = 0
    public var ratingMovieDB : Int = 0
    public var ratersMovieDB : Int = 0
    public var ratingSIMKL : Int = 0
    public var ratersSIMKL : Int = 0
    public var ratingTVmaze : Int = 0
    public var ratingRottenTomatoes : Int = 0
    public var ratingMetaCritic : Int = 0
    public var ratingAlloCine : Int = 0
    public var ratingSensCritique : Int = 0

    public var myRating : Int = 0

    public var country : String = ""
    public var language : String = ""
    public var runtime : Int = 0
    public var homepage : String = ""
    public var nbSaisons : Int = 0
    public var nbEpisodes : Int = 0
    public var certification : String = ""
    
    public var nomConseil : String = ""

    public init(serie:String) {
        self.serie = serie
    }
    
    
    func partialCopy() -> Serie {
        let copie = Serie(serie: serie)
        copie.status = status
        for uneSaison in saisons {
            copie.saisons.append(uneSaison.partialCopy())
        }
        
        return copie
    }
    
    
    func findUpdates(versus: Serie) -> [String] {
        var results : [String] = []

        for uneSaison in saisons {
            if (versus.saisons.count >= uneSaison.saison) {
                results.append(contentsOf: uneSaison.findUpdates(versus: versus.saisons[uneSaison.saison - 1]))
            }
            else {
                if (uneSaison.starts == ZeroDate) {
                    results.append("Saison \(uneSaison.saison) annoncée")
                } else {
                    results.append("Saison \(uneSaison.saison) annoncée entre le \(dateFormShort.string(from: uneSaison.starts)) et le \(dateFormShort.string(from: uneSaison.ends))")
                }
            }
        }
        
        return results
    }
    
    public func slug() -> String {
        return self.serie.lowercased().replacingOccurrences(of: "%", with: "-")
                                        .replacingOccurrences(of: "'", with: "-")
                                        .replacingOccurrences(of: " ", with: "-")
                                        .replacingOccurrences(of: "*", with: "-")
                                        .replacingOccurrences(of: "(", with: "-")
                                        .replacingOccurrences(of: ")", with: "-")
                                        .replacingOccurrences(of: "!", with: "-")
                                        .replacingOccurrences(of: ":", with: "-")
                                        .replacingOccurrences(of: ".", with: "-")
                                        .replacingOccurrences(of: "--", with: "-")
                                        .replacingOccurrences(of: "--", with: "-")
                                        .replacingOccurrences(of: "--", with: "-")
                                        .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
    
    public required init(coder decoder: NSCoder) {
        self.serie = decoder.decodeObject(forKey: "serie") as? String ?? ""
        self.saisons = decoder.decodeObject(forKey: "saisons") as? [Saison] ?? []
        self.idIMdb = decoder.decodeObject(forKey: "idIMdb") as? String ?? ""
        self.idTrakt = decoder.decodeObject(forKey: "idTrakt") as? String ?? ""
        self.idTVdb = decoder.decodeObject(forKey: "idTVdb") as? String ?? ""
        self.idSIMKL = decoder.decodeObject(forKey: "idSIMKL") as? String ?? ""
        self.idMoviedb = decoder.decodeObject(forKey: "idMoviedb") as? String ?? ""
        self.idTVmaze = decoder.decodeObject(forKey: "idTVmaze") as? String ?? ""
        self.idAlloCine = decoder.decodeObject(forKey: "idAlloCine") as? String ?? ""
        self.idBetaSeries = decoder.decodeObject(forKey: "idBetaSeries") as? String ?? ""
        self.idSensCritique = decoder.decodeObject(forKey: "idSensCritique") as? String ?? ""
        self.slugMetaCritic = decoder.decodeObject(forKey: "slugMetaCritic") as? String ?? ""

        self.unfollowed = decoder.decodeBool(forKey: "unfollowed")
        self.watchlist = decoder.decodeBool(forKey: "watchlist")
        
        self.network = decoder.decodeObject(forKey: "network") as? String ?? ""
        self.networkLogo = decoder.decodeObject(forKey: "networkLogo") as? String ?? ""
        self.diffuseur = decoder.decodeObject(forKey: "diffuseur") as? String ?? ""
        self.banner = decoder.decodeObject(forKey: "banner") as? String ?? ""
        self.poster = decoder.decodeObject(forKey: "poster") as? String ?? ""
        self.status = decoder.decodeObject(forKey: "status") as? String ?? ""
        self.resume = decoder.decodeObject(forKey: "resume") as? String ?? ""
        self.resumeFR = decoder.decodeObject(forKey: "resumeFR") as? String ?? ""
        self.genres = decoder.decodeObject(forKey: "genres") as? [String] ?? []
        
        self.year = decoder.decodeInteger(forKey: "year")
        
        self.ratingIMDB = decoder.decodeInteger(forKey: "ratingIMDB")
        self.ratersIMDB = decoder.decodeInteger(forKey: "ratersIMDB")
        self.ratingTrakt = decoder.decodeInteger(forKey: "ratingTrakt")
        self.ratersTrakt = decoder.decodeInteger(forKey: "ratersTrakt")
        self.ratingBetaSeries = decoder.decodeInteger(forKey: "ratingBetaSeries")
        self.ratersBetaSeries = decoder.decodeInteger(forKey: "ratersBetaSeries")
        self.ratingMovieDB = decoder.decodeInteger(forKey: "ratingMovieDB")
        self.ratersMovieDB = decoder.decodeInteger(forKey: "ratersMovieDB")
        self.ratingSIMKL = decoder.decodeInteger(forKey: "ratingSIMKL")
        self.ratersSIMKL = decoder.decodeInteger(forKey: "ratersSIMKL")
        self.ratingTVmaze = decoder.decodeInteger(forKey: "ratingTVmaze")
        self.ratingRottenTomatoes = decoder.decodeInteger(forKey: "ratingRottenTomatoes")
        self.ratingMetaCritic = decoder.decodeInteger(forKey: "ratingMetaCritic")
        self.ratingAlloCine = decoder.decodeInteger(forKey: "ratingAlloCine")
        self.ratingSensCritique = decoder.decodeInteger(forKey: "ratingSensCritique")

        self.myRating = decoder.decodeInteger(forKey: "myRating")

        self.country = decoder.decodeObject(forKey: "country") as? String ?? ""
        self.language = decoder.decodeObject(forKey: "language") as? String ?? ""
        self.runtime = decoder.decodeInteger(forKey: "runtime")
        self.homepage = decoder.decodeObject(forKey: "homepage") as? String ?? ""
        self.nbSaisons = decoder.decodeInteger(forKey: "nbSaisons")
        self.nbEpisodes = decoder.decodeInteger(forKey: "nbEpisodes")
        self.certification = decoder.decodeObject(forKey: "certification") as? String ?? ""

        self.nomConseil = decoder.decodeObject(forKey: "nomConseil") as? String ?? ""
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.serie, forKey: "serie")
        coder.encode(self.saisons, forKey: "saisons")
        coder.encode(self.idIMdb, forKey: "idIMdb")
        coder.encode(self.idTrakt, forKey: "idTrakt")
        coder.encode(self.idTVdb, forKey: "idTVdb")
        coder.encode(self.idSIMKL, forKey: "idSIMKL")
        coder.encode(self.idMoviedb, forKey: "idMoviedb")
        coder.encode(self.idTVmaze, forKey: "idTVmaze")
        coder.encode(self.idAlloCine, forKey: "idAlloCine")
        coder.encode(self.idBetaSeries, forKey: "idBetaSeries")
        coder.encode(self.idSensCritique, forKey: "idSensCritique")
        coder.encode(self.slugMetaCritic, forKey: "slugMetaCritic")

        coder.encode(self.unfollowed, forKey: "unfollowed")
        coder.encode(self.watchlist, forKey: "watchlist")
        
        coder.encode(self.network, forKey: "network")
        coder.encode(self.networkLogo, forKey: "networkLogo")
        coder.encode(self.diffuseur, forKey: "diffuseur")
        coder.encode(self.banner, forKey: "banner")
        coder.encode(self.poster, forKey: "poster")
        coder.encode(self.status, forKey: "status")
        coder.encode(self.resume, forKey: "resume")
        coder.encode(self.resumeFR, forKey: "resumeFR")
        coder.encode(self.genres, forKey: "genres")
        
        coder.encodeCInt(Int32(self.year), forKey: "year")
        
        coder.encodeCInt(Int32(self.ratingIMDB), forKey: "ratingIMDB")
        coder.encodeCInt(Int32(self.ratersIMDB), forKey: "ratersIMDB")
        coder.encodeCInt(Int32(self.ratingTrakt), forKey: "ratingTrakt")
        coder.encodeCInt(Int32(self.ratersTrakt), forKey: "ratersTrakt")
        coder.encodeCInt(Int32(self.ratingBetaSeries), forKey: "ratingBetaSeries")
        coder.encodeCInt(Int32(self.ratersBetaSeries), forKey: "ratersBetaSeries")
        coder.encodeCInt(Int32(self.ratingMovieDB), forKey: "ratingMovieDB")
        coder.encodeCInt(Int32(self.ratersMovieDB), forKey: "ratersMovieDB")
        coder.encodeCInt(Int32(self.ratingSIMKL), forKey: "ratingSIMKL")
        coder.encodeCInt(Int32(self.ratersSIMKL), forKey: "ratersSIMKL")
        coder.encodeCInt(Int32(self.ratingTVmaze), forKey: "ratingTVmaze")
        coder.encodeCInt(Int32(self.ratingRottenTomatoes), forKey: "ratingRottenTomatoes")
        coder.encodeCInt(Int32(self.ratingMetaCritic), forKey: "ratingMetaCritic")
        coder.encodeCInt(Int32(self.ratingAlloCine), forKey: "ratingAlloCine")
        coder.encodeCInt(Int32(self.ratingSensCritique), forKey: "ratingSensCritique")

        coder.encodeCInt(Int32(self.myRating), forKey: "myRating")

        coder.encode(self.country, forKey: "country")
        coder.encode(self.language, forKey: "language")
        coder.encodeCInt(Int32(self.runtime), forKey: "runtime")
        coder.encode(self.homepage, forKey: "homepage")
        coder.encodeCInt(Int32(self.nbSaisons), forKey: "nbSaisons")
        coder.encodeCInt(Int32(self.nbEpisodes), forKey: "nbEpisodes")
        coder.encode(self.certification, forKey: "certification")

        coder.encode(self.nomConseil, forKey: "nomConseil")
    }
    
    public func merge(_ uneSerie : Serie) {
        if (uneSerie.network != "")         { self.network = uneSerie.network }
        if (uneSerie.networkLogo != "")     { self.networkLogo = uneSerie.networkLogo }
        if (uneSerie.diffuseur != "")       { self.diffuseur = uneSerie.diffuseur }
        if (uneSerie.banner != "")          { self.banner = uneSerie.banner }
        if (uneSerie.poster != "")          { self.banner = uneSerie.poster }
        if (uneSerie.status != "")          { self.status = uneSerie.status }
        if (uneSerie.resume != "")          { self.resume = uneSerie.resume }
        if (uneSerie.resumeFR != "")        { self.resumeFR = uneSerie.resumeFR }
        if (uneSerie.genres != [])          { self.genres = uneSerie.genres }
        if (uneSerie.idIMdb != "")          { self.idIMdb = uneSerie.idIMdb }
        if (uneSerie.idTrakt != "")         { self.idTrakt = uneSerie.idTrakt }
        if (uneSerie.idTVdb != "")          { self.idTVdb = uneSerie.idTVdb }
        if (uneSerie.idSIMKL != "")         { self.idSIMKL = uneSerie.idSIMKL }
        if (uneSerie.idMoviedb != "")       { self.idMoviedb = uneSerie.idMoviedb }
        if (uneSerie.idTVmaze != "")        { self.idTVmaze = uneSerie.idTVmaze }
        if (uneSerie.idAlloCine != "")      { self.idAlloCine = uneSerie.idAlloCine }
        if (uneSerie.idBetaSeries != "")    { self.idBetaSeries = uneSerie.idBetaSeries }
        if (uneSerie.idSensCritique != "")  { self.idSensCritique = uneSerie.idSensCritique }
        if (uneSerie.slugMetaCritic != "")  { self.slugMetaCritic = uneSerie.slugMetaCritic }

        if (uneSerie.unfollowed != false)   { self.unfollowed = uneSerie.unfollowed }
        if (uneSerie.watchlist != false)    { self.watchlist = uneSerie.watchlist }
        
        if (uneSerie.year != 0)             { self.year = uneSerie.year }
        
        if (uneSerie.ratingIMDB != 0)       { self.ratingIMDB = uneSerie.ratingIMDB }
        if (uneSerie.ratersIMDB != 0)       { self.ratersIMDB = uneSerie.ratersIMDB }
        if (uneSerie.ratingTrakt != 0)      { self.ratingTrakt = uneSerie.ratingTrakt }
        if (uneSerie.ratersTrakt != 0)      { self.ratersTrakt = uneSerie.ratersTrakt }
        if (uneSerie.ratingBetaSeries != 0) { self.ratingBetaSeries = uneSerie.ratingBetaSeries }
        if (uneSerie.ratersBetaSeries != 0) { self.ratersBetaSeries = uneSerie.ratersBetaSeries }
        if (uneSerie.ratingMovieDB != 0)    { self.ratingMovieDB = uneSerie.ratingMovieDB }
        if (uneSerie.ratersMovieDB != 0)    { self.ratersMovieDB = uneSerie.ratersMovieDB }
        if (uneSerie.ratingSIMKL != 0)      { self.ratingSIMKL = uneSerie.ratingSIMKL }
        if (uneSerie.ratersSIMKL != 0)      { self.ratersSIMKL = uneSerie.ratersSIMKL }
        if (uneSerie.ratingTVmaze != 0)     { self.ratingTVmaze = uneSerie.ratingTVmaze }
        if (uneSerie.ratingRottenTomatoes != 0)      { self.ratingRottenTomatoes = uneSerie.ratingRottenTomatoes }
        if (uneSerie.ratingMetaCritic != 0) { self.ratingMetaCritic = uneSerie.ratingMetaCritic }
        if (uneSerie.ratingAlloCine != 0)   { self.ratingAlloCine = uneSerie.ratingAlloCine }
        if (uneSerie.ratingSensCritique != 0)        { self.ratingSensCritique = uneSerie.ratingSensCritique }

        if (uneSerie.myRating != 0)         { self.myRating = uneSerie.myRating }

        if (uneSerie.country != "")         { self.country = uneSerie.country }
        if (uneSerie.language != "")        { self.language = uneSerie.language }
        if (uneSerie.runtime != 0)          { self.runtime = uneSerie.runtime }
        if (uneSerie.homepage != "")        { self.homepage = uneSerie.homepage }
        if (uneSerie.nbSaisons != 0)        { self.nbSaisons = uneSerie.nbSaisons }
        if (uneSerie.nbEpisodes != 0)       { self.nbEpisodes = uneSerie.nbEpisodes }
        if (uneSerie.certification != "")   { self.certification = uneSerie.certification }

        if (uneSerie.nomConseil != "")      { self.nomConseil = uneSerie.nomConseil }

        for uneSaison in uneSerie.saisons {
            if (uneSaison.saison <= self.saisons.count) {
                self.saisons[uneSaison.saison - 1].merge(uneSaison)
            } else {
                self.saisons.append(uneSaison)
            }
        }
    }
    
    public func getGlobalRating() -> Int {
        var total : Int = 0
        var nb : Int = 0
        
        if (getFairGlobalRatingTrakt() != 0)            { nb = nb + 1; total = total + getFairGlobalRatingTrakt() }
        if (getFairGlobalRatingBetaSeries() != 0)       { nb = nb + 1; total = total + getFairGlobalRatingBetaSeries() }
        if (getFairGlobalRatingMoviedb() != 0)          { nb = nb + 1; total = total + getFairGlobalRatingMoviedb() }
        if (getFairGlobalRatingIMdb() != 0)             { nb = nb + 1; total = total + getFairGlobalRatingIMdb() }
        if (getFairGlobalRatingTVmaze() != 0)           { nb = nb + 1; total = total + getFairGlobalRatingTVmaze() }
        if (getFairGlobalRatingRottenTomatoes() != 0)   { nb = nb + 1; total = total + getFairGlobalRatingRottenTomatoes() }
        if (getFairGlobalRatingMetaCritic() != 0)       { nb = nb + 1; total = total + getFairGlobalRatingMetaCritic() }
        if (getFairGlobalRatingAlloCine() != 0)         { nb = nb + 1; total = total + getFairGlobalRatingAlloCine() }
        if (getFairGlobalRatingSensCritique() != 0)     { nb = nb + 1; total = total + getFairGlobalRatingSensCritique() }
        if (getFairGlobalRatingSIMKL() != 0)            { nb = nb + 1; total = total + getFairGlobalRatingSIMKL() }

        if (nb > 0) {
            return Int(Double(total) / Double(nb))
        } else {
            return 0
        }
    }
    
    public func cleverMerge(TVdb : Serie, Moviedb : Serie, Trakt : Serie, BetaSeries : Serie, IMDB : Serie, RottenTomatoes : Serie, TVmaze : Serie, MetaCritic : Serie, AlloCine: Serie, SensCritique: Serie, SIMKL: Serie) {
        self.serie = Trakt.serie
        self.country = Trakt.country
        self.year = Trakt.year
        self.homepage = Trakt.homepage
        self.language = Trakt.language
        self.runtime = Trakt.runtime
        self.network = Trakt.network
        self.certification = Trakt.certification
        self.resume = Trakt.resume
        self.genres = Trakt.genres
        self.status = Trakt.status
        
        if (Trakt.idIMdb != "") { self.idIMdb = Trakt.idIMdb }
        else if (Moviedb.idIMdb != "") { self.idIMdb = Moviedb.idIMdb }
        else if (BetaSeries.idIMdb != "") { self.idIMdb = BetaSeries.idIMdb }
        else if (TVmaze.idIMdb != "") { self.idIMdb = TVmaze.idIMdb }
        else if (SIMKL.idIMdb != "") { self.idIMdb = SIMKL.idIMdb }

        if (Trakt.idTVdb != "") { self.idTVdb = Trakt.idTVdb }
        else if (Moviedb.idTVdb != "") { self.idTVdb = Moviedb.idTVdb }
        else if (TVmaze.idTVdb != "") { self.idTVdb = TVmaze.idTVdb }
        else if (SIMKL.idTVdb != "") { self.idTVdb = SIMKL.idTVdb }
        
        if (Moviedb.idMoviedb != "") { self.idMoviedb = Moviedb.idMoviedb }
        else if (SIMKL.idMoviedb != "") { self.idMoviedb = SIMKL.idMoviedb }
        else { self.idMoviedb = Trakt.idMoviedb }

        if (Trakt.idTrakt != "") { self.idTrakt = Trakt.idTrakt }
        if (BetaSeries.idBetaSeries != "") { self.idBetaSeries = BetaSeries.idBetaSeries }
        if (SIMKL.idSIMKL != "") { self.idSIMKL = SIMKL.idSIMKL }
        if (TVmaze.idTVmaze != "") { self.idTVmaze = TVmaze.idTVmaze }
        if (SensCritique.idSensCritique != "") { self.idSensCritique = SensCritique.idSensCritique }
        if (AlloCine.idAlloCine != "") { self.idAlloCine = AlloCine.idAlloCine }
        if (MetaCritic.slugMetaCritic != "") { self.slugMetaCritic = MetaCritic.slugMetaCritic }

        self.ratingTrakt = Trakt.ratingTrakt
        self.ratingBetaSeries = BetaSeries.ratingBetaSeries
        self.ratingMovieDB = Moviedb.ratingMovieDB
        if (IMDB.ratingIMDB != 0) { self.ratingIMDB = IMDB.ratingIMDB } else { self.ratingIMDB = SIMKL.ratingIMDB }
        self.ratingTVmaze = TVmaze.ratingTVmaze
        self.ratingRottenTomatoes = RottenTomatoes.ratingRottenTomatoes
        self.ratingMetaCritic = MetaCritic.ratingMetaCritic
        self.ratingAlloCine = AlloCine.ratingAlloCine
        self.ratingSensCritique = SensCritique.ratingSensCritique
        self.ratingSIMKL = SIMKL.ratingSIMKL

        self.diffuseur = BetaSeries.diffuseur
        self.resumeFR = BetaSeries.resumeFR
        
        self.banner = TVdb.banner
        
        self.poster = Moviedb.poster
        self.networkLogo = Moviedb.networkLogo
        self.nbSaisons = Moviedb.nbSaisons
        self.nbEpisodes = Moviedb.nbEpisodes

        for uneSaison in Moviedb.saisons {
            if (self.saisons.count >= uneSaison.saison) {
                self.saisons[uneSaison.saison - 1].starts = uneSaison.starts
                self.saisons[uneSaison.saison - 1].nbEpisodes = uneSaison.nbEpisodes
            } else {
                self.saisons.append(uneSaison)
            }
        }
    }

    
    public func cleverMergeBackup(TVdb : Serie, Moviedb : Serie, Trakt : Serie, BetaSeries : Serie, IMDB : Serie, RottenTomatoes : Serie, TVmaze : Serie, MetaCritic : Serie, AlloCine: Serie, SensCritique: Serie, SIMKL: Serie) {
        if (Trakt.serie != "") { self.serie = Trakt.serie }
        else if (Moviedb.serie != "") { self.serie = Moviedb.serie }
        else if (BetaSeries.serie != "") { self.serie = BetaSeries.serie }
        else if (SIMKL.serie != "") { self.serie = SIMKL.serie }
        else { self.serie = TVdb.serie }
        
        if (Trakt.idIMdb != "") { self.idIMdb = Trakt.idIMdb }
        else if (Moviedb.idIMdb != "") { self.idIMdb = Moviedb.idIMdb }
        else if (BetaSeries.idIMdb != "") { self.idIMdb = BetaSeries.idIMdb }
        else if (TVmaze.idIMdb != "") { self.idIMdb = TVmaze.idIMdb }
        else if (SIMKL.idIMdb != "") { self.idIMdb = SIMKL.idIMdb }
        else { self.idIMdb = TVdb.idIMdb }

        if (Trakt.idTVdb != "") { self.idTVdb = Trakt.idTVdb }
        else if (TVdb.idTVdb != "") { self.idTVdb = TVdb.idTVdb }
        else if (Moviedb.idTVdb != "") { self.idTVdb = Moviedb.idTVdb }
        else if (TVmaze.idTVdb != "") { self.idTVdb = TVmaze.idTVdb }
        else if (SIMKL.idTVdb != "") { self.idTVdb = SIMKL.idTVdb }
        else { self.idTVdb = BetaSeries.idTVdb }
        
        if (Moviedb.idMoviedb != "") { self.idMoviedb = Moviedb.idMoviedb }
        else if (SIMKL.idMoviedb != "") { self.idMoviedb = SIMKL.idMoviedb }
        else { self.idMoviedb = Trakt.idMoviedb }

        if (Trakt.idTrakt != "") { self.idTrakt = Trakt.idTrakt }
        if (BetaSeries.idBetaSeries != "") { self.idBetaSeries = BetaSeries.idBetaSeries }
        if (SIMKL.idSIMKL != "") { self.idSIMKL = SIMKL.idSIMKL }
        if (TVmaze.idTVmaze != "") { self.idTVmaze = TVmaze.idTVmaze }
        if (SensCritique.idSensCritique != "") { self.idSensCritique = SensCritique.idSensCritique }
        if (AlloCine.idAlloCine != "") { self.idAlloCine = AlloCine.idAlloCine }
        if (MetaCritic.slugMetaCritic != "") { self.slugMetaCritic = MetaCritic.slugMetaCritic }

        self.ratingTrakt = Trakt.ratingTrakt
        self.ratingBetaSeries = BetaSeries.ratingBetaSeries
        self.ratingMovieDB = Moviedb.ratingMovieDB
        if (IMDB.ratingIMDB != 0) { self.ratingIMDB = IMDB.ratingIMDB } else { self.ratingIMDB = SIMKL.ratingIMDB }
        self.ratingTVmaze = TVmaze.ratingTVmaze
        self.ratingRottenTomatoes = RottenTomatoes.ratingRottenTomatoes
        self.ratingMetaCritic = MetaCritic.ratingMetaCritic
        self.ratingAlloCine = AlloCine.ratingAlloCine
        self.ratingSensCritique = SensCritique.ratingSensCritique
        self.ratingSIMKL = SIMKL.ratingSIMKL

        if (Trakt.country != "") { self.country = Trakt.country }
        else if (SIMKL.country != "") { self.country = SIMKL.country }
        else { self.country = Moviedb.country }
        
        if (TVdb.banner != "") { self.banner = TVdb.banner }
        else { self.banner = BetaSeries.banner }
        
        if (Moviedb.poster != "") { self.poster = Moviedb.poster }
        else if (SIMKL.poster != "") { self.poster = SIMKL.poster }
        else { self.poster = BetaSeries.poster }
        
        if (Trakt.year != 0) { self.year = Trakt.year }
        else if (BetaSeries.year != 0) { self.year = BetaSeries.year }
        else if (Moviedb.year != 0) { self.year = Moviedb.year }
        else if (SIMKL.year != 0) { self.year = SIMKL.year }
        else if (TVmaze.year != 0) { self.year = TVmaze.year }
        else if (MetaCritic.year != 0) { self.year = MetaCritic.year }

        if (Trakt.homepage != "") { self.homepage = Trakt.homepage }
        else if (SIMKL.homepage != "") { self.homepage = SIMKL.homepage }
        else { self.homepage = Moviedb.homepage }
        
        if (Trakt.language != "") { self.language = Trakt.language }
        else if (BetaSeries.language != "") { self.language = BetaSeries.language }
        else { self.language = Moviedb.language }
        
        if (BetaSeries.nbSaisons != 0) { self.nbSaisons = BetaSeries.nbSaisons }
        if (MetaCritic.nbSaisons != 0) { self.nbSaisons = MetaCritic.nbSaisons }
        else { self.nbSaisons = Moviedb.nbSaisons }

        if (Trakt.nbEpisodes != 0) { self.nbEpisodes = Trakt.nbEpisodes }
        else if (Moviedb.nbEpisodes != 0) { self.nbEpisodes = Moviedb.nbEpisodes }
        else if (SIMKL.nbEpisodes != 0) { self.nbEpisodes = SIMKL.nbEpisodes }
        else { self.nbEpisodes = BetaSeries.nbEpisodes }
        
        if (Trakt.runtime != 0) { self.runtime = Trakt.runtime }
        else if (TVdb.runtime != 0) { self.runtime = TVdb.runtime }
        else if (BetaSeries.runtime != 0) { self.runtime = BetaSeries.runtime }
        else if (SIMKL.runtime != 0) { self.runtime = SIMKL.runtime }
        else if (MetaCritic.runtime != 0) { self.runtime = MetaCritic.runtime }
        else { self.runtime = Moviedb.runtime }
        
        if (Moviedb.networkLogo != "") { self.networkLogo = Moviedb.networkLogo }
        if (BetaSeries.diffuseur != "") { self.diffuseur = BetaSeries.diffuseur }

        if (Moviedb.network != "") { self.network = Moviedb.network }
        else if (BetaSeries.network != "") { self.network = BetaSeries.network }
        else if (Trakt.network != "") { self.network = Trakt.network }
        else if (SIMKL.network != "") { self.network = SIMKL.network }
        else { self.network = TVdb.network }
        
        if (Trakt.certification != "") { self.certification = Trakt.certification }
        else if (BetaSeries.certification != "") { self.certification = BetaSeries.certification }
        else if (SIMKL.certification != "") { self.certification = SIMKL.certification }
        else if (MetaCritic.certification != "") { self.certification = MetaCritic.certification }
        else { self.certification = TVdb.certification }
        
        if (Trakt.resume != "") { self.resume = Trakt.resume }
        else if (Moviedb.resume != "") { self.resume = Moviedb.resume }
        else if (SIMKL.resume != "") { self.resume = SIMKL.resume }
        else if (MetaCritic.resume != "") { self.resume = MetaCritic.resume }
        else { self.resume = TVdb.resume }

        if (BetaSeries.resumeFR != "") { self.resumeFR = BetaSeries.resumeFR }
        else if (SensCritique.resumeFR != "") { self.resumeFR = SensCritique.resumeFR }

        if (Moviedb.genres != []) { self.genres = Moviedb.genres }
        else if (TVdb.genres != []) { self.genres = TVdb.genres }
        else if (BetaSeries.genres != []) { self.genres = BetaSeries.genres }
        else if (SIMKL.genres != []) { self.genres = SIMKL.genres }
        else { self.genres = Trakt.genres }
        
        if (Trakt.status != "") { self.status = Trakt.status }
        else if (BetaSeries.status != "") { self.status = BetaSeries.status }
        else if (Moviedb.status != "") { self.status = Moviedb.status }
        else if (SIMKL.status != "") { self.status = SIMKL.status }
        else { self.status = TVdb.status }
        
        for uneSaison in Moviedb.saisons {
            if (self.saisons.count >= uneSaison.saison) {
                self.saisons[uneSaison.saison - 1].starts = uneSaison.starts
                self.saisons[uneSaison.saison - 1].nbEpisodes = uneSaison.nbEpisodes
            } else {
                self.saisons.append(uneSaison)
            }
        }
    }
    
    public func getFairGlobalRatingTrakt() -> Int {
        let val : Int = Int( notesMid + (notesRange * Double(ratingTrakt - moyenneTrakt) / ecartTypeTrakt))
        
        if (ratingTrakt == 0) { return 0 }
        
        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingMoviedb() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingMovieDB - moyenneMovieDB) / ecartTypeMovieDB))
        
        if (ratingMovieDB == 0) { return 0 }

        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingBetaSeries() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingBetaSeries - moyenneBetaSeries) / ecartTypeBetaSeries))
        
        if (ratingBetaSeries == 0) { return 0 }

        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingIMdb() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingIMDB - moyenneIMDB) / ecartTypeIMDB))
        
        if (ratingIMDB == 0) { return 0 }

        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingTVmaze() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingTVmaze - moyenneTVmaze) / ecartTypeTVmaze))
        
        if (ratingTVmaze == 0) { return 0 }

        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingRottenTomatoes() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingRottenTomatoes - moyenneRottenTomatoes) / ecartTypeRottenTomatoes))
        
        if (ratingRottenTomatoes == 0) { return 0 }

        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingMetaCritic() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingMetaCritic - moyenneMetaCritic) / ecartTypeMetaCritic))
        
        if (ratingMetaCritic == 0) { return 0 }

        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingAlloCine() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingAlloCine - moyenneAlloCine) / ecartTypeAlloCine))
        
        if (ratingAlloCine == 0) { return 0 }

        if (val < 0) { return 0}
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingSensCritique() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingSensCritique - moyenneSensCritique) / ecartTypeSensCritique))
        
        if (ratingSensCritique == 0) { return 0 }

        if (val < 0) { return 0 }
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func getFairGlobalRatingSIMKL() -> Int {
        let val : Int =  Int( notesMid + (notesRange * Double(ratingSIMKL - moyenneSIMKL) / ecartTypeSIMKL))
        
        if (ratingSIMKL == 0) { return 0 }

        if (val < 0) { return 0 }
        else if (val > 100) { return 100 }
        else { return val }
    }
    
    public func watching() -> Bool {
        if (watchlist || unfollowed) { return false }
        
        for uneSaison in saisons {
            if ((uneSaison.nbWatchedEps > 0) && (uneSaison.nbWatchedEps < uneSaison.nbEpisodes)) {
                return true
            }
        }
        
        return false
    }
    
    
    public func enCours() -> Bool {
        if (watchlist || unfollowed) { return false }
        
        if (saisons.count > 0) {
            if ( ((saisons[saisons.count - 1].watched() == false) || ( (status != "ended") && (status != "Ended") && (status != "canceled") ) ) ) {
                return true
            }
        }
        
        return false
    }

}

