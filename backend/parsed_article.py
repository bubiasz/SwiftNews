class ParsedArticle:
    def __init__(self, category, lang, location, title, url, date, content=""):
        self.__category = category
        self.__lang = lang
        self.__location = location
        self.__title = title
        self.__content = content
        self.__url = url
        self.__date = date

    def get_category(self):
        return self.__category

    def get_lang(self):
        return self.__lang

    def get_location(self):
        return self.__location

    def get_title(self):
        return self.__title

    def get_content(self):
        return self.__content

    def get_url(self):
        return self.__url

    def get_date(self):
        return self.__date