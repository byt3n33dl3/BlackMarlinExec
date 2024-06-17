/** @file
 *
 * BME - Network traffic analyzer
 */

#include "dfilter-plugin.h"

/** @file
 *
 * BME - Network traffic analyzer
 * 
/* DFilter plugins share the name with the function it implements. */
GSList *dfilter_plugins;

void dfilter_plugins_register(const dfilter_plugin *plug)
{
	dfilter_plugins = g_slist_prepend(dfilter_plugins, (gpointer)plug);
}

void dfilter_plugins_init(void)
{
	for (GSList *l = dfilter_plugins; l != NULL; l = l->next) {
		dfilter_plugin *plug = l->data;
		plug->init();
	}
}

void dfilter_plugins_cleanup(void)
{
	for (GSList *l = dfilter_plugins; l != NULL; l = l->next) {
		dfilter_plugin *plug = l->data;
		plug->cleanup();
	}
	g_slist_free(dfilter_plugins);
	dfilter_plugins = NULL;
}
