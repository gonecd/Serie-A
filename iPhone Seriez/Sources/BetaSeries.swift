//
//  BetaSeries.swift
//  Seriez
//
//  Created by Cyril Delamare on 08/05/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation


class Casting {
    var name        : String = ""
    var personnage  : String = ""
    var photo       : String = ""
}


class BetaSeries : NSObject {
    var chrono : TimeInterval = 0
    let dateFormBetaSeries   = DateFormatter()

    let BetaSeriesUserkey : String = "aa6120d2cf7e"
    
    override init() {
        super.init()
        dateFormBetaSeries.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()
        
        var request : URLRequest = URLRequest(url: URL(string: reqAPI)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(BetaSeriesUserkey)", forHTTPHeaderField: "X-BetaSeries-Key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("BetaSeries::error \(response.statusCode) received for req=\(reqAPI)"); ended = true; return }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("BetaSeries::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
            } else { print(error as Any); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result
    }
    
    
    func getEpisodesRatings(_ uneSerie: Serie) {
        let today : Date = Date()
        
        // Récupération des ratings
        for saison in uneSerie.saisons {
            // Création de la liste de tous les épisodes d'une saison
            var listeEpisodes: String = ""
            for episode in saison.episodes {
                if (episode.idTVdb != 0) {
                    if (listeEpisodes != "") { listeEpisodes = listeEpisodes+"," }
                    listeEpisodes = listeEpisodes+String(episode.idTVdb)
                }
            }
            
            if (listeEpisodes == "") {
                print("BetaSeries::getEpisodesRatings - No episode ID to load for \(uneSerie.serie) saison \(saison.saison)")
                continue
            }
            
            let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.betaseries.com/episodes/display?thetvdb_id=\(listeEpisodes)") as? NSDictionary ?? NSDictionary()
            
            if (reqResult.object(forKey: "episodes") != nil) {
                for unEpisode in reqResult.object(forKey: "episodes")! as! NSArray {
                    let numEpisode: Int = ((unEpisode as AnyObject).object(forKey: "episode")! as! Int)-1
                    
                    if (numEpisode < saison.episodes.count) {
                        if (saison.episodes[numEpisode].date.compare(today) == .orderedAscending) {
                            saison.episodes[numEpisode].ratingBetaSeries = Int(20 * (((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
                            saison.episodes[numEpisode].ratersBetaSeries = ((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "total") as? Int ?? 0
                            saison.episodes[numEpisode].idBetaSeries = (unEpisode as AnyObject).object(forKey: "id") as? Int ?? 0
                        }
                        
                    }
                }
            }
        }
    }
    
//    func getEpisodesRatingsBis(_ uneSerie: Serie) {
//        let today : Date = Date()
//        var listeEpisodes: String = ""
//
//        // Création de la liste de tous les épisodes
//        for saison in uneSerie.saisons {
//            for episode in saison.episodes {
//                if (episode.idTVdb != 0) {
//                    if (listeEpisodes != "") { listeEpisodes = listeEpisodes+"," }
//                    listeEpisodes = listeEpisodes+String(episode.idTVdb)
//                }
//            }
//        }
//
//        if (listeEpisodes == "") {
//            print("BetaSeries::getEpisodesRatingsBis - No episode ID to load for \(uneSerie.serie)")
//            return
//        }
//
//        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.betaseries.com/episodes/display?thetvdb_id=\(listeEpisodes)") as? NSDictionary ?? NSDictionary()
//
//        if (reqResult.object(forKey: "episodes") != nil) {
//            for unEpisode in reqResult.object(forKey: "episodes")! as! NSArray {
//                let numSaison: Int = ((unEpisode as AnyObject).object(forKey: "season")! as! Int)-1
//                let numEpisode: Int = ((unEpisode as AnyObject).object(forKey: "episode")! as! Int)-1
//
//                if (numSaison < uneSerie.saisons.count) {
//                    if (numEpisode < uneSerie.saisons[numSaison].episodes.count) {
//                        if (uneSerie.saisons[numSaison].episodes[numEpisode].date.compare(today) == .orderedAscending) {
//                            uneSerie.saisons[numSaison].episodes[numEpisode].ratingBetaSeries = Int(20 * (((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
//                            uneSerie.saisons[numSaison].episodes[numEpisode].ratersBetaSeries = ((unEpisode as AnyObject).object(forKey: "note")! as AnyObject).object(forKey: "total") as? Int ?? 0
//                        }
//
//                    }
//                }
//            }
//        }
//    }
    
    
    func getSerieGlobalInfos(idTVDB : String, idIMDB : String, idBetaSeries : String) -> Serie {
        let uneSerie : Serie = Serie(serie: "")
        var reqURL : String = ""
        
        if (idIMDB != "")            { reqURL = "https://api.betaseries.com/shows/display?v=3.0&imdb_id=\(idIMDB)" }
        else if (idTVDB != "")       { reqURL = "https://api.betaseries.com/shows/display?v=3.0&thetvdb_id=\(idTVDB)" }
        else if (idBetaSeries != "") { reqURL = "https://api.betaseries.com/shows/display?v=3.0&id=\(idBetaSeries)" }
        else                    { return uneSerie }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: reqURL) as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return uneSerie }
        
        let show = reqResult.object(forKey: "show") as! NSDictionary
        
        uneSerie.serie = show.object(forKey: "title") as? String ?? ""
        uneSerie.idIMdb = show.object(forKey: "imdb_id") as? String ?? ""
        uneSerie.idTVdb = String(show.object(forKey: "thetvdb_id") as? Int ?? 0)
        uneSerie.idBetaSeries = String(show.object(forKey: "id") as? Int ?? 0)
        uneSerie.resume = show.object(forKey: "description") as? String ?? ""
        uneSerie.network = show.object(forKey: "network") as? String ?? ""
        uneSerie.banner = (show.object(forKey: "images")! as AnyObject).object(forKey: "banner") as? String ?? ""
        uneSerie.poster = (show.object(forKey: "images")! as AnyObject).object(forKey: "poster") as? String ?? ""
        uneSerie.status = show.object(forKey: "status") as? String ?? ""
        uneSerie.genres = show.object(forKey: "genres") as? [String] ?? []
        uneSerie.year = Int(show.object(forKey: "creation") as? String ?? "0")!
        uneSerie.ratingBetaSeries = Int(20 * ((show.object(forKey: "notes")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
        uneSerie.ratersBetaSeries = (show.object(forKey: "notes")! as AnyObject).object(forKey: "total") as? Int ?? 0
        uneSerie.language = show.object(forKey: "language") as? String ?? ""
        uneSerie.runtime = Int(show.object(forKey: "length") as? String ?? "0")!
        uneSerie.nbEpisodes = Int(show.object(forKey: "episodes") as? String ?? "0")!
        uneSerie.nbSaisons = Int(show.object(forKey: "seasons") as? String ?? "0")!
        uneSerie.certification = show.object(forKey: "rating") as? String ?? ""
        
        return uneSerie
    }
    
    
    
    func getDiffuseurs(idTVDB : String, idIMDB : String) -> [Diffuseur] {
        var reqURL : String = ""
        var result : [Diffuseur] = []
        
        if (idIMDB != "")       { reqURL = "https://api.betaseries.com/shows/display?v=3.0&imdb_id=\(idIMDB)" }
        else if (idTVDB != "")  { reqURL = "https://api.betaseries.com/shows/display?v=3.0&thetvdb_id=\(idTVDB)" }
        else                    { return result }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: reqURL) as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return result }
        
        let show = reqResult.object(forKey: "show") as! NSDictionary
        
        if ((show.object(forKey: "platforms") != nil) && !(show.object(forKey: "platforms") is NSNull)) {
            let platforms = show.object(forKey: "platforms") as! NSDictionary
            
            if (platforms.object(forKey: "vod") != nil) {
                for unePlateforme in (platforms.object(forKey: "vod")! as? NSArray ?? NSArray()) {
                    let unDiffuseur : Diffuseur = Diffuseur.init()
                    unDiffuseur.mode = "VOD"
                    unDiffuseur.name = ((unePlateforme as! NSDictionary).object(forKey: "name")) as? String ?? ""
                    let Id : String = ((unePlateforme as! NSDictionary).object(forKey: "id")) as? String ?? "0"
                    unDiffuseur.logo = "https://pictures.betaseries.com/platforms/" + Id + ".jpg"
                    
                    result.append(unDiffuseur)
                }
            }
            
            if (platforms.object(forKey: "svods") != nil) {
                for unePlateforme in (platforms.object(forKey: "svods")! as! NSArray) {
                    let unDiffuseur : Diffuseur = Diffuseur.init()
                    unDiffuseur.mode = "SVOD"
                    unDiffuseur.name = ((unePlateforme as! NSDictionary).object(forKey: "name")) as? String ?? ""
                    unDiffuseur.logo = ((unePlateforme as! NSDictionary).object(forKey: "logo")) as? String ?? ""
                    unDiffuseur.contenu = "?"
                    
                    if ((unePlateforme as! NSDictionary).object(forKey: "available") != nil) {
                        let dernier : Int = ((((unePlateforme as! NSDictionary).object(forKey: "available"))! as AnyObject).object(forKey: "last")) as? Int ?? 0
                        let premier : Int = ((((unePlateforme as! NSDictionary).object(forKey: "available"))! as AnyObject).object(forKey: "first")) as? Int ?? dernier
                        
                        if (premier == dernier) { unDiffuseur.contenu = "Saison " + String(dernier) }
                        else                    { unDiffuseur.contenu = "Saisons " + String(premier) + " - " + String(dernier) }
                    }
                    
                    result.append(unDiffuseur)
                }
            }
        }
        
        return result
    }
    
    
    
    func getSimilarShows(TVDBid : String) -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        var compteur : Int = 0
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.betaseries.com/shows/similars?v=3.0&thetvdb_id=\(TVDBid)") as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return (showNames, showIds) }
        
        for oneShow in (reqResult.object(forKey: "similars") as! NSArray) {
            let titre : String = ((oneShow as! NSDictionary).object(forKey: "show_title")) as? String ?? ""
            let idTVDB : String = String(((oneShow as! NSDictionary).object(forKey: "thetvdb_id")) as? Int ?? 0)
            
            if (compteur < similarShowsPerSource) {
                compteur = compteur + 1
                showNames.append(titre)
                showIds.append(idTVDB)
            }
        }
        
        return (showNames, showIds)
    }
    
    
    func getTrendingShows() -> (names : [String], ids : [String]) { return getShowList(url: "https://api.betaseries.com/shows/discover?v=3.0&limit=\(popularShowsPerSource)") }
    
    func getPopularShows() -> (names : [String], ids : [String]) { return getShowList(url: "https://api.betaseries.com/shows/list?v=3.0&order=popularity&limit=\(popularShowsPerSource)") }
    
    func getShowList(url : String) -> (names : [String], ids : [String]) {
        var showNames : [String] = []
        var showIds : [String] = []
        let reqResult : NSDictionary = loadAPI(reqAPI: url) as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return (showNames, showIds) }
        
        for oneShow in (reqResult.object(forKey: "shows") as! NSArray) {
            let titre : String = ((oneShow as! NSDictionary).object(forKey: "title")) as? String ?? ""
            let idIMDB : String = ((oneShow as! NSDictionary).object(forKey: "imdb_id")) as? String ?? ""
            
            showNames.append(titre)
            showIds.append(idIMDB)
        }
        
        return (showNames, showIds)
    }
    
    
    func rechercheParTitre(serieArechercher : String) -> [Serie] {
        var serieListe : [Serie] = []
        let reqResult : NSDictionary = loadAPI(reqAPI: "https://api.betaseries.com/shows/search?title=\(serieArechercher.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)&v=3.0&order=popularity") as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return serieListe }
        
        for oneItem in (reqResult.object(forKey: "shows") as! NSArray) {
            let oneShow : NSDictionary = oneItem as! NSDictionary
            let newSerie : Serie = Serie(serie: oneShow.object(forKey: "title") as! String)
            
            newSerie.idIMdb = oneShow.object(forKey: "imdb_id") as? String ?? ""
            newSerie.idTVdb = String(oneShow.object(forKey: "thetvdb_id") as? Int ?? 0)
            newSerie.resume = oneShow.object(forKey: "description") as? String ?? ""
            newSerie.network = oneShow.object(forKey: "network") as? String ?? ""
            newSerie.banner = (oneShow.object(forKey: "images")! as AnyObject).object(forKey: "banner") as? String ?? ""
            newSerie.poster = (oneShow.object(forKey: "images")! as AnyObject).object(forKey: "poster") as? String ?? ""
            newSerie.status = oneShow.object(forKey: "status") as? String ?? ""
            newSerie.genres = oneShow.object(forKey: "genres") as? [String] ?? []
            newSerie.year = Int(oneShow.object(forKey: "creation") as? String ?? "0")!
            newSerie.ratingBetaSeries = Int(20 * ((oneShow.object(forKey: "notes")! as AnyObject).object(forKey: "mean") as? Double ?? 0.0))
            newSerie.ratersBetaSeries = (oneShow.object(forKey: "notes")! as AnyObject).object(forKey: "total") as? Int ?? 0
            newSerie.language = oneShow.object(forKey: "language") as? String ?? ""
            newSerie.runtime = Int(oneShow.object(forKey: "length") as? String ?? "0")!
            newSerie.nbEpisodes = Int(oneShow.object(forKey: "episodes") as? String ?? "0")!
            newSerie.nbSaisons = Int(oneShow.object(forKey: "seasons") as? String ?? "0")!
            newSerie.certification = oneShow.object(forKey: "rating") as? String ?? ""
            newSerie.watchlist = true
            
            serieListe.append(newSerie)
        }
        
        return serieListe
    }
    
    
    func chercher(genres: String, anneeBeg: String, anneeEnd: String, duree: String, streamers: String) -> ([Serie], Int) {
        var listeSeries : [Serie] = []
        var cpt : Int = 0
        
        var buildURL : String = "https://api.betaseries.com/search/shows?v=3.0&order=popularity"
        
        if (genres != "") {
            buildURL = buildURL + "&genres="
            for unGenre in genres.split(separator: ",") { buildURL = buildURL + (genresBetaSeries[unGenre] as? String ?? "") + "," }
            buildURL.removeLast()
        }
        
        if (streamers != "") {
            buildURL = buildURL + "&svods="
            for streamer in streamers.split(separator: ",") { buildURL = buildURL + String(platformsBetaSeries[streamer] as? Int ?? 0) + "," }
            buildURL.removeLast()
        }
        
        if (duree != "") {
            buildURL = buildURL + "&duration=" + (dureesBetaSeries[duree] as? String ?? "")
        }
        
        if ( (anneeBeg != "") || (anneeEnd != "") ) {
            let anneeDebut : Int = Int(anneeBeg) ?? 2000
            let anneeFin   : Int = Int(anneeEnd) ?? Calendar.current.component(.year, from: Date())
            
            buildURL = buildURL + "&creations="
            for uneAnnee in anneeDebut...anneeFin { buildURL = buildURL + String(uneAnnee) + "," }
            buildURL.removeLast()
        }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: buildURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) as? NSDictionary ?? NSDictionary()
        
        if (reqResult.object(forKey: "total") != nil) {
            cpt = reqResult.object(forKey: "total") as? Int ?? 0
            
            if (reqResult.object(forKey: "shows") != nil) {
                for uneSerie in reqResult.object(forKey: "shows")! as! NSArray {
                    let newSerie : Serie = Serie(serie: ((uneSerie as AnyObject).object(forKey: "title") as! String))
                    newSerie.year = (uneSerie as AnyObject).object(forKey: "release_date") as? Int ?? 0
                    newSerie.poster = (uneSerie as AnyObject).object(forKey: "poster") as? String ?? ""
                    newSerie.idBetaSeries = String((uneSerie as AnyObject).object(forKey: "id") as? Int ?? 0)
                    
                    listeSeries.append(newSerie)
                }
            }
        }
        
        return (listeSeries, cpt)
    }
    
    
    func getEpisodeCast(idTVDB : Int) -> [Casting] {
        var reqURL : String = ""
        var result : [Casting] = []
        
        if (idTVDB != 0) { reqURL = "https://api.betaseries.com/episodes/display?v=3.0&thetvdb_id=\(idTVDB)" }
        else             { return result }
        
        let reqResult : NSDictionary = loadAPI(reqAPI: reqURL) as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return result }
        
        let episode = reqResult.object(forKey: "episode") as! NSDictionary
        
        if ((episode.object(forKey: "characters") != nil) && !(episode.object(forKey: "characters") is NSNull)) {
            let casting = episode.object(forKey: "characters") as? NSArray ?? []
            
            if (casting.count != 0) {
                for oneCast in casting {
                    let unActeur : Casting = Casting.init()
                    unActeur.personnage = ((oneCast as! NSDictionary).object(forKey: "name")) as? String ?? ""
                    unActeur.name = ((oneCast as! NSDictionary).object(forKey: "actor")) as? String ?? ""
                    unActeur.photo = ((oneCast as! NSDictionary).object(forKey: "picture")) as? String ?? ""
                    
                    if (unActeur.name != "") { result.append(unActeur) }
                }
            }
        }
        
        return result
    }
    
    
    func getComments(episodeID : Int) -> [Critique] {
        var reqURL : String = ""
        var result : [Critique] = []
        
        if (episodeID == 0) { return result }
        
        if (episodeID != 0) { reqURL = "https://api.betaseries.com/comments/comments?v=3.0&id=\(episodeID)&type=episode&replies=0&order=desc" }
        else                { return result }

        let reqResult : NSDictionary = loadAPI(reqAPI: reqURL) as? NSDictionary ?? NSDictionary()
        if (reqResult.count == 0) { return result }

        if (reqResult.object(forKey: "comments") != nil) {
            for oneComment in reqResult.object(forKey: "comments")! as! NSArray {
                let uneCritique : Critique = Critique()
                
                uneCritique.source = srcBetaSeries
                uneCritique.texte = ((oneComment as! NSDictionary).object(forKey: "text")) as? String ?? ""
                uneCritique.auteur = ((oneComment as! NSDictionary).object(forKey: "login")) as? String ?? ""
                uneCritique.journal = "BetaSeries user comment"
                
                let dateString : String = ((oneComment as! NSDictionary).object(forKey: "date")) as? String ?? ""
                let dateTmp : Date = dateFormBetaSeries.date(from: dateString) ?? ZeroDate
                uneCritique.date = dateFormLong.string(from: dateTmp)
                
                result.append(uneCritique)
            }
        }
        
        return result
    }
}


