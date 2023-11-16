import datetime as dt

import newspaper

from backend.cron import schemas, scraper


class Parser(scraper.ArticleParserStrategy):

    def __init__(self, language: str):
        self.__language = language

    def set_language(self, language: str) -> None:
        self.__language = language

    def set_location(self, *args) -> None:
        pass

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
