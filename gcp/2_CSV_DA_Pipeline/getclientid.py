import google.auth
import google.auth.transport.requests
import requests
import six.moves.urllib.parse
from google.oauth2 import service_account
import subprocess 
import json
#Add the details Manually 


SCOPES = ['https://www.googleapis.com/auth/cloud-platform']
SERVICE_ACCOUNT_FILE = '../seismic-elf-261104-c47aa69e86d6.json'
project_id = 'seismic-elf-261104'
location = 'us-central1'
composer_environment = 'sanch-composer'


credentials = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
# Authenticate with Google Cloud.Airflow + Docker + Kubernetes (Scalable and painless data pipeline)
# See: https://cloud.google.com/docs/authentication/getting-started
#credentials = service_account.Credentials.from_service_account_file('../seismic-elf-261104-c47aa69e86d6.json')
#scoped_credentials = credentials.with_scopes(['https://www.googleapis.com/auth/cloud-platform'])


authed_session = google.auth.transport.requests.AuthorizedSession(credentials)

environment_url = ('https://composer.googleapis.com/v1beta1/projects/{}/locations/{}'
                '/environments/{}').format(project_id, location, composer_environment)
composer_response = authed_session.request('GET', environment_url)
environment_data = composer_response.json()
airflow_uri = environment_data['config']['airflowUri']

# The Composer environment response does not include the IAP client ID.
# Make a second, unauthenticated HTTP request to the web server to get the
# redirect URI.
redirect_response = requests.get(airflow_uri, allow_redirects=False)
redirect_location = redirect_response.headers['location']

# Extract the client_id query parameter from the redirect.
parsed = six.moves.urllib.parse.urlparse(redirect_location)
query_string = six.moves.urllib.parse.parse_qs(parsed.query)
clientid=query_string['client_id'][0]
print(clientid)

output= None
######### Extarct the Airflow server API name 
output=subprocess.check_output(['gcloud' ,'composer' ,'environments' ,'describe' ,composer_environment ,'--location' , location ,'--format=\"json\"'])
#output=subprocess.call("gcloud composer environments describe "+ composer_environment+  " --location " + location + " --format=\"value(config.airflowUri)\"", shell=True)
webserver=json.loads(output)['config']['airflowUri'][8:-12]   
print(webserver)

#delete 2 lines from strat in main.py 
with open('main.py', 'r') as fin:
    data = fin.read().splitlines(True)
with open('main.py', 'w') as fout:
    fout.writelines(data[2:])

#Append this line sin the main.py 
line1="webserver = " + "\""+ webserver  + "\""
line2="clientid = " +  "\""+ clientid +  "\""

with open("main.py", 'r+') as f:
    content = f.read()
    f.seek(0, 0)
    f.write(line1.rstrip('\r\n') + '\n' + content)

with open("main.py", 'r+') as f:
    content = f.read()
    f.seek(0, 0)
    f.write(line2.rstrip('\r\n') + '\n' + content)

