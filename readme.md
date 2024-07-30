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

### Password

The encryption key must be exactly a 16-character length string.


### Command Line Application

Currently, Adobe AIR doesn't allow console output, so if `nogui` is enabled the application will only be able to communicate errors through the `output.log` file in the Application Resource directory, ie Roaming.