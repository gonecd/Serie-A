//
//  GraphEpisode.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class GraphEpisode: UIView {
    
    var selectTrakt: Int = 1
    var selectTVdb:  Int = 1
    var selectBetaSeries: Int = 1
    
    var theEpisode : Episode = Episode(serie: "", fichier: "", saison: 0, episode: 0)
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        self.background()
        self.traceGrapheCircles()
    }
    
    
    func sendEpisode(_ unEpisode: Episode){
    
        theEpisode = unEpisode
    }
    
    
    func background()
    {
        let ratingTrakt : CGFloat = 7.663
        let ratingBetaSeries : CGFloat = 8.558
        let ratingTVdb : CGFloat = 7.941

        let hauteur : CGFloat = self.frame.height
        let largeur : CGFloat = self.frame.width
        let grandRayon : CGFloat = (largeur - 40.0) / 6
        let textAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        // Colors
        //UIColor.gray.setFill()
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true

        UIColor.white.setStroke()

        // Graphe Circles
        for i:Int in 0 ..< 3
        {
            for j:Int in 0 ..< 4
            {
                let path : UIBezierPath = UIBezierPath()
                let locRayon : CGFloat = grandRayon * (1.0 - (CGFloat(j) / 4))
                path.addArc(withCenter: CGPoint(x: CGFloat(10.0) + grandRayon + CGFloat(i)*(10.0 + 2*grandRayon), y: hauteur / 2),
                            radius: locRayon,
                            startAngle: 2 * .pi, endAngle: 0, clockwise: false)
                path.stroke()
                
                let legende : NSString = String(10 - j) as NSString
                legende.draw(in: CGRect(x: CGFloat(10.0) + grandRayon + CGFloat(i)*(10.0 + 2*grandRayon), y: locRayon + (hauteur / 2),
                                        width: 20, height: 10), withAttributes: textAttributes)
            }
        }

        UIColor.yellow.setStroke()
        var refPath : UIBezierPath

        // On place les logos
        #imageLiteral(resourceName: "trakt.ico").draw(in: CGRect(x: CGFloat(10.0) + grandRayon - 12.0, y:  10.0, width: 24.0, height: 24.0))
        refPath = UIBezierPath()
        refPath.addArc(withCenter: CGPoint(x: CGFloat(10.0) + grandRayon, y: hauteur / 2),
                    radius: grandRayon * (1.0 - (CGFloat(10.0 - ratingTrakt) / 4)),
                    startAngle: 2 * .pi, endAngle: 0, clockwise: false)
        refPath.setLineDash([5.0,5.0], count: 2, phase: 2.0)
        refPath.lineWidth = 2.0
        refPath.stroke()
        
        #imageLiteral(resourceName: "thetvdb.png").draw(in: CGRect(x: CGFloat(20.0) + 3*grandRayon - 12.0, y:  10.0, width: 24.0, height: 24.0))
        refPath = UIBezierPath()
        refPath.addArc(withCenter: CGPoint(x: CGFloat(20.0) + 3*grandRayon, y: hauteur / 2),
                       radius: grandRayon * (1.0 - (CGFloat(10.0 - ratingTVdb) / 4)),
                       startAngle: 2 * .pi, endAngle: 0, clockwise: false)
        refPath.setLineDash([5.0,5.0], count: 2, phase: 2.0)
        refPath.lineWidth = 2.0
        refPath.stroke()
        
        #imageLiteral(resourceName: "betaseries.png").draw(in: CGRect(x: CGFloat(30.0) + 5*grandRayon - 12.0, y:  10.0, width: 24.0, height: 24.0))
        refPath = UIBezierPath()
        refPath.addArc(withCenter: CGPoint(x: CGFloat(30.0) + 5*grandRayon, y: hauteur / 2),
                       radius: grandRayon * (1.0 - (CGFloat(10.0 - ratingBetaSeries) / 4)),
                       startAngle: 2 * .pi, endAngle: 0, clockwise: false)
        refPath.setLineDash([5.0,5.0], count: 2, phase: 2.0)
        refPath.lineWidth = 2.0
        refPath.stroke()
    }
    
    func traceGrapheCircles()
    {
        let hauteur : CGFloat = self.frame.height
        let largeur : CGFloat = self.frame.width
        let grandRayon : CGFloat = (largeur - 40.0) / 6

        UIColor.red.setStroke()
        UIColor.red.withAlphaComponent(0.25).setFill()

        let path : UIBezierPath = UIBezierPath()
        let locRayon : CGFloat = grandRayon * (1.0 - (CGFloat(10.0 - theEpisode.ratingTrakt) / 4))
        path.addArc(withCenter: CGPoint(x: CGFloat(10.0) + grandRayon + CGFloat(0)*(10.0 + 2*grandRayon), y: hauteur / 2),
                    radius: locRayon,
                    startAngle: 2 * .pi, endAngle: 0, clockwise: false)
        path.lineWidth = 2.0
        path.stroke()
        path.fill()
        
        UIColor.green.setStroke()
        UIColor.green.withAlphaComponent(0.25).setFill()
        let path2 : UIBezierPath = UIBezierPath()
        let locRayon2 : CGFloat = grandRayon * (1.0 - (CGFloat(10.0 - theEpisode.ratingTVdb) / 4))
        path2.addArc(withCenter: CGPoint(x: CGFloat(10.0) + grandRayon + CGFloat(1)*(10.0 + 2*grandRayon), y: hauteur / 2),
                    radius: locRayon2,
                    startAngle: 2 * .pi, endAngle: 0, clockwise: false)
        path2.lineWidth = 2.0
        path2.stroke()
        path2.fill()

        UIColor.blue.setStroke()
        UIColor.blue.withAlphaComponent(0.25).setFill()
        let path3 : UIBezierPath = UIBezierPath()
        let locRayon3 : CGFloat = grandRayon * (1.0 - (CGFloat(10.0 - theEpisode.ratingBetaSeries) / 4))
        path3.addArc(withCenter: CGPoint(x: CGFloat(10.0) + grandRayon + CGFloat(2)*(10.0 + 2*grandRayon), y: hauteur / 2),
                    radius: locRayon3,
                    startAngle: 2 * .pi, endAngle: 0, clockwise: false)
        path3.lineWidth = 2.0
        path3.stroke()
        path3.fill()

    }
}


