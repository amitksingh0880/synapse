package com.synapse.ambient

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class SynapseGlanceWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.synapse_widget_layout).apply {
                val nextTitle = widgetData.getString("next_med_title", "All Doses Complete")
                val nextDosage = widgetData.getString("next_med_dosage", "Done for today")
                val nextTime = widgetData.getString("next_med_time", "--:--")
                val waterMl = widgetData.getInt("hydration_consumed_ml", 1750)

                setTextViewText(R.id.widget_med_title, nextTitle)
                setTextViewText(R.id.widget_med_dosage, nextDosage)
                setTextViewText(R.id.widget_med_time, nextTime)
                setTextViewText(R.id.widget_water_stat, "${waterMl} mL")
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
