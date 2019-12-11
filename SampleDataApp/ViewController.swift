//
//  Copyright © 2019 Hituzi Ando. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView:     UITextView!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var cleanButton:  UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("SampleData Directory Path: \(SampleData.dataDirectory)")

        if let json = SampleData.default.import(dataOfFile: "user.json") {
            print(json)
        }

        if let user = SampleData.default.import(dataOfFile: "user.json", ofClass: User.self, once: true) {
            user.saveAsFirstUser()
        }

        if let user = User.firstUser() {
            textView.text = """
                            User:
                                name: \(user.name)
                                country: \(user.country)
                                age: \(user.age)
                            """
        }
    }

    @IBAction func exportButtonClicked(_ sender: Any) {
        let user = User(name: "Hanako", country: "Japan", age: 25)
        SampleData.default.export(data: user, to: "user.json")
    }

    @IBAction func cleanButtonClicked(_ sender: Any) {
        SampleData.default.clean()
    }
}
