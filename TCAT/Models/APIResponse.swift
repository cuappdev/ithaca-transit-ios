//
//  Response.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    var success: Bool
    var data: T
}
