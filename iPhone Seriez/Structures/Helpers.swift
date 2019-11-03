//
//  Helpers.swift
//  SerieA
//
//  Created by Cyril Delamare on 15/04/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import Reachability
import CoreTelephony

var imagesCache : NSCache = NSCache<NSString, UIImage>()


func checkDirectories() {
    do {
        if (FileManager.default.fileExists(atPath: PosterDir.path) == false) {
            try FileManager.default.createDirectory(at: PosterDir, withIntermediateDirectories: false, attributes: nil)
        }
        
        if (FileManager.default.fileExists(atPath: IMdbDir.path) == false) {
            try FileManager.default.createDirectory(at: IMdbDir, withIntermediateDirectories: false, attributes: nil)
        }
    }
    catch let error as NSError { print(error.localizedDescription); }
}


func getImage(_ url: String) -> UIImage {
    if (url == "") { return UIImage() }

    let pathToImage = PosterDir.appendingPathComponent(URL(string: url)!.lastPathComponent).path
    
    if (FileManager.default.fileExists(atPath: pathToImage)) {
        return UIImage(contentsOfFile: pathToImage)!
    }
    else {
        let imageData = NSData(contentsOf: URL(string: url)!)
        imageData?.write(toFile: pathToImage, atomically: true)
        return UIImage(data: imageData! as Data)!
    }
}


func getDrapeau(country : String) -> UIImage {
    switch country {
    case "US": return #imageLiteral(resourceName: "Flag_of_the_United_States.png")
    case "GB": return #imageLiteral(resourceName: "Flag_of_the_United_Kingdom.png")
    case "UK": return #imageLiteral(resourceName: "Flag_of_the_United_Kingdom.png")
    case "FR": return #imageLiteral(resourceName: "Flag_of_France.png")
    case "ES": return #imageLiteral(resourceName: "Flag_of_Spain.png")
    case "DE": return #imageLiteral(resourceName: "Flag_of_Germany.png")
    case "CA": return #imageLiteral(resourceName: "Flag_of_Canada.png")
    case "CZ": return #imageLiteral(resourceName: "Flag_of_the_Czech_Republic.png")
    case "NO": return #imageLiteral(resourceName: "Flag_of_Norway.png")
    case "BR": return #imageLiteral(resourceName: "Flag_of_Brazil.png")
    case "JP": return #imageLiteral(resourceName: "Flag_of_Japan.png")
    case "AU": return #imageLiteral(resourceName: "Flag_of_Australia.png")

    case "IL": return #imageLiteral(resourceName: "Flag_of_Israel.png")
    case "SE": return #imageLiteral(resourceName: "Flag_of_Sweden.png")
    case "FI": return #imageLiteral(resourceName: "Flag_of_Finland.png")
    case "IN": return #imageLiteral(resourceName: "Flag_of_India.png")
    case "TW": return #imageLiteral(resourceName: "Flag_of_Taiwan.png")
    case "CN": return #imageLiteral(resourceName: "Flag_of_China.png")

    case "": return UIImage()

    default:
        print("Pays sans drapeau : \(country)")
        return UIImage()
    }
}

func makeGradiant(carre : UIView, couleur : String) {
    //TODO : https://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow
    
    let myGradient : CAGradientLayer = CAGradientLayer()
    carre.layer.shadowColor = UIColor.black.cgColor
    carre.layer.shadowOpacity = 0.2
    carre.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
    carre.layer.shadowRadius = 10.0

    if (couleur == "Rouge") {
        myGradient.colors = [UIColor(red: 148.0/255.0, green: 17.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor.red.cgColor]
    }
    else if (couleur == "Bleu") {
        myGradient.colors = [UIColor(red: 1.0/255.0, green: 25.0/255.0, blue: 147.0/255.0, alpha: 1.0).cgColor, UIColor.blue.cgColor]
    }
    else if (couleur == "Vert") {
        myGradient.colors = [UIColor(red: 0.0, green: 80.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor(red: 0.0, green: 143.0/255.0, blue: 0.0, alpha: 1.0).cgColor]
    }
    else if (couleur == "Gris") {
        myGradient.colors = [UIColor.darkGray.cgColor, UIColor.gray.cgColor]
    }
    
    myGradient.startPoint = CGPoint(x: 0, y: 0)
    myGradient.endPoint = CGPoint(x: 1, y: 1)
    myGradient.frame = carre.bounds
    myGradient.cornerRadius = 10.0
    
    carre.layer.insertSublayer(myGradient, at: 0)
}

func border(texte: UITextField) {
    texte.layer.borderWidth = 2.0
    texte.layer.borderColor = UIColor.black.cgColor
}

func makeMiniGradiant(carre : UIView, couleur : String) {
    let myGradient : CAGradientLayer = CAGradientLayer()
    
    if (couleur == "Rouge") {
        myGradient.colors = [UIColor(red: 148.0/255.0, green: 17.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor.red.cgColor]
    }
    else if (couleur == "Bleu") {
        myGradient.colors = [UIColor(red: 1.0/255.0, green: 25.0/255.0, blue: 147.0/255.0, alpha: 1.0).cgColor, UIColor.blue.cgColor]
    }
    else if (couleur == "Vert") {
        myGradient.colors = [UIColor(red: 0.0, green: 80.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor(red: 0.0, green: 143.0/255.0, blue: 0.0, alpha: 1.0).cgColor]
    }
    else if (couleur == "Gris") {
        myGradient.colors = [UIColor.darkGray.cgColor, UIColor.gray.cgColor]
    }
    
    myGradient.startPoint = CGPoint(x: 0, y: 0)
    myGradient.endPoint = CGPoint(x: 1, y: 1)
    myGradient.frame = carre.bounds
    
    carre.layer.cornerRadius = 5;
    carre.layer.masksToBounds = true
    carre.layer.insertSublayer(myGradient, at: 0)
}


func arrondir(texte: UITextField, radius : CGFloat) {
    texte.layer.cornerRadius = radius
    texte.layer.masksToBounds = true
}

func arrondirLabel(texte: UILabel, radius : CGFloat) {
    texte.layer.cornerRadius = radius
    texte.layer.masksToBounds = true
}

func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
    
    return components.day!
}


func getNetWork() -> String {
    do {
        let reachability: Reachability = try Reachability()
        
        try reachability.startNotifier()
        
        switch reachability.connection {
        case .unavailable : return "No net"
        case .wifi: return "WiFi"
        case .cellular: return getCellType()
        default : return "Undef"
        }
    } catch {
        print("Reachability: ERROR")
        return "No net"
    }
}


func getCellType() -> String {
  guard let currentRadioAccessTechnology = CTTelephonyNetworkInfo().currentRadioAccessTechnology else { return "Undef" }
  switch currentRadioAccessTechnology {
  case CTRadioAccessTechnologyGPRS,
       CTRadioAccessTechnologyEdge,
       CTRadioAccessTechnologyCDMA1x:
    return "2G"
  case CTRadioAccessTechnologyWCDMA,
       CTRadioAccessTechnologyHSDPA,
       CTRadioAccessTechnologyHSUPA,
       CTRadioAccessTechnologyCDMAEVDORev0,
       CTRadioAccessTechnologyCDMAEVDORevA,
       CTRadioAccessTechnologyCDMAEVDORevB,
       CTRadioAccessTechnologyeHRPD:
    return "3G"
  case CTRadioAccessTechnologyLTE:
    return "4G"
  default:
    return "Undef"
  }
}
