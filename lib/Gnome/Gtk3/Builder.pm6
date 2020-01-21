#TL:1:Gnome::Gtk3::Builder:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Gtk3::Builder

Build an interface from an XML UI definition

=head1 Description

=comment add C<gtk_builder_new_from_resource()> when ready

A B<Gnome::Gtk3::Builder> is an auxiliary object that reads textual descriptions of a user interface and instantiates the described objects. To create a B<Gnome::Gtk3::Builder> from a user interface description, call C<gtk_builder_new_from_file()> or C<gtk_builder_new_from_string()>.

=comment add C<gtk_builder_add_from_resource()> when ready

In the (unusual) case that you want to add user interface descriptions from multiple sources to the same B<Gnome::Gtk3::Builder> you can call C<gtk_builder_new()> to get an empty builder and populate it by (multiple) calls to C<gtk_builder_add_from_file()> or C<gtk_builder_add_from_string()>.

A B<Gnome::Gtk3::Builder> holds a reference to all objects that it has constructed and drops these references when it is finalized. This finalization can cause the destruction of non-widget objects or widgets which are not contained in a toplevel window. For toplevel windows constructed by a builder, it is the responsibility of the user to call C<gtk_widget_destroy()> to get rid of them and all the widgets they contain.

=begin comment
The functions C<gtk_builder_get_object()> and C<gtk_builder_get_objects()>
can be used to access the widgets in the interface by the names assigned
to them inside the UI description. Toplevel windows returned by these
functions will stay around until the user explicitly destroys them
with C<gtk_widget_destroy()>. Other widgets will either be part of a
larger hierarchy constructed by the builder (in which case you should
not have to worry about their lifecycle), or without a parent, in which
case they have to be added to some container to make use of them.
Non-widget objects need to be reffed with C<g_object_ref()> to keep them
beyond the lifespan of the builder.

The function C<gtk_builder_connect_signals()> and variants thereof can be
used to connect handlers to the named signals in the description.
=end comment

=head2 Gnome::Gtk3::Builder UI Definitions

B<Gnome::Gtk3::Builder> parses textual descriptions of user interfaces which are specified in an XML format which can be roughly described by the RELAX NG schema below. We refer to these descriptions as “B<Gnome::Gtk3::Builder> UI definitions” or just “UI definitions” if the context is clear.

It is common to use `.ui` as the filename extension for files containing B<Gnome::Gtk3::Builder> UI definitions.

