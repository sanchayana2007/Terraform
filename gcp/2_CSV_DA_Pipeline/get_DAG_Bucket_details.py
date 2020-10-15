import google.auth
import google.auth.transport.requests
import os
import json 
# Authenticate with Google Cloud.
# See: https://cloud.google.com/docs/authentication/getting-started
d={}

#Set the ServiceAccount file 
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "../compose-test-291802-1f8ba3535e89.json"

#print(os.environ["GOOGLE_APPLICATION_CREDENTIALS"])

credentials, _ = google.auth.default(
            scopes=['https://www.googleapis.com/auth/cloud-platform'])

#credentials= "../seismic-elf-261104-c47aa69e86d6.json"
authed_session = google.auth.transport.requests.AuthorizedSession(
            credentials)

project_id = 'compose-test-291802'
location = 'us-central1'
composer_environment = 'sanch-composer2'

environment_url = (
            'https://composer.googleapis.com/v1beta1/projects/{}/locations/{}'
                '/environments/{}').format(project_id, location, composer_environment)
response = authed_session.request('GET', environment_url)
environment_data = response.json()

# Print the bucket name from the response body.
dag_bucket=environment_data['config']['dagGcsPrefix']
dag_bucket= dag_bucket + '/'

d["dag_bucket"]=dag_bucket
print(json.dumps(d))
