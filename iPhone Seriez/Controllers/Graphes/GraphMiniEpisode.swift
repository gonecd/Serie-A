//
//  GraphMiniEpisode.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 28/08/2021.
//  Copyright © 2021 Home. All rights reserved.
//

import UIKit

class GraphMiniEpisode: UIView {
    
    var noteTrakt : Int = 0
    var noteBetaSeries : Int = 0
    var noteIMdb : Int = 0
    
    var origineX : CGFloat = 0.0
    var origineY :CGFloat = 0.0
    var hauteur : CGFloat = 0.0
    var largeur : CGFloat = 0.0
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineX = 0.0
        origineY = self.frame.height
        hauteur  = self.frame.height + 1.0
        largeur  = self.frame.width
        
        // Drawing code here.
        self.background()
        self.traceGraphePoints()
    }
    
    
    func setEpisode(eps : Episode) {
        noteTrakt = eps.getFairRatingTrakt()
        noteBetaSeries = eps.getFairRatingBetaSeries()
        noteIMdb = eps.getFairRatingIMdb()
    }
    
    
    func background() {
        let path : UIBezierPath = UIBezierPath()
        let path2 : UIBezierPath = UIBezierPath()

        // Couleur des lignes
        colorAxis.setStroke()
        path.lineWidth = 0.5
        path2.lineWidth = 0.5

        // Cadre
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x: origineX + largeur, y: origineY))
        path.addLine(to: CGPoint(x: origineX + largeur, y: origineY-hauteur))
        path.addLine(to: CGPoint(x: origineX, y: origineY-hauteur))
        path.addLine(to: CGPoint(x: origineX, y: origineY))
        path.stroke()
        
        // Quadrillage
        path2.setLineDash([5.0,5.0], count: 2, phase: 5.0)

        path2.move(to: CGPoint(x: origineX + (largeur/4), y: origineY))
        path2.addLine(to: CGPoint(x: origineX + (largeur/4), y: origineY-hauteur))
        path2.stroke()

        path2.move(to: CGPoint(x: origineX + (largeur/2), y: origineY))
        path2.addLine(to: CGPoint(x: origineX + (largeur/2), y: origineY-hauteur))
        path2.stroke()

        path2.move(to: CGPoint(x: origineX + (3*largeur/4), y: origineY))
        path2.addLine(to: CGPoint(x: origineX + (3*largeur/4), y: origineY-hauteur))
        path2.stroke()
    }
    
    

    func traceGraphePoints() {
        traceUnPoint(noteX: noteTrakt,      color: colorTrakt)
        traceUnPoint(noteX: noteBetaSeries, color: colorBetaSeries)
        traceUnPoint(noteX: noteIMdb,       color: colorIMDB)
    }
    
    
    func traceUnPoint(noteX: Int, color: UIColor) {
        let diametre : CGFloat = 8.0

        if (noteX == 0) { return }

        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + (largeur * CGFloat(noteX) / 100),
                                        y: origineY - (hauteur / 2) ),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        
        path.stroke()
        path.fill()
    }

}
