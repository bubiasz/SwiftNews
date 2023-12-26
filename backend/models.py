import sqlalchemy as sql

from backend import database


# Database table to store news
class News(database.Base):
    # Table name in database
    __tablename__ = "news"

    # News metadata fields
    id = sql.Column(sql.BigInteger, index=True, primary_key=True)
    category = sql.Column(sql.String(64), index=True)
    language = sql.Column(sql.String(64), index=True)
    region = sql.Column(sql.String(64), index=True)

    # News data fields
    url = sql.Column(sql.String(512), unique=True)
    date = sql.Column(sql.Date)
    title = sql.Column(sql.Unicode(256))
    content = sql.Column(sql.UnicodeText)


# Database table to store shared news
class SharedNews(database.Base):
    # Table name in database
    __tablename__ = "shared_news"

    # Shared news metadata fields
    id = sql.Column(sql.BigInteger, index=True, primary_key=True)
    category = sql.Column(sql.String(64))
    link = sql.Column(sql.String(64), index=True)
    created = sql.Column(sql.DateTime, default=sql.func.now())

    # Shared news data fields
    user = sql.Column(sql.String(32), index=True)
    url = sql.Column(sql.String(512))
    date = sql.Column(sql.Date)
    title = sql.Column(sql.Unicode(256))
    content = sql.Column(sql.UnicodeText)


# Database table to store QR codes
class QRCode(database.Base):
    # Table name in database
    __tablename__ = "qr_code"

    # QR code metadata fields
    id = sql.Column(sql.BigInteger, index=True, primary_key=True)
    created = sql.Column(sql.DateTime, default=sql.func.now())

    # QR code data fields
    user = sql.Column(sql.String(32), index=True)
    key = sql.Column(sql.String(32), index=True)
    time = sql.Column(sql.Integer)
    language = sql.Column(sql.String(64))
    region = sql.Column(sql.String(64))
    categories = sql.Column(sql.JSON)


# Database table to store support messages
class SupportMessage(database.Base):
    # Table name in database
    __tablename__ = "support_message"

    # Support message metadata fields
    id = sql.Column(sql.BigInteger, index=True, primary_key=True)
    created = sql.Column(sql.DateTime, default=sql.func.now())
    solved = sql.Column(sql.Boolean, default=False)
    response = sql.Column(sql.UnicodeText)

    # Support message data fields
    user = sql.Column(sql.String(32), index=True)
    title = sql.Column(sql.Unicode(256))
    message = sql.Column(sql.UnicodeText)


# Database table to store users
class User(database.Base):
    # Table name in database
    __tablename__ = "user"

    # User metadata fields
    id = sql.Column(sql.BigInteger, index=True, primary_key=True)
    user = sql.Column(sql.String(32), index=True)

    # User data fields
    news = sql.Column(sql.Boolean, default=False)
    shared_reads = sql.Column(sql.Integer, default=0)
    qrcode_reads = sql.Column(sql.Integer, default=0)
    qrcode_makes = sql.Column(sql.Integer, default=0)
    support_reads = sql.Column(sql.Integer, default=0)
