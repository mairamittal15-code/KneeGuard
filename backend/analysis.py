from pathlib import Path
import base64

import cv2
import mediapipe as mp
import numpy as np
import pandas as pd


# ============================================================
# MEDIAPIPE LANDMARK IDS
# ============================================================

LEFT_HIP = 23
RIGHT_HIP = 24

LEFT_KNEE = 25
RIGHT_KNEE = 26

LEFT_ANKLE = 27
RIGHT_ANKLE = 28


# ============================================================
# MODEL
# ============================================================

MODEL_PATH = (
    Path(__file__).parent
    / "models"
    / "pose_landmarker_lite.task"
)


options = mp.tasks.vision.PoseLandmarkerOptions(

    base_options=
    mp.tasks.BaseOptions(
        model_asset_path=str(
            MODEL_PATH
        )
    ),

    running_mode=
    mp.tasks.vision.RunningMode.IMAGE,

    num_poses=1,

    min_pose_detection_confidence=0.5,

    min_pose_presence_confidence=0.5,

    min_tracking_confidence=0.5
)


pose_model = (
    mp.tasks.vision.PoseLandmarker
    .create_from_options(
        options
    )
)


# ============================================================
# BASIC GEOMETRY
# ============================================================

def calculate_angle(a, b, c):

    a = np.array(
        a,
        dtype=float
    )

    b = np.array(
        b,
        dtype=float
    )

    c = np.array(
        c,
        dtype=float
    )


    ba = a - b
    bc = c - b


    denominator = (
        np.linalg.norm(ba)
        *
        np.linalg.norm(bc)
    )


    if denominator == 0:
        return np.nan


    cosine = (
        np.dot(
            ba,
            bc
        )
        /
        denominator
    )


    cosine = np.clip(
        cosine,
        -1.0,
        1.0
    )


    return float(
        np.degrees(
            np.arccos(
                cosine
            )
        )
    )


def landmark_is_good(
    landmarks,
    index,
    threshold=0.55
):

    landmark = landmarks[index]


    visibility = getattr(
        landmark,
        "visibility",
        1.0
    )


    presence = getattr(
        landmark,
        "presence",
        1.0
    )


    return (
        visibility >= threshold
        and
        presence >= threshold
    )


def get_normalized_point(
    landmarks,
    index
):

    landmark = landmarks[index]


    return np.array(
        [
            landmark.x,
            landmark.y
        ],
        dtype=float
    )


def get_pixel_point(
    landmarks,
    index,
    width,
    height
):

    landmark = landmarks[index]


    return (
        int(
            landmark.x
            *
            width
        ),

        int(
            landmark.y
            *
            height
        )
    )


# ============================================================
# POSE DETECTION
# ============================================================

def detect_pose(frame):

    if frame is None:
        return None


    rgb = cv2.cvtColor(
        frame,
        cv2.COLOR_BGR2RGB
    )


    image = mp.Image(

        image_format=
        mp.ImageFormat.SRGB,

        data=
        np.ascontiguousarray(
            rgb
        )
    )


    result = pose_model.detect(
        image
    )


    if not result.pose_landmarks:
        return None


    return result.pose_landmarks[0]


# ============================================================
# ANALYZE ONE FRAME
# ============================================================

