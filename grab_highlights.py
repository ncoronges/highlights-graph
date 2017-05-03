import bs4, requests

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36'
}

from bs4 import BeautifulSoup

with requests.Session() as s:
    s.headers = headers
    r = s.get('https://kindle.amazon.com/login')
    soup = BeautifulSoup(r.content, "html.parser")
    signin_data = {s["name"]: s["value"]
                   for s in soup.select("form[name=signIn]")[0].select("input[name]")
                   if s.has_attr("value")}

    signin_data[u'email'] = 'ncoronges@gmail.com'
    signin_data[u'password'] = 'khaZau9a'

    response = s.post('https://www.amazon.com/ap/signin', data=signin_data)
    soup = bs4.BeautifulSoup(response.text, "html.parser")
    warning = soup.find('div', {'id': 'message_warning'})
    if warning:
        print('Failed to login: {0}'.format(warning.text))
    print(response.content)