package com.oryaz.cilac;

import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.location.Location;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;

import java.security.Permission;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MyLocationService extends Service {

    public static final String ACTION_START_FOREGROUND_SERVICE = "ACTION_START_FOREGROUND_SERVICE";

    public static final String ACTION_STOP_FOREGROUND_SERVICE = "ACTION_STOP_FOREGROUND_SERVICE";
    public static final String CHANNEL_ID = "ForegroundServiceChannel";

    private FusedLocationProviderClient mClient;
    private DbHelper dbHelper;
    private  int id;
    private  UygulamaKonumlar locations;
    LocationCallback mLocationCallback;
    @Override
    public void onCreate() {
        super.onCreate();
        Log.d("SERVICES INFO","Service on create");
        mClient= LocationServices.getFusedLocationProviderClient(getApplicationContext());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(intent != null){
            String action = intent.getAction();
            switch (action){
                case ACTION_START_FOREGROUND_SERVICE:
                    Bundle extras = intent.getExtras();
                    id = (int) extras.get("id");
                    dbHelper=new DbHelper(getApplicationContext());
                    locations=dbHelper.getData(id);
                    createNotificationChannel();
                    startServiceWithNotification();
                    startLocationUpdate();
                    break;
                case ACTION_STOP_FOREGROUND_SERVICE:
                    mClient.removeLocationUpdates(mLocationCallback);
                    stopForeground(true);
                    stopSelf();


                    break;
            }

        }

        return START_STICKY;
    }
    void startLocationUpdate(){
        LocationRequest locationRequest=new LocationRequest();
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        locationRequest.setInterval(1000);
        locationRequest.setFastestInterval(500);

        if(ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED){
            Log.d("LOC","Yar bana haram gecer");
            stopSelf();
            return;
        }
        if(ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_BACKGROUND_LOCATION) != PackageManager.PERMISSION_GRANTED){
            Log.d("LOC","Yar bana haram gecer");
            stopSelf();
            return;
        }
        mLocationCallback=new LocationCallback(){
            @Override
            public void onLocationResult(LocationResult locationResult) {
                if(locationResult == null){
                    Log.d("ERROR","failed location callback");
                    return;
                }

                Location loc=locationResult.getLastLocation();
                String lat=new Double(loc.getLatitude()).toString();
                String lng=new Double(loc.getLongitude()).toString();
                Konum konum=new Konum();
                konum.tip=false;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    konum.tarih= Instant.now().toString();
                }else{
                    konum.tarih="unknown date";
                }
                konum.geoKonum="POINT("+lat+" "+lng+")";
                locations.data.add(konum);
                dbHelper.updateContact(id,locations.toJson(),new Date().toString());


            }
        };
        mClient.requestLocationUpdates(locationRequest,mLocationCallback, Looper.getMainLooper());
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d("LOG","on destroy");
    }
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Background channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }
    void startServiceWithNotification() {
        Intent closeIntent = new Intent(this, MyService.class);
        closeIntent.setAction(MyLocationService.ACTION_STOP_FOREGROUND_SERVICE);
        PendingIntent pendingCloseIntent = PendingIntent.getService(this, 0, closeIntent, 0);

        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0);
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Arkaplanda konumunuz alınıyor.")
                .setContentText("İlaçlama yaptıgınız güzergahı belirleyebilmek için arkaplanda konumunuz alınıyor.")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                //.addAction(android.R.drawable.ic_media_play,"play",pendingPlayIntent)
                //.addAction(android.R.drawable.ic_media_pause,"pause",pendingPauseIntent)
               //.addAction(android.R.drawable.ic_delete,"close",pendingCloseIntent)

                .build();
        startForeground(1,notification);
    }
}