from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from parsed_article import ParsedArticle
from shared import config
from datetime import datetime
import time


class GoogleNewsScraper:
    def __init__(self, lang_region: (str, str)):
        if lang_region not in config.SUPPORTED_LANGUAGES:
            raise Exception("Language not supported")
        self.__options = None
        self.__number_of_columns = len(config.CATEGORIES[lang_region])
        self.__leftmost = config.LEFTMOST_COLUMN_INDEX[lang_region]
        self.__lang = lang_region[0]
        self.__location = lang_region[1]
        self.__articles = []

        self.__configure_options()
        self.__driver = self.__initialize_webdriver()
        self.__wait = WebDriverWait(self.__driver, 10)
        google_news_url = 'https://news.google.com/home?hl={lang}&gl={locationU}&ceid={locationU}:{lang}'.format(
            lang=lang_region[0], locationU=lang_region[1].upper(), location=lang_region[1])

        self.__driver.get(google_news_url)
        self.scrape_articles()
        self.__driver.quit()

    def __configure_options(self):
        self.__options = Options()
        self.__options.experimental_options['prefs'] = {
            'profile.default_content_setting_values.notifications': 2,
            'profile.default_content_setting_values.images': 2,
            'profile.default_content_setting_values.autoplay': 2
        }

        self.__options.add_argument('--headless=new')
        self.__options.add_argument('--disable-gpu')

    def __initialize_webdriver(self):
        self.__driver = webdriver.Chrome(options=self.__options)
        return webdriver.Chrome(options=self.__options)

    def scrape_articles(self):
        buttons = self.__driver.find_elements(By.CSS_SELECTOR, config.ACCEPT_ALL_SELECTOR)
        buttons[1].click()
        try:
            element = self.__wait.until(EC.presence_of_element_located((By.CLASS_NAME, config.HEADERS_SELECTOR)))
        except TimeoutError:
            print("Could not load page")
            return

        # go through all headers
        for current_idx in range(self.__leftmost, self.__leftmost + self.__number_of_columns):
            header = self.__driver.find_elements(By.CLASS_NAME, config.HEADERS_SELECTOR)[current_idx]
            self.__driver.get(header.get_attribute("href"))

            # get links to articles
            article_links = self.__driver.find_elements(By.CLASS_NAME, config.ARTICLE_SELECTOR)[:config.NUMBER_OF_SCRAPED_ARTICLES_PER_CATEGORY]

            # add columnId, name and url of article to articles list
            for i in range(len(article_links)):
                link = article_links[i].get_attribute("href")
                final_url = self.get_final_url(link)
                if final_url is None:
                    continue

                self.__articles.append(
                    (ParsedArticle(
                        category=config.CATEGORIES[(self.__lang, self.__location)][current_idx - self.__leftmost],
                        title="",
                        url=final_url,
                        lang=self.__lang,
                        location=self.__location,
                        date=datetime.now().strftime("%d/%m/%Y %H:%M:%S"
                                                     ))))

    def get_final_url(self, url: str) -> str | None:
        # get final url after redirections from news.google.com
        driver = webdriver.Chrome(options=self.__options)
        driver.get(url)
        buttons = WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located((By.CSS_SELECTOR, 'button.VfPpkd-LgbsSe'))
        )
        buttons[1].click()

        try:
            time.sleep(1)
            self.__wait.until(lambda x: x.execute_script("return document.readyState") == "complete")
        except TimeoutError:
            print("Could not load page")
            return None

        final_url = driver.current_url
        driver.quit()
        return final_url

    def print_articles(self):
        print(self.__articles)

    def get_articles(self):
        return self.__articles



