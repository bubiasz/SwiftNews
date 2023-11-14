from newspaper import Article
from datetime import datetime

from backend.parsed_article import ParsedArticle


class ArticleParser(object):
    __instance = None

    def __new__(cls, lang=None, location=None):
        if not cls.__instance:
            cls.__instance = super(ArticleParser, cls).__new__(cls)
            cls.__instance.__lang = lang
            cls.__instance.__location = location
            cls.__instance.__articles_with_content = []
        return cls.__instance

    def set_lang(self, lang):
        self.__lang = lang

    def set_location(self, location):
        self.__location = location

    def set_geolocation(self, lang_region):
        self.set_lang(lang_region[0])
        self.set_location(lang_region[1])

    def parse_articles(self, articles):
        for article in articles:
            try:
                article_content, article_title = self.__parse_article(article.get_url())
                self.__articles_with_content.append((
                    ParsedArticle(
                        category=article.get_category(),
                        lang=self.__lang,
                        location=self.__location,
                        title=article_title,
                        content=article_content,
                        url=article.get_url(),
                        date=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    )))
            except Exception as e:
                print("Could not read article: {title}\nException: {exception}".format(title=article.get_title(), exception=str(e)))
                continue

    def __parse_article(self, link):
        article = Article(link, language=self.__lang)
        article.download()
        article.parse()
        if article.text == "" or not article.text:
            raise Exception("Could not read the article")
        return article.text, article.title

    def get_articles(self):
        return self.__articles_with_content
