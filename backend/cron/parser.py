from backend.cron.parsers import newspaper_parser, strategy_parser


class Parser:

    # To change the type of parser create a new instance
    def __init__(self, parser: str, language: str, location: str):
        self.__parser = ParserFactory.create_parser(parser, language, location)
        self.__articles = list()

    def set_language(self, language: str) -> None:
        self.__parser.set_language(language)

    def set_location(self, location: str) -> None:
        self.__parser.set_location(location)

    def parser_reset(self) -> None:
        self.__articles = list()

    def parse_articles(self, articles: list) -> None:
        for article in articles:
            try:
                parsed = self.__parser.parse_article(article)
            except ValueError:
                continue

            self.__articles.append(parsed)

    def get_articles(self) -> list:
        return self.__articles


class ParserFactory:
    @staticmethod
    def create_parser(parser: str, language: str, location: str) -> strategy_parser.ParserStrategy:
        if parser.lower() == "article":
            return newspaper_parser.Parser(language, location)
