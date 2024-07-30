package {

import com.sociodox.utils.Base64;
import com.sociodox.utils.Base64;

import flash.data.SQLConnection;
import flash.data.SQLIndexSchema;
import flash.data.SQLSchemaResult;
import flash.data.SQLStatement;
import flash.data.SQLTableSchema;
import flash.data.SQLViewSchema;
import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.events.InvokeEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.ByteArray;

[SWF(width="1200", height="800", frameRate="60", backgroundColor="#FFFFFF")]
public class UtilAirDatabase extends Sprite {

    /**
     * Use TextField to replace console, since AIR doesn't allow console output currently.
     */
    public var textField:TextField;
    public var logBuffer:String;

    public var sqlPath:String;
    public var dbPath:String;
    public var encrypt:Boolean = false;
    public var decrypt:Boolean = false;
    public var password:String;
    public var outputPath:String;
    public var nogui:Boolean = false;
    
    public function UtilAirDatabase() {
        NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);

        textField = new TextField();
        textField.text = logBuffer = "UtilAirDatabase\n";
        textField.width = 1200;
        textField.height = 800;
        textField.multiline = true;
        textField.defaultTextFormat = new TextFormat("Arial", 14, 0x000000);
        addChild(textField);

        winTrace("------------------------------------");
        winTrace("Default Storage Path: " + File.applicationStorageDirectory.nativePath);
        winTrace("------------------------------------");
    }
    

    private function onInvoke(e:InvokeEvent):void {

        var args:Array = e.arguments;
        if (args==null || args.length == 0) {
            winTrace("Arguments are required. Please see documentation for more information.");
            return;
        }
        trace("Args: " , args);


        for each (var arg:String in args) {
            //only split first equal from arg string
            var parts:Array = arg.split("=");
            parts[0] = parts[0].toLowerCase();
            parts[1] = parts.slice(1).join("=");

            var command:String = parts[0];
            var value:String = parts[1];
            switch (command) {
                case "nogui":
                    NativeApplication.nativeApplication.activeWindow.visible = false;
                    nogui = true;
                    break;
                case "sql":
                    sqlPath = value;
                    break;
                case "db":
                case "database":
                    dbPath = value;
                    break;
                case "encrypt":
                    encrypt = value == "true";
                    break;
                case "key":
                case "password":
                    password = value;
                    break;
                case "out":
                case "output":
                    outputPath = value;
                    break;
                case "decrypt":
                    decrypt = value == "true";
                    break;
            }
        }

        if (decrypt) {
            routineDecryptDatabase();
        } else {
            if (sqlPath) {
                routineSQLtoDatabase();
            }
            if (dbPath) {
                routineDatabaseToDatabase();
            }
        }

        if (nogui) {
            //exit
            NativeApplication.nativeApplication.exit();
        }

        logTracesToFile();

    }

    /**
     * Decrypt the database. Save the database to the output path
     */
    protected function routineDecryptDatabase():void {

        if (dbPath == null || password==null) {
            winTrace("No database or password provided to decrypt");
            return;
        }
        if (outputPath == null) {
            winTrace("No output path provided for decryption");
            return;
        }

        //Process the Decrypt Database
        try {
            //create new database to hold decrypted data
            var dbTarget:DatabaseInfo = new DatabaseInfo("target");
            dbTarget.path = outputPath;
            if (dbTarget.deleteIfExists()) {
                winTrace("Output file already exists. Deleting file");
            }
            dbTarget.create();

            winTrace("Decrypting database...");
            winTrace("Database output path: " + dbTarget.file.nativePath);

            //open source database file
            var dbSource:DatabaseInfo = new DatabaseInfo("source");
            dbSource.path = dbPath;
            dbSource.setPassword(password);
            dbSource.open();

            cloneDatabase(dbSource, dbTarget);


        } catch (err:Error) {
            winTrace("Error decrypting database");
            winTrace(err.getStackTrace());
            winTrace("Process Aborted");
            return;
        }

        winTrace("Process Completed");

    }

    /**
     * Process the sql file.  Encrypt the database if required. Save the database to the output path
     */
    protected function routineSQLtoDatabase():void {

        if (sqlPath == null ) {
            winTrace("No sql path provided");
            return;
        }
        if (outputPath == null) {
            winTrace("No output path provided");
            return;
        }

        try {
            //create database
            var db:DatabaseInfo = new DatabaseInfo("target");
            db.path = outputPath;
            db.setPassword(password);
            if (db.deleteIfExists()) {
                winTrace("Output file already exists. Deleting file");
            }
            db.create();

            if (encrypt) {
                winTrace("Creating database with encryption");
            } else {
                winTrace("Creating database without encryption");
            }
            winTrace("Database output path: " + db.file.nativePath);

            winTrace("Processing SQL file: " + sqlPath);

            //open sql file
            var sql:String;
            try {
                var file:File = File.applicationStorageDirectory.resolvePath(sqlPath);
                var fs:FileStream = new FileStream();
                fs.open(file, FileMode.READ);
                sql = fs.readUTFBytes(fs.bytesAvailable);
                fs.close();
            } catch (err:Error) {
                winTrace("Error reading sql file", sqlPath);
                winTrace(err);
                return;
            }

            //execute sql commands
            var commands:Array = sql.split(";");

            db.conn.begin();

            for each (var command:String in commands) {
                if (command == null || command.length == 0) continue;
                try {
                    exec(db.conn, command);
                } catch (err:Error) {
                    winTrace("Error executing command: " + command);
                    winTrace(err);
                }
            }
            db.conn.commit();

            db.conn.close();
        } catch (err:Error) {
            winTrace("Error creating database from SQL:");
            winTrace(err.getStackTrace());
            winTrace("Process Aborted");
            return;
        }

        winTrace("Process Completed");
    }

    /**
     * Process the database file. Encrypt the database if required. Save the database to the output path
     */
    protected function routineDatabaseToDatabase():void {

        if (dbPath == null) {
            winTrace("No database input path provided");
            return;
        }
        if (outputPath == null) {
            winTrace("No output path provided");
            return;
        }

        try {
            //create database
            var dbTarget:DatabaseInfo = new DatabaseInfo("target");
            dbTarget.path = outputPath;
            dbTarget.setPassword(password);
            if (dbTarget.deleteIfExists()) {
                winTrace("Output file already exists. Deleting file");
            }
            dbTarget.create();

            if (encrypt) {
                winTrace("Creating database with encryption");
            } else {
                winTrace("Creating database without encryption");
            }
            winTrace("Database output path: " + dbTarget.file.nativePath);
            winTrace("Processing Database file...");


            //open database file
            var dbSource:DatabaseInfo = new DatabaseInfo("source");
            dbSource.path = dbPath;
            dbSource.open();

            cloneDatabase(dbSource, dbTarget);


        } catch (err:Error) {
            winTrace("Error creating database from Database:");
            winTrace(err.getStackTrace());
            winTrace("Process Aborted");
            return;
        }

        winTrace("Process Completed");
    }

    /**
     * Clone database from source to target.
     */
    protected function cloneDatabase(source:DatabaseInfo, target:DatabaseInfo):void {

        // Copy the schema and data from the source database to the target database
        source.conn.loadSchema();
        var result:SQLSchemaResult = source.conn.getSchemaResult();

        source.conn.close();

        target.conn.begin();
        for each (var table:SQLTableSchema in result.tables) {
            exec(target.conn, table.sql);
            winTrace(table.sql);
        }
        for each (var indice:SQLIndexSchema in result.indices) {
            exec(target.conn, indice.sql);
        }
        for each (var view:SQLViewSchema in result.views) {
            exec(target.conn, view.sql);
        }
        target.conn.commit();


        target.attach(source, "source");

        target.conn.begin();

        for each (var table:SQLTableSchema in result.tables) {
            exec(target.conn, "INSERT INTO " + table.name + " SELECT * FROM source." + table.name + ";");
        }

        target.conn.commit();

        target.conn.detach("source");
        target.conn.close();
    }
    protected function exec(db:SQLConnection, sql:String):void {
        try {
            var queryStatement:SQLStatement = new SQLStatement();
            queryStatement.sqlConnection = db;
            queryStatement.text = sql;
            queryStatement.execute();
        } catch (err:Error) {
            //Catch error to show error in "console"
            winTrace("Error executing command: " + sql);
            winTrace(err);
            //throw error anyway so transaction can fail
            throw err;
        }
    }
    public function winTrace(...strs):void {
        var mess:String = strs.join(" ");
        logBuffer += mess + "\n";
        textField.text += mess + "\n";
        trace(mess);
    }
    public function logTracesToFile():void {
        var file:File = File.applicationStorageDirectory.resolvePath("output.log");
        if (file.exists) file.deleteFile();
        var fs:FileStream = new FileStream();
        fs.open(file, FileMode.WRITE);
        fs.writeUTFBytes(logBuffer);
        fs.close();
    }

}
}
