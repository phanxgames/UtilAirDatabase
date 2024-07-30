package {
import flash.data.SQLConnection;
import flash.data.SQLMode;
import flash.filesystem.File;
import flash.utils.ByteArray;

public class DatabaseInfo {

    private var _path:String;
    private var _conn:SQLConnection;
    private var _baEncryptionKey:ByteArray;
    private var _name:String;
    private var _file:File;


    public function DatabaseInfo(name:String) {
        this._name = name;
    }

    public function setPassword(password:String):void {
        _baEncryptionKey = new ByteArray();
        _baEncryptionKey.writeUTFBytes(password);
        _baEncryptionKey.position = 0;
    }

    public function create():void {
        _conn = new SQLConnection();
        _conn.open(_file, SQLMode.CREATE, false, 1024, _baEncryptionKey);
    }
    public function open():void {
        _conn = new SQLConnection();
        _conn.open(_file, SQLMode.UPDATE, false, 1024, _baEncryptionKey);
    }

    public function attach(database:DatabaseInfo, aliasName:String=null):void {
        _conn.attach(aliasName?aliasName:database._name, database._file, null, database._baEncryptionKey);
    }

    public function deleteIfExists():Boolean {
        if (_file==null) return false;
        if (_file.exists) {
            _file.deleteFile();
            return true;
        }
        return false;
    }

    public function get path():String {
        return _path;
    }

    public function set path(value:String):void {
        _path = value
        _file = File.applicationStorageDirectory.resolvePath(_path);

    }


    public function get conn():SQLConnection {
        return _conn;
    }


    public function get name():String {
        return _name;
    }

    public function get file():File {
        return _file;
    }
}
}
