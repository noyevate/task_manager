# Flutter Practical Coding Test

A robust, animated, and offline-first Task Management application built with Flutter. This project demonstrates clean architecture, reactive state management with BLoC, and persistent local storage using Hive.

## 📱 Features Implemented

### 1. UI/UX & Animations
* **Custom Checkbox Animation:** An animated, interactive completion state for tasks.
* **Hero Animations:** Seamless visual transitions connecting list items to the detail screen.
* **List Operations:** Smooth entry and exit animations for adding and deleting tasks.

### 2. Theming (Dark Mode)
* **Theme Toggle:** Instant switching between Light and Dark themes.
* **Persistence:** User theme preference is saved locally and restored upon app restart.
* **Smooth Transitions:** Visual cross-fade effects when changing themes to reduce eye strain.

### 3. Form Validation
* **Real-time Validation:** Ensures task titles meet requirements (Required, Min 3 chars).
* **Reactive UI:** The "Save" button remains disabled until the form state is valid.
* **Error Feedback:** Clear, inline error messages guide the user.

---

## 🛠 Tech Stack & Packages

* **Framework:** Flutter (SDK)
* **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc) & [equatable](https://pub.dev/packages/equatable)
    * *Reasoning:* BLoC provides a clear separation of business logic from UI, making the app testable and scalable.
* **Local Storage:** [hive](https://pub.dev/packages/hive) & [hive_flutter](https://pub.dev/packages/hive_flutter)
    * *Reasoning:* Chosen for its high performance, NoSQL structure, and ease of use compared to SQflite.
* **Utilities:**
    * `uuid`: Unique ID generation for entities.
    * `intl`: Date formatting.
    * `connectivity_plus`: Network state monitoring.
    * `http`: API readiness.
* **Testing:**
    * `bloc_test`: For testing state changes.
    * `mocktail`: For mocking dependencies and data sources.

---

## 🚀 How to Run the App

**Important Note:** This project utilizes **Hive** with code generation. You must run the build runner to generate the TypeAdapters before the app will compile successfully.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/noyevate/task_manager.git
    cd task_manager
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate Hive Adapters (Required):**
    Run the following command to generate the `.g.dart` files for Hive and JSON serialization:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the App:**
    ```bash
    flutter run
    ```

5.  **Run Tests:**
    To verify the BLoC logic:
    ```bash
    flutter test
    ```

---

## 🏗 Architecture

I followed a **Layered Architecture** to ensure separation of concerns:

1.  **Presentation Layer:**

    * **Screens, Widgets:** purely for UI rendering.
    * **BLoCs:** Handle user input and state emission (Loading, Success, Error).
2.  **Domain/Data Layer:**
    * **Models:** Data structures (`Task` model).
    * **Repositories/Services:** Abstractions for Hive boxes to keep the BLoC clean of database implementation details.

---

## ⚖️ Trade-offs & Decisions

Due to the time constraints of this practical assessment, the following trade-offs were made:

1.  **Hive over SQLite:**
    * I chose Hive because it requires significantly less boilerplate code than SQLite, allowing me to focus more time on the requested custom animations and UI polish.
2.  **Testing Scope:**
    * I prioritized Unit Testing (using `bloc_test` and `mocktail`) to demonstrate logic verification. Integration and Widget tests were de-prioritized in favor of feature completeness.
3.  **In-Memory Lists:**
    * The app loads all Hive data into the list. For a production app with thousands of items, I would implement pagination or lazy loading.
4. **Search and Filter Functionality:**
    

---

## 🐛 Known Issues

* **Landscape Orientation:** The UI is optimized for Portrait mode. While functional, some layouts in Landscape mode on smaller devices might require scrolling.
* **Large Datasets:** Bulk deletion of tasks does not currently have a progress indicator, which might affect UX if deleting hundreds of items at once.