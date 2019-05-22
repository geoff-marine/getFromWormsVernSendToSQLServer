import requests
import pyodbc
import platform
from auth import username, password, Iusername, Ipassword

server = 'vminformdev01' 
database = 'InformaticsLoad' 

if platform.system() == 'Windows':
    driver = 'SQL Server'
else:
    driver = 'ODBC Driver 17 for SQL Server'

cnxn = pyodbc.connect('DRIVER={'+driver+'};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+password)
cursor = cnxn.cursor()

query = 'SELECT distinct AphiaID from ERDDAP_ALL_OBSERVATIONS_BY_SPECIES'

cursor.execute(query)
listOfAphiaIDS = []

Iserver = 'DMSQL' 
Idatabase = 'ReferenceLists' 

Icnxn = pyodbc.connect('DRIVER={'+driver+'};SERVER='+Iserver+';DATABASE='+Idatabase+';UID='+Iusername+';PWD='+Ipassword)
Icursor = Icnxn.cursor()

for row in cursor.fetchall():
    listOfAphiaIDS.append(row)
        
Icursor.execute('truncate table [SpeciesVernacular]')

for row in listOfAphiaIDS: 
    resp = requests.get('http://www.marinespecies.org/rest/AphiaVernacularsByAphiaID/' + str(row.AphiaID))
    #if statement to handle badly formed responses
    if 'json' in resp.headers.get('Content-Type'):       
        for todo_item in resp.json():       
            if todo_item['language_code'] == 'eng':
                insertValue = row.AphiaID, todo_item['vernacular'], todo_item['language_code'], todo_item['language']
                Icursor.execute('''INSERT INTO [SpeciesVernacular] 
                ([AphiaID], [vernacular], [language_code], [language]) VALUES (?,?,?,?)''',  (insertValue))
                
Icursor.commit()
cursor.close()
Icursor.close()