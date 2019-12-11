//
//  Copyright © 2019 Hituzi Ando. All rights reserved.
//

import Foundation

struct User: Codable {

    private static let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    var name    = ""
    var country = ""
    var age     = 0

    func saveAsFirstUser() {
        if let data = try? JSONEncoder().encode(self) {
            try! data.write(to: URL(fileURLWithPath: Self.directory + "/user"), options: .atomic)
        }
    }

    static func firstUser() -> Self? {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: Self.directory + "/user")),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            return user
        }
        return nil
    }
}
