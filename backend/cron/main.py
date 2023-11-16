from backend import config, database, models
from backend.cron import parser, scraper


p = parser.Parser("article", "pl", "pl")

for language, location in config.SUPPORTED_LANGUAGES:
    p.set_language(language)
    p.set_location(location)
    p.parse_articles(
        scraper.GoogleNewsScraper(language, location).get_articles())

    articles = p.get_articles()

    for article in articles:
        with database.get_db() as db:
            db.add(models.News(
                category=article.category,
                language=article.language,
                location=article.location,
                url=article.url,
                date=article.date,
                title=article.title,
                content=article.content
            ))
            db.commit()

    p.parser_reset()
