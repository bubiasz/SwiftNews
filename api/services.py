import os
import random
from typing import List

import qrcode
from sqlalchemy import func

import config
import models
import schemas
import utilities


def read_newsfeed(data: schemas.Newsfeed, db) -> List[schemas.News]:

    main_time, rest_time = int(data.time * 0.9), int(data.time * 0.1)
    categories = data.categories
    categories_sum = sum(categories.values())

    for k, v in categories.items():
        value = int(v / categories_sum * main_time)
        
        if value != 0:
            categories[k] = value
        else:
            del categories[k]

    for _ in range(int(main_time - sum(categories.values()))):
        categories[random.choice(list(categories.keys()))] += 1

    rest_categories = set(data.categories.keys()) - set(categories.keys())
    for _ in range(rest_time):
        k = random.choice(list(rest_categories))
        categories[k] = categories.get(k, 0) + 1

    news = []
    for k, v in categories.items():
        news.append(db.query(models.News).filter(
            models.News.region == data.region,
            models.News.language == data.language,
            models.News.category == k).order_by(func.random()).limit(v).all())
        
    return news


def send_shared_news(data: schemas.SharedNews, db) -> None:

    link = utilities.random_string(64)
    while db.query(models.SharedNews).filter(models.SharedNews.link == link).first() is not None:
        link = utilities.random_string(64)

    db.add(models.SharedNews(
        user=data.user,
        category=data.category,
        link=link,
        created=data.created,
        url=data.url,
        date=data.date,
        title=data.title,
        content=data.content
    ))

    return None


def make_qrcode(data: schemas.QRCodeSchema, db) -> str:

    qr = db.query(models.QRCode).filter(models.QRCode.user == data.user).first()
    if qr is not None:
        db.delete(qr)

    del qr

    key = utilities.random_string(32)
    path = os.path.join(config.QRCODE_PATH, data.user + config.QRCODE_FORMAT)

    code = qrcode.make(str(config.QRCODE_URL + "/" + data.user + "/" + key))
    code.save(path)

    db.add(models.QRCode(
        user=data.user,
        key=key,
        time=data.time,
        region=data.region,
        language=data.language,
        categories=data.categories
    ))

    return path


def send_support(data: schemas.SupportMessage, db) -> None:

    db.add(models.SupportMessage(
        user=data.user,
        title=data.title,
        message=data.message
    ))

    return None


def make_user(db) -> str:

    usr = utilities.random_string(32)
    while db.query(models.User).filter(models.User.user == usr).first() is not None:
        usr = utilities.random_string(32)
    
    db.add(models.User(user=usr))

    return usr
