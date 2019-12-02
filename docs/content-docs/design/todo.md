---
title: Perl6 GTK+ Design
#nav_title: Examples
nav_menu: default-nav
sidebar_menu: design-sidebar
layout: sidebar
---

## TODO list of things
* [ ] **Boxed** values and objects must have the following implemented to prevent memory leaks;
  * [ ] A boolean test to check if object is valid
  * [ ] A clear function which calls some free function -> toggles the valid flag
  * [ ] A `DESTROY()` submethod which calls the clear method or free func if object is still valid.

* [ ] Study ref/unref of gtk objects.

* [x] Reverse testing procedures in `_fallback()` methods.
  ```
  try { $s = &::("gtk_list_store_$native-sub"); };
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;
  ```
  In other packages `gtk_` can be `g_` or `gdk_`.
  * [x] glib
  * [x] gobject
  * [x] gdk
  * [x] gtk

* [x] Add a test to `_fallback()` so that the prefix 'gtk_' can be left of the sub name when used. So the above tests can become;
  ```
  try { $s = &::("gtk_list_store_$native-sub"); };
  try { $s = &::("gtk_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;
  ```
  Also here, in other packages `gtk_` can be `g_` or `gdk_`.
  * [x] glib
  * [x] gobject
  * [x] gdk
  * [x] gtk
  The call to the sub `gtk_list_store_remove` can now be one of `.gtk_list_store_remove()`, `.list_store_remove()` or `.remove()` and the dashed ('-') counterparts. Bringing it down to only one word like the 'remove' above, will not always work. Special cases are `new()` and other methods from classes like **Any** or **Mu**.
  * [ ] Find the short named subs which are also defined in Any or Mu
    * append
    * new
  * [ ] Add a method to catch the call before the one of Any/Mu

* [ ] Is there a way to skip all those if's in the `_fallback()`.

* [x] Caching the sub address in Object must be more specific. There could be a sub name (short version) in more than one module. So the class name of the caller should be stored with it too. We can take the $!gtk-class-name for it. It is even a bug, because equally named subs can be called on the wrong objects. This happened on the Library project where .get-text() from Entry was taken to run on a Label.

* [ ] Make some of the routines in several packages the same
  * [ ] .clear-object()
  * [ ] [ ] .set-native-object()
  * [ ] .get-native-object()
  * [ ] .is-valid()

* [ ] I have noticed that True and False can be used on int32 typed values. The G_TYPE_BOOLEAN (Gtk) or gboolean (Glib C) are defined as int32. Therefore, in these cases, True and False can be used in the examples and documentation instead of 0 or 1.

* [ ] Reorder the list of methods in all modules in such a way that they are sorted.

* [ ] Many methods return native objects. this could be molded into p6 objects when possible.

* [ ] Make it possible to call e.g. `.gtk_label_new()` on a typed object.

* [ ] Add 'is export' to all subs in interface modules. This can help when the subs are needed directly from the interface using modules. Perhaps it can also simplify the `_fallback()` calls to search for subs in interfaces.

* [ ] Use **Method::Also** to have several names for methods. Later on, the other methods can be deprecated. This might be needed when the export TODO above will not help keeping the sub a sub.