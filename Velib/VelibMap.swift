//
//  VelibMap.swift
//  Velib
//
//  Created by Emil Pedersen on 14/06/2022.
//

import Foundation
import SwiftUI
import MapKit

struct VelibMap: View {
    @EnvironmentObject var fetcher: VelibFetcher
    var coordinateRegion: Binding<MKCoordinateRegion>
    
    var body: some View {
        Map(
            coordinateRegion: coordinateRegion,
            showsUserLocation: true,
            annotationItems: fetcher.model.records) { velib in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: velib.fields.coordonneesGeo[0],
                    longitude: velib.fields.coordonneesGeo[1]), anchorPoint: CGPoint(x: 0.5, y: 0.7)) {
                        Circle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(velib.fields.numbikesavailable == 0 ? .red : velib.fields.numdocksavailable == 0 ? .purple : .green)
                            .overlay {
                                Image(systemName: "bicycle")
                            }
                    }
        }
    }
}
