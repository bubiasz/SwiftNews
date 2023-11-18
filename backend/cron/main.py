from backend import config, database, models
from backend.cron import parser, scraper


for language, location in config.SUPPORTED_LANGUAGES:
    p = parser.Parser(config.NEWS_PARSER, language, location)
    s = scraper.Scraper(config.NEWS_SCRAPER, config.NEWS_NUMBER, language, location)
    s.scrape_articles()
    p.parse_articles(
        s.get_articles())

    articles = p.get_articles()

    for article in articles:
        with database.SessionLocal() as db:
            db.add(models.News(
                category=article.category,
                language=article.language,
                location=article.location,
                url=article.url,
                date=article.date,
                title=article.title,
                content=article.content
            ))
            try:
                db.commit()
            except Exception as e:
                print(e)
                db.rollback()
                continue

    p.parser_reset()