let platformsBetaSeries: NSDictionary = [
    "Netflix" : 1,
    "Canal+" : 278,
    "Amazon Prime" : 3,
    "OCS Go" : 2,
    "Disney+" : 246,
    "Apple TV+" : 255
]


let genresBetaSeries: NSDictionary = [
    "Comédie": "Comedy",
    "Drame": "Drama",
    "Crime": "Crime",
    "Horreur": "Horror",
    "Anime": "Anime",
    "Action": "Action",
    "Aventure": "Adventure",
    "Fantastique": "Fantasy",
    "Animation": "Animation",
    "Science-fiction": "Science_Fiction",
    "Mini-série": "Mini-Series",
    "Romance": "Romance",
    "Western": "Western",
    "Thriller": "Thriller",
    "Soap": "Soap",
    "Enfant": "Children",
    "Famille": "Family",
    "Mystère": "Mystery",
    "Sport": "Sport",
    "Suspense": "Suspense",
    "Histoire": "History",
    
    "Indie": "Indie",
    "Comédie musicale": "Musical",
    "Guerre": "War",
    "Arts martiaux": "Martial_Arts",
    
    "Documentaire": "Documentary",
    "Télé-réalité": "Reality",
    "Talk Show": "Talk_Show",
    "Game Show": "Game-Show",
    "Cuisine": "Food",
    "Maison et jardinage": "Home_and_Garden",
    "Actualité": "News",
    "Intérêt particulier": "Special_Interest",
    "Sport": "Sport",
    "Voyage": "Travel",
    "Podcast": "Podcast"
]

let dureesBetaSeries: NSDictionary = [
    "moins de 20 min": "1-19",
    "20 à 30 min": "20-30",
    "30 à 40 min": "31-40",
    "40 à 50 min": "41-50",
    "50 à 60 min": "51-60",
    "plus de 60 min": "61"
]

/*
 
 genres : Genres séparés par une virgule (doivent correspondre aux clés retournées par shows/genres)
 duration : Durée d'un épisode (1-19, 20-30, 31-40, 41-50, 51-60, 61)
 svods : Ids des plateformes SVoD séparés par une virgule
 creations : Années séparées par une virgule
 pays : Pays d'origine des séries séparés par une virgule (doit être le code à 2 lettres du pays)
 chaines : Chaînes de diffusion séparées par une virgule
 
 */
