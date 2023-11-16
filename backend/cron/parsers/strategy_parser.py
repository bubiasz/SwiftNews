from abc import ABC, abstractmethod

from backend.cron import schemas


class ParserStrategy(ABC):
    @abstractmethod
    def parse_article(self, article: object) -> schemas.ParsedArticle:
        pass

    @abstractmethod
    def set_language(self, language: str) -> None:
        pass

    @abstractmethod
    def set_location(self, location: str) -> None:
        pass