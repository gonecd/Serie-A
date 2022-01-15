//
//  WidegtView.swift
//  Mon activitéExtension
//
//  Created by Cyril DELAMARE on 09/10/2021.
//  Copyright © 2021 Home. All rights reserved.
//

import Foundation
import SwiftUI


struct MonActiviteView : View {
    let model: MonActiviteData
    
    var body: some View {
        
        HStack(alignment: .center) {
            
            Text(" ")
                .font(.system(size: 12))
            
            Image(uiImage: model.posterImage)
                .resizable()
                .frame(width: 70, height: 108, alignment: .center)

            VStack(alignment: .leading, spacing: 8) {
                Text(model.data.serie)
                    .font(.system(size: 20, weight: .heavy))
                    .lineLimit(1)
                    .foregroundColor(.black)
                
                HStack() {
                    Text("Saison " + String(model.data.saison))
                        .font(.footnote)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("  👍🏼  " + String(Double(model.data.rateGlobal)/10) + "  ")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                        .background(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                
                HStack() {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("   "+model.data.channel+"   ")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        HStack() {
                            ZStack() {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 15, height: 15)
                                
                                PieSegment(start: .degrees(360.0*Double(model.data.nbWatched)/Double(model.data.nbEps)-90.0), end: .degrees(-90))
                                    .fill(Color.white)
                                    .frame(width: 13, height: 13)
                            }
                            
                            Text(String(model.data.nbWatched) + " éps vus sur " + String(model.data.nbEps))
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack() {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)

                        Group {
                            PieSegment(start: .zero, end: .degrees(59))
                                .fill(Color.white)
                                .frame(width: 49, height: 49)

                            PieSegment(start: .degrees(60), end: .degrees(119))
                                .fill(Color.white)
                                .frame(width: 49, height: 49)

                            PieSegment(start: .degrees(120), end: .degrees(179))
                                .fill(Color.white)
                                .frame(width: 49, height: 49)

                            PieSegment(start: .degrees(180), end: .degrees(239))
                                .fill(Color.white)
                                .frame(width: 49, height: 49)

                            PieSegment(start: .degrees(240), end: .degrees(299))
                                .fill(Color.white)
                                .frame(width: 49, height: 49)

                            PieSegment(start: .degrees(300), end: .degrees(359))
                                .fill(Color.white)
                                .frame(width: 49, height: 49)
                        }

                        Group {
                            PieSegment(start: .zero, end: .degrees(59))
                                .fill(Color.red.opacity(0.4))
                                .frame(width: CGFloat(50*model.data.rateTrakt/100), height: CGFloat(50*model.data.rateTrakt/100))
                            
                            PieSegment(start: .degrees(60), end: .degrees(119))
                                .fill(Color.green.opacity(0.4))
                                .frame(width: CGFloat(50*model.data.rateMovieDB/100), height: CGFloat(50*model.data.rateMovieDB/100))
                            
                            PieSegment(start: .degrees(120), end: .degrees(179))
                                .fill(Color.orange.opacity(0.4))
                                .frame(width: CGFloat(50*model.data.rateIMDB/100), height: CGFloat(50*model.data.rateIMDB/100))

                            PieSegment(start: .degrees(180), end: .degrees(239))
                                .fill(Color.teal.opacity(0.4))
                                .frame(width: CGFloat(50*model.data.rateTVmaze/100), height: CGFloat(50*model.data.rateTVmaze/100))
                            
                            PieSegment(start: .degrees(240), end: .degrees(299))
                                .fill(Color.purple.opacity(0.4))
                                .frame(width: CGFloat(50*model.data.rateRottenTomatoes/100), height: CGFloat(50*model.data.rateRottenTomatoes/100))
                            
                            PieSegment(start: .degrees(300), end: .degrees(359))
                                .fill(Color.blue.opacity(0.4))
                                .frame(width: CGFloat(50*model.data.rateBetaSeries/100), height: CGFloat(50*model.data.rateBetaSeries/100))
                        }
                    }
                    .frame(width: 60, height: 60, alignment: .center)
                }
            }
            Text(" ")
                .font(.system(size: 12))
        }
    }
}



struct PieSegment: Shape {
    var start: Angle
    var end: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.midX, startAngle: start, endAngle: end, clockwise: false)
        return path
    }
}

