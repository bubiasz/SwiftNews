## SwiftNews
SwiftNews is an open-source iOS application designed to aggregate news articles, provide concise summaries, and tailor content based on individual user interests. Built using Python (FastAPI) for the backend and Swift for the iOS interface, SwiftNews offers a seamless experience to stay updated with what's happening around you.

## Technologies in use
On backend we used Python language and its libraries: FastAPI, SQLAlchemy, PostgreSQL, Selenium, newspaper3k.

And on frontend to develop an iOS app we decided to use: Swift, AVKit, Charts, SwiftUI and SwiftData.

## Team members
The project was a collaborative effort between two developers, both focusing on the idea and its execution. This allowed for a seamless blend of creativity and technical expertise, resulting in a successful outcome.
- Jakub Matysek - [bubiasz](https://github.com/bubiasz)
- Wojciech Batko - [wbatek](https://github.com/wbatek)

## The idea behind the app
We created this application because there was no similar one on the market. It weighs only 11MB yet encompasses all essential features. The app allows for personalized news delivery while prioritizing user privacy, as all user data remains stored on their device. Our motivation stemmed from the absence of such an app and our own need for it. This drove us to develop the application in the best way possible with a focus on efficiency and user privacy. We are also open to any suggestions from users and invite them to reach out to us for feedback and ideas. Additionally, we believe in empowering users by providing the option to host their own backend server at home for complete privacy. Soon, a Dockerfile will be added to the project to facilitate this process. Your active participation is key to shaping the app's future. Thank you for your support!

## Used design patterns

### [Singleton](SwiftNews/SwiftNews/APIManager.swift)
The `APIManager` class in `SwiftNews` serves as a Singleton to centralize and manage all API connections within the frontend of the iOS application. This design pattern ensures a single instance of the `APIManager` is created and shared across the application, providing a unified point of access to handle API interactions.

### [Observer](SwiftNews/SwiftNews/Views/ScannerView.swift)
The `QRScannerDelegate` class in `SwiftNews` serves as an observable delegate, implementing the Observer Pattern to handle QR code scanning within the iOS application. This design pattern allows multiple components to react to changes in the scanning process by subscribing to updates from the `QRScannerDelegate`. The ObservableObject protocol and the `@Published` property wrapper facilitate seamless communication between the `QRScannerDelegate` and observing components.

### [Strategy pattern](backend/cron/scrapers/strategy_scraper.py)
The `ParserStrategy` and `ScraperStrategy` interfaces work as the Strategy interfaces, being blueprints for specific implementations such as NewspaperParser, GoogleNewsScraper classes. They are providing concrete application that adhere to the defined strategies. This separation in code helps us improve code maintainability and allow us to create different approaches to scraping the data and parsing it in the fututre. Open for extension but closed for modification.

### [Abstract Factory](backend/cron/scraper.py)
The `ScraperFactory` and `ParserFactory` serve as an Abstract Factory to enable managing families of related classes. The abstraction provided by those classes allow us to create instances of related classes without specifying their concrete implementations inside the code. `ParserFactory` and `ScraperFactory` encapsulate the logic necessary to instantiate different versions of scrapers and parsers based on specific requirements and it enables us to change them easily without need to change anything in the code in the `config` file.

## Screen functionalities
### [SplashView.swift](SwiftNews/SwiftNews/Views/SplashView.swift)
SplashView is the initial screen that sets the tone for the app experience. Its primary functionality lies in seamlessly downloading essential data from the API, ensuring a smooth transition into the main application. This screen acts as a visual introduction, offering users a brief glimpse into the app's purpose and features. Through a captivating visual presentation, it sets the stage for a user-friendly journey by establishing a connection with the necessary data sources.

### [NewsView.swift](SwiftNews/SwiftNews/Views/NewsView.swift)
NewsView is the heart of the application, providing users with a comprehensive platform to engage with news content. Users can read, like, dislike, save, and share news articles. The inclusion of URLs to the news sources facilitates easy access to additional information. A strategically placed button invites users to transition seamlessly to the user zone, unlocking personalized features and enhancing the overall user experience.

### [ProfileView.swift](SwiftNews/SwiftNews/Views/ProfileView.swift)
ProfileView serves as the central hub for user customization. Users can fine-tune their news experience by adjusting preferences such as time settings and location. The screen further branches into multiple functionalities, offering buttons that lead to PreferencesView, SavedView, CodeView, and MessageView. This comprehensive user center ensures a tailored experience while providing easy access to various features and settings.

### [SavedView.swift](SwiftNews/SwiftNews/Views/SavedView.swift)
SavedView acts as a repository for previously saved news articles. Users can revisit and manage their collection of saved content, fostering a sense of organization and personalization. This screen enhances user convenience by offering a consolidated view of content that resonated with them, creating a seamless browsing experience.

### [PreferencesView.swift](SwiftNews/SwiftNews/Views/PreferencesView.swift)
PreferencesView is a dynamic screen that allows users to visualize and interact with their preferences. Through an interactive graph, users can gain insights into their preferred settings, providing a unique and engaging experience. The inclusion of a reset option ensures flexibility, allowing users to refine their preferences over time and adapt to evolving needs.

### [CodeView.swift](SwiftNews/SwiftNews/Views/CodeView.swift)
CodeView serves a dual purpose, displaying a QR code that facilitates data migration between devices and offering a quick transition into the scanner view. The QR code simplifies the process of importing data to a new device, streamlining user interactions and ensuring a hassle-free transition. The inclusion of a button to switch to the scanner view enhances the overall functionality and versatility of this screen.

### [ScannerView.swift](SwiftNews/SwiftNews/Views/ScannerView.swift)
ScannerView complements CodeView by providing users with a dedicated space to scan previously generated QR codes. This functionality enables users to effortlessly import data to a new device, ensuring a seamless continuation of their personalized experience. The integration of a scanning feature adds a layer of convenience, emphasizing the app's commitment to user-friendly interactions.

### [MessageView.swift](SwiftNews/SwiftNews/Views/MessageView.swift)
MessageView serves as a direct channel for users to connect with the developers. By offering a straightforward messaging interface, users can effortlessly send messages, providing valuable feedback or seeking assistance. This feature enhances the app's user support, fostering a collaborative environment and reinforcing the developers' commitment to user satisfaction.
