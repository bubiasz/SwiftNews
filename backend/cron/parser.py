import datetime as dt

import newspaper

from backend.cron import schemas


class ArticleParser:
    __instance: object = None
    __language: str = ""
    __location: str = ""
    __articles_with_content: list = None

    def __new__(cls, language: str = None, location: str = None):
        if not cls.__instance:
            cls.__instance = super(ArticleParser, cls).__new__(cls)
            cls.__instance.__language = language
            cls.__instance.__location = location
            cls.__instance.__articles_with_content = []

        return cls.__instance

    def set_language(self, language: str) -> None:
        self.__language = language

    def set_location(self, location: str) -> None:
        self.__location = location

    def parser_reset(self) -> None:
        self.__articles_with_content = []

    def get_articles(self) -> list:
        return self.__articles_with_content

    def parse_articles(self, articles: list) -> None:
        for article in articles:
            try:
                print(article.url)
                title, content = self.__get_article(article.url)
            except ValueError:
                # handle this error by adding new articles or something?
                pass

            self.__articles_with_content.append(schemas.ParsedArticle(
                category=article.category,
                language=self.__language,
                location=self.__location,
                url=article.url,
                date=dt.datetime.now(),
                title=title,
                content=content,
            ))

    def __get_article(self, link: str) -> (str, str):
        article = newspaper.Article(link, language=self.__language)
        article.download()
        article.parse()

        if article.text == "" or not article.text:
            raise ValueError("Could not read the article")

        return article.title, article.text