def analyze_landmarks(
    landmarks
):

    required = [

        LEFT_HIP,
        RIGHT_HIP,

        LEFT_KNEE,
        RIGHT_KNEE,

        LEFT_ANKLE,
        RIGHT_ANKLE
    ]


    if not all(
        landmark_is_good(
            landmarks,
            index
        )
        for index in required
    ):

        return None


    left_hip = get_normalized_point(
        landmarks,
        LEFT_HIP
    )


    right_hip = get_normalized_point(
        landmarks,
        RIGHT_HIP
    )


    left_knee = get_normalized_point(
        landmarks,
        LEFT_KNEE
    )


    right_knee = get_normalized_point(
        landmarks,
        RIGHT_KNEE
    )


    left_ankle = get_normalized_point(
        landmarks,
        LEFT_ANKLE
    )


    right_ankle = get_normalized_point(
        landmarks,
        RIGHT_ANKLE
    )


    left_angle = calculate_angle(
        left_hip,
        left_knee,
        left_ankle
    )


    right_angle = calculate_angle(
        right_hip,
        right_knee,
        right_ankle
    )


    hip_width = abs(
        left_hip[0]
        -
        right_hip[0]
    )


    if hip_width < 0.01:
        return None


    center_x = (

        left_hip[0]
        +
        right_hip[0]

    ) / 2


    # --------------------------------------------------------
    # INWARD KNEE POSITION
    #
    # Measures where the knee sits relative to the ankle
    # and body center, normalized by hip width.
    # --------------------------------------------------------

    left_inward = (

        abs(
            left_ankle[0]
            -
            center_x
        )

        -

        abs(
            left_knee[0]
            -
            center_x
        )

    ) / hip_width


    right_inward = (

        abs(
            right_ankle[0]
            -
            center_x
        )

        -

        abs(
            right_knee[0]
            -
            center_x
        )

    ) / hip_width


    hip_y = (

        left_hip[1]
        +
        right_hip[1]

    ) / 2


    ankle_y = (

        left_ankle[1]
        +
        right_ankle[1]

    ) / 2


    return {

        "left_angle":
        left_angle,

        "right_angle":
        right_angle,

        "left_inward":
        left_inward,

        "right_inward":
        right_inward,

        "asymmetry":
        abs(
            left_angle
            -
            right_angle
        ),

        "hip_y":
        hip_y,

        "ankle_y":
        ankle_y
    }


# ============================================================
# VIDEO ANALYSIS
# ============================================================

def analyze_video_frames(
    video_path
):

    video = cv2.VideoCapture(
        str(
            video_path
        )
    )


    fps = float(
        video.get(
            cv2.CAP_PROP_FPS
        )
    )


    total_frames = int(
        video.get(
            cv2.CAP_PROP_FRAME_COUNT
        )
    )


    if fps <= 0:
        fps = 30.0


    frame_number = 0

    pose_count = 0

    lower_body_count = 0

    results = []


    while True:

        success, frame = (
            video.read()
        )


        if not success:
            break


        landmarks = detect_pose(
            frame
        )


        if landmarks is not None:

            pose_count += 1


            metrics = analyze_landmarks(
                landmarks
            )


            if metrics is not None:

                lower_body_count += 1


                metrics[
                    "frame"
                ] = frame_number


                metrics[
                    "time"
                ] = (
                    frame_number
                    /
                    fps
                )


                results.append(
                    metrics
                )


        frame_number += 1


    video.release()


    pose_rate = (

        pose_count
        /
        total_frames
        *
        100

        if total_frames
        else 0
    )


    lower_body_rate = (

        lower_body_count
        /
        total_frames
        *
        100

        if total_frames
        else 0
    )


    return (

        pd.DataFrame(
            results
        ),

        fps,

        pose_rate,

        lower_body_rate
    )


# ============================================================
# DATA SMOOTHING
# ============================================================

def smooth_data(
    df
):

    columns = [

        "left_angle",
        "right_angle",

        "left_inward",
        "right_inward",

        "asymmetry",

        "hip_y",
        "ankle_y"
    ]


    for column in columns:

        df[
            column
            +
            "_smooth"
        ] = (

            df[
                column
            ]
            .rolling(
                5,
                center=True,
                min_periods=1
            )
            .median()
        )


    return df


# ============================================================
# FIND CONTIGUOUS TRACKING RUNS
# ============================================================

def get_contiguous_runs(
    df,
    max_gap=2
):

    frames = (

        df[
            "frame"
        ]
        .astype(
            int
        )
        .to_numpy()
    )


    if len(
        frames
    ) == 0:

        return []


    runs = []

    start = 0


    for i in range(
        1,
        len(
            frames
        )
    ):

        if (

            frames[i]
            -
            frames[
                i - 1
            ]

            >
            max_gap
        ):

            runs.append(
                (
                    start,
                    i
                )
            )


            start = i


    runs.append(
        (
            start,
            len(
                frames
            )
        )
    )


    return runs


# ============================================================
# FIND JUMP
# ============================================================

