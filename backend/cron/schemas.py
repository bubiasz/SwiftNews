import datetime as dt


class ParsedArticle:

    def __init__(self, category: str, language: str, location: str,
                 url: str, date: dt.date, title: str, content: str = None):
        self.category = category
        self.language = language
        self.location = location
        self.url = url
        self.date = date
        self.title = title
        self.content = content
