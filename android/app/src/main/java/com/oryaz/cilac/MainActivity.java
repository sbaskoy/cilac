package com.oryaz.cilac;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Debug;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private Intent serviceIntent;
    private String  methodChannel="com.oryaz.cilac/backgroudservice";
    private  static final String STREAM="com.oryaz.cilac/stream";
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        serviceIntent=new Intent(MainActivity.this,MyService.class);
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),methodChannel).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                        if(call.method.equals("startService")){
                        int id=(int)call.argument("id");
                        startBackgroundService(id);
                        result.success("services started");
                        }
                        if(call.method.equals("stopService")){
                            stopBackgroundService();
                            result.success("services stop");
                        }
                        if(call.method.equals("alwaysLocation")){
                            boolean res=checkLocationPermission();
                            result.success(res);
                        }
                    }
                }
        );
    }

    public static final int MY_PERMISSIONS_REQUEST_LOCATION = 99;

    public boolean checkLocationPermission() {
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {

            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION)) {

                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.
                new AlertDialog.Builder(this)
                        .setTitle("Konum İzni")
                        .setMessage("Bu uygulama arkaplanda konumuzu kullanmak istiyor.")
                        .setPositiveButton("Kabul Et", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialogInterface, int i) {
                                //Prompt the user once explanation has been shown
                                ActivityCompat.requestPermissions(MainActivity.this,
                                        new String[]{Manifest.permission.ACCESS_BACKGROUND_LOCATION},
                                        MY_PERMISSIONS_REQUEST_LOCATION);
                            }
                        })
                        .create()
                        .show();


            } else {
                // No explanation needed, we can request the permission.
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                        MY_PERMISSIONS_REQUEST_LOCATION);
            }
            return false;
        } else {
            return true;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_LOCATION: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, yay! Do the
                    // location-related task you need to do.
                    if (ContextCompat.checkSelfPermission(this,
                            Manifest.permission.ACCESS_FINE_LOCATION)
                            == PackageManager.PERMISSION_GRANTED) {

                        //Request location updates:

                    }

                } else {

                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.

                }
                return;
            }

        }
    }
    private  void stopBackgroundService(){
        Intent serviceIntent = new Intent(getApplicationContext(),MyLocationService.class);
        serviceIntent.setAction(MyLocationService.ACTION_STOP_FOREGROUND_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
            Log.d("SDK IND > VERSION","startForegroundService");
        } else {
            startService(serviceIntent);
            Log.d("SDK IND < VERSION","startService");
        }
    }
    private void startBackgroundService(int id){
        Intent serviceIntent = new Intent(this,MyLocationService.class);
        serviceIntent.putExtra("id", id);
        serviceIntent.setAction(MyLocationService.ACTION_START_FOREGROUND_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startService(serviceIntent);
            Log.d("SDK IND > VERSION","startForegroundService");
        } else {
            startService(serviceIntent);
            Log.d("SDK IND < VERSION","startService");
        }
    }
}
