package com.oryaz.cilac;

import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;

import android.hardware.GeomagneticField;

import android.provider.Settings;
import android.widget.Toast;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;


import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MyService extends Service {
    private static final String TAG_FOREGROUND_SERVICE = "FOREGROUND_SERVICE";

    public static final String ACTION_START_FOREGROUND_SERVICE = "ACTION_START_FOREGROUND_SERVICE";

    public static final String ACTION_STOP_FOREGROUND_SERVICE = "ACTION_STOP_FOREGROUND_SERVICE";

    public static final String ACTION_PAUSE = "ACTION_PAUSE";

    public static final String ACTION_PLAY = "ACTION_PLAY";
    public static final String LISTEN = "LISTEN";
    public static final String STOP_LISTEN = "STOP_LISTEN";
    public static final String CHANNEL_ID = "ForegroundServiceChannel";

    private static final int MINUTES = 1000 * 60 * 2;
    public LocationManager locationManager;
    public MyLocationListener listener;
    public Location previousBestLocation = null;
    public static Context mContext;
    private boolean isGpsEnabled = false;
    private boolean isNetworkEnabled = false;

    private GeomagneticField geoField;
    private double latitude = 0.0;
    private double longitude = 0.0;
    private DbHelper dbHelper;
    private int id = 0;
    UygulamaKonumlar konumlar;


    public class MyLocationListener implements LocationListener {
        @RequiresApi(api = Build.VERSION_CODES.O)
        public void onLocationChanged(final Location loc) {
            //if (isBetterLocation(loc, previousBestLocation)) {

            //}
            setupFinalLocationData(loc);
        }

        public void onProviderDisabled(String provider) {
        }

        public void onProviderEnabled(String provider) {
        }

        public void onStatusChanged(String provider, int status, Bundle extras) {
        }
    }



    @Override
    public void onCreate() {
        super.onCreate();

        mContext = getApplicationContext();
        Log.d("LOG!","onCreate");
        dbHelper = new DbHelper(mContext);
        Log.d("LOG!","dbHelper");
        if (locationManager == null) {
            locationManager = (LocationManager) mContext.getSystemService(Context.LOCATION_SERVICE);
        }
        Log.d("LOG!","getCurrentLocation");
            getCurrentLocation();
    }



    private void getCurrentLocation() {
        try {
            assert locationManager != null;
            isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
            isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
            Log.d("LOG!","getCurrentLocation Ok");
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        if (!isGpsEnabled && !isNetworkEnabled) {
            showSettingsAlert();
        }
        listener = new MyLocationListener();
        Log.d("LOG!","Listener");

        try {
            locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 0, listener);
            locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 1000, 0, listener);
        } catch (SecurityException e) {
            e.printStackTrace();
        }
    }

    private void showSettingsAlert() {
        Toast.makeText(mContext, "GPS is disabled in your device. Please Enable it ?", Toast.LENGTH_LONG).show();
        Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }

    protected boolean isBetterLocation(Location location, Location currentBestLocation) {
        if (currentBestLocation == null) {
            return true;
        }
        long timeDelta = location.getTime() - currentBestLocation.getTime();
        boolean isSignificantlyNewer = timeDelta > MINUTES;
        boolean isSignificantlyOlder = timeDelta < -MINUTES;
        boolean isNewer = timeDelta > 0;

        if (isSignificantlyNewer) {
            return true;
        } else if (isSignificantlyOlder) {
            return false;
        }

        int accuracyDelta = (int) (location.getAccuracy() - currentBestLocation.getAccuracy());
        boolean isLessAccurate = accuracyDelta > 0;
        boolean isMoreAccurate = accuracyDelta < 0;
        boolean isSignificantlyLessAccurate = accuracyDelta > 200;
        boolean isFromSameProvider = isSameProvider(location.getProvider(), currentBestLocation.getProvider());
        if (isMoreAccurate) {
            return true;
        } else if (isNewer && !isLessAccurate) {
            return true;
        } else if (isNewer && !isSignificantlyLessAccurate && isFromSameProvider) {
            return true;
        }
        return false;
    }


    private boolean isSameProvider(String provider1, String provider2) {
        if (provider1 == null) {
            return provider2 == null;
        }
        return provider1.equals(provider2);
    }
    @RequiresApi(api = Build.VERSION_CODES.O)
    private void setupFinalLocationData(Location mLocation) {
        Log.d("LOG!","final Data");
        if (mLocation != null) {
            geoField = new GeomagneticField(
                    Double.valueOf(mLocation.getLatitude()).floatValue(),
                    Double.valueOf(mLocation.getLongitude()).floatValue(),
                    Double.valueOf(mLocation.getAltitude()).floatValue(),
                    System.currentTimeMillis()
            );

            latitude = mLocation.getLatitude();
            longitude = mLocation.getLongitude();
            Log.d("LOG!","final Data 2");
            String lat=new Double(latitude).toString();
            String lng=new Double(longitude).toString();
            Konum konum=new Konum();
            konum.tip=false;
            konum.tarih= Instant.now().toString();
            konum.geoKonum="POINT("+lat+" "+lng+")";
            konumlar.data.add(konum);
            Log.d("LOG!","final Data 3");
            Log.d("LOC",konum.geoKonum);
            dbHelper.updateContact(id,konumlar.toJson(),new Date().toString());

        }
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);
        if(intent != null)
        {
            String action = intent.getAction();
            switch (action)
            {
                case ACTION_START_FOREGROUND_SERVICE:
                    Bundle extras = intent.getExtras();
                    id = (int) extras.get("id");
                    konumlar=new UygulamaKonumlar();
                    konumlar.pUygulamaID=id;
                    konumlar.data=new ArrayList<Konum>();

                    createNotificationChannel();

                    //Intent playIntent = new Intent(this, ISoundService.class);
                    //playIntent.setAction(ACTION_PLAY);
                    //PendingIntent pendingPlayIntent = PendingIntent.getService(this, 0, playIntent, 0);

                    //Intent pauseIntent = new Intent(this, ISoundService.class);
                    //pauseIntent.setAction(ACTION_PAUSE);
                    //PendingIntent pendingPauseIntent = PendingIntent.getService(this, 0, pauseIntent, 0);

                    Intent closeIntent = new Intent(this, MyService.class);
                    closeIntent.setAction(MyService.ACTION_STOP_FOREGROUND_SERVICE);
                    PendingIntent pendingCloseIntent = PendingIntent.getService(this, 0, closeIntent, 0);

                    Intent notificationIntent = new Intent(this, MainActivity.class);
                    PendingIntent pendingIntent = PendingIntent.getActivity(this,
                            0, notificationIntent, 0);
                    Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                            .setContentTitle("Background process")
                            .setContentText("Your location listening on background")
                            .setSmallIcon(R.mipmap.ic_launcher)
                            .setContentIntent(pendingIntent)
                            //.addAction(android.R.drawable.ic_media_play,"play",pendingPlayIntent)
                            //.addAction(android.R.drawable.ic_media_pause,"pause",pendingPauseIntent)
                            .addAction(android.R.drawable.ic_delete,"close",pendingCloseIntent)

                            .build();
                    startForeground(1, notification);




                    // Toast.makeText(getApplicationContext(), "Foreground service is started.", Toast.LENGTH_LONG).show();
                    break;
                case ACTION_STOP_FOREGROUND_SERVICE:
                    locationManager.removeUpdates(listener);
                    stopForegroundService();

                    break;
                case ACTION_PLAY:

                    break;
                case ACTION_PAUSE:

                    break;

            }
        }
        return START_STICKY;
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
    private void stopForegroundService()
    {
        Log.d(TAG_FOREGROUND_SERVICE, "Stop foreground service.");


        stopForeground(true);


        stopSelf();
    }



    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