<!--[RELAX NG Compact Syntax](https://git.gnome.org/browse/gtk+/tree/gtk/gtkbuilder.rnc)-->

The toplevel element is <interface>. It optionally takes a “domain” attribute, which will make the builder look for translated strings using C<dgettext()> in the domain specified. This can also be done by calling C<gtk_builder_set_translation_domain()> on the builder. Objects are described by <object> elements, which can contain <property> elements to set properties, <signal> elements which connect signals to handlers, and <child> elements, which describe child objects (most often widgets inside a container, but also e.g. actions in an action group, or columns in a tree model). A <child> element contains an <object> element which describes the child object. The target toolkit version(s) are described by <requires> elements, the “lib” attribute specifies the widget library in question (currently the only supported value is “gtk+”) and the “version” attribute specifies the target version in the form “<major>.<minor>”. The builder will error out if the version requirements are not met.

Typically, the specific kind of object represented by an <object> element is specified by the “class” attribute. If the type has not been loaded yet, GTK+ tries to find the C<get_type()> function from the class name by applying heuristics. This works in most cases, but if necessary, it is possible to specify the name of the C<get_type()> function explictly with the "type-func" attribute. As a special case, B<Gnome::Gtk3::Builder> allows to use an object that has been constructed by a B<Gnome::Gtk3::UIManager> in another part of the UI definition by specifying the id of the B<Gnome::Gtk3::UIManager> in the “constructor” attribute and the name of the object in the “id” attribute.

Objects may be given a name with the “id” attribute, which allows the application to retrieve them from the builder with C<gtk_builder_get_object()> which is also used indirectly when a widget is created usin `.new(:$build-id)`. An id is also necessary to use the object as property value in other parts of the UI definition. GTK+ reserves ids starting and ending with ___ (3 underscores) for its own purposes.

Setting properties of objects is pretty straightforward with the <property> element: the “name” attribute specifies the name of the property, and the content of the element specifies the value. If the “translatable” attribute is set to a true value, GTK+ uses C<gettext()> (or C<dgettext()> if the builder has a translation domain set) to find a translation for the value. This happens before the value is parsed, so it can be used for properties of any type, but it is probably most useful for string properties. It is also possible to specify a context to disambiguate short strings, and comments which may help the translators.

B<Gnome::Gtk3::Builder> can parse textual representations for the most common property types: characters, strings, integers, floating-point numbers, booleans (strings like “TRUE”, “t”, “yes”, “y”, “1” are interpreted as C<1>, strings like “FALSE”, “f”, “no”, “n”, “0” are interpreted as C<0>), enumerations (can be specified by their name, nick or integer value), flags (can be specified by their name, nick, integer value, optionally combined with “|”, e.g. “GTK_VISIBLE|GTK_REALIZED”) and colors (in a format understood by C<gdk_rgba_parse()>).

=begin comment
GVariants can be specified in the format understood by C<g_variant_parse()>, and pixbufs can be specified as a filename of an image file to load.
=end comment

Objects can be referred to by their name and by default refer to objects declared in the local xml fragment and objects exposed via C<gtk_builder_expose_object()>. In general, B<Gnome::Gtk3::Builder> allows forward references to objects — declared in the local xml; an object doesn’t have to be constructed before it can be referred to. The exception to this rule is that an object has to be constructed before it can be used as the value of a construct-only property.

=begin comment
It is also possible to bind a property value to another object's property value using the attributes "bind-source" to specify the source object of the binding, "bind-property" to specify the source property and optionally "bind-flags" to specify the binding flags Internally builder implement this using GBinding objects. For more information see C<g_object_bind_property()>
=end comment

Signal handlers are set up with the <signal> element. The “name” attribute specifies the name of the signal, and the “handler” attribute specifies the function to connect to the signal. The remaining attributes, “after” and “swapped” attributes are ignored by the Raku modules. The "object" field has a meaning in B<Gnome::Gtk3::Glade>.

=begin comment
By default, GTK+ tries to find the handler using C<g_module_symbol()>, but this can be changed by passing a custom C<builder-connect-func()> to C<gtk_builder_connect_signals_full()>. The remaining attributes, “after”, “swapped” and “object”, have the same meaning as the corresponding parameters of the C<g_signal_connect_object()> or C<g_signal_connect_data()> functions. A “last_modification_time” attribute is also allowed, but it does not have a meaning to the builder.
=end comment

Sometimes it is necessary to refer to widgets which have implicitly been constructed by GTK+ as part of a composite widget, to set properties on them or to add further children (e.g. the I<vbox> of a B<Gnome::Gtk3::Dialog>). This can be achieved by setting the “internal-child” propery of the <child> element to a true value. Note that B<Gnome::Gtk3::Builder> still requires an <object> element for the internal child, even if it has already been constructed.

A number of widgets have different places where a child can be added (e.g. tabs vs. page content in notebooks). This can be reflected in a UI definition by specifying the “type” attribute on a <child>. The possible values for the “type” attribute are described in the sections describing the widget-specific portions of UI definitions.

=head2 A Gnome::Gtk3::Builder UI Definition

Note the class names are e.g. GtkDialog, not Gnome::Gtk3::Dialog. This is because those are the c-source class names of the GTK+ objects.

  <interface>
    <object class="GtkDialog>" id="dialog1">
      <child internal-child="vbox">
        <object class="GtkBox>" id="vbox1">
          <property name="border-width">10</property>
          <child internal-child="action_area">
            <object class="GtkButtonBox>" id="hbuttonbox1">
              <property name="border-width">20</property>
              <child>
                <object class="GtkButton>" id="ok_button">
                  <property name="label">gtk-ok</property>
                  <property name="use-stock">TRUE</property>
                  <signal name="clicked" handler="ok_button_clicked"/>
                </object>
              </child>
            </object>
          </child>
        </object>
      </child>
    </object>
  </interface>

To load it and use it do the following (assume above text is in $gui).

  my Gnome::Gtk3::Builder $builder .= new(:string($gui));
  my Gnome::Gtk3::Button $button .= new(:build-id<ok_button>));



=begin comment
Beyond this general structure, several object classes define their own XML DTD fragments for filling in the ANY placeholders in the DTD above. Note that a custom element in a <child> element gets parsed by the custom tag handler of the parent object, while a custom element in an <object> element gets parsed by the custom tag handler of the object.

These XML fragments are explained in the documentation of the respective objects.
=end comment

