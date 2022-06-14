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
    @State var selected: VelibLocation? = nil
    
    var body: some View {
        VelibMap(coordinateRegion: $region, selection: $selected)
            .ignoresSafeArea(.all)
            .overlay(alignment: .topLeading) {
                Button {
                    Task.detached {
                        do {
                            if let coords = await fetcher.location.location?.coordinate {
                                try await fetcher.fetch(around: coords)
                            }
                        } catch let error {
                            print(error)
                            Task { @MainActor in
                                self.error = error
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }.buttonStyle(.bordered)
                    .padding()
            }
            .sheet(item: $selected) { velib in
                NavigationView {
                    Form {
                        HStack {
                            Text("Vélos disponibles")
                            Spacer()
                            Text("\(velib.fields.numbikesavailable)")
                        }
                        HStack {
                            Text("Emplacements vides")
                            Spacer()
                            Text("\(velib.fields.numdocksavailable)")
                        }
                        HStack {
                            Text("Capacité")
                            Spacer()
                            Text("\(velib.fields.capacity)")
                        }
                    }.navigationTitle(velib.fields.name)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
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
