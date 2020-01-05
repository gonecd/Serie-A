//
//  TodayViewController.swift
//  Updates
//
//  Created by Cyril DELAMARE on 01/11/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import NotificationCenter
import SeriesCommon

class TodayViewController: UIViewController, NCWidgetProviding {
        
    var sharedInfos :[InfosRefresh] = []
    let hauteurParUpdate : Int = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
        
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .expanded) {
            preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(10+(hauteurParUpdate*sharedInfos.count)))
            fullView(size: CGSize(width: maxSize.width, height: CGFloat(10+(hauteurParUpdate*sharedInfos.count))))
        }
        else {
            preferredContentSize = maxSize
            lightView(size: maxSize)
        }
    }
    

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        loadInfos()
        lightView(size: (extensionContext?.widgetMaximumSize(for: .compact))!)

        completionHandler(NCUpdateResult.newData)
    }
 
    func loadInfos() {
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"Refresh") as? Data {
            sharedInfos = try! PropertyListDecoder().decode(Array<InfosRefresh>.self, from: data)
        }
    }
    
    func cleanView() {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }

    func addLabel(x : Int, y : Int, w : Int, h : Int, size : CGFloat, weight : UIFont.Weight, alignement : NSTextAlignment, text : String) {
        let myLabel = UILabel(frame: CGRect(x: x, y: y, width: w , height: h))
        myLabel.font = .systemFont(ofSize: size, weight : weight)
        myLabel.textAlignment = alignement
        myLabel.text = text
        self.view.addSubview(myLabel)
    }
    
    func addRoundLabel(x : Int, y : Int, w : Int, h : Int, color : UIColor, size : CGFloat, weight : UIFont.Weight, text : String) {
        let myLabel = UILabel(frame: CGRect(x: x, y: y, width: w, height: h))
        myLabel.textColor = color
        myLabel.font = .systemFont(ofSize: size, weight : weight)
        myLabel.textAlignment = .center
        myLabel.text = text
        myLabel.layer.borderColor = color.cgColor
        myLabel.layer.borderWidth = 1
        myLabel.layer.cornerRadius = 7
        myLabel.layer.masksToBounds = true
        self.view.addSubview(myLabel)
    }
    
    func addImage(x : Int, y : Int, w : Int, h : Int, image : UIImage) {
        let myImage : UIImageView = UIImageView(frame: CGRect(x: x, y: y, width: w, height: h));
        myImage.image = image
        self.view.addSubview(myImage)
    }
    
    func fullView(size : CGSize) {
        cleanView()

        var netColor : UIColor
        
        for i in 0..<sharedInfos.count {
            addLabel(x : 15, y : 5+(hauteurParUpdate*i), w : 100, h : 25, size : 15.0, weight : .bold, alignement : .center, text : sharedInfos[sharedInfos.count-1-i].timestamp)
            
            switch sharedInfos[sharedInfos.count-1-i].network {
            case "WiFi" : netColor = .systemGreen
            case "No net" : netColor = .systemRed
            case "4G" : netColor = .systemOrange
            case "3G" : netColor = .systemOrange
            case "2G" : netColor = .systemOrange
            default : netColor = .systemGray
            }
            addRoundLabel(x : 140, y : 10+(hauteurParUpdate*i), w : 50, h : 15, color : netColor, size : 12.0, weight : .regular, text : sharedInfos[sharedInfos.count-1-i].network)

            if (sharedInfos[sharedInfos.count-1-i].refreshDates == "No") {
                addRoundLabel(x : 200, y : 10+(hauteurParUpdate*i), w : 40, h : 15, color : .systemRed, size : 12.0, weight : .regular, text : "No")
            }
            else {
                addLabel(x : 200, y : 10+(hauteurParUpdate*i), w : 40, h : 15, size : 12.0, weight : .regular, alignement : .right, text : sharedInfos[sharedInfos.count-1-i].refreshDates)
            }

            if (sharedInfos[sharedInfos.count-1-i].refreshIMDB == "No") {
                addRoundLabel(x : 250, y : 10+(hauteurParUpdate*i), w : 40, h : 15, color : .systemRed, size : 12.0, weight : .regular, text : "No")
            }
            else {
                addLabel(x : 250, y : 10+(hauteurParUpdate*i), w : 40, h : 15, size : 12.0, weight : .regular, alignement : .right, text : sharedInfos[sharedInfos.count-1-i].refreshIMDB)
            }

            if (sharedInfos[sharedInfos.count-1-i].refreshViewed == "No") {
                addRoundLabel(x : 300, y : 10+(hauteurParUpdate*i), w : 40, h : 15, color : .systemRed, size : 12.0, weight : .regular, text : "No")
            }
            else {
                addLabel(x : 300, y : 10+(hauteurParUpdate*i), w : 40, h : 15, size : 12.0, weight : .regular, alignement : .right, text : sharedInfos[sharedInfos.count-1-i].refreshViewed)
            }
        }
    }
    
    func lightView(size : CGSize) {
        cleanView()
        
        var dates : String = ""
        var imdb : String = ""
        var viewed : String = ""
        var cptUpdates : Int = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        let today : String = dateFormatter.string(from: Date())

        for i in 0..<sharedInfos.count {
            if (sharedInfos[i].timestamp.prefix(5) == today) {
                if (sharedInfos[i].refreshDates != "No") { dates = String(sharedInfos[i].timestamp.suffix(5)) }
                if (sharedInfos[i].refreshIMDB != "No") { imdb = String(sharedInfos[i].timestamp.suffix(5)) }
                if (sharedInfos[i].refreshViewed != "No") { viewed = String(sharedInfos[i].timestamp.suffix(5)) }
                cptUpdates = cptUpdates + 1
            }
        }
        
        // Ajout des titres
        addLabel(x : 100, y : 13, w : 80, h : 25, size : 12.0, weight : .regular, alignement : .center, text : "Dates saisons")
        addLabel(x : 190, y : 13, w : 80, h : 25, size : 12.0, weight : .regular, alignement : .center, text : "Notes IMDB")
        addLabel(x : 280, y : 13, w : 80, h : 25, size : 12.0, weight : .regular, alignement : .center, text : "Episodes vus")
        
        // Ajout des logos
        addImage(x : 100, y : 45, w : 48, h : 48, image : #imageLiteral(resourceName: "tvmaze.ico"))
        addImage(x : 190, y : 45, w : 48, h : 48, image : #imageLiteral(resourceName: "imdb.ico"))
        addImage(x : 280, y : 45, w : 48, h : 48, image : #imageLiteral(resourceName: "trakt.ico"))

        // Ajout des heures
        addLabel(x : 150, y : 80, w : 40, h : 15, size : 11.0, weight : .light, alignement : .left, text : dates)
        addLabel(x : 240, y : 80, w : 40, h : 15, size : 11.0, weight : .light, alignement : .left, text : imdb)
        addLabel(x : 330, y : 80, w : 40, h : 15, size : 11.0, weight : .light, alignement : .left, text : viewed)
        
        
        // Ajout des flags
        if (dates == "" ) {
            addImage(x : 150, y : 45, w : 32, h : 32, image : #imageLiteral(resourceName: "ko.png"))
        }
        else {
            addImage(x : 150, y : 45, w : 32, h : 32, image : #imageLiteral(resourceName: "ok.png"))
        }
        
        if (imdb == "" ) {
            addImage(x : 240, y : 45, w : 32, h : 32, image : #imageLiteral(resourceName: "ko.png"))
        }
        else {
            addImage(x : 240, y : 45, w : 32, h : 32, image : #imageLiteral(resourceName: "ok.png"))
        }
        
        if (viewed == "" ) {
            addImage(x : 330, y : 45, w : 32, h : 32, image : #imageLiteral(resourceName: "ko.png"))
        }
        else {
            addImage(x : 330, y : 45, w : 32, h : 32, image : #imageLiteral(resourceName: "ok.png"))
        }
        
        // Ajout de Today + Nb Updates
        addLabel(x : 5, y : 10, w : 100, h : 25, size : 24.0, weight : .heavy, alignement : .left, text : "Today :")
        addLabel(x : 15, y : 30, w : 70, h : 25, size : 12.0, weight : .regular, alignement : .left, text : "(" + String(cptUpdates) + " updates)")
    }
    
    
}
