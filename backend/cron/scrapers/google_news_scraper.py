import time
import datetime as dt

from selenium import webdriver
from selenium.common import TimeoutException
from selenium.webdriver.chrome import options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.ui import WebDriverWait

from backend import config
from backend.cron import schemas
from backend.cron.scrapers import strategy_scraper


class Scraper(strategy_scraper.ScraperStrategy):
    def __init__(self, number_of_articles: int, language: str, location: str) -> None:
        self.__number_of_articles = number_of_articles
        self.__language = language
        self.__location = location
        self.__articles = list()

    @staticmethod
    def __configure_options() -> options.Options:
        o = options.Options()
        o.experimental_options['prefs'] = {
            'profile.default_content_setting_values.notifications': 2,
            'profile.default_content_setting_values.images': 2,
            'profile.default_content_setting_values.autoplay': 2
        }

        o.add_argument('--headless=new')
        o.add_argument('--disable-gpu')

        return o

    def scrape_articles(self) -> None:
        leftmost = config.LEFTMOST_COLUMN_INDEX[(self.__language, self.__location)]
        rightmost = leftmost + len(config.CATEGORIES[(self.__language, self.__location)])
        chrome_options = self.__configure_options()
        driver = webdriver.Chrome(options=chrome_options)
        driver.get(
            f"{config.GOOGLE_NEWS_URL}hl={self.__language}&gl={self.__location.upper()}&ceid={self.__location}:{self.__language.upper()}")

        buttons = driver.find_elements(By.CSS_SELECTOR, config.ACCEPT_ALL_SELECTOR)
        buttons[1].click()

        try:
            WebDriverWait(driver, 10).until(ec.presence_of_element_located((By.CLASS_NAME, config.HEADERS_SELECTOR)))
        except TimeoutException:
            print("Could not load page")
            return

        # go through all headers
        for current_idx in range(leftmost, rightmost):
            header = driver.find_elements(By.CLASS_NAME, config.HEADERS_SELECTOR)[current_idx]
            driver.get(header.get_attribute("href"))

            # get links to articles
            article_links = driver.find_elements(By.CLASS_NAME, config.ARTICLE_SELECTOR)[
                            :self.__number_of_articles * 4]

            # add columnId, name and url of article to articles list
            for i in range(0, len(article_links), 4):
                link = article_links[i].get_attribute("href")
                final_url = self.get_final_url(link, driver)
                if final_url is None or not all(domain not in final_url for domain in config.LINK_BLACKLIST):
                    continue

                self.__articles.append((
                    schemas.ParsedArticle(
                        category=config.CATEGORIES[(self.__language, self.__location)][current_idx - leftmost],
                        language=self.__language,
                        location=self.__location,
                        url=final_url,
                        date=dt.datetime.now(),
                        title=None,
                        content=None
                    )))

        driver.quit()

    @staticmethod
    def get_final_url(url: str, driver: webdriver) -> str:
        driver.execute_script("window.open('');")
        driver.switch_to.window(driver.window_handles[1])
        driver.get(url)

        try:
            time.sleep(1)
            WebDriverWait(driver, 10).until(lambda x: x.execute_script("return document.readyState") == "complete")
        except TimeoutException:
            print("Could not load page")
            return None

        final_url = driver.current_url
        driver.close()
        driver.switch_to.window(driver.window_handles[0])
        return final_url

    def print_articles(self):
        print(self.__articles)

    def get_articles(self):
        return self.__articles

    def set_language(self, language):
        self.__language = language

    def set_location(self, location):
        self.__location = location

    def set_number_of_articles(self, number):
        self.__number_of_articles = number