def find_jump_run(
    df,
    fps
):

    candidates = []


    for start, end in get_contiguous_runs(
        df
    ):

        run = (

            df.iloc[
                start:end
            ]

            .copy()
        )


        if len(
            run
        ) < 12:

            continue


        hips = (

            run[
                "hip_y_smooth"
            ]

            .to_numpy()
        )


        early_count = min(

            len(
                hips
            ) - 1,

            max(
                3,
                int(
                    0.25
                    *
                    fps
                )
            )
        )


        if early_count < 2:
            continue


        baseline = np.median(
            hips[
                :early_count
            ]
        )


        apex = int(
            np.argmin(
                hips
            )
        )


        signal = (

            baseline
            -
            hips[
                apex
            ]
        )


        if signal < 0.012:
            continue


        if apex >= (
            len(
                run
            )
            -
            4
        ):

            continue


        candidates.append(
            (

                signal
                *
                len(
                    run
                ),

                run,

                baseline,

                apex,

                signal
            )
        )


    if not candidates:
        return None


    candidates.sort(

        key=lambda item:
            item[0],

        reverse=True
    )


    return candidates[0]


# ============================================================
# DETECT TAKEOFF / APEX / LANDING
# ============================================================

def detect_landing(
    df,
    fps
):

    result = find_jump_run(
        df,
        fps
    )


    if result is None:
        return None


    (
        _,
        run,
        baseline_hip,
        apex_local,
        jump_signal

    ) = result


    run = run.reset_index(
        drop=True
    )


    hip = (

        run[
            "hip_y_smooth"
        ]

        .to_numpy()
    )


    ankle = (

        run[
            "ankle_y_smooth"
        ]

        .to_numpy()
    )


    frames = (

        run[
            "frame"
        ]

        .astype(
            int
        )

        .to_numpy()
    )


    # --------------------------------------------------------
    # TAKEOFF
    # --------------------------------------------------------

    takeoff_threshold = (

        baseline_hip

        -

        max(
            0.008,

            jump_signal
            *
            0.20
        )
    )


    takeoff = None


    for i in range(
        apex_local
        +
        1
    ):

        if (
            hip[i]
            <
            takeoff_threshold
        ):

            takeoff = i
            break


    if takeoff is None:
        return None


    # --------------------------------------------------------
    # LANDING SEARCH
    # --------------------------------------------------------

    search_start = (
        apex_local
        +
        1
    )


    search_end = min(

        len(
            run
        ),

        apex_local

        +

        max(
            6,
            int(
                fps
            )
        )
    )


    if (
        search_start
        >=
        search_end
    ):

        return None


    baseline_count = min(

        len(
            ankle
        ),

        max(
            3,
            int(
                0.25
                *
                fps
            )
        )
    )


    baseline_ankle = np.median(
        ankle[
            :baseline_count
        ]
    )


    hip_tolerance = max(

        0.012,

        jump_signal
        *
        0.35
    )


    ankle_signal = (

        baseline_ankle

        -

        np.min(
            ankle[
                takeoff:
                apex_local + 1
            ]
        )
    )


    ankle_tolerance = max(

        0.015,

        ankle_signal
        *
        0.40
    )


    hip_velocity = np.gradient(
        hip
    )


    ankle_velocity = np.gradient(
        ankle
    )


    landing = None


    for i in range(
        search_start,
        search_end
    ):

        hip_returned = (

            hip[i]

            >=

            baseline_hip
            -
            hip_tolerance
        )


        ankle_returned = (

            ankle[i]

            >=

            baseline_ankle
            -
            ankle_tolerance
        )


        stabilizing = (

            hip_velocity[i]

            >=

            -0.003
        )


        if (

            hip_returned
            and
            ankle_returned
            and
            stabilizing

        ):

            landing = i
            break


    # --------------------------------------------------------
    # FALLBACK
    # --------------------------------------------------------

    if landing is None:

        candidates = []


        for i in range(
            search_start,
            search_end
        ):

            score = (

                abs(
                    hip[i]
                    -
                    baseline_hip
                )

                +

                abs(
                    ankle[i]
                    -
                    baseline_ankle
                )

                +

                0.2
                *
                abs(
                    hip_velocity[i]
                )

                +

                0.1
                *
                abs(
                    ankle_velocity[i]
                )
            )


            candidates.append(
                (
                    score,
                    i
                )
            )


        if not candidates:
            return None


        landing = min(

            candidates,

            key=lambda item:
                item[0]

        )[1]


    return {

        "takeoff_frame":
        int(
            frames[
                takeoff
            ]
        ),

        "apex_frame":
        int(
            frames[
                apex_local
            ]
        ),

        "landing_frame":
        int(
            frames[
                landing
            ]
        )
    }