=begin comment
Additionally, since 3.10 a special <template> tag has been added to the format allowing one to define a widget class’s components. See the [B<Gnome::Gtk3::Widget> documentation](https://developer.gnome.org/gtk3/3.24/GtkWidget.html#composite-templates) for details.
=end comment


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Gtk3::Builder;
  also is Gnome::GObject::Object;

=head2 Example

  my Gnome::Gtk3::Builder $builder .= new;
  my Gnome::Glib::Error $e = $builder.add-from-file($ui-file);
  die $e.message if $e.error-is-valid;

  my Gnome::Gtk3::Button .= new(:build-id<my-glade-button-id>);

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::Glib::Error;
use Gnome::GObject::Object;

#-------------------------------------------------------------------------------
# /usr/include/gtk-3.0/gtk/INCLUDE
# https://developer.gnome.org/WWW
unit class Gnome::Gtk3::Builder:auth<github:MARTIMM>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=end pod
#-------------------------------------------------------------------------------
=begin pod
=head2 enum GtkBuilderError

Error codes that identify various errors that can occur while using
B<Gnome::Gtk3::Builder>.


=item GTK_BUILDER_ERROR_INVALID_TYPE_FUNCTION: A type-func attribute didn’t name a function that returns a C<GType>.
=item GTK_BUILDER_ERROR_UNHANDLED_TAG: The input contained a tag that B<Gnome::Gtk3::Builder> can’t handle.
=item GTK_BUILDER_ERROR_MISSING_ATTRIBUTE: An attribute that is required by B<Gnome::Gtk3::Builder> was missing.
=item GTK_BUILDER_ERROR_INVALID_ATTRIBUTE: B<Gnome::Gtk3::Builder> found an attribute that it doesn’t understand.
=item GTK_BUILDER_ERROR_INVALID_TAG: B<Gnome::Gtk3::Builder> found a tag that it doesn’t understand.
=item GTK_BUILDER_ERROR_MISSING_PROPERTY_VALUE: A required property value was missing.
=item GTK_BUILDER_ERROR_INVALID_VALUE: B<Gnome::Gtk3::Builder> couldn’t parse some attribute value.
=item GTK_BUILDER_ERROR_VERSION_MISMATCH: The input file requires a newer version of GTK+.
=item GTK_BUILDER_ERROR_DUPLICATE_ID: An object id occurred twice.
=item GTK_BUILDER_ERROR_OBJECT_TYPE_REFUSED: A specified object type is of the same type or derived from the type of the composite class being extended with builder XML.
=item GTK_BUILDER_ERROR_TEMPLATE_MISMATCH: The wrong type was specified in a composite class’s template XML
=item GTK_BUILDER_ERROR_INVALID_PROPERTY: The specified property is unknown for the object class.
=item GTK_BUILDER_ERROR_INVALID_SIGNAL: The specified signal is unknown for the object class.
=item GTK_BUILDER_ERROR_INVALID_ID: An object id is unknown


=end pod

#TE:1:GtkBuilderError:
enum GtkBuilderError is export (
  'GTK_BUILDER_ERROR_INVALID_TYPE_FUNCTION',
  'GTK_BUILDER_ERROR_UNHANDLED_TAG',
  'GTK_BUILDER_ERROR_MISSING_ATTRIBUTE',
  'GTK_BUILDER_ERROR_INVALID_ATTRIBUTE',
  'GTK_BUILDER_ERROR_INVALID_TAG',
  'GTK_BUILDER_ERROR_MISSING_PROPERTY_VALUE',
  'GTK_BUILDER_ERROR_INVALID_VALUE',
  'GTK_BUILDER_ERROR_VERSION_MISMATCH',
  'GTK_BUILDER_ERROR_DUPLICATE_ID',
  'GTK_BUILDER_ERROR_OBJECT_TYPE_REFUSED',
  'GTK_BUILDER_ERROR_TEMPLATE_MISMATCH',
  'GTK_BUILDER_ERROR_INVALID_PROPERTY',
  'GTK_BUILDER_ERROR_INVALID_SIGNAL',
  'GTK_BUILDER_ERROR_INVALID_ID'
);

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

#-------------------------------------------------------------------------------
#`{{
void
(*GtkBuilderConnectFunc) (
  GtkBuilder *builder,
                          GObject *object,
                          const gchar *signal_name,
                          const gchar *handler_name,
                          GObject *connect_object,
                          GConnectFlags flags,
                          gpointer user_data);
}}

#-------------------------------------------------------------------------------
=begin pod
=head2 new

Create builder object and load gui design.

  multi method new ( Str :$filename! )

Same as above but read the design from the string.

  multi method new ( Str :$string! )

Create an empty builder.

  multi method new ( Bool :$empty! )

=end pod

#TM:1:new():
#TM:0:new(:filename):
#TM:0:new(:string):

submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'Gnome::Gtk3::Builder';

  if ? %options<filename> {
    self.set-native-object(gtk_builder_new_from_file(%options<filename>));
  }

  elsif ? %options<string> {
    self.set-native-object(
      gtk_builder_new_from_string( %options<string>, %options<string>.chars)
    );
  }

  elsif ? %options<empty> {
    Gnome::N::deprecate( '.new(:empty)', '.new()', '0.21.3', '0.24.0');
    self.set-native-object(gtk_builder_new());
  }

#TODO No widget or build-id for a builder!
#  elsif ? %options<native-object> || %options<build-id> {
#    # provided in GObject
#  }

  elsif %options.keys.elems {
    die X::Gnome.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }

  else { #elsif ? %options<empty> {
    self.set-native-object(gtk_builder_new());
  }

  # only after creating the native-object, the gtype is known
  self.set-class-info('GtkBuilder');


  self.set-builder(self);
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("gtk_builder_$native-sub"); }
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;

#note "ad $native-sub: ", $s;
  self.set-class-name-of-sub('GtkBuilder');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
