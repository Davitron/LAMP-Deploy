# LAMP-Deploy
An output that demonstrates how to deploy a minimalistic LAMP stack application


#### TOOLS USED

- CLOUD PROVIDER - Google Cloud PLatform(GCP)
  
- AUTOMATION SCRIPT - BASH SCRIPT
- CLI TOOL - GCLOUD SDK

### GETTING STARTED
#### Installations
1) Create an [account](https://cloud.google.com/) on GCP
2) Install the [GCLOUD SDK / CLI](https://cloud.google.com/sdk/) tool

#### Authentication
3) Switch to your terminal and run `$ gcloud auth login` to authenticate your CLI tool
4) If you don not have a project, you can create one with 
   
   `$ gcloud projects create <PROJECT-ID> --name="<PROJECT-NAME>"`
5) Set the project you want gcloud to interact with `$ gcloud set project PROJECT-ID
   
#### Deployment
There are 4 variables to take note of.
  - APPNAME  - The name of the application you want to deploy
  - SQL_ROOT_PASSWORD - The root password for the MYSQL database
  - DB_NAME - The database name for the the LAMP stack application
  - DB_PASSWORD - The password for the LAMP stack database

6) run the deployment with the following command
   
   ` bash setup-server.sh <APPNAME> <SQL_ROOT_PASSWORD> <DB_NAME> <DB_PASSWORD>`