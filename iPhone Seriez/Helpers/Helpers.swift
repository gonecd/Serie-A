//
//  Helpers.swift
//  SerieA
//
//  Created by Cyril Delamare on 15/04/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import ContactsUI


var imagesCache : NSCache = NSCache<NSString, UIImage>()

func emptyCache() {
    do {
        if (FileManager.default.fileExists(atPath: PosterDir.path) == true) {
            try FileManager.default.removeItem(atPath: PosterDir.path)
            try FileManager.default.createDirectory(at: PosterDir, withIntermediateDirectories: false, attributes: nil)
        }
    }
    catch let error as NSError { print(error.localizedDescription); }
}


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
        if (imageData != nil) {
            return UIImage(data: imageData! as Data)!
        }
        else {
            return UIImage()
        }
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
    case "BE": return #imageLiteral(resourceName: "Flag_of_Belgium.png")
    case "IT": return #imageLiteral(resourceName: "Flag_of_Italy.png")
    case "MX": return #imageLiteral(resourceName: "Flag_of_Mexico.png")
    case "DK": return #imageLiteral(resourceName: "Flag_of_Denmark.png")
    case "KR": return #imageLiteral(resourceName: "Flag_of_South_Korea.png")
    case "NZ": return #imageLiteral(resourceName: "Flag_of_New_Zealand.png")
    case "AR": return #imageLiteral(resourceName: "Flag_of_Argentina.png")
    case "IE": return #imageLiteral(resourceName: "Flag_of_Ireland.png")
        
    case "": return UIImage()
        
    default:
        print("Pays sans drapeau : \(country)")
        return UIImage()
    }
}

