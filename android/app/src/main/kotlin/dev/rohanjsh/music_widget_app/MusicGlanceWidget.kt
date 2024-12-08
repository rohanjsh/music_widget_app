package dev.rohanjsh.music_widget_app

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.ImageProvider
import androidx.glance.Image
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import androidx.glance.layout.Alignment
import androidx.compose.ui.unit.sp
import androidx.glance.layout.size
import androidx.glance.unit.ColorProvider
import androidx.glance.layout.ContentScale
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.height
import androidx.glance.text.FontWeight
import androidx.glance.text.TextAlign

class MusicGlanceWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val data = currentState.preferences
        val isPlaying = data.getBoolean("isPlaying", false)

        Box(
            modifier = GlanceModifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            // Background Image
            Image(
                provider = ImageProvider(R.drawable.widget_background),
                contentDescription = null,
                modifier = GlanceModifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
            
            // Content Column
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                verticalAlignment = Alignment.Vertical.Top
            ) {

                Spacer(modifier = GlanceModifier.height(32.dp))
                // Play/Pause Button
                Box(
                    modifier = GlanceModifier
                        .clickable(onClick = actionRunCallback<TogglePlayback>()),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        provider = ImageProvider(
                            if (isPlaying) android.R.drawable.ic_media_pause
                            else android.R.drawable.ic_media_play
                        ),
                        contentDescription = if (isPlaying) "Pause" else "Play",
                        modifier = GlanceModifier.size(40.dp) // Slightly smaller to accommodate text
                    )
                }
                Spacer(modifier = GlanceModifier.height(12.dp))
                Text(
                    text = "A cool song",
                    style = TextStyle(
                        color = ColorProvider(Color.White),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center
                    )
                )


            }
        }
    }
}

class TogglePlayback : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("appWidgets://toggleplay")
        )
        backgroundIntent.send()
    }
}