#TODO check if these are needed
multi method add-gui ( Str:D :$filename! ) {

  Gnome::N::deprecate(
    '.add-gui(:filename)', '.gtk_builder_add_from_file()', '0.18.4', '0.22.0'
  );

  my Gnome::Glib::Error $e = gtk_builder_add_from_file(
    self.get-native-object, $filename
  );
  die X::Gnome.new(:message($e.message)) if $e.error-is-valid;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
multi method add-gui ( Str:D :$string! ) {

  Gnome::N::deprecate(
    '.add-gui(:string)', '.gtk_builder_add_from_string()', '0.18.4', '0.22.0'
  );

  my Gnome::Glib::Error $e = gtk_builder_add_from_string(
    self.get-native-object, $string);
  die X::Gnome.new(:message($e.message)) if $e.error-is-valid;
}

#-------------------------------------------------------------------------------
#TM:1:gtk_builder_error_quark:
=begin pod
=head2 [[gtk_] builder_] error_quark

Return the domain code of the builder error domain.

  method gtk_builder_error_quark ( --> Int )

The following example shows the fields of a returned error when a faulty string is provided in the call.

  my Gnome::Glib::Quark $quark .= new;
  my Gnome::Glib::Error $e = $builder.add-from-string($text);
  is $e.domain, $builder.gtk_builder_error_quark(),
     "domain code: $e.domain()";
  is $quark.to-string($e.domain), 'gtk-builder-error-quark',
     "error domain: $quark.to-string($e.domain())";

=end pod

sub gtk_builder_error_quark (  )
  returns int32
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:gtk_builder_new:
=begin pod
=head2 [gtk_] builder_new

Creates a new empty builder object.

=comment add C<gtk_builder_new_from_resource()> when ready

This function is only useful if you intend to make multiple calls to C<gtk_builder_add_from_file()> or C<gtk_builder_add_from_string()> in order to merge multiple UI descriptions into a single builder.

Most users will probably want to use C<gtk_builder_new_from_file()> C<gtk_builder_new_from_string()>.

Returns: a new (empty) B<Gnome::Gtk3::Builder> object

Since: 2.12

  method gtk_builder_new ( --> N-GObject  )

=end pod

sub gtk_builder_new (  )
  returns N-GObject
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:gtk_builder_add_from_file:
=begin pod
=head2 [[gtk_] builder_] add_from_file

Parses a file containing a [B<Gnome::Gtk3::Builder> UI definition](https://developer.gnome.org/gtk3/3.24/GtkBuilder.html#BUILDER-UI) and merges it with the current contents of I<builder>.

Most users will probably want to use C<gtk_builder_new_from_file()>.

If an error occurs, a valid Gnome::Glib::Error object is returned with an error domain of C<GTK_BUILDER_ERROR>, C<G_MARKUP_ERROR> or C<G_FILE_ERROR>.

You should not use this function with untrusted files (ie: files that are not part of your application). Broken B<Gnome::Gtk3::Builder> files can easily crash your program, and it’s possible that memory was leaked leading up to the reported failure. The only reasonable thing to do when an error is detected is to throw an Exception when necessary.

Returns: Gnome::Glib::Error. Test the error-is-valid flag of that object to see if there was an error.

Since: 2.12

  method gtk_builder_add_from_file (
    Str $filename, N-GObject $error
    --> Gnome::Glib::Error
  )

=item Str $filename; the name of the file to parse

=end pod

# need a proto because otherwise the signature.parms will
# become Mu in Gnome::N::test-call()
proto gtk_builder_add_from_file ( N-GObject $builder, Str $filename, |) { * }
multi sub gtk_builder_add_from_file (
  N-GObject $builder, Str $filename, Any $error
  --> uint32
) {
  Gnome::N::deprecate(
    '.gtk_builder_add_from_file( N-GObject, Str, Any --> uint32)', '.gtk_builder_add_from_file( N-GObject, Str)', '0.17.10', '0.22.0'
  );

  my CArray[N-GError] $ga .= new(N-GError);
  _gtk_builder_add_from_file( $builder, $filename, $ga)
}

multi sub gtk_builder_add_from_file (
  N-GObject $builder, Str $filename
  --> Gnome::Glib::Error
) {
  my CArray[N-GError] $ga .= new(N-GError);
  _gtk_builder_add_from_file( $builder, $filename, $ga);
  Gnome::Glib::Error.new(:gerror($ga[0]))
}

sub _gtk_builder_add_from_file (
  N-GObject $builder, Str $filename, CArray[N-GError] $error
) returns uint32
  is native(&gtk-lib)
  is symbol('gtk_builder_add_from_file')
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] add_from_resource

Parses a resource file containing a [B<Gnome::Gtk3::Builder> UI definition](https://developer.gnome.org/gtk3/3.24/GtkBuilder.html#BUILDER-UI) and merges it with the current contents of I<builder>.

Most users will probably want to use C<gtk_builder_new_from_resource()>.

If an error occurs, a valid Gnome::Glib::Error object is returned with an error domain of C<GTK_BUILDER_ERROR>, C<G_MARKUP_ERROR> or C<G_FILE_ERROR>. The only reasonable thing to do when an error is detected is to throw an Exception when necessary.

Returns: Gnome::Glib::Error. Test the error-is-valid flag to see if there was an error.

Since: 3.4

  method gtk_builder_add_from_resource ( Str $resource_path, N-GObject $error --> UInt  )

=item Str $resource_path; the path of the resource file to parse
=item N-GObject $error; (allow-none): return location for an error, or C<Any>

=end pod

sub gtk_builder_add_from_resource ( N-GObject $builder, Str $resource_path, N-GObject $error )
  returns uint32
  is native(&gtk-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:gtk_builder_add_from_string:
=begin pod
=head2 [[gtk_] builder_] add_from_string

Parses a string containing a [B<Gnome::Gtk3::Builder> UI definition](https://developer.gnome.org/gtk3/3.24/GtkBuilder.html#BUILDER-UI) and merges it with the current contents of I<builder>.

Most users will probably want to use C<gtk_builder_new_from_string()>.

If an error occurs, a valid Gnome::Glib::Error object is returned with an error domain of C<GTK_BUILDER_ERROR>, C<G_MARKUP_ERROR> or C<G_FILE_ERROR>. The only reasonable thing to do when an error is detected is to throw an Exception when necessary.

Returns: Gnome::Glib::Error. Test the error-is-valid flag to see if there was an error.

Since: 2.12

  method gtk_builder_add_from_string ( Str $buffer, UInt $length, N-GObject $error --> UInt  )

=item Str $buffer; the string to parse
=item Int $length; the length of I<buffer> (may be -1 if I<buffer> is nul-terminated)

=end pod

proto gtk_builder_add_from_string ( N-GObject $builder, Str $buffer, |) { * }
multi sub gtk_builder_add_from_string (
  N-GObject $builder, Str $buffer, Int $length, Any $error
  --> uint32
) {

  Gnome::N::deprecate(
    '.gtk_builder_add_from_string( N-GObject, Str, Any --> uint32)', '.gtk_builder_add_from_string( N-GObject, Str)', '0.17.10', '0.22.0'
  );

  my CArray[N-GError] $ga .= new(N-GError);
  _gtk_builder_add_from_string( $builder, $buffer, $length, $ga)
}

multi sub gtk_builder_add_from_string (
  N-GObject $builder, Str $buffer
  --> Gnome::Glib::Error
) {
  my CArray[N-GError] $ga .= new(N-GError);
  _gtk_builder_add_from_string( $builder, $buffer, $buffer.chars, $ga);
  Gnome::Glib::Error.new(:gerror($ga[0]));
}

sub _gtk_builder_add_from_string (
  N-GObject $builder, Str $buffer, int64 $length, CArray[N-GError] $error
) returns uint32
  is native(&gtk-lib)
  is symbol('gtk_builder_add_from_string')
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] add_objects_from_file

Parses a file containing a [B<Gnome::Gtk3::Builder> UI definition]
building only the requested objects and merges
them with the current contents of I<builder>.

If you are adding an object that depends on an object that is not
its child (for instance a B<Gnome::Gtk3::TreeView> that depends on its
B<Gnome::Gtk3::TreeModel>), you have to explicitly list all of them in I<object_ids>.

If an error occurs, a valid Gnome::Glib::Error object is returned with an error domain of C<GTK_BUILDER_ERROR>, C<G_MARKUP_ERROR> or C<G_FILE_ERROR>. The only reasonable thing to do when an error is detected is to throw an Exception when necessary.

Returns: Gnome::Glib::Error. Test the error-is-valid flag to see if there was an error.

Since: 2.14

  method gtk_builder_add_objects_from_file ( Str $filename, CArray[Str] $object_ids, N-GObject $error --> UInt  )

=item Str $filename; the name of the file to parse
=item CArray[Str] $object_ids; (array zero-terminated=1) (element-type utf8): nul-terminated array of objects to build
=item N-GObject $error; (allow-none): return location for an error, or C<Any>

=end pod

sub gtk_builder_add_objects_from_file ( N-GObject $builder, Str $filename, CArray[Str] $object_ids, N-GObject $error )
  returns uint32
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] add_objects_from_resource

Parses a resource file containing a [B<Gnome::Gtk3::Builder> UI definition](https://developer.gnome.org/gtk3/3.24/GtkBuilder.html#BUILDER-UI)
building only the requested objects and merges
them with the current contents of I<builder>.

Upon errors 0 will be returned and I<error> will be assigned a
C<GError> from the C<GTK_BUILDER_ERROR>, C<G_MARKUP_ERROR> or C<G_RESOURCE_ERROR>
domain.

If you are adding an object that depends on an object that is not
its child (for instance a B<Gnome::Gtk3::TreeView> that depends on its
B<Gnome::Gtk3::TreeModel>), you have to explicitly list all of them in I<object_ids>.

Returns: A positive value on success, 0 if an error occurred

Since: 3.4

  method gtk_builder_add_objects_from_resource ( Str $resource_path, CArray[Str] $object_ids, N-GObject $error --> UInt  )

=item Str $resource_path; the path of the resource file to parse
=item CArray[Str] $object_ids; (array zero-terminated=1) (element-type utf8): nul-terminated array of objects to build
=item N-GObject $error; (allow-none): return location for an error, or C<Any>

=end pod

sub gtk_builder_add_objects_from_resource ( N-GObject $builder, Str $resource_path, CArray[Str] $object_ids, N-GObject $error )
  returns uint32
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] add_objects_from_string

Parses a string containing a [B<Gnome::Gtk3::Builder> UI definition](https://developer.gnome.org/gtk3/3.24/GtkBuilder.html#BUILDER-UI)
building only the requested objects and merges
them with the current contents of I<builder>.

Upon errors 0 will be returned and I<error> will be assigned a
C<GError> from the C<GTK_BUILDER_ERROR> or C<G_MARKUP_ERROR> domain.

If you are adding an object that depends on an object that is not
its child (for instance a B<Gnome::Gtk3::TreeView> that depends on its
B<Gnome::Gtk3::TreeModel>), you have to explicitly list all of them in I<object_ids>.

Returns: A positive value on success, 0 if an error occurred

Since: 2.14

  method gtk_builder_add_objects_from_string ( Str $buffer, UInt $length, CArray[Str] $object_ids, N-GObject $error --> UInt  )

=item Str $buffer; the string to parse
=item UInt $length; the length of I<buffer> (may be -1 if I<buffer> is nul-terminated)
=item CArray[Str] $object_ids; (array zero-terminated=1) (element-type utf8): nul-terminated array of objects to build
=item N-GObject $error; (allow-none): return location for an error, or C<Any>

=end pod

sub gtk_builder_add_objects_from_string ( N-GObject $builder, Str $buffer, uint64 $length, CArray[Str] $object_ids, N-GObject $error )
  returns uint32
  is native(&gtk-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:3:gtk_builder_get_object:
=begin pod
=head2 [[gtk_] builder_] get_object

Gets the object named I<name>. Note that this function does not
increment the reference count of the returned object.

Returns: (nullable) (transfer none): the object named I<name> or C<Any> if
it could not be found in the object tree.

Since: 2.12

  method gtk_builder_get_object ( Str $name --> N-GObject  )

=item Str $name; name of object to get

=end pod

sub gtk_builder_get_object ( N-GObject $builder, Str $name )
  returns N-GObject
  is native(&gtk-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] get_objects

Gets all objects that have been constructed by I<builder>. Note that
this function does not increment the reference counts of the returned
objects.

Returns: (element-type GObject) (transfer container): a newly-allocated C<GSList> containing all the objects
constructed by the B<Gnome::Gtk3::Builder> instance. It should be freed by
C<g_slist_free()>

Since: 2.12

  method gtk_builder_get_objects ( --> N-GObject  )


=end pod

sub gtk_builder_get_objects ( N-GObject $builder )
  returns N-GObject
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] expose_object

Add I<object> to the I<builder> object pool so it can be referenced just like any
other object built by builder.

Since: 3.8

  method gtk_builder_expose_object ( Str $name, N-GObject $object )

=item Str $name; the name of the object exposed to the builder
=item N-GObject $object; the object to expose

=end pod

sub gtk_builder_expose_object ( N-GObject $builder, Str $name, N-GObject $object )
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] connect_signals

This method is a simpler variation of C<gtk_builder_connect_signals_full()>.
It uses symbols explicitly added to I<builder> with prior calls to
C<gtk_builder_add_callback_symbol()>. In the case that symbols are not
explicitly added; it uses C<GModule>’s introspective features (by opening the module C<Any>)
to look at the application’s symbol table. From here it tries to match
the signal handler names given in the interface description with
symbols in the application and connects the signals. Note that this
function can only be called once, subsequent calls will do nothing.

Note that unless C<gtk_builder_add_callback_symbol()> is called for
all signal callbacks which are referenced by the loaded XML, this
function will require that C<GModule> be supported on the platform.

If you rely on C<GModule> support to lookup callbacks in the symbol table,
the following details should be noted:

When compiling applications for Windows, you must declare signal callbacks
with C<G_MODULE_EXPORT>, or they will not be put in the symbol table.
On Linux and Unices, this is not necessary; applications should instead
be compiled with the -Wl,--export-dynamic CFLAGS, and linked against
gmodule-export-2.0.

Since: 2.12

  method gtk_builder_connect_signals ( Pointer $user_data )

=item Pointer $user_data; user data to pass back with all signals

=end pod

sub gtk_builder_connect_signals ( N-GObject $builder, Pointer $user_data )
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] connect_signals_full

This function can be thought of the interpreted language binding
version of C<gtk_builder_connect_signals()>, except that it does not
require GModule to function correctly.

Since: 2.12

  method gtk_builder_connect_signals_full ( GtkBuilderConnectFunc $func, Pointer $user_data )

=item GtkBuilderConnectFunc $func; (scope call): the function used to connect the signals
=item Pointer $user_data; arbitrary data that will be passed to the connection function

=end pod

sub gtk_builder_connect_signals_full ( N-GObject $builder, GtkBuilderConnectFunc $func, Pointer $user_data )
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] set_translation_domain

