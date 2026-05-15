# Forensic DNA Dilution Calculator

A cross-platform mobile application designed to calculate DNA dilutions for common forensic STR kits. The app provides quick, accurate calculations to determine whether to use the DNA extract directly or if a dilution is required, specifying the exact volumes needed for the PCR reaction.

## Features

*   **GlobalFiler Kit:** Calculates dilutions based on a 1.0 ng/μL target concentration and 15 μL maximum input volume.
*   **Identifiler Plus Kit:** Calculates dilutions based on a 1.0 ng/μL target concentration and 10 μL maximum input volume.
*   **MiniFiler Kit:** Calculates dilutions based on a 0.5 ng/μL target concentration and 10 μL maximum input volume.
*   **DNA Concentration Input:** Enter the quantified DNA concentration in ng/μL.
*   **Clear Recommendations:**
    *   <span style="color:green">**Green:**</span> Use extract DIRECTLY (Optimal concentration).
    *   <span style="color:blue">**Blue:**</span> DILUTION required (Provides specific TE and DNA volumes for a 1:10 or custom dilution).
    *   <span style="color:red">**Red:**</span> Use extract DIRECTLY (Low concentration, add maximum allowable volume).
*   **Modern Interface:** Clean, white mobile-responsive design for easy use in the laboratory.

## Tech Stack

*   **Framework:** Flutter
*   **Language:** Dart
*   **UI Components:** Material Design 3

## Setup and Run

1.  Ensure you have Flutter installed on your system.
2.  Clone this repository.
3.  Run `flutter pub get` to install dependencies.
4.  Run `flutter run` to launch the application on your preferred device or emulator.

## CouldAI

This app was generated with [CouldAI](https://could.ai), an AI app builder for cross-platform apps that turns prompts into real native iOS, Android, Web, and Desktop apps with autonomous AI agents that architect, build, test, deploy, and iterate production-ready applications.