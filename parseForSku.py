import sys

from bs4 import BeautifulSoup
soup = BeautifulSoup(sys.stdin, 'html.parser')

print (soup.find(class_='js-product-item').get('data-digital-river-id'))