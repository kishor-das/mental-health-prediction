import requests
import pandas as pd

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', 492)


#2015-2016
year_list_1 = ['2015','2016']

for i in year_list_1:
        url = "https://www.countyhealthrankings.org/sites/default/files/{0}%20County%20Health%20Rankings%20Data%20-%20v3.xls".format(str(i)) 
        resp = requests.get(url)
        with open('./data/'+str(i)+'.csv', 'wb') as output:
            output.write(resp.content)
        output.close()

#2017
url = "https://www.countyhealthrankings.org/sites/default/files/2017CountyHealthRankingsData.xls"
 
resp = requests.get(url)
with open('./data/2017.csv', 'wb') as output:
    output.write(resp.content)
output.close()

#2018
url = "https://www.countyhealthrankings.org/sites/default/files/2018%20County%20Health%20Rankings%20Data%20-%20v2.xls"
 
resp = requests.get(url)
with open('./data/2018.csv', 'wb') as output:

    output.write(resp.content)
output.close()

#2019    
url = "https://www.countyhealthrankings.org/sites/default/files/media/document/2019%20County%20Health%20Rankings%20Data%20-%20v3.xls"

 
resp = requests.get(url)
with open('./data/2019.csv', 'wb') as output:

    output.write(resp.content)
output.close()


#2020
url = "https://www.countyhealthrankings.org/sites/default/files/media/document/2020%20County%20Health%20Rankings%20Data%20-%20v2.xlsx"
 
resp = requests.get(url)
with open('./data/2020.csv', 'wb') as output:
    output.write(resp.content)
output.close()
