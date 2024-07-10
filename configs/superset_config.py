from urllib.parse import quote_plus
from sensorfabric.mdh import MDH
from sensorfabric import utils
import os
from datetime import datetime, timezone
import base64

# Will store global keys for connecting directly with MDH Data Explorer.
MDH_dataExplorer = {
    'AccessKeyId': '',
    'SecretAccessKey': '',
    'SessionToken':'',
    'Expiration':'',
    'region':'us-east-1',
    'catalog':'AwsDataCatalog',
    'schema_name':'',
    'workgroup': 'mdh_export_database_external_prod',
    's3_output': ''
}

# Holds details about MDH service account credentials.
secret_key = None
service_account = None
project_id = None

def getExplorerCredentials(secret_key, service_account, project_id):
    """
    Get the temporary AWS explorer credentials from AWS.
    These only last for a certain amount of time before they expire.
    """
    global MDH_dataExplorer  # We are going to make changes to this.

    mdh = MDH(account_secret=secret_key,
          account_name=service_account,
          project_id=project_id)
    token = mdh.genServiceToken()

    dataExplorer = mdh.getExplorerCreds()

    # Populate the global MDH explorer credentials.
    for key in dataExplorer.keys():
        if key in MDH_dataExplorer:
            MDH_dataExplorer[key] = dataExplorer[key]

    print(f"New explorer credentials have been generated. Will expire on - {MDH_dataExplorer['Expiration']}")

def custom_db_connector_mutator(uri, params, username, security_manager, source):
    global MDH_dataExplorer

    # We only update the sql alchemy parameters
    if not uri.host == 'mdh.athena.com': 
        return uri, params

    # Do a quick check to make sure that the credentials have not expired.
    expireUTC = datetime.fromisoformat(MDH_dataExplorer['Expiration'])
    nowUTC = datetime.now(timezone.utc)
    if nowUTC > expireUTC:
        getExplorerCredentials(secret_key, service_account, project_id)

    # Rewrite the SQLALCHEMY_DATABASE_URI here if needed for mdh specific injections.
    uri = (
            f"awsathena+rest://"
            f"athena.{MDH_dataExplorer['region']}.amazonaws.com:443/{MDH_dataExplorer['schema_name']}"
            f"?s3_staging_dir={quote_plus(MDH_dataExplorer['s3_output'])}&work_group={MDH_dataExplorer['workgroup']}"
            )

    params = {
        "connect_args": {
            "catalog_name": MDH_dataExplorer['catalog'],
            "aws_access_key_id": MDH_dataExplorer['AccessKeyId'],
            "aws_secret_access_key": MDH_dataExplorer['SecretAccessKey'],
            "aws_session_token": MDH_dataExplorer['SessionToken']
        }
    }

    return uri, params

DB_CONNECTION_MUTATOR=custom_db_connector_mutator

ROW_LIMIT = 100000
PREFERRED_DATABASES = [
    'Amazon Athena'
]

SECRET_KEY=os.environ.get('SECRET_KEY')
if SECRET_KEY is None:
    raise Exception('SECRET_KEY environment variable not set')

# If the MDH_SECRET envrionment variable has been set then we put superset in MDH
# connect mode.
if os.getenv('MDH_SECRET') and os.getenv('MDH_ACC_NAME') and os.getenv('MDH_PROJECT_ID'):
    print('Superset is being put in MDH connect mode.')

    secret_key = os.getenv('MDH_SECRET')
    # Decode the base64 string into normal multiline string for the key.
    secret_key = base64.b64decode(secret_key)
    service_account = os.getenv('MDH_ACC_NAME')
    project_id = os.getenv('MDH_PROJECT_ID')

    # This sets the global variable MDH_dataExplorer with the required credentials.
    getExplorerCredentials(secret_key,
                           service_account,
                           project_id)

    # Also add some of the other fields needed to make the connection from the enviroment
    # variables.
    MDH_dataExplorer['region'] = os.getenv('MDH_REGION', 'us-east-1')
    MDH_dataExplorer['schema_name'] = os.getenv('MDH_SCHEMA')
    MDH_dataExplorer['s3_output'] = os.getenv('MDH_S3')
else:
    print('Normal superset mode.')
