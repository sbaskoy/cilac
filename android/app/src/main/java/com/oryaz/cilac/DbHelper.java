package com.oryaz.cilac;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import com.google.gson.Gson;

public class DbHelper extends SQLiteOpenHelper {

    public static final String DATABASE_NAME = "LocalDb.db";
    public static final String CONTACTS_TABLE_NAME = "UygulamaKonumlar";
    public static final String CONTACTS_COLUMN_ID = "id";
    public static final String CONTACTS_COLUMN_JSON = "json";
    public static final String CONTACTS_COLUMN_DATE = "date";

    private HashMap hp;

    public DbHelper(Context context) {
        super(context, DATABASE_NAME , null, 1);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        Log.d("DATABASE","onCreate");
        db.execSQL(
                "Create table IF NOT EXISTS UygulamaKonumlar(id integer,json text,date text)"
        );
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        Log.d("DATABASE","onUpgrade");
        db.execSQL("DROP TABLE IF EXISTS UygulamaKonumlar");
        onCreate(db);
    }

    public boolean insert (String json, String date) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put("json", json);
        contentValues.put("date", date);

        db.insert("UygulamaKonumlar", null, contentValues);
        return true;
    }

    public UygulamaKonumlar getData(int id) {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor res =  db.rawQuery( "select * from UygulamaKonumlar where id="+id+"", null );
        if(res.getCount()==0)return null;
        List<String> result = new ArrayList<String>();
        while (res.moveToNext()) {
            result.add(res.getString(res.getColumnIndex("json")));
        }
        res.close();
        Gson gson=new Gson();
        UygulamaKonumlar locations=gson.fromJson(result.get(0),UygulamaKonumlar.class);


        return locations;
    }

    public int numberOfRows(){
        SQLiteDatabase db = this.getReadableDatabase();
        int numRows = (int) DatabaseUtils.queryNumEntries(db, CONTACTS_TABLE_NAME);
        return numRows;
    }

    public boolean updateContact (Integer id, String json, String date) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put("json", json);
        contentValues.put("date", date);

        db.update("UygulamaKonumlar", contentValues, "id = ? ", new String[] { Integer.toString(id) } );
        return true;
    }
}