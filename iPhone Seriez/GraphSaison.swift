//
//  GraphSaison.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class GraphSaison: UIView {
    
    var selectTrakt: Int = 1
    var selectTVdb:  Int = 1
    var selectBetaSeries: Int = 1
    
    var theSaison : Saison = Saison(serie:"", saison:0)

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true

        // Drawing code here.
        self.background()
        self.traceGraphePoints()
    }
    
    
    func sendSaison(_ uneSaison: Saison)
    {
        theSaison = uneSaison
    }
    
    func background()
    {
        let origineX : CGFloat = 30.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        let largeur : CGFloat = (self.frame.width - origineX - 10.0)
        let textAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.white]
        let nbEpisodes : Int = theSaison.episodes.count
        
        // Lignes
        UIColor.white.setStroke()

        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()
        
        // Lignes achurées horizontales
        for i:Int in 1 ..< 4
        {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i)/4)))
            pathLine.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i)/4)))
            
            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }
        
        // Légende en Y
        for i:Int in 0 ..< 5
        {
            let episode : NSString = String(6+i) as NSString
            episode.draw(in: CGRect(x: 10, y: origineY - (hauteur * CGFloat(i)/4), width: 20, height: 10), withAttributes: textAttributes)
        }
        
        // Coches verticales
        for i:Int in 0 ..< nbEpisodes
        {
            let saison : NSString = String(i+1) as NSString
            saison.draw(in: CGRect(x: origineX - 5.0 + (largeur * (CGFloat(i)+0.5) / CGFloat(nbEpisodes)), y: self.frame.height - 25, width: 15, height: 12), withAttributes: textAttributes)
        }
        
        if (nbEpisodes < 1) { return }
        
        // Lignes hachurées verticale
        for i:Int in 1 ..< nbEpisodes
        {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbEpisodes)), y: origineY))
            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbEpisodes)), y: origineY - hauteur))
            
            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }
    }
    
    
    func traceGraphePoints()
    {
        
        let nbEpisodes : Int = theSaison.episodes.count
        let origineX : CGFloat = 30.0
        let largeur : CGFloat = (self.frame.width - origineX - 10.0)
        
        for i:Int in 0 ..< nbEpisodes
        {
            let offset : CGFloat = (largeur * (CGFloat(i)+0.5) / CGFloat(nbEpisodes))
            
            if (selectTVdb == 1) { traceUnPoint(theSaison.episodes[i].ratingTVdb, uneCouleur: UIColor.green, offsetEpisode: offset, offsetSource: 2) }
            if (selectTrakt == 1) { traceUnPoint(theSaison.episodes[i].ratingTrakt, uneCouleur: UIColor.red, offsetEpisode: offset, offsetSource: 5) }
            if (selectBetaSeries == 1) { traceUnPoint(theSaison.episodes[i].ratingBetaSeries, uneCouleur: UIColor.blue, offsetEpisode: offset, offsetSource: 8) }
        }
    }
    
    
    func traceUnPoint(_ uneNote: Double, uneCouleur: UIColor, offsetEpisode: CGFloat, offsetSource: CGFloat)
    {
        let diametre : CGFloat = 4.0
        let origineX : CGFloat = 30.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        
        if (uneNote < 6.0) { return }
        
        uneCouleur.setStroke()
        uneCouleur.setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX - 5 + offsetEpisode + offsetSource, y: origineY - (hauteur * CGFloat(uneNote - 6))/4),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.stroke()
        path.fill()
    }
}

