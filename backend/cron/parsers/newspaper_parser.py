import datetime as dt

import newspaper

from backend.cron import schemas
from backend.cron.parsers import strategy_parser


class Parser(strategy_parser.ParserStrategy):

    def __init__(self, language: str, location: str):
        self.__language = language
        self.__location = location

    def set_language(self, language: str) -> None:
        self.__language = language

    def set_location(self, location: str) -> None:
        self.__location = location

    def parse_article(self, article: object) -> schemas.ParsedArticle:
        try:
            title, content = self.__download_article(article.url)
        except ValueError:
            raise ValueError("Empty article")

        return schemas.ParsedArticle(
            category=article.category,
            language=self.__language,
            location=self.__location,
            url=article.url,
            date=dt.datetime.now(),
            title=title,
            content=content,
        )

    def __download_article(self, url: str) -> (str, str):
        article = newspaper.Article(url, language=self.__language)
        article.download()
        article.parse()

        if not article.text:
            raise ValueError("Empty article")

        return article.title, article.text
