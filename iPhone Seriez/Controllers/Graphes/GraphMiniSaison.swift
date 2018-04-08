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
    var noteMoviedb : Int = 0
    var noteIMdb : Int = 0
    
    var moyTrakt : Double = 0.0
    var moyTVdb : Double = 0.0
    var moyBetaSeries : Double = 0.0
    var moyMoviedb : Double = 0.0
    var moyIMdb : Double = 0.0
    
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
    
    
    func sendNotes(_ rateTrakt : Int, rateTVdb : Int, rateBetaSeries : Int, rateMoviedb : Int, rateIMdb : Int,
                   seasonsAverageTrakt : Double, seasonsAverageTVdb : Double, seasonsAverageBetaSeries : Double, seasonsAverageMoviedb : Double, seasonsAverageIMdb : Double)
    {
        noteTrakt = rateTrakt
        noteTVdb = rateTVdb
        noteBetaSeries = rateBetaSeries
        noteMoviedb = rateMoviedb
        noteIMdb = rateIMdb
        
        if (seasonsAverageTrakt.isNaN) { moyTrakt = 80.0 }
        else { moyTrakt = seasonsAverageTrakt }
        
        if (seasonsAverageTVdb.isNaN) { moyTVdb = 80.0 }
        else { moyTVdb = seasonsAverageTVdb }
        
        if (seasonsAverageBetaSeries.isNaN) { moyBetaSeries = 80.0 }
        else { moyBetaSeries = seasonsAverageBetaSeries }
        
        if (seasonsAverageMoviedb.isNaN) { moyMoviedb = 80.0 }
        else { moyMoviedb = seasonsAverageMoviedb }
        
        if (seasonsAverageIMdb.isNaN) { moyIMdb = 80.0 }
        else { moyIMdb = seasonsAverageIMdb }
    }
    
    func background()
    {
        let path : UIBezierPath = UIBezierPath()
        let longueurFleche : CGFloat = 3.0
        
        // Couleur des lignes
        UIColor.white.setStroke()
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
        if (moyTVdb != 0.0)       { traceUnPoint(noteTVdb,       noteY: Int(Double(noteTVdb * 80) / moyTVdb),             color: colorTVdb) }
        if (moyTrakt != 0.0)      { traceUnPoint(noteTrakt,      noteY: Int(Double(noteTrakt * 80) / moyTrakt),           color: colorTrakt) }
        if (moyBetaSeries != 0.0) { traceUnPoint(noteBetaSeries, noteY: Int(Double(noteBetaSeries * 80) / moyBetaSeries), color: colorBetaSeries) }
        if (moyMoviedb != 0.0)    { traceUnPoint(noteMoviedb,    noteY: Int(Double(noteMoviedb * 80) / moyMoviedb),       color: colorMoviedb) }
        if (moyIMdb != 0.0)       { traceUnPoint(noteIMdb,       noteY: Int(Double(noteIMdb * 80) / moyIMdb),             color: colorIMDB) }
    }
    
    
    func traceUnPoint(_ noteX: Int, noteY: Int, color: UIColor)
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
        
        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
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


