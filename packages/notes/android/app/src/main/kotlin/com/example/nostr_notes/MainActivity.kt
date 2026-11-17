package com.alekseii.yu.popkov.nostrNotes

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener

class MainActivity : FlutterFragmentActivity(), FlutterUiDisplayListener {
    private var isFlutterUiDisplayed = false

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen().setKeepOnScreenCondition { !isFlutterUiDisplayed }
        super.onCreate(savedInstanceState)
    }

    override fun onFlutterUiDisplayed() {
        isFlutterUiDisplayed = true
    }

    override fun onFlutterUiNoLongerDisplayed() = Unit
}