# ============================================================
# LANDING WINDOW
# ============================================================

def get_landing_window(
    df,
    landing_frame,
    fps
):

    before = int(
        0.20
        *
        fps
    )


    after = int(
        0.50
        *
        fps
    )


    result = df[

        (
            df[
                "frame"
            ]

            >=

            landing_frame
            -
            before
        )

        &

        (
            df[
                "frame"
            ]

            <=

            landing_frame
            +
            after
        )

    ].copy()


    if len(
        result
    ):

        result[
            "relative_time"
        ] = (

            result[
                "frame"
            ]

            -

            landing_frame

        ) / fps


    return result


# ============================================================
# GET A SPECIFIC VIDEO FRAME
# ============================================================

def get_video_frame(
    video_path,
    frame_number
):

    video = cv2.VideoCapture(
        str(
            video_path
        )
    )


    video.set(
        cv2.CAP_PROP_POS_FRAMES,
        int(
            frame_number
        )
    )


    success, frame = (
        video.read()
    )


    video.release()


    if not success:
        return None


    return frame


# ============================================================
# DRAW LANDING FRAME
# ============================================================

def draw_landing_overlay(
    frame,
    landmarks
):

    if (
        frame is None
        or
        landmarks is None
    ):

        return None


    image = frame.copy()


    height, width = (
        image.shape[:2]
    )


    left_hip = get_pixel_point(
        landmarks,
        LEFT_HIP,
        width,
        height
    )


    right_hip = get_pixel_point(
        landmarks,
        RIGHT_HIP,
        width,
        height
    )


    left_knee = get_pixel_point(
        landmarks,
        LEFT_KNEE,
        width,
        height
    )


    right_knee = get_pixel_point(
        landmarks,
        RIGHT_KNEE,
        width,
        height
    )


    left_ankle = get_pixel_point(
        landmarks,
        LEFT_ANKLE,
        width,
        height
    )


    right_ankle = get_pixel_point(
        landmarks,
        RIGHT_ANKLE,
        width,
        height
    )


    left_angle = calculate_angle(

        left_hip,
        left_knee,
        left_ankle
    )


    right_angle = calculate_angle(

        right_hip,
        right_knee,
        right_ankle
    )


    # OpenCV uses BGR
    white = (
        255,
        255,
        255
    )


    yellow = (
        0,
        230,
        255
    )


    dark = (
        20,
        20,
        20
    )


    # --------------------------------------------------------
    # HIP LINE
    # --------------------------------------------------------

    cv2.line(

        image,

        left_hip,

        right_hip,

        white,

        4
    )


    # --------------------------------------------------------
    # LEFT LEG
    # --------------------------------------------------------

    cv2.line(

        image,

        left_hip,

        left_knee,

        white,

        5
    )


    cv2.line(

        image,

        left_knee,

        left_ankle,

        white,

        5
    )


    # --------------------------------------------------------
    # RIGHT LEG
    # --------------------------------------------------------

    cv2.line(

        image,

        right_hip,

        right_knee,

        white,

        5
    )


    cv2.line(

        image,

        right_knee,

        right_ankle,

        white,

        5
    )


    # --------------------------------------------------------
    # JOINT DOTS
    # --------------------------------------------------------

    points = [

        left_hip,
        right_hip,

        left_knee,
        right_knee,

        left_ankle,
        right_ankle
    ]


    for point in points:

        cv2.circle(

            image,

            point,

            10,

            dark,

            -1
        )


        cv2.circle(

            image,

            point,

            7,

            yellow,

            -1
        )


    # --------------------------------------------------------
    # TEXT LABEL BACKGROUNDS
    # --------------------------------------------------------

    left_label = (
        f"L {left_angle:.0f} deg"
    )


    right_label = (
        f"R {right_angle:.0f} deg"
    )


    cv2.putText(

        image,

        left_label,

        (
            max(
                10,
                left_knee[0]
                -
                100
            ),

            max(
                35,
                left_knee[1]
                -
                25
            )
        ),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.8,

        white,

        3,

        cv2.LINE_AA
    )


    cv2.putText(

        image,

        right_label,

        (
            right_knee[0]
            +
            20,

            max(
                35,
                right_knee[1]
                -
                25
            )
        ),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.8,

        white,

        3,

        cv2.LINE_AA
    )


    # --------------------------------------------------------
    # LANDING LABEL
    # --------------------------------------------------------

    cv2.rectangle(

        image,

        (
            15,
            15
        ),

        (
            315,
            62
        ),

        dark,

        -1
    )


    cv2.putText(

        image,

        "Detected landing",

        (
            30,
            48
        ),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.8,

        white,

        2,

        cv2.LINE_AA
    )


    return image


