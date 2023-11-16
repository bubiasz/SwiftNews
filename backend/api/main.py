from typing import List

from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from sqlalchemy.orm import Session

from backend import config, database, models
from backend.api import schemas, services

###############
#
# Database connect and app start
#
###############

models.database.Base.metadata.create_all(bind=database.engine)


def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


app = FastAPI()


###############
# 
# Newsfeed API endpoints
#
###############

@app.post("/api/newsfeed", response_class=List[schemas.News])
def read_newsfeed(data: schemas.Newsfeed, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == data.user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    if usr.news is True:
        raise HTTPException(status_code=429, detail="Newsfeed already generated")

    news = services.read_newsfeed(data, db)
    usr.news = True
    db.commit()

    return news


###############
# 
# Shared news API endpoints
# 
###############

@app.get("/api/sharednews/{user}/{link}", response_model=schemas.News)
def read_sharednews(user: str, link: str, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    if usr.shared_reads > config.SHARED_NEWS_READ_LIMIT:
        raise HTTPException(status_code=429, detail="Daily shared news read limit reached")

    data = db.query(models.SharedNews).filter(models.SharedNews.link == link).first()

    if data is None:
        raise HTTPException(status_code=404, detail="Shared news not found")

    return data


@app.post("/api/sharednews", response_class=JSONResponse)
def send_sharednews(data: schemas.SharedNews, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == data.user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    news = db.query(models.SharedNews).filter(models.SharedNews.user == data.user).all()

    if len(news) > config.SHARED_NEWS_SEND_LIMIT:
        raise HTTPException(status_code=429, detail="Daily shared news limit reached")

    services.send_sharednews(data, db)
    usr.shared_reads += 1
    db.commit()

    return JSONResponse(content={"message": "Shared news sent"})


###############
# 
# QR code API endpoints
# 
###############

@app.get("/api/qrcode/{user}/{key}", response_model=schemas.QRCodeSchema)
def read_qrcode(user: str, key: str, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    if usr.qrcode_reads > config.QRCODE_READS_LIMIT:
        raise HTTPException(status_code=429, detail="Daily read QR code limit reached")

    data = db.query(models.QRCode).filter(
        models.QRCode.user == user, models.QRCode.key == key).first()

    usr.qrcode_reads += 1
    db.commit()

    if data is None:
        raise HTTPException(status_code=404, detail="QR code not found")

    return data


@app.post("/api/qrcode", response_class=FileResponse)
def make_qrcode(data: schemas.QRCodeSchema, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == data.user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    if usr.qrcode_makes > config.QRCODE_MAKES_LIMIT:
        raise HTTPException(status_code=429, detail="Daily make QR code limit reached")

    qr = services.make_qrcode(data, db)
    usr.qrcode_makes += 1
    db.commit()

    return qr


###############
# 
# Support API endpoints
#
###############

@app.get("/api/support/{user}", response_model=List[schemas.SupportResponse])
def read_support(user: str, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    if usr.support_reads > config.SUPPORT_MESSAGE_READS:
        raise HTTPException(status_code=429, detail="Support message read limit reached")

    msg = db.query(models.SupportMessage).filter(
        models.SupportMessage.user == user, models.SupportMessage.solved == True).all()

    return msg


@app.post("/api/support", response_class=JSONResponse)
def send_support(data: schemas.SupportMessage, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == data.user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    msg = db.query(models.SupportMessage).filter(
        models.SupportMessage.user == data.user, models.SupportMessage.solved == False).all()

    if len(msg) > config.SUPPORT_MESSAGE_LIMIT:
        raise HTTPException(status_code=429, detail="Daily support limit reached")

    services.send_support(data, db)
    db.commit()

    return JSONResponse(content={"message": "Support message sent"})


###############
#
# User API endpoints
#
###############

@app.get("/api/user", response_class=JSONResponse)
def make_user(db: Session = Depends(get_db)):
    usr = services.make_user(db)
    db.commit()

    return JSONResponse(content={"user": usr})
