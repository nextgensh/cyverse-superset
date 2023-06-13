[![Project Supported by CyVerse](https://de.cyverse.org/Powered-By-CyVerse-blue.svg)](https://learning.cyverse.org/projects/vice/en/latest/) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

# UA Cyverse Superset

## What is Apache Superset and what can it be used for?
Superset is no-code visualization framework that offers users the following options

1. Create interactive dashboard.
1. Pick from a wide range of charts without writing a single line of code.
1. Provides an interactive SQL editor as part of SQL Lab.
1. Save, share and view recent queries.
1. Connect to wide range of databases including AWS Athena. A complete list can be found [here](https://superset.apache.org/docs/databases/installing-database-drivers)

Superset acts as thin layer between your data source and the visualization dashboards. Hence it can process large quantities of data,
limited only by the database backend chosen.
You can read more about Superset in the [official documentation.](https://superset.apache.org/docs/intro)

## How is this different from the standard superset docker build?
This build has been adapted to run on UA Cyverse with the following modifications

1. SQLlite is set to be the default database to store metadata for superset (this is where all the connection data, graphs and dashboards is saved).
1. The original docker build for superset spins up a separate container for each service - redis cache, postgresql database for metastore, websocket for async communication, and superset app.
   We are limited to a single container on Cyverse. Hence in memory cache support with redis has been droped. Postgresql has been switched out for sqlite. Websocket support has been droped.
   This build is meant only for data exploration in a research setting, not for running in production.
1. A periodic cron job (every 5 minutes) is responsible for copying the local sqlite database into `superset-sqlite` inside the users cyverse home folder. This allows for the application data
   to remain persistent even after restarts. 
1. During startup the app checks inside `superset-sqlite` to check if a database file exists. If it does then charts, users and dashboard from it are loaded.

## How do I start this app in Cyverse?
1. Navigate to cyverse discovery environment.
1. On the top left dropdown pick `Browse All Apps`
1. Look for an app named `sensorfabric-superset`

Alternatively you can also use the search bar on the top in discovery environment and search for `sensorfabric-superset`. 

## How do I launch the app?
Click on the application to get started. You will then be taken to the quick launch wizard.

1. Give a name to your analysis and pick an output folder (you can leave these as default)
1. Fill up the analysis parameters in the next screen. 
   **If you plan to reuse this instance of superset make to store these parameters securely as they will be needed to resume all your dashboards and login** 
   1. Admin Username - Each superset instance sets up a default admin user. This is the username for it. You will need it to login.
   1. Admin Password - Password for your admin account.
   1. Secret Key - The local database stored in your home folder is encrypted using this key. We recommend setting a key that is atleast alphanumeric and 42 characters long. Longer the better!
      If you are on Linux, Mac or inside WSL in windows you can generate a random secret using `openssl rand -base64 42`. 
1. Resource Requirements - You can leave this default. If you plan to render compute expensive graphs you might want to give yourself more CPU cores for rendering.
1. (optional) You can save your parameters for a saved launch in the next step. This will allow to quickly launch the instance again to reuse your charts, and won't have to keep entering the same paramters over and over again.

## Are we done?
Yes! Click on `goto analysis`.
The application could take sevral minutes to launch to launch. You can always come to it from the analysis section.
You will see a sign in screen. Once you enter your credentials (you setup during the launch) you should be able to login into superset.

## Where do I find the local database file?
Every 5 minutes the app automatically stores the local database file into `/iplant/home/[cyverse_username]/superset-sqlite`. 
**DANGER-**Anyone you share this file with along with the launch parameters will have full access to your dashboards, and database keys. Please be careful who you share this with.
Because this file is automatically synced, we recommend waiting at least 5 minutes before terminating your analysis from the time you have made any change.

## Resuming were you left off
If you want to resume your previous dashboard, just start the app again using the exact same parameters you used initially to launch it.

## How can I can share my dashboards with other cyverse users?
If you share the databse file `superset-sqlite/superset.db` with other cyverse users along with launch parameters, they can access your dashbaords.

## Someone shared their database file with me, how do I resume from it?
1. Add this file inside `/iplant/home/[cyverse_username]/superset-sqlite`
1. Launch the app with the same launch parameters as those used by the original user when the dashboards were made.

## How do I connect to AWS Athena database for sensorfabric?
1. Log into superset.
1. Click on `settings` in the top right.
1. Click on `database connections`.
1. Click on `+ Database` to add a new database connection.
1. If you are using sensorfabric select `Amazon Athena` from the `Supported Databases` dropdown.
1. Change the name to your liking.
1. If using sensorfabric the `SQLALCHEMY URI` would have been shared with you securely using UA Stache. **Never store this locally on your laptop or right it down.**
1. Click on `Connect` and you are all set.
