//
//  GraphEpisode.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class GraphEpisode: UIView {
    
    var theEpisode : Episode = Episode(serie: "", fichier: "", saison: 0, episode: 0)
    
    var origineX : CGFloat = 0.0
    var origineY : CGFloat = 0.0
    var hauteur  : CGFloat = 0.0
    var largeur  : CGFloat = 0.0
    var bordure  : CGFloat = 10.0
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineX = 10.0
        origineY = (self.frame.height - 25.0)
        hauteur  = (self.frame.height - 25.0 - bordure)
        largeur  = (self.frame.width - origineX - bordure)
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = true
        
        // Drawing code here.
        self.traceBarres()
        self.background()
    }
    
    
    func sendEpisode(_ unEpisode: Episode){
        theEpisode = unEpisode
    }
    
    
    func background()
    {
        let textAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: colorAxis]
        
        // Lignes
        colorAxis.setStroke()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()
        
        // Lignes achurées verticales
        for i:Int in 0 ..< 5
        {
            path.move(to: CGPoint(x: origineX + (largeur * CGFloat(i)/4), y: origineY))
            path.addLine(to: CGPoint(x: origineX  + (largeur * CGFloat(i)/4), y: origineY - hauteur))
            
            path.setLineDash([5.0,5.0], count: 2, phase: 5.0)
            path.stroke()
            
            let episode : NSString = String(i*25) as NSString
            episode.draw(in: CGRect(x: origineX + (largeur * CGFloat(i)/4) - 7.0,
                                    y: origineY + 5.0, width: 20, height: 10),
                         withAttributes: textAttributes)
        }
    }
    
    func traceBarres()
    {
        traceUneBarre(theEpisode.getFairRatingTVdb(),       color: colorTVdb,       offset: 5, image : #imageLiteral(resourceName: "thetvdb.png"))
        traceUneBarre(theEpisode.getFairRatingTrakt(),      color: colorTrakt,      offset: 4, image : #imageLiteral(resourceName: "trakt.ico"))
        traceUneBarre(theEpisode.getFairRatingBetaSeries(), color: colorBetaSeries, offset: 3, image : #imageLiteral(resourceName: "betaseries.png"))
        traceUneBarre(theEpisode.getFairRatingIMdb(),       color: colorIMDB,       offset: 2, image : #imageLiteral(resourceName: "imdb.ico"))
        traceUneBarre(theEpisode.getFairRatingMoviedb(),    color: colorMoviedb,    offset: 1, image : #imageLiteral(resourceName: "themoviedb.ico"))
    }
    
    func traceUneBarre(_ noteX: Int, color: UIColor, offset: Int, image : UIImage)
    {
        let nbSource : CGFloat = 5.0
        let col : CGFloat = hauteur / (4 * nbSource)

        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        
        path.move(to: CGPoint(x: origineX,
                              y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - col))
        
        path.addLine(to: CGPoint(x: origineX + ( largeur * CGFloat(noteX) / 100),
                                 y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - col))
        
        path.addLine(to: CGPoint(x: origineX + ( largeur * CGFloat(noteX) / 100),
                                 y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - (3 * col)))
        
        path.addLine(to: CGPoint(x: origineX,
                                 y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - (3 * col)))
        
        path.addLine(to: CGPoint(x: origineX,
                                 y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - col))
        
        path.stroke()
        path.fill()
        
        image.draw(in: CGRect(x: origineX + ( largeur * CGFloat(noteX) / 100) - 12.0,
                              y:  origineY - (CGFloat(offset - 1) * hauteur / nbSource) - (3 * col) - 4.0,
                              width: 24.0, height: 24.0))
        
    }
}