Sets the translation domain of I<builder>.
See prop C<translation-domain>.

Since: 2.12

  method gtk_builder_set_translation_domain ( Str $domain )

=item Str $domain; (allow-none): the translation domain or C<Any>

=end pod

sub gtk_builder_set_translation_domain ( N-GObject $builder, Str $domain )
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] get_translation_domain

Gets the translation domain of I<builder>.

Returns: the translation domain. This string is owned
by the builder object and must not be modified or freed.

Since: 2.12

  method gtk_builder_get_translation_domain ( --> Str  )


=end pod

sub gtk_builder_get_translation_domain ( N-GObject $builder )
  returns Str
  is native(&gtk-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:gtk_builder_get_type_from_name:
=begin pod
=head2 [[gtk_] builder_] get_type_from_name

Looks up a type by name, using the virtual function that
B<Gnome::Gtk3::Builder> has for that purpose. This is mainly used when
implementing the B<Gnome::Gtk3::Buildable> interface on a type.

Returns: the C<GType> found for I<type_name> or C<G_TYPE_INVALID>
if no type was found

Since: 2.12

  method gtk_builder_get_type_from_name ( Str $type_name --> UInt  )

=item Str $type_name; type name to lookup

=end pod

sub gtk_builder_get_type_from_name ( N-GObject $builder, Str $type_name )
  returns uint64
  is native(&gtk-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] value_from_string

This function demarshals a value from a string. This function
calls C<g_value_init()> on the I<value> argument, so it need not be
initialised beforehand.

This function can handle char, uchar, boolean, int, uint, long,
ulong, enum, flags, float, double, string, B<Gnome::Gdk3::Color>, B<Gnome::Gdk3::RGBA> and
B<Gnome::Gtk3::Adjustment> type values. Support for B<Gnome::Gtk3::Widget> type values is
still to come.

Upon errors C<0> will be returned and I<error> will be assigned a
C<GError> from the C<GTK_BUILDER_ERROR> domain.

Returns: C<1> on success

Since: 2.12

  method gtk_builder_value_from_string ( GParamSpec $pspec, Str $string, N-GObject $value, N-GObject $error --> Int  )

=item GParamSpec $pspec; the C<GParamSpec> for the property
=item Str $string; the string representation of the value
=item N-GObject $value; (out): the C<GValue> to store the result in
=item N-GObject $error; (allow-none): return location for an error, or C<Any>

=end pod

sub gtk_builder_value_from_string ( N-GObject $builder, GParamSpec $pspec, Str $string, N-GObject $value, N-GObject $error )
  returns int32
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] value_from_string_type

