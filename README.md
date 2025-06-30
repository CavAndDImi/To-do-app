# 📝 Flutter To-Do App

A powerful and interactive Flutter-based To-Do application that allows you to manage daily and monthly tasks with categorized types (basic, counter, reminder, timer). It features persistent local storage using [Hive](https://pub.dev/packages/hive) and an intuitive swipe interface using [CarouselSlider](https://pub.dev/packages/carousel_slider).

---

## 📦 Features

- 📅 **Daily and Monthly Views**  
  Navigate and manage tasks for specific days or the entire month.

- ✅ **Task Status**  
  Mark tasks as complete/incomplete with a checkbox.

- ➕ **Task Creation**  
  Add new tasks with different types:  
  - `Normal` (basic)  
  - `Counter`  
  - `Reminder`  
  - `Timer`

- ❌ **Task Deletion**  
  Instantly remove tasks from the list.

- 🔄 **Date Navigation**  
  Move to the next or previous day using the arrow buttons in the AppBar.

- 💾 **Persistent Storage**  
  Automatically saves tasks using Hive — your data stays even after you close the app.

---

## 🛠️ Tech Stack

- **Flutter** (UI Toolkit)
- **Hive** (NoSQL local database)
- **Intl** (Date formatting)
- **Carousel Slider** (Horizontal page navigation)

---

## 📸 UI Overview

- Two views: Daily and Monthly (swipe between them)
- Dynamic AppBar that updates date and context
- List of tasks with checkbox and delete icon
- Input field with task type selector (popup menu)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Dart 3.x
- Run `flutter doctor` to verify setup

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/CavAndDImi/To-do-app.git
   cd to_do_app
