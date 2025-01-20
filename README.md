# CryptoCoins App

The **CryptoCoins App** is a mobile application built with UIKit, designed to offer users a well-organized and interactive list of cryptocurrency coins. Featuring a clean and user-friendly interface, the app enables users to easily explore a variety of crypto coins.
## Screenshots

<div style="display: flex; gap: 10px;">
  <img src="https://github.com/janeshsutharios/JaneshCryptoCoinTask/blob/main/JaneshSutharCryptoDemoiOS/Screenshots/Dashboard.png" alt="CryptoCoinsList Screen" width="240" />
  <img src="https://github.com/janeshsutharios/JaneshCryptoCoinTask/blob/main/JaneshSutharCryptoDemoiOS/Screenshots/Filter.png" alt="Filter Coins by Status/Type View" width="240" />
</div>

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [Contact](#contact)

## Overview

The CryptoFinder App is a user-friendly cryptocurrency coin listing application built to provide users with an intuitive interface to explore and filter through a wide range of cryptocurrencies. With the ability to search and apply multiple filters, users can easily discover coins that match their criteria. The app is designed with modern UI principles and optimized performance, making it suitable for crypto enthusiasts and professionals.

## Features

1. **Crypto Coins List**:
   - Displays a comprehensive list of crypto coins.
   - Each coin view includes:
     - **Name**
     - **Symbol**
     - **Type**
   - Disabled view for coins that are not active.

2. **Filter Functionality**:
   - Users can apply multiple filters simultaneously:
     - Filter by `is_active`.
     - Filter by `type`.
     - Filter by `is_new`.

3. **Search Functionality**:
   - User can search for coins by `name` or `symbol`.

## Architecture

This project follows the **Clean Architecture - Model-View-ViewModel** architecture pattern, which helps keep the code modular, maintainable, and testable.

- **Presentation Layer**: Manages the user interface (UI) and handles user interactions.
  
- **Domain Layer**: Contains the core business logic and is independent of any framework or technology.
  
- **Data Layer**: Responsible for data management and access from various sources (network, local storage).

- **Core Layer**: Contains reusable utilities and application-wide resources.

- **Infrastructure Layer**: Provides foundational services like network communication and configuration.

## Usage

To use the CryptoFinder app, follow these steps:

1. **Launch the App**: 
   Open the CryptoFinder app on your device or simulator. You will be greeted with the home screen displaying the list of Crypto Coins.

2. **Filter Coins by Status/Type**: 
   Tap on the filter option to apply multiple filters at once and narrow down the list of coins.
   - Filter by Active Status: Filter coins to show only active or inactive coins.
   - Filter by Coin Type: Filter coins based on their type (e.g., "Token", "Coin").
   - Filter by New Crypto: Show only new cryptocurrencies.

3. **Search for a Coin**: 
   Tap on the search bar to search for a specific coin by:
   - Coin Name: Type the name of the coin (e.g., Bitcoin).
   - Coin Symbol: Type the symbol (e.g., BTC).


## Contributing

Contributions to the CryptoFinder app are welcome and encouraged! To contribute to the project, please follow these steps:

1. **Fork the Repository**: 
   Click the "Fork" button at the top right of the repository page to create your own copy of the project.

2. **Clone Your Fork**: 
   Clone your forked repository to your local machine using the command:

   ```bash
   git clone https://github.com/janeshsutharios/JaneshCryptoCoinTask

3. Create a New Branch: Navigate to the project directory and create a new branch for your feature or bug fix:

   ```bash
   git checkout -b feature/YourFeatureName

4. Make Your Changes: Implement your changes, ensuring that your code adheres to the project's coding standards. Be sure to write tests for any new features or functionality.

5. Commit Your Changes: Commit your changes with a clear and descriptive message:

   ```bash
   git commit -m "Add a new feature"

6. Push to Your Branch: Push your changes to your forked repository:

   ```bash
   git push origin feature/YourFeatureName

7. Open a Pull Request: Go to the original repository and open a pull request from your branch. Provide a detailed description of the changes you made and the reasons behind them.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 

## Acknowledgments

We would like to acknowledge the following resources and contributors that have made this project possible:

- **Clean Architecture**: Thank you to [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) for providing a comprehensive and reliable framework for building scalable and maintainable software.
- **UIKit**: Special thanks to [UIKit](https://developer.apple.com/documentation/uikit/) for building user interfaces on iOS. UIKit has been instrumental in creating beautiful and responsive user interfaces for this project.
- **Swift**: Thank you to [Swift](https://www.swift.org/documentation/), Apple’s powerful and intuitive programming language. Swift has been the backbone of this project, providing both performance and safety for writing high-quality code.

If you find this project useful, consider giving it a star on GitHub or contributing to its development!


## Contact

For inquiries or feedback, please reach out:

- **Email**: [janesh.stack@gmail.com](mailto:janesh.stack@gmail.com)
- **GitHub**: [JaneshSuthar](https://github.com/janeshsutharios)

Feel free to get in touch for any questions or suggestions regarding the Crypto app!

