from typing import Optional

from pydantic import BaseModel


# Used in newsfeed [post]
class Newsfeed(BaseModel):
    # User data fields
    user: str
    time: int
    region: str
    language: str
    categories: dict[str, int]


# Used in newsfeed [post], sharednews [get]
class News(BaseModel):
    # News metadata fields
    category: str

    # News data fields
    url: str
    date: str
    title: str
    content: str


# Used in sharednews [post]
class SharedNews(News):
    # Shared news metadata fields
    user: str
    category: str

    # Shared news data fields
    url: str
    date: str
    title: str
    content: str


# Used in qrcode [get], qrcode [post]
class QRCodeSchema(BaseModel):
    # QR code metadata fields
    user: str

    # QR code data fields
    time: int
    region: str
    language: str
    categories: dict[str, int]


# Used in support [get]
class SupportResponse(BaseModel):
    # Support message data fields
    response: Optional[str]


# Used in support [post]
class SupportMessage(BaseModel):
    # Support message data fields
    user: str
    title: str
    message: str


# Used in config [get]
class ConfigItem(BaseModel):
    language: str
    region: str
    categories: list[str]
