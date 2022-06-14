//
//  ContentView.swift
//  Velib
//
//  Created by Emil Pedersen on 14/06/2022.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var fetcher: VelibFetcher
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.81521, longitude: 2.36319), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    @State var error: Error? = nil
    
    var body: some View {
        Map(
            coordinateRegion: $region,
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
        .ignoresSafeArea(.all)
        .onAppear {
            Task.detached {
                do {
                    try await fetcher.requestLocation()
                    if let coords = await fetcher.location.location?.coordinate {
                        Task { @MainActor in
                            region.center = coords
                        }
                        try await fetcher.fetch(around: coords)
                    }
                } catch let error {
                    print(error)
                    Task { @MainActor in
                        self.error = error
                    }
                }
            }
        }
        .errorAlert(error: $error)
    }
}

extension View {
    func errorAlert(error: Binding<Error?>) -> some View {
        self.alert(isPresented: .constant(error.wrappedValue != nil), error: error.wrappedValue as NSError?) {
            Button("OK") {
                error.wrappedValue = nil
            }
        }
    }
}

extension NSError: LocalizedError {
    public var errorDescription: String? {
        localizedDescription
    }
    
    public var failureReason: String? {
        localizedFailureReason
    }
    
    public var recoverySuggestion: String? {
        localizedRecoverySuggestion
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VelibFetcher())
    }
}
