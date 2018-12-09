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
    var noteTVmaze : Int = 0
    var noteMoviedb : Int = 0
    
    var origineX : CGFloat = 0.0
    var origineY : CGFloat = 0.0
    var hauteur : CGFloat = 0.0
    var largeur : CGFloat = 0.0
    let bordure : CGFloat = 5.0
    
    var centreX : CGFloat = 0.0
    var centreY : CGFloat = 0.0
    var rayon   : CGFloat = 0.0
    
    var grapheType : Int = 0

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineX = bordure
        origineY = (self.frame.height - bordure)
        hauteur  = (self.frame.height - bordure - bordure)
        largeur  = (self.frame.width - origineX - bordure)
        
        centreX = self.frame.height / 2
        centreY = self.frame.width / 2
        rayon = min(centreX, centreY) - bordure
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        // Drawing code here.
        if (grapheType == 0)
        {
            self.traceGrapheCercle()
            self.backgroundCercles()
        }
        else
        {
            self.traceGrapheBarre()
            self.backgroundBarres()
        }
    }
    
    
    func setType(type : Int)
    {
        grapheType = type
    }
    
    func sendNotes(rateTrakt : Int, rateTVdb : Int, rateBetaSeries : Int, rateMoviedb : Int, rateIMdb : Int, rateTVmaze : Int, rateRottenTomatoes : Int)
    {
        noteTrakt = rateTrakt
        noteTVdb = rateTVdb
        noteBetaSeries = rateBetaSeries
        noteIMDB = rateIMdb
        noteRottenTomatoes = rateRottenTomatoes
        noteTVmaze = rateTVmaze
        noteMoviedb = rateMoviedb
    }
    
    func backgroundCercles()
    {
        let nbSource : CGFloat = 7.0

        // Couleur des lignes
        colorAxis.setStroke()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 0.5
        path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                    radius: rayon,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.stroke()
        
        
        for i in 1...7 {
            path.move(to: CGPoint(x: centreX + rayon*cos(2 * .pi * CGFloat(i) / nbSource), y:centreY + rayon*sin(2 * .pi * CGFloat(i) / nbSource)))
            path.addLine(to: CGPoint(x: centreX, y: centreY))
            path.stroke()
        }
        
        // Quadrillage
        path.lineWidth = 0.5
        path.setLineDash([5.0,5.0], count: 2, phase: 5.0)
        path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                    radius: rayon / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.stroke()
    }
    

    func backgroundBarres()
    {
        // Couleur des lignes
        colorAxis.setStroke()
        
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
        traceUneBarre(noteTVdb,           color: colorTVdb,           offset: 1)
        traceUneBarre(noteTrakt,          color: colorTrakt,          offset: 2)
        traceUneBarre(noteBetaSeries,     color: colorBetaSeries,     offset: 3)
        traceUneBarre(noteIMDB,           color: colorIMDB,           offset: 4)
        traceUneBarre(noteMoviedb,        color: colorMoviedb,        offset: 5)
        traceUneBarre(noteTVmaze,         color: colorTVmaze,         offset: 6)
        traceUneBarre(noteRottenTomatoes, color: colorRottenTomatoes, offset: 7)
    }
    
    
    func traceUneBarre(_ noteX: Int, color: UIColor, offset: Int)
    {
        let nbSource : CGFloat = 7.0
        let col : CGFloat = largeur / (4 * nbSource)
        
        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        
        path.move(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / nbSource) + col,          y: origineY))
        path.addLine(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / nbSource) + col,       y: origineY - ( hauteur * CGFloat(noteX) / 100) ))
        path.addLine(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / nbSource) + (col * 3), y: origineY - ( hauteur * CGFloat(noteX) / 100) ))
        path.addLine(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / nbSource) + (col * 3), y: origineY))
        path.addLine(to: CGPoint(x: origineX + (CGFloat(offset - 1) * largeur / nbSource) + col,       y: origineY))
        
        path.stroke()
        path.fill()
    }
    
    
    func traceGrapheCercle()
    {
        traceUnCercle(noteTVdb,           color: colorTVdb,           offset: 1)
        traceUnCercle(noteTrakt,          color: colorTrakt,          offset: 2)
        traceUnCercle(noteBetaSeries,     color: colorBetaSeries,     offset: 3)
        traceUnCercle(noteIMDB,           color: colorIMDB,           offset: 4)
        traceUnCercle(noteMoviedb,        color: colorMoviedb,        offset: 5)
        traceUnCercle(noteTVmaze,         color: colorTVmaze,         offset: 6)
        traceUnCercle(noteRottenTomatoes, color: colorRottenTomatoes, offset: 7)
    }
    
    
    func traceUnCercle(_ noteX: Int, color: UIColor, offset: Int)
    {
        let nbSource : CGFloat = 7.0
        let taille : CGFloat = rayon * CGFloat(noteX) / 100
        
        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 0.5
        path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                    radius: taille,
                    startAngle: 2 * .pi * CGFloat(offset) / nbSource,
                    endAngle: 2 * .pi * CGFloat(offset - 1) / nbSource,
                    clockwise: false)
        path.stroke()
        
        path.move(to: CGPoint(x: centreX + taille*cos(2 * .pi * CGFloat(offset) / nbSource), y:centreY + taille*sin(2 * .pi * CGFloat(offset) / nbSource)))
        path.addLine(to: CGPoint(x: centreX, y: centreY))
        path.addLine(to: CGPoint(x: centreX + taille*cos(2 * .pi * CGFloat(offset - 1) / nbSource), y:centreY + taille*sin(2 * .pi * CGFloat(offset - 1) / nbSource)))
        path.stroke()
        
        path.fill()
    }
    

}