Like C<gtk_builder_value_from_string()>, this function demarshals
a value from a string, but takes a C<GType> instead of C<GParamSpec>.
This function calls C<g_value_init()> on the I<value> argument, so it
need not be initialised beforehand.

Upon errors C<0> will be returned and I<error> will be assigned a
C<GError> from the C<GTK_BUILDER_ERROR> domain.

Returns: C<1> on success

Since: 2.12

  method gtk_builder_value_from_string_type ( N-GObject $type, Str $string, N-GObject $value, N-GObject $error --> Int  )

=item N-GObject $type; the C<GType> of the value
=item Str $string; the string representation of the value
=item N-GObject $value; (out): the C<GValue> to store the result in
=item N-GObject $error; (allow-none): return location for an error, or C<Any>

=end pod

sub gtk_builder_value_from_string_type ( N-GObject $builder, N-GObject $type, Str $string, N-GObject $value, N-GObject $error )
  returns int32
  is native(&gtk-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:gtk_builder_new_from_file:
=begin pod
=head2 [[gtk_] builder_] new_from_file

Builds the [B<Gnome::Gtk3::Builder> UI definition](https://developer.gnome.org/gtk3/3.24/GtkBuilder.html#BUILDER-UI) in the file I<filename>.

If there is an error opening the file or parsing the description then
the program will be aborted.  You should only ever attempt to parse
user interface descriptions that are shipped as part of your program.

Returns: a B<Gnome::Gtk3::Builder> containing the described interface

Since: 3.10

  method gtk_builder_new_from_file ( Str $filename --> N-GObject  )

=item Str $filename; filename of user interface description file

=end pod

sub gtk_builder_new_from_file ( Str $filename )
  returns N-GObject
  is native(&gtk-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] new_from_resource

Builds the [B<Gnome::Gtk3::Builder> UI definition](https://developer.gnome.org/gtk3/3.24/GtkBuilder.html#BUILDER-UI) at I<resource_path>.

If there is an error locating the resource or parsing the
description, then the program will be aborted.

Returns: a B<Gnome::Gtk3::Builder> containing the described interface

Since: 3.10

  method gtk_builder_new_from_resource ( Str $resource_path --> N-GObject  )

=item Str $resource_path; a C<GResource> resource path

=end pod

sub gtk_builder_new_from_resource ( Str $resource_path )
  returns N-GObject
  is native(&gtk-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:gtk_builder_new_from_string:
=begin pod
=head2 [[gtk_] builder_] new_from_string

Builds the user interface described by I<string> (in the [B<Gnome::Gtk3::Builder> UI definition](https://developer.gnome.org/gtk3/3.24/GtkBuilder.html#BUILDER-UI) format).

If I<string> is C<Any>-terminated, then I<length> should be -1.
If I<length> is not -1, then it is the length of I<string>.

If there is an error parsing I<string> then the program will be
aborted. You should not attempt to parse user interface description
from untrusted sources.

Returns: a B<Gnome::Gtk3::Builder> containing the interface described by I<string>

Since: 3.10

  method gtk_builder_new_from_string ( Str $string, Int $length --> N-GObject  )

=item Str $string; a user interface (XML) description
=item Int $length; the length of I<string>, or -1

=end pod

sub gtk_builder_new_from_string ( Str $string, int64 $length )
  returns N-GObject
  is native(&gtk-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] add_callback_symbol

Adds the I<callback_symbol> to the scope of I<builder> under the given I<callback_name>.

Using this function overrides the behavior of C<gtk_builder_connect_signals()>
for any callback symbols that are added. Using this method allows for better
encapsulation as it does not require that callback symbols be declared in
the global namespace.

Since: 3.10

  method gtk_builder_add_callback_symbol ( Str $callback_name, GCallback $callback_symbol )

=item Str $callback_name; The name of the callback, as expected in the XML
=item GCallback $callback_symbol; (scope async): The callback pointer

=end pod

sub gtk_builder_add_callback_symbol ( N-GObject $builder, Str $callback_name, GCallback $callback_symbol )
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] add_callback_symbols

A convenience function to add many callbacks instead of calling
C<gtk_builder_add_callback_symbol()> for each symbol.

Since: 3.10

  method gtk_builder_add_callback_symbols ( Str $first_callback_name, GCallback $first_callback_symbol )

=item Str $first_callback_name; The name of the callback, as expected in the XML
=item GCallback $first_callback_symbol; (scope async): The callback pointer @...: A list of callback name and callback symbol pairs terminated with C<Any>

=end pod

sub gtk_builder_add_callback_symbols ( N-GObject $builder, Str $first_callback_name, GCallback $first_callback_symbol, Any $any = Any )
  is native(&gtk-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[gtk_] builder_] lookup_callback_symbol

Fetches a symbol previously added to I<builder>
with C<gtk_builder_add_callback_symbols()>

This function is intended for possible use in language bindings
or for any case that one might be cusomizing signal connections
using C<gtk_builder_connect_signals_full()>

Returns: (nullable): The callback symbol in I<builder> for I<callback_name>, or C<Any>

Since: 3.10

  method gtk_builder_lookup_callback_symbol ( Str $callback_name --> GCallback  )

=item Str $callback_name; The name of the callback

=end pod

sub gtk_builder_lookup_callback_symbol ( N-GObject $builder, Str $callback_name )
  returns GCallback
  is native(&gtk-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:gtk_builder_set_application:
=begin pod
=head2 [[gtk_] builder_] set_application

Sets the application associated with I<builder>.

You only need this function if there is more than one C<GApplication>
in your process. I<application> cannot be C<Any>.

Since: 3.10

  method gtk_builder_set_application ( N-GObject $application )

=item N-GObject $application; a B<Gnome::Gtk3::Application>

=end pod

sub gtk_builder_set_application ( N-GObject $builder, N-GObject $application )
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:gtk_builder_get_application:
=begin pod
=head2 [[gtk_] builder_] get_application

Gets the B<Gnome::Gtk3::Application> associated with the builder.

The B<Gnome::Gtk3::Application> is used for creating action proxies as requested
from XML that the builder is loading.

By default, the builder uses the default application: the one from
C<g_application_get_default()>. If you want to use another application
for constructing proxies, use C<gtk_builder_set_application()>.

Returns: (nullable) (transfer none): the application being used by the builder,
or C<Any>

Since: 3.10

  method gtk_builder_get_application ( --> N-GObject  )


=end pod

sub gtk_builder_get_application ( N-GObject $builder )
  returns N-GObject
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
#`{{
=begin pod
=head2 [[gtk_] builder_] extend_with_template

Main private entry point for building composite container
components from template XML.

This is exported purely to let gtk-builder-tool validate
templates, applications have no need to call this function.

Returns: A positive value on success, 0 if an error occurred

  method gtk_builder_extend_with_template ( N-GObject $widget, N-GObject $template_type, Str $buffer, UInt $length, N-GObject $error --> UInt  )

=item N-GObject $widget; the widget that is being extended
=item N-GObject $template_type; the type that the template is for
=item Str $buffer; the string to parse
=item UInt $length; the length of I<buffer> (may be -1 if I<buffer> is nul-terminated)
=item N-GObject $error; (allow-none): return location for an error, or C<Any>

=end pod

sub gtk_builder_extend_with_template ( N-GObject $builder, N-GObject $widget, N-GObject $template_type, Str $buffer, uint64 $length, N-GObject $error )
  returns uint32
  is native(&gtk-lib)
  { * }
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Properties

An example of using a string type property of a B<Gnome::Gtk3::Label> object. This is just showing how to set/read a property, not that it is the best way to do it. This is because a) The class initialization often provides some options to set some of the properties and b) the classes provide many methods to modify just those properties. In the case below one can use B<new(:label('my text label'))> or B<gtk_label_set_text('my text label')>.

  my Gnome::Gtk3::Label $label .= new;
  my Gnome::GObject::Value $gv .= new(:init(G_TYPE_STRING));
  $label.g-object-get-property( 'label', $gv);
  $gv.g-value-set-string('my text label');

=head2 Supported properties

=head3 translation-domain

The translation domain used when translating property values that
have been marked as translatable in interface descriptions.
If the translation domain is C<Any>, B<Gnome::Gtk3::Builder> uses C<gettext()>,
otherwise C<g_dgettext()>.

Since: 2.12

The B<Gnome::GObject::Value> type of property I<translation-domain> is C<G_TYPE_STRING>.

=end pod
