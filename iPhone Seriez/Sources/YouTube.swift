//
//  YouTube.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 23/08/2025.
//  Copyright © 2025 Home. All rights reserved.
//

import Foundation

struct YoutubeVideo {
    var titre        : String = ""
    var description  : String = ""
    var channel      : String = ""
    var videoID      : String = ""
    var thumbnails   : String = ""
    var date         : Date   = ZeroDate
    var langue       : String = ""
    var duree        : String = ""
    var likes        : String = ""
}


class YouTube {
    var chrono : TimeInterval = 0
    let dateFormYouTube = DateFormatter()
    let keyYouTube : String = "AIzaSyCT2c4MtGQIcUJtDc8uKY1Wst7cRwP5xOQ"
    
    init() {
        dateFormYouTube.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
    }
    
    func loadAPI(reqAPI: String) -> NSObject {
        let startChrono : Date = Date()
        var ended : Bool = false
        var result : NSObject = NSObject()
        
        var request = URLRequest(url: URL(string: reqAPI)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if (response.statusCode != 200) { print("YouTube::error \(response.statusCode) received for req=\(reqAPI) "); ended = true; return; }
                    result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSObject
                    ended = true
                    
                } catch let error as NSError { print("YouTube::failed \(error.localizedDescription) for req=\(reqAPI)"); ended = true; }
            } else { print(error as Any); ended = true; }
        }
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        chrono = chrono + Date().timeIntervalSince(startChrono)
        return result

    }
    
    func searchRecap(serie: String, Season : Int) -> [YoutubeVideo] {
        let reqAPI : String = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=10&q=\(serie) season \(Season) Recap&key=\(keyYouTube)"
        let reqResult : NSDictionary = loadAPI(reqAPI: reqAPI) as? NSDictionary ?? NSDictionary()
        var videoList : String = ""
        
        if (reqResult.object(forKey: "items") != nil) {
            let listItems = reqResult.object(forKey: "items") as? NSArray ?? NSArray()
            
            if (listItems.count > 0) {
                for oneItem in listItems {
                    let snippet : NSDictionary = (oneItem as? NSDictionary)?.object(forKey: "snippet") as? NSDictionary ?? NSDictionary()
                    let titre : String = snippet.object(forKey: "title") as? String ?? ""
                    let id : String = ((oneItem as? NSDictionary)?.object(forKey: "id") as? NSDictionary)?.object(forKey: "videoId") as? String ?? ""

                    if (titre.lowercased().contains(serie.lowercased())) {
                        videoList = videoList + id + ","
                    }
                }
            }
        }

        
//        if (reqResult.object(forKey: "items") != nil) {
//            let listItems = reqResult.object(forKey: "items") as? NSArray ?? NSArray()
//            
//            if (listItems.count > 0) {
//                for oneItem in listItems {
//                    var oneVideo : YoutubeVideo = YoutubeVideo()
//                    let snippet : NSDictionary = (oneItem as? NSDictionary)?.object(forKey: "snippet") as? NSDictionary ?? NSDictionary()
//                    
//                    oneVideo.titre = snippet.object(forKey: "title") as? String ?? ""
//                    oneVideo.description = snippet.object(forKey: "description") as? String ?? ""
//                    oneVideo.channel = snippet.object(forKey: "channelTitle") as? String ?? ""
//                    oneVideo.videoID = ((oneItem as? NSDictionary)?.object(forKey: "id") as? NSDictionary)?.object(forKey: "videoId") as? String ?? ""
//                    oneVideo.thumbnails = ((snippet.object(forKey: "thumbnails") as? NSDictionary)?.object(forKey: "default") as? NSDictionary)?.object(forKey: "url") as? String ?? ""
//                    
//                    if (oneVideo.titre.lowercased().contains(serie.lowercased())) { videoList.append(oneVideo) }
//                }
//            }
//        }
        
        if videoList.count > 0 { return getRecapDetails(liste: videoList ) }
        else { return [] }
    }
    
    
    func getRecapDetails(liste : String) -> [YoutubeVideo] {
        var videoList : [YoutubeVideo] = []
//        var ids : String = ""
//        for oneVid in liste { ids = ids + oneVid.videoID + "," }
//        if ids.count > 0 { ids.removeLast() }
        
        let reqAPI : String = "https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id=\(liste)&key=\(keyYouTube)"
        let reqResult : NSDictionary = loadAPI(reqAPI: reqAPI) as? NSDictionary ?? NSDictionary()

        if (reqResult.object(forKey: "items") != nil) {
            let listItems = reqResult.object(forKey: "items") as? NSArray ?? NSArray()
            
            if (listItems.count > 0) {
                for oneItem in listItems {
                    var oneVideo : YoutubeVideo = YoutubeVideo()
                    
                    oneVideo.videoID = (oneItem as? NSDictionary)?.object(forKey: "id") as? String ?? ""
                    
                    let snippet : NSDictionary = (oneItem as? NSDictionary)?.object(forKey: "snippet") as? NSDictionary ?? NSDictionary()
                    oneVideo.titre = snippet.object(forKey: "title") as? String ?? ""
                    oneVideo.date = dateFormYouTube.date(from: snippet.object(forKey: "publishedAt") as? String ?? "2000-01-01T00:00:00Z")!
                    oneVideo.langue = snippet.object(forKey: "defaultLanguage") as? String ?? ""
                    oneVideo.description = snippet.object(forKey: "description") as? String ?? ""
                    oneVideo.channel = snippet.object(forKey: "channelTitle") as? String ?? ""
                    oneVideo.thumbnails = ((snippet.object(forKey: "thumbnails") as? NSDictionary)?.object(forKey: "default") as? NSDictionary)?.object(forKey: "url") as? String ?? ""
                    
                    let details : NSDictionary = (oneItem as? NSDictionary)?.object(forKey: "contentDetails") as? NSDictionary ?? NSDictionary()
                    oneVideo.duree = details.object(forKey: "duration") as? String ?? ""
                    oneVideo.duree = oneVideo.duree.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "M", with: "m ").replacingOccurrences(of: "S", with: "s")
                    
                    let stats : NSDictionary = (oneItem as? NSDictionary)?.object(forKey: "statistics") as? NSDictionary ?? NSDictionary()
                    oneVideo.likes = "👍🏼 " + (stats.object(forKey: "likeCount") as? String ?? "")

                    videoList.append(oneVideo)
                }
            }
        }

        return videoList
    }
}
