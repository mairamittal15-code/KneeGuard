from pathlib import Path
import os
import shutil
import tempfile

from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from analysis import analyze_video


app = FastAPI(
    title="KneeGuard API",
    version="1.0"
)


app.add_middleware(

    CORSMiddleware,

    allow_origins=[
        "*"
    ],

    allow_credentials=True,

    allow_methods=[
        "*"
    ],

    allow_headers=[
        "*"
    ]
)


@app.get("/")
def home():

    return {
        "message":
        "KneeGuard API is running"
    }


@app.post("/analyze")
async def analyze(
    video: UploadFile = File(...)
):

    suffix = Path(
        video.filename
        or
        "video.mov"
    ).suffix


    temp_path = None


    try:

        with tempfile.NamedTemporaryFile(

            delete=False,

            suffix=suffix

        ) as temp:

            shutil.copyfileobj(

                video.file,

                temp
            )


            temp_path = (
                temp.name
            )


        result = analyze_video(
            temp_path
        )


        return result


    except Exception as error:

        return JSONResponse(

            status_code=400,

            content={
                "error":
                str(
                    error
                )
            }
        )


    finally:

        if (
            temp_path
            and
            os.path.exists(
                temp_path
            )
        ):

            try:

                os.remove(
                    temp_path
                )

            except OSError:

                pass