func makeGradiant(carre : UIView, couleur : String) {
    //TODO : https://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow
    
    guard let sublayers = carre.layer.sublayers else { return }
    for sublayer in sublayers where sublayer.name == "ColorGradiant" {
        sublayer.removeFromSuperlayer()
    }
    
    let myGradient : CAGradientLayer = CAGradientLayer()
    carre.layer.shadowColor = UIColor.gray.cgColor
    carre.layer.shadowOpacity = 0.2
    carre.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
    carre.layer.shadowRadius = 10.0
    
    if (couleur == "Rouge") {
        myGradient.colors = [UIColor(red: 148.0/255.0, green: 17.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor.systemRed.cgColor]
    }
    else if (couleur == "Bleu") {
        myGradient.colors = [UIColor(red: 1.0/255.0, green: 25.0/255.0, blue: 147.0/255.0, alpha: 1.0).cgColor, UIColor.systemBlue.cgColor]
    }
    else if (couleur == "Vert") {
        myGradient.colors = [UIColor(red: 0.0, green: 80.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor(red: 0.0, green: 143.0/255.0, blue: 0.0, alpha: 1.0).cgColor]
    }
    else if (couleur == "Gris") {
        myGradient.colors = [UIColor.darkGray.cgColor, UIColor.lightGray.cgColor]
    }
    else {
        myGradient.colors = [UIcolor1.cgColor, UIcolor2.cgColor]
    }
    
    myGradient.startPoint = CGPoint(x: 0, y: 0)
    myGradient.endPoint = CGPoint(x: 1, y: 1)
    myGradient.frame = carre.bounds
    myGradient.cornerRadius = 10.0
    myGradient.name = "ColorGradiant"
    
    carre.layer.insertSublayer(myGradient, at: 0)
}


func seriesBackgrounds(carre : UIView) {
    let myGradient : CAGradientLayer = CAGradientLayer()
    carre.layer.shadowColor = UIColor.gray.cgColor
    carre.layer.shadowOpacity = 0.2
    carre.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
    carre.layer.shadowRadius = 10.0
    
    myGradient.colors = [SerieColor1.cgColor, SerieColor2.cgColor]
    
    myGradient.startPoint = CGPoint(x: 0, y: 0)
    myGradient.endPoint = CGPoint(x: 1, y: 1)
    myGradient.frame = carre.bounds
    myGradient.cornerRadius = 10.0
    myGradient.name = "colorGradient"
    
    carre.layer.insertSublayer(myGradient, at: 0)
}


func border(texte: UITextField) {
    texte.layer.borderWidth = 2.0
    texte.layer.borderColor = UIColor.black.cgColor
}

func makeMiniGradiant(carre : UIView, couleur : String) {
    let myGradient : CAGradientLayer = CAGradientLayer()
    
    if (couleur == "Rouge") {
        myGradient.colors = [UIColor(red: 148.0/255.0, green: 17.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor.systemRed.cgColor]
    }
    else if (couleur == "Bleu") {
        myGradient.colors = [UIColor(red: 1.0/255.0, green: 25.0/255.0, blue: 147.0/255.0, alpha: 1.0).cgColor, UIColor.systemBlue.cgColor]
    }
    else if (couleur == "Vert") {
        myGradient.colors = [UIColor(red: 0.0, green: 80.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor(red: 0.0, green: 143.0/255.0, blue: 0.0, alpha: 1.0).cgColor]
    }
    else if (couleur == "Gris") {
        myGradient.colors = [UIColor.darkGray.cgColor, UIColor.lightGray.cgColor]
    }
    
    myGradient.startPoint = CGPoint(x: 0, y: 0)
    myGradient.endPoint = CGPoint(x: 1, y: 1)
    myGradient.frame = carre.bounds
    
    carre.layer.cornerRadius = 5;
    carre.layer.masksToBounds = true
    carre.layer.insertSublayer(myGradient, at: 0)
}

func arrondir(fenetre: UIView, radius : CGFloat) {
    fenetre.layer.cornerRadius = radius
    fenetre.layer.borderWidth = 4.0
    fenetre.layer.borderColor = UIColor.systemFill.cgColor
    fenetre.layer.masksToBounds = true
}

func arrondir(texte: UITextField, radius : CGFloat) {
    texte.layer.cornerRadius = radius
    texte.layer.masksToBounds = true
}

func arrondirLabel(texte: UILabel, radius : CGFloat) {
    texte.layer.cornerRadius = radius
    texte.layer.masksToBounds = true
}

func arrondirButton(texte: UIButton, radius : CGFloat) {
    texte.layer.cornerRadius = radius
    texte.layer.masksToBounds = true
}

func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
    
    return components.day!
}


func colorGradient(borneInf : CGFloat, borneSup: CGFloat, valeur: CGFloat) -> UIColor {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    
    if (valeur < (borneSup - borneInf)/2 ) {
        red = 204.0 / 255.0
        green = red * (valeur - borneInf) / ( (borneSup - borneInf)/2 )
    } else {
        green = 204.0 / 255.0
        red = green * (borneSup - valeur) / ( (borneSup - borneInf)/2 )
    }
    
    return UIColor.init(red: red, green: green, blue: 0.0, alpha: 1.0)
}


func getStreamers(serie: String, idTVDB: String, idIMDB: String, saison: Int) -> [String] {
    var allStreamers : [String] = []
    
    for oneDiffuseur in justWatch.getDiffuseurs(serie: serie, saison: saison) {
            if (oneDiffuseur.mode == "Streaming") {
                allStreamers.append(oneDiffuseur.logo)
            }
        }
    
//    for oneDiffuseur in betaSeries.getDiffuseurs(idTVDB : idTVDB, idIMDB : idIMDB) {
//        //        if (oneDiffuseur.mode == "SVOD") {
//        if (oneDiffuseur.dernier >= saison) { allStreamers.append(oneDiffuseur.logo) }
//        //        }
//    }
    
    return allStreamers
}


func parentguideColor(severity: String) -> UIColor {
    
    switch severity {
    case "None": return UIColor.systemGray5
    case "Mild": return UIColor.systemGreen.withAlphaComponent(0.5)
    case "Moderate": return UIColor.systemOrange.withAlphaComponent(0.5)
    case "Severe": return UIColor.systemRed.withAlphaComponent(0.5)
    case "Faible": return UIColor.systemGreen.withAlphaComponent(0.5)
    case "Modéré": return UIColor.systemOrange.withAlphaComponent(0.5)
    case "Élevé": return UIColor.systemRed.withAlphaComponent(0.5)
    default:
        print ("Unknown severity : \(severity)")
        return UIColor.systemGray6
    }
}


func getLogoDiffuseur(diffuseur: String) -> UIImage {
    
    switch (diffuseur) {
    case "Netflix": return #imageLiteral(resourceName: "netflix.jpg")
    case "Canal+": return #imageLiteral(resourceName: "canal plus.jpg")
    case "Apple TV+": return #imageLiteral(resourceName: "apple tv.jpg")
    case "Disney+": return #imageLiteral(resourceName: "disney.jpg")
    case "Amazon": return #imageLiteral(resourceName: "prime video.jpg")
    case "Prime Video": return #imageLiteral(resourceName: "prime video.jpg")
    case "Max": return #imageLiteral(resourceName: "max.jpg")
    case "Paramount+": return #imageLiteral(resourceName: "paramount.jpg")
    case "OCS": return #imageLiteral(resourceName: "ocs.jpg")
    case "M6+": return #imageLiteral(resourceName: "M6.jpg")
    case "TF1+": return #imageLiteral(resourceName: "tf1.jpg")
    case "Arte": return #imageLiteral(resourceName: "arte.jpg")
    case "france.tv": return #imageLiteral(resourceName: "francetv.jpg")
    case "": return UIImage()

    default: 
        print("Logo diffuseur inconnu = \(diffuseur)")
        return UIImage()
    }
    
}



//import SwiftUI
//import CoreImage
//import CoreImage.CIFilterBuiltins


func extractDominantColor(from image: UIImage) -> UIColor? {
    guard let inputImage = CIImage(image: image) else { return nil }
    
    let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
    
    guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
    guard let outputImage = filter.outputImage else { return nil }
    
    var bitmap = [UInt8](repeating: 0, count: 4)
    let context = CIContext(options: [.workingColorSpace: kCFNull!])
    context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
    
    return UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
}


func reqAccessToContacts() {
    let store = CNContactStore()
    
    if (CNContactStore.authorizationStatus(for: .contacts) == .notDetermined) {
        store.requestAccess(for: .contacts){ succeeded, err in
            guard err == nil && succeeded else { return }
        }
    }

}

func getContactFromID(contactID: String) -> CNContact {
    let contact = CNContact()
    let contactStore = CNContactStore()
    var contacts = [CNContact]()
    
    let predicate = CNContact.predicateForContacts(withIdentifiers: [contactID])
    let keysToFetch = [CNContactFamilyNameKey, CNContactNicknameKey, CNContactGivenNameKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
    
    do {
        contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        
        if contacts.count == 0 {
            print("No contacts were found matching the ID.")
            return contact
        }
        
        return contacts[0]
    }
    catch {
        print("Unable to fetch contacts.")
    }
    
    return contact
}
