#!/usr/bin/env python
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.keys import Keys
import time
import sys

# read the optus account from file
account_file=sys.argv[1]
f=open(account_file, 'r')
try:
    lines=f.readlines()
    username=lines[0].strip()
    password=lines[1].strip()
finally:
    f.close()

# get the optus traffic information
browser = webdriver.Firefox() 
try:
    browser.get("https://memberservices.optuszoo.com.au/ms/usagemeter/currentmonthdslbroadbandusagemeter.htm")

    browser.find_element_by_name("j_username").send_keys(username)
    browser.find_element_by_name("j_password").send_keys(password + Keys.RETURN)
    time.sleep(3)
    assert "Member Services" in browser.title

    try:
       status = browser.find_elements_by_xpath("//td[@class='label']")
       if len(status) > 1:
           print status[0].text.replace("\n", "")
           print status[1].text.replace("\n", "")
    except NoSuchElementException as e:
       assert 0, "load page error: " + str(e)
       exit(0)

finally:
    browser.close()
    browser.quit()

