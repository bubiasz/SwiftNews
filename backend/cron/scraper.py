import time
import datetime as dt

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from backend import config
from backend.cron import schemas


class GoogleNewsScraper:
    def __init__(self, language: str, location: str) -> None:
        self.__options = None
        self.__number_of_columns = len(config.CATEGORIES[(language, location)])
        self.__leftmost = config.LEFTMOST_COLUMN_INDEX[(language, location)]
        self.__language = language
        self.__location = location
        self.__articles = []

        self.__configure_options()
        self.__driver = webdriver.Chrome(options=self.__options)
        self.__wait = WebDriverWait(self.__driver, 10)
        self.__driver.get(
            f"{config.NEWS_URL}hl={language}&gl={location.upper()}&ceid={location}:{language.upper()}")

        self.scrape_articles()
        self.__driver.quit()

    def __configure_options(self) -> None:
        self.__options = Options()
        self.__options.experimental_options['prefs'] = {
            'profile.default_content_setting_values.notifications': 2,
            'profile.default_content_setting_values.images': 2,
            'profile.default_content_setting_values.autoplay': 2
        }

        self.__options.add_argument('--headless=new')
        self.__options.add_argument('--disable-gpu')

    def scrape_articles(self) -> None:
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
            article_links = self.__driver.find_elements(By.CLASS_NAME, config.ARTICLE_SELECTOR)[
                            :config.NUMBER_OF_SCRAPED_ARTICLES_PER_CATEGORY]

            # add columnId, name and url of article to articles list
            for i in range(len(article_links)):
                link = article_links[i].get_attribute("href")
                final_url = self.get_final_url(link)
                if final_url is None:
                    continue

                self.__articles.append((
                    schemas.ParsedArticle(
                        category=config.CATEGORIES[(self.__language, self.__location)][current_idx - self.__leftmost],
                        language=self.__language,
                        location=self.__location,
                        url=final_url,
                        date=dt.datetime.now(),
                        title=None,
                        content=None
                    )))

    def get_final_url(self, url: str) -> str:
        driver = webdriver.Chrome(options=self.__options)
        driver.get(url)
        buttons = WebDriverWait(driver, 10).until(
            EC.presence_of_all_elements_located((By.CSS_SELECTOR, 'button.VfPpkd-LgbsSe')))
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
