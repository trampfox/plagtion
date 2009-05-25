/*
 * DO NOT EDIT THIS FILE - it is generated by Glade.
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

#include <gdk/gdkkeysyms.h>
#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

#define GLADE_HOOKUP_OBJECT(component,widget,name) \
  g_object_set_data_full (G_OBJECT (component), name, \
    gtk_widget_ref (widget), (GDestroyNotify) gtk_widget_unref)

#define GLADE_HOOKUP_OBJECT_NO_REF(component,widget,name) \
  g_object_set_data (G_OBJECT (component), name, widget)

GtkWidget*
create_mainWindow (void)
{
  GtkWidget *mainWindow;
  GtkWidget *mainNotebook;
  GtkWidget *empty_notebook_page;
  GtkWidget *label1;

  mainWindow = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_widget_set_size_request (mainWindow, 640, 480);
  gtk_window_set_title (GTK_WINDOW (mainWindow), _("Plagtion 0.0.1"));

  mainNotebook = gtk_notebook_new ();
  gtk_widget_show (mainNotebook);
  gtk_container_add (GTK_CONTAINER (mainWindow), mainNotebook);

  empty_notebook_page = gtk_vbox_new (FALSE, 0);
  gtk_widget_show (empty_notebook_page);
  gtk_container_add (GTK_CONTAINER (mainNotebook), empty_notebook_page);

  label1 = gtk_label_new (_("Plagtion"));
  gtk_widget_show (label1);
  gtk_notebook_set_tab_label (GTK_NOTEBOOK (mainNotebook), gtk_notebook_get_nth_page (GTK_NOTEBOOK (mainNotebook), 0), label1);

  g_signal_connect ((gpointer) mainWindow, "delete_event",
                    G_CALLBACK (on_mainWindow_delete_event),
                    NULL);

  /* Store pointers to all widgets, for use by lookup_widget(). */
  GLADE_HOOKUP_OBJECT_NO_REF (mainWindow, mainWindow, "mainWindow");
  GLADE_HOOKUP_OBJECT (mainWindow, mainNotebook, "mainNotebook");
  GLADE_HOOKUP_OBJECT (mainWindow, label1, "label1");

  return mainWindow;
}

