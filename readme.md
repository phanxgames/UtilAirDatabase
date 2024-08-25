## UtilAirDatabase

Creates an SQLite database in the Adobe AIR format with optional encryption.

Inputs include either an .sql file or an existing .db SQLite database file. 

### Create Database

Create a database from an SQL file:
```
UtilAirDatabase.exe sql="C:\path\to\file.sql" 
out="C:\path\to\file.db" encrypt=true password="password"
```
Create a database from an existing SQLite database file:
```
UtilAirDatabase.exe db="C:\path\to\file.db" 
out="C:\path\to\file.db" encrypt=true password="password"
```
Omit the `encrypt` and `password` parameters to create an unencrypted database.  
The provided input database `db` cannot be encrypted.

### Decrypt Database

Clones an encrypted database to a new unencrypted database:
```
UtilAirDatabase.exe db="C:\path\to\file.db" 
out="C:\path\to\file.db" decrypt=true password="password"
```

### All Options

- `sql` `="path.sql"` Path to the input SQL file.
- `db` `="path.db"` Path to the input SQLite database file.
- `out` `="path.db"` Path to the output SQLite database file.
- `encrypt` `=true` Encrypt the output database.
- `decrypt`  `=true` Decrypt the provided database.
- `password`  `="passwordHere"` Password for encryption/decryption.
- `nogui` - Disable the GUI.
- `socket` `=9999` Enable socket communication on the provided local port.
- `socketcb` `=9` Socket callback code (any number) to reply to the specific request.

### Password

The encryption key must be exactly a 16-character length string.


### Command Line Application

Currently, Adobe AIR doesn't allow console output, so if `nogui` is enabled the application will only be 
able to communicate errors through the `output.log` file in the Application Resource directory, ie Roaming.


### Socket Communication

The application can communicate with a calling process through a socket connection.
This allows for a pseudo strout-like response to the calling process.

Usage:
```
UtilAirDatabase.exe ... socket=9999 socketcb=9
```
The application will attempt to connect to the provided socket port, a server setup from the calling process. 
See middleware [UtilAirDatabase-nodejs](https://github.com/phanxgames/UtilAirDatabase-nodejs) for an example.

The socketcb parameter is an incrementing number that the calling process can use to identify the callback response to the request. 
This is optional, but is needed in the middleware implementation.