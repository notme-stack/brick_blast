# Brick Blast UI & Theme Analysis

This document outlines the visual identity and theme implementation of Brick Blast, based on the codebase analysis.

## 1. Visual Identity & Theme
The game features a **Cyber / Space** aesthetic, characterized by deep dark backgrounds, neon accents, and glassmorphism effects.

### Color Palette
- **Backgrounds**: Deep slate/navy gradients to create a sense of depth or space.
  - **Main Gradient**: `0xFF1E293B` (Top) $\to$ `0xFF0F172A` (Bottom).
  - **Home Ambient**: `0xFF081533` $\to$ `0xFF040A1D`.
- **Primary Accents**:
  - **Cyan/Blue** (`0xFF38BDF8`): The core "player" color, used for Balls, Launcher, and Grid lines.
  - **Gold/Amber** (`0xFFFBBF24`): Represents value and danger. Used for **Coins** and **Boss Waves**.
- **Brick Colors**:
  - A tiered set of 8 distinct vibrant colors: Red, Orange, Green, Blue, Purple, Pink, Sky, Lime.
  - **Boss Bricks**: Glow with a Gold hue (`0xFFFBBF24`) and have a blur effect.

## 2. Styling Principles
The UI leans heavily into **Modern Arcade** and **Glassmorphism**:

- **Shapes**:
  - **Pill Shapes**: Buttons and stat containers use fully rounded corners (`borderRadius: 999`).
  - **Soft Edges**: Most containers have rounded corners (`borderRadius: 12-32`).
- **Depth & Effects**:
  - **Gradients**: Almost entirely replaces flat colors. Buttons, backgrounds, and even text containers use `LinearGradient`.
  - **Glassmorphism**: `BackdropFilter` with blur, combined with semi-transparent white/blue borders, creates "glass" panels.
  - **Shadows**: Soft, colored shadows (e.g., `BoxShadow(color: Color(0x664D5BE0), blurRadius: 30)`) lift elements off the background.
  - **Glows**: Projectiles and Boss Bricks use `MaskFilter.blur` to create neon glow effects.

## 3. Typography
- **Font Family**: Default Flutter font (likely Roboto/SF Pro), but heavily stylized.
- **Weights**: Dominant use of **Extra Bold (`w800`, `w900`)** for numbers, scores, and headings to match the arcade feel.
- **Letter Spacing**:
  - **Standard Text**: Slightly tracked out (`letterSpacing: 0.8`).
  - **Decorative Text**: Extremely tracked out (e.g., "SHOOTER" has `letterSpacing: 9.0`).

## 4. Key UI Components

### Home Screen
- **Logo**: A constructed "Diamond Mark" using rotated gradients.
- **Play Button**: Large, pill-shaped, with a distinct purple-to-blue gradient and strong drop shadow.
- **Stats**: Displayed in "Pills" at the top (Level, Coins, Best Score).

### Game Screen
- **HUD**: A floating, glass-like container at the top.
  - Displays Score (Prominent), Wave count, and Level.
  - Uses `Icons.settings` for the pause menu.
- **Shooter Board**:
  - **Trajectory**: Drawn as a dotted line or "Light Sabre" (solid neon line).
  - **danger Line**: A subtle transparent red line indicating the game-over threshold.
  - **Animations**: Custom `Ticker` drives the simulation loop for smooth 120Hz physics updates.

## 5. Implementation Notes
- **Custom Painting**: The main gameboard is drawn using `CustomPainter` (`_ShooterBoardPainter`) for performance and precise control over rendering.
- **Responsiveness**: The UI uses `LayoutBuilder` and custom scaling logic (`_HomeSizeClass`) to adapt to different screen aspect ratios (Compact vs. Tall).
