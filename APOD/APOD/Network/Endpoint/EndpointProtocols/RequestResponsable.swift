//
//  RequestResponsable.swift
//  APOD
//
//  Created by 홍진표 on 11/12/24.
//

import Foundation

/// equal to `typealias RequestResponsable = Requestable & Responsable`
protocol RequestResponsable: Requestable, Responsable { }
