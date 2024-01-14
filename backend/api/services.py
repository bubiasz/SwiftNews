import os
import random
import datetime
from typing import List

import qrcode
from sqlalchemy import func

from backend import config, models
from backend.api import schemas, utilities


def read_newsfeed(data: schemas.Newsfeed, db) -> List[schemas.News]:
    main_time, rest_time = int(data.time * 0.9), int(data.time * 0.1)
    categories = data.categories
    categories_sum = sum(categories.values())

    for k, v in categories.items():
        categories[k] = int(v / categories_sum * main_time)

    categories = {k: v for k, v in categories.items() if v != 0}

    for _ in range(int(main_time - sum(categories.values()))):
        categories[random.choice(list(categories.keys()))] += 1

    rest_categories = set(data.categories.keys()) - set(categories.keys())
    if rest_categories:
        for _ in range(rest_time):
            k = random.choice(list(rest_categories))
            categories[k] = categories.get(k, 0) + 1

    region, language = data.location.lower().split()
    news = list()
    for k, v in categories.items():
        news.extend(db.query(models.News).filter(
            models.News.region == region,
            models.News.language == language,
            models.News.category == k).order_by(func.random()).limit(v).all())

    return news


def send_sharednews(data: schemas.SharedNews, db) -> None:
    link = utilities.random_string(64)
    while db.query(models.SharedNews).filter(models.SharedNews.link == link).first() is not None:
        link = utilities.random_string(64)

    db.add(models.SharedNews(
        user=data.user,
        category=data.category,
        link=link,
        created=datetime.datetime.now(),
        url=data.url,
        date=data.date,
        title=data.title,
        content=data.content
    ))

    return "/".join([config.BASE_URL, "api/sharednews", data.user, link])


def make_qrcode(data: schemas.QRCodeSchema, db) -> str:
    qr = db.query(models.QRCode).filter(models.QRCode.user == data.user).first()
    if qr is not None:
        db.delete(qr)

    del qr

    key = utilities.random_string(32)
    url = str(config.QRCODE_URL + "/" + data.user + "/" + key)
    dir_path = os.path.join(config.QRCODE_PATH, data.user)

    os.makedirs(dir_path, exist_ok=True)
    code = qrcode.make(url)
    code.save(os.path.join(dir_path, key + config.QRCODE_FORMAT))

    db.add(models.QRCode(
        user=data.user,
        key=key,
        time=data.time,
        location=data.location,
        categories=data.categories
    ))

    return "/".join([config.STATIC_URL, "qrcode", data.user, key + config.QRCODE_FORMAT])


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
