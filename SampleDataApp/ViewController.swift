//
//  Copyright © 2019 Hituzi Ando. All rights reserved.
//

import UIKit

import Fakery

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

        if let user = SampleData.default.import(dataOfFile: "user.json", ofType: User.self, lock: true) {
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
        let faker = Faker()
        let user  = User(name: faker.name.name(),
                         country: faker.address.country(),
                         age: faker.number.randomInt(min: 20, max: 80))
        if SampleData.default.export(data: user, to: "user.json") {
            textView.text += "\nExported. Next, Restart app."
        }
    }

    @IBAction func cleanButtonClicked(_ sender: Any) {
        SampleData.default.clean()

        textView.text += "\nCleaned up."
    }
}
