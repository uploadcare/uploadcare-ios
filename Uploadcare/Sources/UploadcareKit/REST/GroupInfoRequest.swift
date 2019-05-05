//
//  GroupInfoRequest.swift
//  Uploadcare
//
//  Created by Artem Loenko on 05/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

/**
 *  Requests group information from Uploadcare service.
 */
public final class GroupInfoRequest: RequestProtocol {

    struct Constants {
        static let groupIDKey: String = "group_id"
    }

    public var parameters: Dictionary<String, String>
    public var path: String = Configuration.FileGroup.infoPath
    public var payload: RequestPayloadProtocol?

    init(groupID: String) {
        self.parameters = [ Constants.groupIDKey : groupID ]
    }

}
