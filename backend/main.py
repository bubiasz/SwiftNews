from webscraper import GoogleNewsScraper
from article_parser import ArticleParser

from shared import models, database, config


def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


d = get_db()
session = database.SessionLocal()

parser = ArticleParser()
final_articles = parser.get_articles()

for lang_region in config.SUPPORTED_LANGUAGES:
    x = GoogleNewsScraper(lang_region)
    parser.set_geolocation(lang_region)
    parser.parse_articles(x.get_articles())
    parsed_articles = parser.get_articles()

    for article in final_articles:
        entry = models.News(
            category=article.get_category(),
            language=article.get_lang(),
            region=article.get_location(),
            title=article.get_title(),
            content=article.get_content(),
            url=article.get_url(),
            date=article.get_date()
        )

        session.add(entry)
        try:
            session.commit()
        except:
            session.rollback()
