//
//  Helpers.swift
//  SerieA
//
//  Created by Cyril Delamare on 15/04/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

var imagesCache : NSCache = NSCache<NSString, UIImage>()

func getImage(_ url: String) -> UIImage
{
    trace(texte : "<< Helper : getImage >>", logLevel : logFuncCalls, scope : scopeController)
    trace(texte : "<< Helper : getImage >> Params : No Params", logLevel : logFuncParams, scope : scopeController)
    
    if (url == "") { return UIImage() }
    
    do {
        if ((imagesCache.object(forKey: url as NSString)) == nil)
        {
            trace(texte : "<< Helper : getImage >> Return : caching image", logLevel : logDebug, scope : scopeController)
            let imageData : Data = try Data.init(contentsOf: URL(string: url)!)
            imagesCache.setObject(UIImage.init(data: imageData)!, forKey: url as NSString)
        }
        trace(texte : "<< Helper : getImage >> Return : cached image", logLevel : logFuncReturn, scope : scopeController)
        return imagesCache.object(forKey: url as NSString)!
    }
    catch let error as NSError { print("getImage failed for \(url) : \(error)") }
    
    trace(texte : "<< Helper : getImage >> Return : empty image", logLevel : logFuncReturn, scope : scopeController)
    return UIImage()
}

func trace(texte : String, logLevel : Int, scope : Int)
{
    let showTimeStamp   : Bool = true
    let showLogLevel    : Int  = logErrors
    let showSource      : Bool = true
    let showHelper      : Bool = false
    let showGraphe      : Bool = false
    let showController  : Bool = false
    let showStructure   : Bool = false
    
    
    if (logLevel <= showLogLevel )
    {
        if ( ((scope == scopeSource) && (showSource))
            || ((scope == scopeHelper) && (showHelper))
            || ((scope == scopeGraphe) && (showGraphe))
            || ((scope == scopeStructure) && (showStructure))
            || ((scope == scopeController) && (showController)) )
        {
            if (showTimeStamp)
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS.sss"
                
                print(dateFormatter.string(from: Date()) + " : " + texte)
            }
            else
            {
                print(texte)
            }
        }
    }
}

func getDrapeau(country : String) -> UIImage
{
    trace(texte : "<< Helper : getDrapeau >>", logLevel : logFuncCalls, scope : scopeHelper)
    trace(texte : "<< Helper : getDrapeau >> Params : country = \(country)", logLevel : logFuncParams, scope : scopeHelper)
    
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
        
    default:
        print("Pays sans drapeau : \(country)")
        return UIImage()
    }
}

func makeGradiant(carre : UIView, couleur : String)
{
    trace(texte : "<< Helper : makeGradiant >>", logLevel : logFuncCalls, scope : scopeHelper)
    trace(texte : "<< Helper : makeGradiant >> Params : carre = \(carre), couleur = \(couleur)", logLevel : logFuncParams, scope : scopeHelper)
    
    //TODO : https://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow
    
    let myGradient : CAGradientLayer = CAGradientLayer()
    
    if (couleur == "Rouge")
    {
        myGradient.colors = [UIColor(red: 148.0/255.0, green: 17.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor.red.cgColor]
    }
    else if (couleur == "Bleu")
    {
        myGradient.colors = [UIColor(red: 1.0/255.0, green: 25.0/255.0, blue: 147.0/255.0, alpha: 1.0).cgColor, UIColor.blue.cgColor]
    }
    else if (couleur == "Vert")
    {
        myGradient.colors = [UIColor(red: 0.0, green: 80.0/255.0, blue: 0.0, alpha: 1.0).cgColor, UIColor(red: 0.0, green: 143.0/255.0, blue: 0.0, alpha: 1.0).cgColor]
    }
    
    myGradient.startPoint = CGPoint(x: 0, y: 0)
    myGradient.endPoint = CGPoint(x: 1, y: 1)
    myGradient.frame = carre.bounds
    
    carre.layer.cornerRadius = 10;
    
    carre.layer.shadowColor = UIColor.black.cgColor
    carre.layer.shadowOpacity = 0.4
    carre.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
    carre.layer.shadowRadius = 10.0
    
    carre.layer.insertSublayer(myGradient, at: 0)
    
    trace(texte : "<< Helper : makeGradiant >> Return : No Return", logLevel : logFuncReturn, scope : scopeHelper)
}


func arrondir(texte: UITextField, radius : CGFloat)
{
    trace(texte : "<< Helper : arrondir >>", logLevel : logFuncCalls, scope : scopeHelper)
    trace(texte : "<< Helper : arrondir >> Params : texte = \(texte), radius = \(radius)", logLevel : logFuncParams, scope : scopeHelper)
    
    texte.layer.cornerRadius = radius
    texte.layer.masksToBounds = true
    
    trace(texte : "<< Helper : arrondir >> Return : No Return", logLevel : logFuncReturn, scope : scopeHelper)
}

func arrondirLabel(texte: UILabel, radius : CGFloat)
{
    trace(texte : "<< Helper : arrondirLabel >>", logLevel : logFuncCalls, scope : scopeHelper)
    trace(texte : "<< Helper : arrondirLabel >> Params : texte = \(texte), radius = \(radius)", logLevel : logFuncParams, scope : scopeHelper)
    
    texte.layer.cornerRadius = radius
    texte.layer.masksToBounds = true
    
    trace(texte : "<< Helper : arrondirLabel >> Return : No Return", logLevel : logFuncReturn, scope : scopeHelper)
}

func daysBetweenDates(startDate: Date, endDate: Date) -> Int
{
    trace(texte : "<< Helper : daysBetweenDates >>", logLevel : logFuncCalls, scope : scopeHelper)
    trace(texte : "<< Helper : daysBetweenDates >> Params : startDate = \(startDate), endDate = \(endDate)", logLevel : logFuncParams, scope : scopeHelper)
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
    
    trace(texte : "<< Helper : daysBetweenDates >> Return : days = \(components.day!)", logLevel : logFuncReturn, scope : scopeHelper)
    return components.day!
}
