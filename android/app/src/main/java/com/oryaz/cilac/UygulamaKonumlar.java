package com.oryaz.cilac;

import java.util.List;

public class UygulamaKonumlar {
    public  int pUygulamaID;
    public List<Konum> data;
    String toJson(){
        String str="";
        for (Konum konum:this.data
             ) {
            str+=konum.toJson()+",";
        }
        str=str.substring(0,str.length()-1);
        return  "{"+
                "\"pUygulamaID\":"+this.pUygulamaID+","+
                "\"data\":["+
                str+
        "]"+
                "}";


    }
}

