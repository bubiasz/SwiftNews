from typing import List

from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from sqlalchemy import JSON
from sqlalchemy.orm import Session

import config
import models
import schemas
import database
import services

###############
#
# Database connection and app startup
#
###############

models.Base.metadata.create_all(bind=database.engine)

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

app = FastAPI()
