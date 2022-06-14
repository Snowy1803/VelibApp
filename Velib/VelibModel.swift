//
//  VelibModel.swift
//  Velib
//
//  Created by Emil Pedersen on 14/06/2022.
//

import Foundation

struct VelibModel: Codable {
    var records: [VelibLocation]
}

struct VelibLocation: Identifiable, Codable {
    var fields: VelibFields
    var id: String { fields.stationcode }
}

struct VelibFields: Codable {
    var name: String
    var stationcode: String
    var numbikesavailable: Int
    var ebike: Int
    var mechanical: Int
    var numdocksavailable: Int
    var capacity: Int
    var nomArrondissementCommunes: String
    var dist: String
    var coordonneesGeo: [Double]
}