# ============================================================
# ENCODE IMAGE
# ============================================================

def image_to_base64(
    image
):

    if image is None:
        return None


    success, buffer = cv2.imencode(
        ".jpg",
        image,
        [
            int(
                cv2.IMWRITE_JPEG_QUALITY
            ),
            88
        ]
    )


    if not success:
        return None


    return (
        base64
        .b64encode(
            buffer
        )
        .decode(
            "utf-8"
        )
    )


# ============================================================
# TRAINING PLAN
# ============================================================

def get_training_plan(
    left,
    right,
    asymmetry
):

    if (
        left > 0.15
        or
        right > 0.15
    ):

        return {

            "focus":
            "Landing knee control",

            "reason":
            (
                "One or both knees showed noticeable "
                "inward movement after landing."
            ),

            "exercises":
            [

                {
                    "name":
                    "Single-leg squat",

                    "volume":
                    "3 × 8 / side",

                    "instruction":
                    (
                        "Keep your knee tracking over "
                        "the middle of your foot."
                    )
                },

                {
                    "name":
                    "Lateral step-down",

                    "volume":
                    "3 × 8 / side",

                    "instruction":
                    (
                        "Lower slowly without allowing "
                        "your knee to collapse inward."
                    )
                },

                {
                    "name":
                    "Jump + stick",

                    "volume":
                    "3 × 5",

                    "instruction":
                    (
                        "Land softly and hold the landing "
                        "for 2–3 seconds."
                    )
                },

                {
                    "name":
                    "Single-leg landing hold",

                    "volume":
                    "3 × 5 / side",

                    "instruction":
                    (
                        "Land on one leg and regain balance "
                        "before the next repetition."
                    )
                }
            ]
        }


    if asymmetry > 8:

        return {

            "focus":
            "Left-right consistency",

            "reason":
            (
                "Your two legs handled the landing "
                "somewhat differently."
            ),

            "exercises":
            [

                {
                    "name":
                    "Single-leg squat",

                    "volume":
                    "3 × 8 / side",

                    "instruction":
                    (
                        "Compare movement quality "
                        "between your two sides."
                    )
                },

                {
                    "name":
                    "Reverse lunge",

                    "volume":
                    "3 × 8 / side",

                    "instruction":
                    (
                        "Keep your front knee centered "
                        "over the foot."
                    )
                },

                {
                    "name":
                    "Single-leg jump + stick",

                    "volume":
                    "3 × 5 / side",

                    "instruction":
                    (
                        "Aim for similarly controlled "
                        "landings on each leg."
                    )
                },

                {
                    "name":
                    "Single-leg balance",

                    "volume":
                    "3 × 30 sec / side",

                    "instruction":
                    (
                        "Maintain stable hip, knee, "
                        "and ankle alignment."
                    )
                }
            ]
        }


    return {

        "focus":
        "Maintain landing control",

        "reason":
        (
            "This assessment showed relatively "
            "controlled landing alignment."
        ),

        "exercises":
        [

            {
                "name":
                "Jump + stick",

                "volume":
                "3 × 5",

                "instruction":
                "Land softly and hold the landing."
            },

            {
                "name":
                "Lateral bounds",

                "volume":
                "3 × 6 / side",

                "instruction":
                (
                    "Control each landing before "
                    "starting the next jump."
                )
            },

            {
                "name":
                "Single-leg squat",

                "volume":
                "3 × 8 / side",

                "instruction":
                (
                    "Maintain knee-over-foot alignment."
                )
            },

            {
                "name":
                "Controlled deceleration",

                "volume":
                "5 reps",

                "instruction":
                (
                    "Jog forward and come to a "
                    "controlled athletic stop."
                )
            }
        ]
    }


# ============================================================
# MAIN FUNCTION CALLED BY FASTAPI
# ============================================================

