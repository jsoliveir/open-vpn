#!/bin/python3
import os
username = os.environ["username"]
password = os.environ["password"]

login_url='https://login.microsoftonline.com/'
username_field_name="loginfmt"
password_field_name="passwd"

from selenium import webdriver

from webdriver_manager.chrome \
    import ChromeDriverManager

from selenium.webdriver.support \
    import expected_conditions as EC

from selenium.webdriver.chrome.service \
    import Service

from selenium.webdriver.support.ui \
    import WebDriverWait

from selenium.webdriver.chrome.options \
    import Options

from selenium.webdriver.common.keys \
    import Keys

from selenium.webdriver.common.by \
    import By

# Initialize the WebDriver
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
chrome_options.add_argument("--disable-extensions")

service = Service(executable_path=ChromeDriverManager().install())
driver = webdriver.Chrome(service=service,options=chrome_options)

# Open the Microsoft login page
driver.get(login_url)

try:
    # Wait until the username input field is present
    WebDriverWait(driver, 10)\
        .until(EC.presence_of_element_located((By.NAME, username_field_name)))
    
    # Enter the username
    username_field = driver.find_element(By.NAME, username_field_name)
    username_field.send_keys(username)
    username_field.send_keys(Keys.RETURN)
    
    # Wait for the password input field to appear
    password_field = WebDriverWait(driver, 10)\
        .until(EC.visibility_of_element_located((By.NAME, password_field_name)))
    
    password_field.send_keys(password)
    password_field.send_keys(Keys.RETURN)

    WebDriverWait(driver, 10)\
        .until(EC.invisibility_of_element_located((By.NAME,  password_field_name)))

    print("Login successful")
    exit(0)
except Exception as e:
    print("Login failed")
    exit(1)
finally:
    # Close the browser
    driver.quit()