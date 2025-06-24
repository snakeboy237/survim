from selenium import webdriver

driver = webdriver.Chrome()
driver.get("http://localhost:8080")
assert "Pension Portal" in driver.title
driver.quit()
