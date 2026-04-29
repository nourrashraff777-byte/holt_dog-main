# Holt Dog Design System

Welcome to the Holt Dog Design System. This document serves as the "Source of Truth" for all visual components, color palettes, and typography used in the app, derived directly from the official UI design PDF.

## 🎨 Color Palette

We use a semantic color system to ensure consistency and clarity.

| Category | Color | HEX | Usage |
| :--- | :--- | :--- | :--- |
| **Primary** | ![](https://via.placeholder.com/15/673AB7/000000?text=+) Purple | `#673AB7` | Main brand identity, Headers, Action Icons. |
| **Secondary** | ![](https://via.placeholder.com/15/D81B60/000000?text=+) Magenta | `#D81B60` | Primary action buttons (Next), Curved Header backgrounds. |
| **Success** | ![](https://via.placeholder.com/15/4CAF50/000000?text=+) Green | `#4CAF50` | "Rescued" status, Positive feedback. |
| **Error** | ![](https://via.placeholder.com/15/F44336/000000?text=+) Red | `#F44336` | "Needs Help" status, Emergency actions. |
| **Warning** | ![](https://via.placeholder.com/15/FF9800/000000?text=+) Orange | `#FF9800` | "Under Care" status. |

## Typography

We use **Inter** as our primary font family for its readability and modern feel.

- **HeadlineLarge**: 32pt, Bold (Screen titles)
- **HeadlineMedium**: 24pt, Bold (Section titles)
- **BodyLarge**: 18pt, Regular (Primary content)
- **BodyMedium**: 16pt, Regular (Standard text)
- **BodySmall**: 14pt, Regular (Subtext, captions)

## Layout & Components

### Spacing Scale
- `spaceS`: 8pt
- `spaceM`: 16pt
- `spaceL`: 24pt (Standard Screen Padding)
- `spaceXL`: 32pt

### Border Radius
- `radiusM` (12pt): Standard Cards.
- `radiusL` (20pt): Text Input fields.
- `radiusXL` (30pt): Primary Buttons.
- `radiusFull` (100pt): Specialized curved components.

## How to use in Code

> [!TIP]
> Always use the centralized constants and the theme! This makes the app easy to change in the future.

```dart
// Colors
color: AppColors.primary

// Styles
padding: EdgeInsets.all(AppStyles.spaceM)
borderRadius: BorderRadius.circular(AppStyles.radiusL)

// Typography
style: Theme.of(context).textTheme.headlineLarge
```
