//
//  GraphMiniSerie.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class GraphMiniSerie: UIView {
    
    var noteTrakt : Int = 0
    var noteTVdb : Int = 0
    var noteBetaSeries : Int = 0
    var noteIMDB : Int = 0
    var noteRottenTomatoes : Int = 0
    var noteMoviedb : Int = 0

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
        self.traceGrapheBarre()
    }
    
    
    func sendNotes(_ rateTrakt : Int, rateTVdb : Int, rateBetaSeries : Int)
    {
        noteTrakt = rateTrakt
        noteTVdb = rateTVdb
        noteBetaSeries = rateBetaSeries
        noteIMDB = 71
        noteRottenTomatoes = 71
        noteMoviedb = 71
    }
    
    func background()
    {
        // Couleur des lignes
        UIColor.white.setStroke()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 0.5
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()
        
        // Quadrillage
        let path2 : UIBezierPath = UIBezierPath()
        path2.lineWidth = 0.5
        path2.setLineDash([5.0,5.0], count: 2, phase: 5.0)
        path2.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 2)))
        path2.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2)))
        path2.stroke()
    }
    
    
    func traceGrapheBarre()
    {
        traceUneBarre(noteTVdb,             uneCouleur: colorTVdb,              offset: 1)
        traceUneBarre(noteTrakt,            uneCouleur: colorTrakt,             offset: 2)
        traceUneBarre(noteBetaSeries,       uneCouleur: colorBetaSeries,        offset: 3)
        traceUneBarre(noteIMDB,             uneCouleur: colorIMDB,              offset: 4)
        traceUneBarre(noteRottenTomatoes,   uneCouleur: colorRottenTomatoes,    offset: 5)
        traceUneBarre(noteMoviedb,          uneCouleur: colorMoviedb,           offset: 6)
    }
    
    
    func traceUneBarre(_ noteX: Int, uneCouleur: UIColor, offset: Int)
    {
        var value = noteX
        let col : CGFloat = largeur / 24
        
        if ( noteX == 0 ) { return }
        if ( noteX < 70 ) { value = 70 }
        if ( noteX > 90 ) { value = 90 }
        
        uneCouleur.setStroke()
        uneCouleur.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        
        path.move(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / 6) + col,
                              y: origineY))
        
        path.addLine(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / 6) + col,
                                 y: origineY - ( hauteur * CGFloat(value - 70) / 20) ))
        
        path.addLine(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / 6) + col + (largeur / 12),
                                 y: origineY - ( hauteur * CGFloat(value - 70) / 20) ))

        path.addLine(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / 6) + col + (largeur / 12),
                                 y: origineY))

        path.addLine(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / 6) + col,
                                 y: origineY))
        
        path.stroke()
        path.fill()
    }
}



