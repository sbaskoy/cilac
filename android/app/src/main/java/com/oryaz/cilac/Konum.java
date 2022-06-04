package com.oryaz.cilac;

public class Konum {
    public String tarih;
    public String geoKonum;
    public boolean tip;
    String toJson(){
        return "{" +
                "\"tarih\":\"" + this.tarih+"\","+
                "\"geoKonum\":\""+this.geoKonum+"\","+
                "\"tip\":"+this.tip+
                "}";
    }
}
