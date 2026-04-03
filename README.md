# 🍕 Zomato Clone — Flutter

A pixel-perfect, frontend-only Zomato clone built with Flutter. The app faithfully recreates the Zomato experience — from the animated home feed and voice-powered search to interactive maps, a full cart & checkout flow, and a polished profile hub — all driven by local JSON data and open APIs with no backend required.

---

## ✨ Features

### 🏠 Home Screen
- Auto-playing **promotional banner carousel**
- **Sticky animated header** — the banner smoothly morphs into a search bar as you scroll
- Horizontally scrollable **food category chips** with a "See All" modal
- Quick-filter chips (Near & Fast, Gourmet, Top Rated) and an advanced **filter bottom sheet**
- Two-row **restaurant carousel** and a vertical **restaurant list**
- Floating **cart bar** that slides in/out based on scroll direction

### 🔍 Search Screen
- Full-screen search with **live filtered results**
- **Voice input** (speech-to-text) via microphone button
- Recent searches and category grid

### 🍽️ Restaurant Details Screen
- Image gallery with **page-view carousel**
- Dish menu with **Add / quantity controls**
- Rating badge, delivery time, and offer tags

### 🛒 Cart & Checkout
- Cart managed globally via a `CartManager` singleton (`ChangeNotifier`)
- Checkout screen with item list, quantity adjustments, delivery address, and total bill
- **Post-order Lottie success animation** that auto-navigates back to Home after 3.5 s

### 📍 Address Management
- List of saved addresses with add/edit support
- **Interactive map** (FlutterMap + OpenStreetMap) with a draggable pin
- **Debounced reverse geocoding** (800 ms) — address label updates as you drag the pin
- "Use current location" button via device GPS

### 👤 Profile
- Profile card with Zomato Gold member status and savings summary
- **Edit profile** form (name, email, mobile, DOB, anniversary, gender) — Save button activates only when a change is detected
- **Zomato Gold** benefits screen with coupon input
- Saved addresses, coupons, orders, and payment screens

### 📞 Audio Call
- Real-time **voice calling** powered by Zego UIKit — enter a user ID and ring them instantly

### 🎨 UI Polish
- **Shimmer loading** skeletons while data loads
- **Lottie animations** for the success screen
- **Responsive layout** — 1-column on mobile, 2–3 columns on tablet/desktop
- Google Fonts (Poppins) applied globally
- Light/dark-adaptive icon colors in the top bar

---

## 📱 Screens

| Screen | Description |
|--------|-------------|
| `HomeScreen` | Main feed with banner, categories, filters, and restaurant lists |
| `RestaurantDetailsScreen` | Restaurant info, dish menu, and add-to-cart |
| `SearchScreen` | Live search with voice input and category grid |
| `CheckoutScreen` | Order review, address, payment method, and place order |
| `SuccessScreen` | Lottie animation after order placement |
| `ProfileScreen` | User profile hub |
| `EditProfileScreen` | Editable profile form |
| `GoldScreen` | Zomato Gold membership benefits |
| `AddressScreen` | Saved address list |
| `AddEditAddressScreen` | Interactive map-based address picker |
| `LocationScreen` | Search-based location picker (Nominatim) |
| `AudioCallScreen` | Zego-powered voice call screen |
| `OrdersScreen` | Past orders list |
| `BookmarksDetailScreen` | Bookmarked restaurants |
| `CollectionsScreen` | Curated restaurant collections |
| `CouponsScreen` | Available coupons |
| `PaymentScreen` | Payment method management |

---

## 🧱 Tech Stack

| Category | Package |
|----------|---------|
| Framework | Flutter (Dart) |
| State Management | `provider` · `ValueNotifier` |
| Maps | `flutter_map` · `latlong2` |
| Geocoding / GPS | `geocoding` · `geolocator` |
| Networking | `http` |
| Animations | `lottie` · `shimmer` |
| Carousel | `carousel_slider` |
| Voice Input | `speech_to_text` |
| Audio Calls | `zego_uikit_prebuilt_call` |
| Fonts | `google_fonts` (Poppins) |
| Image Caching | `cached_network_image` |
| Navigation | `scroll_to_index` · `flutter_floating_bottom_bar` |
| Storage | `shared_preferences` |
| UI Helpers | `dotted_border` · `intl` · `permission_handler` |

---

## 🗂️ Project Structure

```
lib/
├── main.dart                   # App entry point, Zego SDK init
├── models/                     # Data models & state
│   ├── app_data.dart           # Restaurant & Dish models
│   ├── cart_manager.dart       # Cart ChangeNotifier singleton
│   ├── address_model.dart      # AddressModel + ValueNotifiers
│   ├── user_profile.dart       # UserProfile + ValueNotifier
│   └── filter_options.dart     # FilterOptions model
├── screens/                    # Full-page screens (17 screens)
├── widgets/                    # Reusable UI components
├── services/                   # Location & API services
└── utils/                      # Responsive layout helpers

assets/
├── data/
│   ├── restaurants.json        # Local restaurant & dish data
│   └── search_categories.json  # Search category chips
├── images/                     # App logo and banners
└── lottie/
    └── success.json            # Order success animation
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.11
- Dart ≥ 3.0

### Run the app

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

---

## 📡 External APIs Used

| Service | Purpose |
|---------|---------|
| [Nominatim (OpenStreetMap)](https://nominatim.openstreetmap.org/) | Address search & location suggestions |
| `geocoding` package | Reverse geocoding from GPS coordinates |
| `geolocator` package | Device GPS position |
| [Zego Cloud](https://www.zegocloud.com/) | Real-time audio calls |
| [Google Fonts CDN](https://fonts.google.com/) | Poppins typeface |

> **Note:** This is a frontend-only demo. Restaurant data is loaded from local JSON assets. No authentication or backend server is required.

---

## 📸 App Flow

```
App Opens
  └── Home Feed (banner carousel + restaurant list)
        ├── Scroll → sticky search bar animates in
        ├── Tap Search → voice/text search with live results
        ├── Tap Filter → bottom sheet with sort, time, rating, offers
        ├── Tap Restaurant → details + dish menu
        │     └── Add Dish → floating cart bar appears
        │           └── View Cart → Checkout → Place Order
        │                 └── Success animation → back to Home
        ├── Tap Address → saved addresses or pick on map
        └── Tap Avatar → Profile hub
              ├── Edit Profile
              ├── Zomato Gold
              ├── Addresses
              └── Audio Call
```

---

## 🙌 Credits

UI inspired by the [Zomato](https://www.zomato.com/) mobile app. Built for learning and demonstration purposes only.

