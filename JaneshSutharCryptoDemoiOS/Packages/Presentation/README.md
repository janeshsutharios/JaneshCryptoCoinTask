#  About Presentation Layer
Presentation Layer contains UI (UIViewControllers or SwiftUI Views). Views are coordinated by ViewModels (Presenters) which execute one or many Use Cases. Presentation Layer depends only on the Domain Layer.



Presentation Layer contains ViewModels with items that are observed from the View. ViewModel does not import UIKit. Because keeping the ViewModel clean from any UI frameworks like UIKit, SwiftUI or WatchKit will allow for easy reuse and refactor. For example in future the Views refactor from UIKit to SwiftUI will be much easier, because the ViewModel will not need to change.
