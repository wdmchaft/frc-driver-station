package com.comets.DriverStation;

import android.app.*;
import android.os.Bundle;
import android.widget.*;
import android.content.*;
import android.content.res.*;

public class DriverStationActivity extends TabActivity {
	
	
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        
        Resources res = getResources(); // Resource object to get Drawables
        TabHost tabHost = getTabHost();  // The activity TabHost
        TabHost.TabSpec spec;  // Resusable TabSpec for each tab
        Intent intent;  // Reusable Intent for each tab

        intent = new Intent().setClass(this, MainTabActivity.class);
        spec = tabHost.newTabSpec("main").setIndicator("Main",
                          res.getDrawable(R.drawable.controller))
                      .setContent(intent);
        tabHost.addTab(spec);

        intent = new Intent().setClass(this, IOTabActivity.class);
        spec = tabHost.newTabSpec("io").setIndicator("I/O",
                          res.getDrawable(R.drawable.sliders))
                      .setContent(intent);
        tabHost.addTab(spec);

        intent = new Intent().setClass(this, SettingsTabActivity.class);
        spec = tabHost.newTabSpec("settings").setIndicator("Settings",
                          res.getDrawable(R.drawable.gear2))
                      .setContent(intent);
        tabHost.addTab(spec);

        tabHost.setCurrentTab(0);
    }
}