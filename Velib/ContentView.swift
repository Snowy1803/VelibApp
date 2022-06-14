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
            .background {
                BetterSheet(item: $selected) { velib in
                    LocationModal(velib: velib)
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

struct BetterSheet<Item, Content: View>: UIViewRepresentable {
    @Binding var item: Item?
    @ViewBuilder var content: (Item) -> Content
    
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let item = item else {
            uiView.window?.rootViewController?.dismiss(animated: true)
            return
        }
        let profile = UIHostingController(rootView: content(item))
        profile.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak uiView] _ in
            uiView?.window?.rootViewController?.dismiss(animated: true)
        })
        
        let nav = UINavigationController(rootViewController: profile)
        nav.navigationBar.standardAppearance.backgroundColor = .systemBackground
        nav.navigationBar.standardAppearance.shadowColor = .clear
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        uiView.window?.rootViewController?.dismiss(animated: true) // dismiss what's potentially currently shown
        uiView.window?.rootViewController?.present(nav, animated: true)
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
