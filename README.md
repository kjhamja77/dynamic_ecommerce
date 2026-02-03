# Dynamic E-Commerce App

A modern, scalable Flutter e-commerce application built with Clean Architecture principles, featuring a dynamic content management system and comprehensive shopping experience.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with a clear separation of concerns across multiple layers:

### Core Module (`lib/core/`)
- **Constants**: App-wide constants and responsive design utilities
- **Widgets**: Reusable UI components used across features
- **Network**: HTTP client, interceptors, and network utilities
- **Dependency Injection**: GetIt service locator configuration
- **Errors**: Custom failure classes and error handling
- **Services**: Location services, analytics, currency formatting
- **Theme**: App-wide theming and dark/light mode support

### Features (`lib/features/`)
Each feature follows the same layered structure:

#### Domain Layer
- **Entities**: Core business objects
- **Use Cases**: Business logic and rules
- **Repositories**: Abstract interfaces for data access

#### Data Layer
- **Repositories**: Concrete implementations of repository interfaces
- **Data Sources**: Local and remote data providers
- **Models**: Data transfer objects and mappers

#### Presentation Layer
- **Pages**: Main screen widgets
- **Widgets**: Feature-specific UI components
- **BLoCs/Cubits**: State management
- **Models**: Presentation-specific data models

## 📁 Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── constants/                 # App constants
│   ├── widgets/                   # Reusable widgets
│   ├── network/                   # Network layer
│   ├── di/                        # Dependency injection
│   ├── errors/                    # Error handling
│   ├── services/                  # Core services
│   └── theme/                     # App theming
├── features/                      # Feature modules
│   ├── auth/                      # Authentication
│   ├── home/                      # Home screen with dynamic components
│   ├── catalog/                   # Product catalog
│   ├── search/                    # Search functionality
│   ├── filters/                   # Filter system
│   ├── product_details/           # Product details
│   ├── cart/                      # Shopping cart
│   ├── favorites/                 # Wishlist/Favorites
│   ├── checkout/                  # Checkout & Payments
│   ├── profile/                   # User profile
│   ├── addresses/                 # Address management
│   ├── orders/                    # Order management
│   └── settings/                  # App settings
└── main.dart                      # App entry point
```

## 🚀 Features

### ✅ Implemented
- **Authentication**: Login/Register with secure storage, biometric authentication, guest mode
- **Dynamic Home Screen**: API-driven components (banners, categories, products, special offers)
- **Catalog**: Dynamic product listing with advanced filters and sorting
- **Search**: Category-based search with subcategories and nested categories
- **Filters**: Comprehensive filtering system (price, category, brand, attributes)
- **Product Details**: Full product information with image gallery, variants, stock management
- **Shopping Cart**: Add/remove items, quantity management, persistent cart
- **Favorites/Wishlist**: Save favorite products with badge indicator
- **Checkout**: Multi-step checkout process with address selection
- **Payment Integration**: 
  - Al Qaseh payment gateway
  - Payment status handling with webhooks
  - Order placement and confirmation
- **User Profile**: User management, orders, addresses, settings
- **Settings**: Theme (light/dark/system), language (English/Arabic), notifications
- **Localization**: Full support for English and Arabic (RTL)
- **Location Services**: Location-based features with permission handling
- **Analytics**: Firebase Analytics integration with user control

### 🔄 Recent Updates
- Payment flow improvements with proper status handling
- Category image fallback icons
- Favorites and cart badge indicators in navigation
- Price formatting improvements
- Product variant selection with stock management
- Special offer cards redesign

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8+
- **State Management**: BLoC Pattern + Cubit
- **Architecture**: Clean Architecture
- **Dependency Injection**: GetIt
- **Network**: Dio with interceptors and authentication
- **Local Storage**: Hive, SharedPreferences, Secure Storage
- **UI**: Material Design 3, Google Fonts, Responsive Design
- **Images**: Cached Network Image with authentication, Photo View
- **Analytics**: Firebase Analytics
- **Payments**: Al Qaseh payment gateway integration

## 🎨 UI/UX Features

- **Responsive Design**: Adaptive layouts for all screen sizes
- **Dark/Light Theme**: Material 3 theming system with system preference support
- **Smooth Animations**: Page transitions and micro-interactions
- **Loading States**: Shimmer effects and skeleton screens
- **Error Handling**: User-friendly error messages and retry mechanisms
- **Accessibility**: Screen reader support and semantic labels
- **RTL Support**: Full right-to-left layout support for Arabic
- **Badge Indicators**: Cart and favorites count badges in navigation
- **Image Fallbacks**: Default icons for missing category images

## 🔧 Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/filesdna/dynamic-ecommerce.git
   cd dynamic-ecommerce
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Update `lib/core/constants/app_constants.dart` with your API base URL
   - Configure Firebase (if using analytics)
   - Set up payment gateway credentials

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Desktop (Windows, macOS, Linux)

## 🧪 Testing

- **Unit Tests**: Business logic and use cases
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user flows

## 📦 Key Dependencies

### Core Dependencies
- `flutter_bloc`: State management
- `get_it`: Dependency injection
- `dio`: HTTP client
- `google_fonts`: Typography
- `cached_network_image`: Image caching
- `equatable`: Value comparison

### Feature Dependencies
- `photo_view`: Image gallery
- `shimmer`: Loading effects
- `webview_flutter`: Payment webviews
- `permission_handler`: Location permissions
- `firebase_analytics`: Analytics tracking
- `flutter_secure_storage`: Secure storage
- `hive`: Local database

## 🏆 Best Practices

- **Clean Architecture**: Clear separation of concerns
- **SOLID Principles**: Single responsibility, dependency inversion
- **Error Handling**: Comprehensive failure handling with proper error states
- **Performance**: Lazy loading, caching, pagination, image optimization
- **Security**: Secure storage, input validation, authenticated requests
- **Testing**: High test coverage with TDD approach
- **Code Organization**: Feature-based modular structure
- **State Management**: Predictable state changes with BLoC pattern

## 🌐 Localization

The app supports multiple languages:
- **English** (LTR)
- **Arabic** (RTL)

All UI strings are externalized and can be easily extended to support additional languages.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the coding standards and architecture patterns
4. Add tests for new functionality
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC team for state management patterns
- Clean Architecture principles by Robert C. Martin
- The open-source community for excellent packages

## 📞 Support

For issues, questions, or contributions, please open an issue on the GitHub repository.
