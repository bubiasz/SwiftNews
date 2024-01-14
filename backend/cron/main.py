import sqlalchemy.exc

from backend import config, database, models
from backend.cron import parser, scraper
import time


start_time = time.time()
for language, location in config.SUPPORTED_LANGUAGES:
    p = parser.Parser(config.NEWS_PARSER, language, location)
    s = scraper.Scraper(config.NEWS_SCRAPER, config.NEWS_NUMBER, language, location)
    
    s.scrape_articles()
    p.parse_articles(s.get_articles())
    articles = p.get_articles()

    for article in articles:
        with database.SessionLocal() as db:
            db.add(models.News(
                category=article.category,
                language=article.language,
                region=article.location,
                url=article.url,
                date=article.date,
                title=article.title,
                content=article.content
            ))
            try:
                db.commit()
            except sqlalchemy.exc.IntegrityError as e:
                db.rollback()

    del p, s, articles
