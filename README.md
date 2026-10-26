# KneeGuard

**Personalized movement analysis from a simple phone video.**

KneeGuard is an iOS movement-analysis application that uses computer vision to analyze jump-landing mechanics and turn them into understandable, personalized feedback.

I created KneeGuard after seeing how seriously knee injuries can affect athletes and learning that movement patterns such as inward knee movement and left-right differences can play an important role in ACL injury risk.

Rather than requiring specialized motion-capture equipment, KneeGuard is designed to make basic movement analysis accessible through an ordinary phone video.

## What KneeGuard Does

A user records a short front-facing jump and uploads the video to KneeGuard.

The application then:

- identifies the athlete's landing
- tracks the hips, knees, and ankles
- measures inward knee movement
- compares left and right knee angles
- calculates a custom Movement Score
- explains what the measurements mean
- creates a targeted training plan
- saves assessments so users can track their progress over time

The analysis is personalized to the individual video. Knee movement is normalized relative to the user's body proportions, and the left and right sides are compared against each other rather than against another person's body.

## Movement Score

KneeGuard combines three measurements into a prototype Movement Score:

- left inward knee movement
- right inward knee movement
- left-right knee-angle asymmetry

Inward knee movement receives the greatest combined weighting, while asymmetry also contributes to the score.

The Movement Score is an experimental movement-quality metric that I designed for this project. It is not a clinically validated ACL-risk score.

## Personalized Training

KneeGuard does more than display measurements.

Based on the movement pattern it detects, the app changes its training focus and recommends exercises such as:

- jump-and-stick drills
- lateral step-downs
- single-leg squats
- controlled single-leg landings
- balance and left-right consistency exercises

Users can repeat assessments and compare their own results over time.

## Technology

### iOS Application

- Swift
- SwiftUI
- Xcode

### Analysis Backend

- Python
- FastAPI
- MediaPipe Pose Landmarker
- OpenCV
- NumPy
- Pandas

## How It Works

MediaPipe Pose Landmarker uses computer vision to identify body landmarks in each video frame.

KneeGuard's Python analysis then uses those landmarks to estimate the jump and landing sequence and calculate movement measurements from the hip, knee, and ankle positions.

The iPhone application communicates with the Python analysis backend through FastAPI.

## Running KneeGuard

### Backend

Create a Python virtual environment:

```bash
python3 -m venv .venv
```

Activate it on macOS/Linux:

```bash
source .venv/bin/activate
```

Install the required packages:

```bash
pip install -r requirements.txt
```

Start the FastAPI server:

```bash
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

### iOS App

Open the KneeGuard Xcode project.

If the backend is running locally on another computer, update the server address in `APIService.swift` to that computer's local IP address.

For example:

```text
http://YOUR-SERVER-IP:8000/analyze
```

The iPhone and computer must be able to communicate over the same network when using a local backend.

## Project Development

KneeGuard was developed and tested through repeated jump recordings using people with different heights, builds, and landing patterns.

Development included:

- improving automatic landing detection
- normalizing measurements for different body proportions
- designing the custom Movement Score
- connecting a Swift/SwiftUI application to a Python backend
- testing on both the Xcode simulator and a physical iPhone
- creating movement-specific training recommendations
- adding assessment history and progress tracking

## Important Disclaimer

KneeGuard is an experimental movement-feedback and educational tool.

It is **not a medical device, medical diagnosis, or clinically validated predictor of ACL injury**. A KneeGuard score should not be interpreted as a person's probability of sustaining an ACL tear.

Medical or injury-related concerns should be discussed with a qualified healthcare professional.

## Open Source

KneeGuard is open source under the MIT License.

Third-party libraries, models, and dependencies remain subject to their respective licenses.

## Author

Created for the 2026 Congressional App Challenge.