//
//
//
//import UIKit
//
//class GraphSaison: UIView {
//
//    var selectTrakt: Int = 1
//    var selectTVdb:  Int = 1
//    var selectBetaSeries: Int = 1
//
//    var theSaison : Saison = Saison(serie:"", saison:0)
//    var myPath : UIBezierPath = UIBezierPath()
//    var drawingLayer : CAShapeLayer = CAShapeLayer()
//
//    override func draw(_ dirtyRect: CGRect) {
//        super.draw(dirtyRect)
//
//        let gradient : CAGradientLayer = CAGradientLayer()
//        gradient.colors = [UIColor.blue.cgColor, UIColor.lightGray.cgColor]
//        gradient.startPoint = CGPoint(x: 0, y: 0)
//        gradient.endPoint = CGPoint(x: 1, y: 1)
//        gradient.frame = self.bounds
//        //gradient.opacity = 0.3
//
//        self.layer.cornerRadius = 10;
//        self.layer.masksToBounds = true
//
//        self.layer.insertSublayer(gradient, at: 0)
//
//        drawingLayer.frame = self.bounds
//        drawingLayer.fillColor = UIColor.clear.cgColor
//        drawingLayer.strokeColor = UIColor.red.cgColor
//        let origineX : CGFloat = 30.0
//        let origineY :CGFloat = self.frame.height - 30.0
//        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
//        let largeur : CGFloat = (self.frame.width - origineX - 10.0)
//
//        myPath.move(to: CGPoint(x: origineX + 10.0, y: origineY))
//        myPath.addLine(to: CGPoint(x:origineX + 10.0, y:origineY-hauteur))
//        myPath.addLine(to: CGPoint(x:origineX+largeur + 10.0, y:origineY-hauteur))
//        myPath.addLine(to: CGPoint(x:origineX+largeur + 10.0, y:origineY))
//        myPath.addLine(to: CGPoint(x:origineX + 10.0, y:origineY))
//        myPath.stroke()
//
//        drawingLayer.path = myPath.cgPath
//        self.layer.insertSublayer(drawingLayer, above: gradient)
//
//        //gradient.mask = drawingLayer
//
//
//        // Drawing code here.
//        self.background()
//        self.traceGraphePoints()
//    }
//
//
//    func sendSaison(_ uneSaison: Saison)
//    {
//        theSaison = uneSaison
//    }
//
//    func background()
//    {
//        let origineX : CGFloat = 30.0
//        let origineY :CGFloat = self.frame.height - 30.0
//        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
//        let largeur : CGFloat = (self.frame.width - origineX - 10.0)
//        let textAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.white]
//        let nbEpisodes : Int = theSaison.episodes.count
//
//        //UIColor.gray.setFill()
//        //self.layer.cornerRadius = 15
//        //self.layer.masksToBounds = true
//        //bounds.fill()
//
//        // Lignes
//        UIColor.red.setStroke()
//
//        myPath.move(to: CGPoint(x: origineX + 10.0, y: origineY))
//        myPath.addLine(to: CGPoint(x:origineX + 10.0, y:origineY-hauteur))
//        myPath.addLine(to: CGPoint(x:origineX+largeur + 10.0, y:origineY-hauteur))
//        myPath.addLine(to: CGPoint(x:origineX+largeur + 10.0, y:origineY))
//        myPath.addLine(to: CGPoint(x:origineX + 10.0, y:origineY))
//        myPath.stroke()
//
//        UIColor.white.setStroke()
//
//        // Cadre
//        let path : UIBezierPath = UIBezierPath()
//        path.move(to: CGPoint(x: origineX, y: origineY))
//        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
//        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
//        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
//        path.addLine(to: CGPoint(x:origineX, y:origineY))
//        path.stroke()
//
//        // Lignes achurées horizontales
//        for i:Int in 1 ..< 4
//        {
//            let pathLine : UIBezierPath = UIBezierPath()
//            pathLine.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i)/4)))
//            pathLine.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i)/4)))
//
//            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
//            pathLine.stroke()
//        }
//
//        // Légende en Y
//        for i:Int in 0 ..< 5
//        {
//            let episode : NSString = String(6+i) as NSString
//            episode.draw(in: CGRect(x: 10, y: origineY - (hauteur * CGFloat(i)/4), width: 20, height: 10), withAttributes: textAttributes)
//        }
//
//        // Coches verticales
//        for i:Int in 0 ..< nbEpisodes
//        {
//            let saison : NSString = String(i+1) as NSString
//            saison.draw(in: CGRect(x: origineX - 5.0 + (largeur * (CGFloat(i)+0.5) / CGFloat(nbEpisodes)), y: self.frame.height - 25, width: 15, height: 12), withAttributes: textAttributes)
//        }
//
//        if (nbEpisodes < 1) { return }
//
//        // Lignes hachurées verticale
//        for i:Int in 1 ..< nbEpisodes
//        {
//            let pathLine : UIBezierPath = UIBezierPath()
//            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbEpisodes)), y: origineY))
//            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbEpisodes)), y: origineY - hauteur))
//
//            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
//            pathLine.stroke()
//        }
//    }
//
//
//    func traceGraphePoints()
//    {
//
//        let nbEpisodes : Int = theSaison.episodes.count
//        let origineX : CGFloat = 30.0
//        let largeur : CGFloat = (self.frame.width - origineX - 10.0)
//
//        for i:Int in 0 ..< nbEpisodes
//        {
//            let offset : CGFloat = (largeur * (CGFloat(i)+0.5) / CGFloat(nbEpisodes))
//
//            if (selectTVdb == 1) { traceUnPoint(theSaison.episodes[i].ratingTVdb, uneCouleur: UIColor.green, offsetEpisode: offset, offsetSource: 2) }
//            if (selectTrakt == 1) { traceUnPoint(theSaison.episodes[i].ratingTrakt, uneCouleur: UIColor.red, offsetEpisode: offset, offsetSource: 5) }
//            if (selectBetaSeries == 1) { traceUnPoint(theSaison.episodes[i].ratingBetaSeries, uneCouleur: UIColor.blue, offsetEpisode: offset, offsetSource: 8) }
//        }
//    }
//
//
//    func traceUnPoint(_ uneNote: Double, uneCouleur: UIColor, offsetEpisode: CGFloat, offsetSource: CGFloat)
//    {
//        let diametre : CGFloat = 4.0
//        let origineX : CGFloat = 30.0
//        let origineY :CGFloat = self.frame.height - 30.0
//        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
//
//        if (uneNote < 6.0) { return }
//
//        uneCouleur.setStroke()
//        uneCouleur.setFill()
//
//        let path : UIBezierPath = UIBezierPath()
//        path.addArc(withCenter: CGPoint(x: origineX - 5 + offsetEpisode + offsetSource, y: origineY - (hauteur * CGFloat(uneNote - 6))/4),
//                    radius: diametre / 2,
//                    startAngle: 2 * .pi,
//                    endAngle: 0,
//                    clockwise: false)
//        path.stroke()
//        path.fill()
//    }
//}



