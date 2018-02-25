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
    var noteTrakt : Int = 0
    var noteTVdb : Int = 0
    var noteBetaSeries : Int = 0

    var moyTrakt : Double = 0.0
    var moyTVdb : Double = 0.0
    var moyBetaSeries : Double = 0.0

    var origineX : CGFloat = 0.0
    var origineY :CGFloat = 0.0
    var hauteur : CGFloat = 0.0
    var largeur : CGFloat = 0.0
    let bordure : CGFloat = 5.0
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineX = bordure
        origineY = (self.frame.height - bordure)
        hauteur  = (self.frame.height - bordure - bordure)
        largeur  = (self.frame.width - origineX - bordure)

        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = true
        
        // Drawing code here.
        self.background()
        self.traceGraphePoints()
    }
    
    
    func sendNotes(_ rateTrakt : Int, rateTVdb : Int, rateBetaSeries : Int,
                        seasonsAverageTrakt : Double, seasonsAverageTVdb : Double, seasonsAverageBetaSeries : Double)
    {
        noteTrakt = rateTrakt
        noteTVdb = rateTVdb
        noteBetaSeries = rateBetaSeries
        
        moyTrakt = seasonsAverageTrakt
        moyTVdb = seasonsAverageTVdb
        moyBetaSeries = seasonsAverageBetaSeries
    }
    
    func background()
    {
        let nbLignesQuadrillage : Int = 2
        
        // Couleur des lignes
        UIColor.white.setStroke()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()
        
        // Quadrillage
        path.setLineDash([5.0,5.0], count: 2, phase: 5.0)
        path.lineWidth = 0.5
        for i:Int in 1 ..< nbLignesQuadrillage
        {
            // Lignes horizontales
            path.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i) / CGFloat(nbLignesQuadrillage))))
            path.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i) / CGFloat(nbLignesQuadrillage))))
            path.stroke()
            
            // Lignes verticales
            path.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbLignesQuadrillage)), y: origineY))
            path.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbLignesQuadrillage)), y: origineY - hauteur))
            path.stroke()
        }
    }
    
    
    func traceGraphePoints()
    {
        traceUnPoint(noteTVdb, noteY: Int(Double(noteTVdb * 80) / moyTVdb), uneCouleur: colorTVdb)
        traceUnPoint(noteTrakt, noteY: Int(Double(noteTrakt * 80) / moyTrakt), uneCouleur: colorTrakt)
        traceUnPoint(noteBetaSeries, noteY: Int(Double(noteBetaSeries * 80) / moyBetaSeries), uneCouleur: colorBetaSeries)
    }
    
    
    func traceUnPoint(_ noteX: Int, noteY: Int, uneCouleur: UIColor)
    {
        let diametre : CGFloat = 8.0
        var xvalue = noteX
        var yvalue = noteY

        if ( noteX == 0 ) { return }
        if ( noteY == 0 ) { return }
        
        if ( noteX < 70 ) { xvalue = 70 }
        if ( noteY < 70 ) { yvalue = 70 }
        if ( noteX > 90 ) { xvalue = 90 }
        if ( noteY > 90 ) { yvalue = 90 }

        uneCouleur.setStroke()
        uneCouleur.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + (largeur * CGFloat(xvalue - 70))/20,
                                        y: origineY - (hauteur * CGFloat(yvalue - 70))/20),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)

        path.stroke()
        path.fill()
    }
}


