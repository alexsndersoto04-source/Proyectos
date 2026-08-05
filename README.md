# Void Runner

A fast-paced cyberpunk platformer built with Godot Engine. Features unique mechanics like dash, wall-jump, double jump, and void dash (teleport).

## Game Features

- **20 Unique Levels** with progressive difficulty
- **Multiple Movement Abilities:**
  - Dash - Quick horizontal movement
  - Wall Jump - Jump off walls
  - Double Jump - Jump again in mid-air
  - Void Dash - Short-range teleport
- **Power-ups:** Shield, health, collectibles
- **Enemy AI:** Multiple enemy types with different behaviors
- **High Score System** with persistent saves
- **Level Select** to replay completed levels

## Controls

| Action | Keyboard | Mobile |
|--------|----------|--------|
| Move | A/D or Arrow Keys | Virtual Joystick |
| Jump | Space or W | Jump Button |
| Dash | J or Shift | Dash Button |
| Void Dash | K or Ctrl | Void Button |
| Pause | Escape or P | Pause Button |

## Building

### Prerequisites

- Godot Engine 4.2+
- Android SDK (for Android builds)
- JDK 17 (for Android builds)

### Android Build

1. Open the project in Godot
2. Install Android export templates
3. Configure Android SDK path
4. Export to Android

### Automated Builds with GitHub Actions

This project uses GitHub Actions to automatically build APKs. Every push to main triggers a build.

**To download the APK:**
1. Go to Actions tab in GitHub
2. Click on the latest workflow run
3. Download the APK artifact

## Project Structure

```
├── assets/          # Game assets (sprites, sounds, etc.)
├── effects/         # Visual effects
├── levels/          # Level data files
├── scenes/          # Game scenes
│   ├── MainMenu.tscn
│   ├── Level_01.tscn
│   └── ...
├── scripts/         # GDScript files
│   ├── Player.gd
│   ├── Enemy.gd
│   └── ...
├── ui/              # UI elements
├── project.godot    # Godot project file
└── icon.svg         # Game icon
```

## License

MIT License
