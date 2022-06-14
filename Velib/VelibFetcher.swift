//
//  VelibFetcher.swift
//  Velib
//
//  Created by Emil Pedersen on 14/06/2022.
//

import Foundation
import CoreLocation
import Combine

class VelibFetcher: NSObject, ObservableObject, URLSessionDelegate, CLLocationManagerDelegate {
    @Published var model: VelibModel = VelibModel(records: [])
    
    @Published var locationStatusChanged: Void = ()
    
    let location = CLLocationManager()
    
    func requestLocation() async throws {
        NSLog("Checking location access")
        switch location.authorizationStatus {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            return
        case .restricted, .denied:
            throw LocationAccessError.denied
        case .notDetermined:
            NSLog("Requesting location access")
            location.delegate = self
            location.requestWhenInUseAuthorization()
            var cancellable: AnyCancellable? = nil
            await withCheckedContinuation { cont in
                cancellable = $locationStatusChanged.sink {
                    if cancellable != nil {
                        cancellable = nil
                        cont.resume()
                    }
                }
            }
            return try await requestLocation()
        @unknown default:
            fatalError("unknown status")
        }
    }
    
    func fetch(around location: CLLocationCoordinate2D) async throws {
        let url = URL(string: "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&q=&sort=-dist&facet=name&facet=is_installed&facet=is_renting&facet=is_returning&facet=nom_arrondissement_communes&geofilter.distance=\(location.latitude)%2C\(location.longitude)%2C5000")!
        NSLog("Fetching velibs at %@", url.description)
        let (data, _) = try await URLSession.shared.data(from: url)
        NSLog("Got data back")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(VelibModel.self, from: data)
        NSLog("Found %d new velibs", resp.records.count)
        Task { @MainActor in
            model = resp
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatusChanged = ()
    }
}

enum LocationAccessError: Error {
    case denied
}
