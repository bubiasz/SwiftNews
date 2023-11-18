from backend.cron.scrapers import google_news_scraper, strategy_scraper


class Scraper:

    def __init__(self, scraper: str, number_of_articles: int, language: str, location: str):
        self.__scraper = ScraperFactory.create_scraper(scraper, number_of_articles, language, location)
        self.__articles = list()

    def set_language(self, language: str) -> None:
        self.__scraper.set_language(language)

    def set_location(self, location: str) -> None:
        self.__scraper.set_location(location)

    def scraper_reset(self) -> None:
        self.__articles = list()

    def set_number_of_articles(self, number: int) -> None:
        self.__scraper.set_number_of_articles(number)

    def scrape_articles(self) -> None:
        self.__scraper.scrape_articles()

    def get_articles(self) -> list:
        return self.__scraper.get_articles()


class ScraperFactory:
    @staticmethod
    def create_scraper(parser: str, number_of_articles: int, language: str, location: str):
        if parser.lower() == "google":
            return google_news_scraper.Scraper(number_of_articles, language, location)
