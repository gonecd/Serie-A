//
//  GraphMiniSaison.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class GraphMiniSaison: UIView {
    
    var theSaison : Saison = Saison(serie:"", saison:0)
    var noteTrakt : Double = 0.0
    var noteTVdb : Double = 0.0
    var noteBetaSeries : Double = 0.0

    var moyTrakt : Double = 0.0
    var moyTVdb : Double = 0.0
    var moyBetaSeries : Double = 0.0

    var origineX : CGFloat = 0.0
    var origineY :CGFloat = 0.0
    var hauteur : CGFloat = 0.0
    var largeur : CGFloat = 0.0
    let bordure : CGFloat = 5.0
    
    // Correction des notes pour homogénéisation
    let correctionTVdb : Double = 7.664
    let correctionBetaSeries : Double = 8.558
    let correctionTrakt : Double = 7.941

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineX = bordure
        origineY = (self.frame.height - bordure)
        hauteur  = (self.frame.height - bordure - bordure)
        largeur  = (self.frame.width - origineX - bordure)

        // Drawing code here.
        self.background()
        self.traceGraphePoints()
    }
    
    
    func sendNotes(_ rateTrakt : Double, rateTVdb : Double, rateBetaSeries : Double,
                        averageTrakt : Double, averageTVdb : Double, averageBetaSeries : Double)
    {
        noteTrakt = rateTrakt
        noteTVdb = rateTVdb
        noteBetaSeries = rateBetaSeries
        
        moyTrakt = averageTrakt
        moyTVdb = averageTVdb
        moyBetaSeries = averageBetaSeries
    }
    
    func background()
    {
        let nbLignesQuadrillage : Int = 2
        
        // Couleur des lignes
        UIColor.darkGray.setStroke()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()
        
        // Quadrillage
        let pathLine : UIBezierPath = UIBezierPath()
        pathLine.setLineDash([5.0,5.0], count: 2, phase: 5.0)
        pathLine.lineWidth = 0.5
        for i:Int in 1 ..< nbLignesQuadrillage
        {
            // Lignes horizontales
            pathLine.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i) / CGFloat(nbLignesQuadrillage))))
            pathLine.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i) / CGFloat(nbLignesQuadrillage))))
            pathLine.stroke()
            
            // Lignes verticales
            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbLignesQuadrillage)), y: origineY))
            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbLignesQuadrillage)), y: origineY - hauteur))
            pathLine.stroke()
        }
    }
    
    
    func traceGraphePoints()
    {
        traceUnPoint(noteTVdb * 8 / correctionTVdb, noteY: noteTVdb * 8 / moyTVdb, uneCouleur: UIColor.green)
        traceUnPoint(noteTrakt * 8 / correctionTrakt, noteY: noteTrakt * 8 / moyTrakt, uneCouleur: UIColor.red)
        traceUnPoint(noteBetaSeries * 8 / correctionBetaSeries, noteY: noteBetaSeries * 8 / moyBetaSeries, uneCouleur: UIColor.blue)
    }
    
    
    func traceUnPoint(_ noteX: Double, noteY: Double, uneCouleur: UIColor)
    {
        let diametre : CGFloat = 6.0
        
        if ((noteX < 7.0) || (noteX.isNaN) || (noteY < 7.0) || (noteY.isNaN)) { return }

        uneCouleur.setStroke()
        uneCouleur.setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + (largeur * CGFloat(noteX - 7))/2,
                                        y: origineY - (hauteur * CGFloat(noteY - 7))/2),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)

        path.stroke()
        path.fill()
    }
}


