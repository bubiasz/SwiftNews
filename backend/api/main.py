import os

from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles

from sqlalchemy.orm import Session

from backend import config, database, models
from backend.api import schemas, services

###############
#
# Database connect and app start
#
###############

os.makedirs("static/qrcode", exist_ok=True)
models.database.Base.metadata.create_all(bind=database.engine)


def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")


###############
#
# User API endpoints
#
###############

@app.get("/api/user", response_class=JSONResponse)
def make_user(db: Session = Depends(get_db)):
    usr = services.make_user(db)
    db.commit()

    return JSONResponse(content={"id": usr})


###############
#
# Get all possible language, region and categories
#
###############

@app.get("/api/config", response_model=schemas.Config)
def get_config():
    return schemas.Config(
        times=[10, 20, 30],
        locations=list(schemas.ConfigItem(
            language=k[0], region=k[1], categories=v) for k, v in config.CATEGORIES.items())
    )


###############
# 
# Newsfeed API endpoints
#
###############

@app.post("/api/newsfeed", response_model=list[schemas.News])
def read_newsfeed(data: schemas.Newsfeed, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == data.user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    # if usr.news is True:
    #     raise HTTPException(status_code=429, detail="Newsfeed already generated")

    news = services.read_newsfeed(data, db)
    usr.news = True
    db.commit()

    print(news)

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

    url = services.send_sharednews(data, db)
    usr.shared_reads += 1
    db.commit()

    print(url)

    return JSONResponse(content={"url": url})


###############
# 
# QR code API endpoints
# 
###############

@app.get("/api/qrcode/{user}/{key}", response_model=schemas.QRCodeSchema)
def read_qrcode(user: str, key: str, db: Session = Depends(get_db)):
    print(user)

    usr = db.query(models.User).filter(models.User.user == user).first()

    if usr is None:
        print("^" * 20)
        raise HTTPException(status_code=404, detail="Invalid user")

    # if usr.qrcode_reads > config.QRCODE_READS_LIMIT:
    #     raise HTTPException(status_code=429, detail="Daily read QR code limit reached")

    print(user, key)

    data = db.query(models.QRCode).filter(
        models.QRCode.user == user, models.QRCode.key == key).first()

    usr.qrcode_reads += 1
    db.commit()

    print(data)

    if data is None:
        raise HTTPException(status_code=404, detail="QR code not found")

    return data


@app.post("/api/qrcode", response_class=JSONResponse)
def make_qrcode(data: schemas.QRCodeSchema, db: Session = Depends(get_db)):
    usr = db.query(models.User).filter(models.User.user == data.user).first()

    if usr is None:
        raise HTTPException(status_code=404, detail="Invalid user")

    # if usr.qrcode_makes > config.QRCODE_MAKES_LIMIT:
    #     raise HTTPException(status_code=429, detail="Daily make QR code limit reached")

    qr = services.make_qrcode(data, db)
    usr.qrcode_makes += 1
    db.commit()

    return JSONResponse(content={"url": qr})


###############
# 
# Support API endpoints
#
###############

@app.get("/api/support/{user}", response_model=list[schemas.SupportResponse])
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
