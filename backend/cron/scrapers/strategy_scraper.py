from abc import ABC, abstractmethod


class ScraperStrategy(ABC):
    @abstractmethod
    def set_language(self, language: str) -> None:
        pass

    @abstractmethod
    def set_location(self, location: str) -> None:
        pass

    @abstractmethod
    def set_number_of_articles(self, number: int) -> None:
        pass

    @abstractmethod
    def scrape_articles(self) -> None:
        pass

    @abstractmethod
    def get_articles(self) -> list:
        pass
