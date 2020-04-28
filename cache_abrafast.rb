require 'selenium-webdriver'

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
@driver = Selenium::WebDriver.for :chrome, options: options
@wait = Selenium::WebDriver::Wait.new(timeout: 120)
@driver.manage.timeouts.implicit_wait = 60
@refresh = 5

def runner
  main_index = href_loop('https://abrafast.store/sitemap_index.xml')
  map_loop(main_index)
end

def href_loop(url)
  puts "*****  opening #{url}  *****"
  @driver.get "#{url}"
  page_links = get_sitemaps(@driver)
  puts "*****  generating href list for #{url}  *****"
  hrefs = []
  page_links.each do |link|
    hrefs << link.text
  end
  puts "*****  href list generated  *****"
  return hrefs
end

def map_loop(href_list)
  href_list.each do |link|
    secondary_index = href_loop(link)
    secondary_index.each do |url|
      cache_url(url)
    end
  end
end

def cache_url(url)
  puts url
  @refresh.times do 
    @driver.get "#{url}"
  end
end

def get_sitemaps(driver)
  index_table = get_element(driver, :id, 'sitemap')
  sitemaps = get_elements(index_table, :css, '[href]')
end

def get_element(instance, selector, selector_name)
  element = @wait.until {
    element = instance.find_element(selector, selector_name)
    element if element != nil
  }
  return element
end

def get_elements(instance, selector, selector_name)
  elements = @wait.until {
    elements = instance.find_elements(selector, selector_name)
    elements if elements != []
  }
  return elements
end

runner