# Grocerio

A Flutter Grocery & Inventory Handler

## Overview

Started August 2025, Grocerio is a utility-focused Flutter app for managing grocery and inventory lists. Users can create, edit, and categorize items with quantity, unit, and optional images.

![Home Page](/assets/mdscreenshots/Home.png)
![List Page](/assets/mdscreenshots/GroceryList.png)

## Key Features

- Lists: Create grocery or stock lists, access from Home page, view item details.

- Item Editing: Inline editing for quantity and unit, swipe-to-edit mode, deletion with confirmation.

![Edit Mode](/assets/mdscreenshots/EditMode.png)

- Voice Input: Add items verbally (minor quirks remain).

- Scheduling: Grocery lists timestamped for weekly, biweekly, monthly, or one-time use.

- Preferences: Change font, text size, page order, theme mode, and color.

## UI Highlights

- Fixed-height, responsive widgets respecting text size

- Buttons and modals: Add Item, Complete Shopping, Voice Input

- Smooth scroll and consistent layouts across device sizes

## Technical Notes

- State Management: Mostly StatefulWidgets with isolated controllers and listeners.

- Storage: Isar for local storage; async functions for API calls.

- Image Handling: API images with fallback icons; keys protected via .gitignore.

- Real-Time Updates: Items save instantly and stream updates to UI.

## Known Limitations / Future Work

- Push notifications

- Item suggestion dropdown

- Automatic list date updates

- Voice input minor quirks

- Redirect to image sources not working

- Checkbox bugs

## Setup

- Clone repository

- Run flutter pub get

- Load special configs and API keys (see .gitignore for placeholders) [key.env.example](/key.env.example)

## Credits

- Images: [PEXELS API Image search](https://www.pexels.com/api/)
- AI Assistance: [Cursor](https://cursor.com/) , [ChatGPT](https://chatgpt.com/) - busy work and debugging help
