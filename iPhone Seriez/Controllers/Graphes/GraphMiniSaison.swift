//
//  GraphMiniSaison.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class GraphMiniSaison: UIView {
    
    var noteTrakt : Int = 0
    var noteTVdb : Int = 0
    var noteBetaSeries : Int = 0
    var noteMoviedb : Int = 0
    var noteIMdb : Int = 0
    
    var moyTrakt : Int = 0
    var moyTVdb : Int = 0
    var moyBetaSeries : Int = 0
    var moyMoviedb : Int = 0
    var moyIMdb : Int = 0
    
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
    
    
    func sendNotes(rateTrakt : Int, rateTVdb : Int, rateBetaSeries : Int, rateMoviedb : Int, rateIMdb : Int,
                   seasonsAverageTrakt : Int, seasonsAverageTVdb : Int, seasonsAverageBetaSeries : Int, seasonsAverageMoviedb : Int, seasonsAverageIMdb : Int)
    {
        noteTrakt = rateTrakt
        noteTVdb = rateTVdb
        noteBetaSeries = rateBetaSeries
        noteMoviedb = rateMoviedb
        noteIMdb = rateIMdb
        
        moyTrakt = seasonsAverageTrakt
        moyTVdb = seasonsAverageTVdb
        moyBetaSeries = seasonsAverageBetaSeries
        moyMoviedb = seasonsAverageMoviedb
        moyIMdb = seasonsAverageIMdb
    }
    
    func background()
    {
        let path : UIBezierPath = UIBezierPath()
        let longueurFleche : CGFloat = 3.0
        
        // Couleur des lignes
        colorAxis.setStroke()
        path.lineWidth = 0.5
        
        // Lignes horizontales
        path.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 2)))
        path.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2)))
        path.stroke()
        
        path.move(to: CGPoint(x: origineX + largeur - longueurFleche, y: origineY - (hauteur / 2) - longueurFleche))
        path.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2)))
        path.addLine(to: CGPoint(x: origineX + largeur - longueurFleche, y: origineY - (hauteur / 2) + longueurFleche))
        path.stroke()
        
        // Lignes verticales
        path.move(to: CGPoint(x: origineX + (largeur / 2), y: origineY))
        path.addLine(to: CGPoint(x: origineX + (largeur / 2), y: origineY - hauteur))
        path.stroke()
        
        path.move(to: CGPoint(x: origineX + (largeur / 2) - longueurFleche, y: origineY - hauteur + longueurFleche))
        path.addLine(to: CGPoint(x: origineX + (largeur / 2), y: origineY - hauteur))
        path.addLine(to: CGPoint(x: origineX + (largeur / 2) + longueurFleche, y: origineY - hauteur + longueurFleche))
        path.stroke()
    }
    
    
    func traceGraphePoints()
    {
        traceUnPoint(noteX: noteTVdb,           noteY: moyTVdb,        color: colorTVdb)
        traceUnPoint(noteX: noteTrakt,          noteY: moyTrakt,       color: colorTrakt)
        traceUnPoint(noteX: noteBetaSeries,     noteY: moyBetaSeries,  color: colorBetaSeries)
        traceUnPoint(noteX: noteMoviedb,        noteY: moyMoviedb,     color: colorMoviedb)
        traceUnPoint(noteX: noteIMdb,           noteY: moyIMdb,        color: colorIMDB)

    }
    
    
    func traceUnPoint(noteX: Int, noteY: Int, color: UIColor)
    {
        let diametre : CGFloat = 8.0

        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + (largeur * CGFloat(noteX) / 100),
                                        y: origineY - (hauteur * CGFloat(noteY) / 100)),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        
        path.stroke()
        path.fill()
    }
}