def analyze_video(
    video_path
):

    (
        df,
        fps,
        pose_rate,
        lower_body_rate

    ) = analyze_video_frames(
        video_path
    )


    if len(
        df
    ) < 8:

        raise ValueError(
            "Not enough reliable lower-body frames were detected."
        )


    df = smooth_data(
        df
    )


    jump = detect_landing(
        df,
        fps
    )


    if jump is None:

        raise ValueError(
            "A complete jump and landing could not be detected."
        )


    landing_frame_number = (
        jump[
            "landing_frame"
        ]
    )


    landing_df = get_landing_window(

        df,

        landing_frame_number,

        fps
    )


    if len(
        landing_df
    ) < 8:

        raise ValueError(
            "Not enough reliable frames were captured around the landing."
        )


    post_contact = landing_df[

        landing_df[
            "relative_time"
        ]

        >=

        0

    ].copy()


    if len(
        post_contact
    ) == 0:

        post_contact = (
            landing_df
        )


    # --------------------------------------------------------
    # MAIN MOVEMENT MEASUREMENTS
    # --------------------------------------------------------

    left = float(

        post_contact[
            "left_inward_smooth"
        ]

        .max()
    )


    right = float(

        post_contact[
            "right_inward_smooth"
        ]

        .max()
    )


    asymmetry = float(

        post_contact[
            "asymmetry_smooth"
        ]

        .max()
    )


    # ========================================================
    # MOVEMENT SCORE
    #
    # THIS IS OUR CUSTOM PROTOTYPE HEURISTIC.
    #
    # 35% left inward movement
    # 35% right inward movement
    # 30% left-right angle asymmetry
    #
    # Larger deviations produce larger penalties.
    # ========================================================

    left_penalty = min(

        max(
            left,
            0
        )

        /
        0.25,

        1
    )


    right_penalty = min(

        max(
            right,
            0
        )

        /
        0.25,

        1
    )


    asymmetry_penalty = min(

        asymmetry
        /
        25,

        1
    )


    total_penalty = (

        0.35
        *
        left_penalty

        +

        0.35
        *
        right_penalty

        +

        0.30
        *
        asymmetry_penalty
    )


    score = int(

        round(

            100

            -

            total_penalty
            *
            45
        )
    )


    # --------------------------------------------------------
    # TRAINING PLAN
    # --------------------------------------------------------

    training = get_training_plan(

        left,
        right,
        asymmetry
    )


    # --------------------------------------------------------
    # GRAPH DATA
    # --------------------------------------------------------

    graph_points = []


    for _, row in landing_df.iterrows():

        graph_points.append(
            {

                "time":
                float(
                    row[
                        "relative_time"
                    ]
                ),

                "left":
                float(
                    row[
                        "left_inward_smooth"
                    ]
                    *
                    100
                ),

                "right":
                float(
                    row[
                        "right_inward_smooth"
                    ]
                    *
                    100
                )
            }
        )


    # --------------------------------------------------------
    # ANNOTATED LANDING FRAME
    # --------------------------------------------------------

    landing_frame = get_video_frame(

        video_path,

        landing_frame_number
    )


    annotated_frame_base64 = None


    if landing_frame is not None:

        landing_landmarks = detect_pose(
            landing_frame
        )


        if landing_landmarks is not None:

            annotated_frame = draw_landing_overlay(

                landing_frame,

                landing_landmarks
            )


            annotated_frame_base64 = image_to_base64(
                annotated_frame
            )


    # --------------------------------------------------------
    # FINAL RESPONSE
    # --------------------------------------------------------

    return {

        "score":
        score,

        "left_inward":
        left
        *
        100,

        "right_inward":
        right
        *
        100,

        "asymmetry":
        asymmetry,

        "takeoff_time":

        jump[
            "takeoff_frame"
        ]
        /
        fps,

        "apex_time":

        jump[
            "apex_frame"
        ]
        /
        fps,

        "landing_time":

        jump[
            "landing_frame"
        ]
        /
        fps,

        "pose_tracking":
        pose_rate,

        "lower_body_tracking":
        lower_body_rate,

        "focus":
        training[
            "focus"
        ],

        "focus_reason":
        training[
            "reason"
        ],

        "exercises":
        training[
            "exercises"
        ],

        "graph":
        graph_points,

        "annotated_frame_base64":
        annotated_frame_base64
    }